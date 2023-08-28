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
import 'package:vietmap_map/domain/entities/vietmap_model.dart';
import 'package:vietmap_map/extension/latlng_extension.dart';
import 'package:vietmap_map/features/routing_screen/bloc/routing_bloc.dart';
import 'package:vietmap_map/features/routing_screen/components/routing_header.dart';
import '../../constants/route.dart';
import '../../di/app_context.dart';
import '../map_screen/bloc/map_bloc.dart';
import '../map_screen/bloc/map_state.dart';
import '../navigation_screen/models/navigation_params.dart';
import '../routing_screen/bloc/routing_event.dart';
import '../routing_screen/bloc/routing_state.dart';
import 'components/routing_bottom_panel_v2.dart';

class RoutingScreenV2 extends StatefulWidget {
  const RoutingScreenV2({super.key});

  @override
  State<RoutingScreenV2> createState() => _RoutingScreenV2State();
}

class _RoutingScreenV2State extends State<RoutingScreenV2> {
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
  Widget instructionImage = const SizedBox.shrink();
  String guideDirection = "";
  Widget recenterButton = const SizedBox.shrink();
  RouteProgressEvent? routeProgressEvent;
  FocusNode focusNode = FocusNode();

  Future<void> initialize() async {
    if (!mounted) return;

    _navigationOption = _vietmapPlugin.getDefaultOptions();
    _navigationOption.simulateRoute = false;
    _navigationOption.isCustomizeUI = true;

    _navigationOption.apiKey = AppContext.getVietmapAPIKey() ?? "";
    _navigationOption.mapStyle = AppContext.getVietmapMapStyleUrl() ?? "";

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
        var res = await Geolocator.getCurrentPosition();
        if (!mounted) return;
        routingBloc.add(RoutingEventUpdateRouteParams(
            originDescription: 'Vị trí của bạn',
            originPoint: res.toLatLng(),
            destinationDescription: args.name,
            destinationPoint: LatLng(args.lat ?? 0, args.lng ?? 0)));
      } else {
        var position = await Geolocator.getCurrentPosition();
        if (!mounted) return;
        routingBloc.add(RoutingEventUpdateRouteParams(
            originDescription: 'Vị trí của bạn',
            originPoint: LatLng(position.latitude, position.longitude)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoutingBloc, RoutingState>(
      bloc: routingBloc,
      listener: (context, state) {
        if (state is RoutingStateNativeRouteBuilt) {
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
            routingBloc.add(RoutingEventClearDirection());
            return Future.value(true);
          },
          child: Scaffold(
            body: Column(children: [
              RoutingHeader(
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
                      onMapRendered: () async {
                        if (ModalRoute.of(context)!.settings.arguments !=
                            null) {
                          var args = ModalRoute.of(context)!.settings.arguments
                              as VietmapModel;
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
                          _navigationController
                              ?.buildRoute(
                                  wayPoints: listWaypoint,
                                  profile: DrivingProfile.drivingTraffic)
                              .then((value) {});
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
                    SlidingUpPanel(
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
                        panel: RoutingBottomPanelV2(
                          onViewListStep: () {
                            if (_panelController.panelPosition == 0.0) {
                              _panelController.animatePanelToPosition(1.0);
                            } else {
                              _panelController.animatePanelToPosition(0.0);
                            }
                          },
                          panelPosition: panelPosition,
                          onStartNavigation: () {
                            Navigator.pushNamed(
                                context, Routes.navigationScreen,
                                arguments: NavigationScreenParams(
                                  from: context
                                      .read<RoutingBloc>()
                                      .state
                                      .routingParams!
                                      .originPoint!,
                                  to: context
                                      .read<RoutingBloc>()
                                      .state
                                      .routingParams!
                                      .destinationPoint!,
                                  profile: context
                                      .read<RoutingBloc>()
                                      .state
                                      .routingParams!
                                      .vehicle,
                                ));
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
}
