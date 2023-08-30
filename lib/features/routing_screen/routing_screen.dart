import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart'; 
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_flutter_navigation/embedded/controller.dart';
import 'package:vietmap_flutter_navigation/models/direction_route.dart';
import 'package:vietmap_flutter_navigation/models/options.dart';
import 'package:vietmap_flutter_navigation/models/route_progress_event.dart';
import 'package:vietmap_flutter_navigation/models/way_point.dart';
import 'package:vietmap_flutter_navigation/navigation_plugin.dart';
import 'package:vietmap_flutter_navigation/views/navigation_view.dart';
import 'package:vietmap_map/constants/colors.dart';
import 'package:vietmap_map/domain/entities/vietmap_model.dart';
import 'package:vietmap_map/extension/latlng_extension.dart';
import 'package:vietmap_map/features/routing_screen/bloc/routing_bloc.dart';
import 'package:vietmap_map/features/routing_screen/components/routing_header.dart';
import '../../di/app_context.dart';
import '../map_screen/bloc/map_bloc.dart';
import '../map_screen/bloc/map_state.dart';
import '../routing_screen/bloc/routing_event.dart';
import '../routing_screen/bloc/routing_state.dart';
import 'components/routing_bottom_panel.dart';
import 'components/vietmap_banner_instruction_view.dart';
import 'components/vietmap_bottom_view.dart';
import 'models/routing_params_model.dart';

class RoutingScreen extends StatefulWidget {
  const RoutingScreen({super.key});

  @override
  State<RoutingScreen> createState() => _RoutingScreenState();
}

class _RoutingScreenState extends State<RoutingScreen> {
  bool isFromOrigin = true;
  final PanelController _panelController = PanelController();
  double panelPosition = 0.0;

  MapNavigationViewController? _navigationController;
  late MapOptions _navigationOption;
  final _vietmapPlugin = VietMapNavigationPlugin();

  List<WayPoint> wayPoints = [
    WayPoint(name: "You are here", latitude: 10.759091, longitude: 106.675817),
    WayPoint(name: "You are here", latitude: 10.762528, longitude: 106.653099)
  ]; 
  String guideDirection = "";
  Widget recenterButton = const SizedBox.shrink();
  RouteProgressEvent? routeProgressEvent;
  FocusNode focusNode = FocusNode();
  bool _isRunning = false;

  Future<void> initialize() async {
    if (!mounted) return;

    _navigationOption = _vietmapPlugin.getDefaultOptions();
    _navigationOption.simulateRoute = false;
    _navigationOption.isCustomizeUI = true;

    _navigationOption.apiKey = AppContext.getVietmapAPIKey() ?? "";
    _navigationOption.mapStyle = AppContext.getVietmapMapStyleUrl() ?? "";
    _navigationOption.padding = const EdgeInsets.all(100);

    _vietmapPlugin.setDefaultOptions(_navigationOption);
  }

