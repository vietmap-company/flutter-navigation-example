// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_flutter_navigation/embedded/controller.dart';
import 'package:vietmap_flutter_navigation/models/direction_route.dart';
import 'package:vietmap_flutter_navigation/models/options.dart';
import 'package:vietmap_flutter_navigation/models/route_progress_event.dart';
import 'package:vietmap_flutter_navigation/navigation_plugin.dart';
import 'package:vietmap_flutter_navigation/views/navigation_view.dart';
import 'package:vietmap_map/constants/colors.dart';
import 'package:vietmap_map/domain/entities/vietmap_model.dart';
import 'package:vietmap_map/extension/latlng_extension.dart';
import 'package:vietmap_map/features/routing_screen/components/routing_header.dart';
import 'package:vietmap_map/method_channel/vietmap_automotive_plugin.dart';
import '../../constants/events.dart';
import '../../di/app_context.dart';
import '../map_screen/bloc/map_bloc.dart';
import '../map_screen/bloc/map_state.dart';
import 'bloc/bloc.dart';
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
  final MethodChannel _navigationChannel = AppContext.getNavigationChannel();
  final VietMapAutomotivePlugin _vietmapAutomotivePlugin =
      VietMapAutomotivePlugin();
  bool isFromOrigin = true;
  final PanelController _panelController = PanelController();
  double panelPosition = 0.0;

  MapNavigationViewController? _navigationController;
  late MapOptions _navigationOption;
  final _vietmapPlugin = VietMapNavigationPlugin();

  List<LatLng> wayPoints = const [
    LatLng(10.759091, 106.675817),
    LatLng(10.762528, 106.653099)
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
                  originDescription:
                      state.response.getFullAddress() ?? 'Vị trí của bạn',
                  originPoint: LatLng(
                      state.response.lat ?? 0, state.response.lng ?? 0)));
            } else {
              routingBloc.add(RoutingEventUpdateRouteParams(
                  destinationDescription:
                      state.response.getFullAddress() ?? 'Vị trí đã chọn',
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
                                // _vietmapAutomotivePlugin.stopNavigation();
                                _navigationController?.finishNavigation();
                                _onStopNavigation();
                                Navigator.pop(context);
                              },
                              child: const Text('Có'))
                        ],
                      ));
              return Future.value(false);
            }
            // _vietMapAutomotivePlugin.stopNavigation();
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
                      onBackButtonTapCallback: () {
                        // _vietMapAutomotivePlugin.stopNavigation();
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
                        _navigationChannel.setMethodCallHandler(
                          (call) async {
                            switch (call.method) {
                              case Events.stopNavigation:
                                _onStopNavigation();
                                break;
                              case Events.onCancelNavigation:
                                _onStopNavigation();
                                break;

                              case Events.onStartNavigation:
                                await _navigationController?.startNavigation();
                                setState(() {
                                  _isRunning = true;
                                });
                                break;
                              case Events.onRecenter:
                                await _navigationController?.recenter();
                                break;
                              case Events.onOverview:
                                await _navigationController?.overview();
                                _showRecenterButton();
                                break;
                              case Events.onFinishNavigation:
                                await _navigationController?.finishNavigation();
                                break;
                              default:
                            }
                          },
                        );
                        if (ModalRoute.of(context)!.settings.arguments !=
                            null) {
                          var args = ModalRoute.of(context)!.settings.arguments
                              as VietmapModel;
                          routingBloc.add(RoutingEventUpdateRouteParams(
                              destinationDescription:
                                  args.getAddress() ?? 'Vị trí đã chọn',
                              destinationPoint:
                                  LatLng(args.lat ?? 0, args.lng ?? 0)));
                        }

                        var position = await Geolocator.getCurrentPosition();
                        if (!mounted) return;
                        routingBloc.add(RoutingEventUpdateRouteParams(
                            originDescription: 'Vị trí của bạn',
                            originPoint:
                                LatLng(position.latitude, position.longitude)));

                        EasyLoading.show();
                        if (ModalRoute.of(context)!.settings.arguments !=
                            null) {
                          var args = ModalRoute.of(context)!.settings.arguments
                              as RoutingParamsModel;
                          var listWaypoint = <LatLng>[];
                          var res = await Geolocator.getCurrentPosition();
                          listWaypoint.add(LatLng(res.toLatLng().latitude,
                              res.toLatLng().longitude));

                          listWaypoint
                              .add(LatLng(args.lat ?? 0, args.lng ?? 0));
                          if (args.isStartNavigation) {
                            _navigationController
                                ?.buildAndStartNavigation(
                                    waypoints: listWaypoint,
                                    profile: DrivingProfile.drivingTraffic)
                                .then((value) {
                              setState(() {
                                EasyLoading.dismiss();
                                _isRunning = true;
                              });
                            });
                          } else {
                            _navigationController?.buildRoute(
                                waypoints: listWaypoint,
                                profile: DrivingProfile.drivingTraffic);
                          }
                        }
                        EasyLoading.dismiss();
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
                                  content: const Text(
                                    'Bạn đã đến nơi',
                                    style: TextStyle(),
                                    textAlign: TextAlign.center,
                                  ),
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
                                  // _vietMapAutomotivePlugin.cancelNavigation();
                                  setState(() {
                                    _isRunning = false;
                                  });
                                },
                                routeProgressEvent: routeProgressEvent,
                                onOverviewCallback: () {
                                  // _vietMapAutomotivePlugin.overview();
                                  _showRecenterButton();
                                },
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
                            panelBuilder: () => RoutingBottomPanel(
                                  onViewListStep: () {
                                    if (_panelController.panelPosition <= 0.5) {
                                      _panelController
                                          .animatePanelToPosition(1.0);
                                    } else {
                                      _panelController
                                          .animatePanelToPosition(0.0);
                                    }
                                  },
                                  panelPosition: panelPosition,
                                  onStartNavigation: () {
                                    // _vietMapAutomotivePlugin.startNavigation();
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
          // _vietMapAutomotivePlugin.recenter();
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