  RoutingBloc get routingBloc => BlocProvider.of<RoutingBloc>(context);
  MapOptions? options;
  @override
  void initState() {
    super.initState();
    initialize();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Future.delayed(const Duration(milliseconds: 200))
          .then((value) => _panelController.hide());
      if (ModalRoute.of(context)!.settings.arguments != null) {
        var args = ModalRoute.of(context)!.settings.arguments as VietmapModel;
        routingBloc.add(RoutingEventUpdateRouteParams(
            destinationDescription: args.name,
            destinationPoint: LatLng(args.lat ?? 0, args.lng ?? 0)));
      }

      var position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      routingBloc.add(RoutingEventUpdateRouteParams(
          originDescription: 'Vị trí của bạn',
          originPoint: LatLng(position.latitude, position.longitude)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoutingBloc, RoutingState>(
      bloc: routingBloc,
      listener: (context, state) {
        if (state is RoutingStateNativeRouteBuilt && !_isRunning) {
          _panelController.show();
        }
      },
      child: BlocListener<MapBloc, MapState>(
        listener: (context, state) {
          if (state is MapStateGetPlaceDetailSuccess) {
            if (isFromOrigin) {
              routingBloc.add(RoutingEventUpdateRouteParams(
                  originDescription: state.response.name,
                  originPoint: LatLng(
                      state.response.lat ?? 0, state.response.lng ?? 0)));
            } else {
              routingBloc.add(RoutingEventUpdateRouteParams(
                  destinationDescription: state.response.name,
                  destinationPoint: LatLng(
                      state.response.lat ?? 0, state.response.lng ?? 0)));
            }
          }
        },
        child: WillPopScope(
          onWillPop: () {
            if (_isRunning) {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text('Thông báo'),
                        content:
                            const Text('Bạn có muốn dừng hướng dẫn đi đường?'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Không')),
                          TextButton(
                              onPressed: () {
                                _navigationController?.finishNavigation();
                                _onStopNavigation();
                                Navigator.pop(context);
                              },
                              child: const Text('Có'))
                        ],
                      ));
              return Future.value(false);
            }
            routingBloc.add(RoutingEventClearDirection());
            return Future.value(true);
          },
          child: Scaffold(
            body: Column(children: [
              _isRunning
                  ? const SizedBox.shrink(
                      key: Key("hide"),
                    )
                  : RoutingHeader(
                      key: const Key("routingHeader"),
                      onOriginTapCallback: () {
                        setState(() {
                          isFromOrigin = true;
                        });
                      },
                      onDestinationTapCallback: () => setState(() {
                        isFromOrigin = false;
                      }),
                    ),
              Expanded(
                child: Stack(
                  children: [
                    NavigationView(
                      mapOptions: _navigationOption,
                      onNewRouteSelected: (DirectionRoute p0) {
                        routingBloc.add(
                            RoutingEventNativeRouteBuilt(directionRoute: p0));
                      },
                      onMapRendered: () async {
                        EasyLoading.show();
                        if (ModalRoute.of(context)!.settings.arguments !=
                            null) {
                          var args = ModalRoute.of(context)!.settings.arguments
                              as RoutingParamsModel;
                          var listWaypoint = <WayPoint>[];
                          var res = await Geolocator.getCurrentPosition();
                          listWaypoint.add(WayPoint(
                              name: '',
                              latitude: res.toLatLng().latitude,
                              longitude: res.toLatLng().longitude));

                          listWaypoint.add(WayPoint(
                              name: '',
                              latitude: args.lat,
                              longitude: args.lng));
                          if (args.isStartNavigation) {
                            _navigationController
                                ?.buildAndStartNavigation(
                                    wayPoints: listWaypoint,
                                    profile: DrivingProfile.drivingTraffic)
                                .then((value) {
                              setState(() {
                                EasyLoading.dismiss();
                                _isRunning = true;
                              });
                            });
                          } else {
                            _navigationController?.buildRoute(
                                wayPoints: listWaypoint,
                                profile: DrivingProfile.drivingTraffic);
                          }
                        }
                      },
                      onMapCreated: (p0) async {
                        _navigationController = p0;
                        routingBloc.add(RoutingEventUpdateRouteParams(
                            navigationController: _navigationController));
                      },
                      onRouteBuilt: (DirectionRoute p0) {
                        routingBloc.add(
                            RoutingEventNativeRouteBuilt(directionRoute: p0));
                        setState(() {
                          EasyLoading.dismiss();
                        });
                      },
                      onMapMove: () => _showRecenterButton(),
                      onRouteProgressChange:
                          (RouteProgressEvent routeProgressEvent) {
                        if (!mounted) return; 
                        setState(() {
                          this.routeProgressEvent = routeProgressEvent;
                        });
                      },
                      onArrival: () {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => AlertDialog(
                                  title: const Text('Thông báo'),
                                  content: const Text('Bạn đã đến nơi'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'))
                                  ],
                                ));
                      },
                    ),
                    _isRunning
                        ? Positioned(
                            top: MediaQuery.of(context).viewPadding.top,
                            child: VietmapBannerInstructionView( 
                              routeProgressEvent: routeProgressEvent,
                            ),
                          )
                        : const SizedBox.shrink(),
                    _isRunning
                        ? Positioned(
                            bottom: 0,
                            child: VietmapBottomActionView(
                                controller: _navigationController,
                                onStopNavigationCallback: () {
                                  setState(() {
                                    _isRunning = false;
                                  });
                                },
                                routeProgressEvent: routeProgressEvent,
                                onOverviewCallback: _showRecenterButton,
                                recenterButton: recenterButton),
                          )
                        : SlidingUpPanel(
                            parallaxEnabled: true,
                            parallaxOffset: .6,
                            controller: _panelController,
                            minHeight: MediaQuery.of(context).size.height * 0.2,
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                            onPanelSlide: (position) {
                              setState(() {
                                panelPosition = position;
                              });
                            },
                            panel: RoutingBottomPanel(
                              onViewListStep: () {
                                if (_panelController.panelPosition == 0.0) {
                                  _panelController.animatePanelToPosition(1.0);
                                } else {
                                  _panelController.animatePanelToPosition(0.0);
                                }
                              },
                              panelPosition: panelPosition,
                              onStartNavigation: () {
                                _navigationController?.startNavigation();
                                setState(() {
                                  _isRunning = true;
                                });
                              },
                              routingBloc: routingBloc,
                            ))
                  ],
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }

  _showRecenterButton() {
    recenterButton = TextButton(
        style: ButtonStyle(overlayColor:
            MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
          return Colors.transparent;
        })),
        onPressed: () {
          _navigationController?.recenter();
          recenterButton = const SizedBox.shrink();
        },
        child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
                border: Border.all(color: Colors.black45, width: 1)),
            child: const Row(
              children: [
                Icon(
                  Icons.keyboard_double_arrow_up_sharp,
                  size: 35,
                  color: vietmapColor,
                ),
                Text(
                  'Về giữa',
                  style: TextStyle(fontSize: 18, color: vietmapColor),
                )
              ],
            )));
    setState(() {});
  }


  _onStopNavigation() {
    Navigator.pop(context);
    setState(() {
      routeProgressEvent = null;
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _navigationController?.onDispose();
    super.dispose();
  }
}
