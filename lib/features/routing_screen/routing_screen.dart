import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_map/domain/entities/vietmap_model.dart';
import 'package:vietmap_map/extension/latlng_extension.dart';
import 'package:vietmap_map/features/routing_screen/bloc/routing_bloc.dart';
import 'package:vietmap_map/features/routing_screen/components/routing_bottom_panel.dart';
import 'package:vietmap_map/features/routing_screen/components/routing_header.dart';

import '../../constants/colors.dart';
import '../../constants/route.dart';
import '../../di/app_context.dart';
import '../map_screen/bloc/map_bloc.dart';
import '../map_screen/bloc/map_state.dart';
import '../navigation_screen/models/navigation_params.dart';
import 'bloc/routing_event.dart';
import 'bloc/routing_state.dart';

class RoutingScreen extends StatefulWidget {
  const RoutingScreen({super.key});

  @override
  State<RoutingScreen> createState() => _RoutingScreenState();
}

class _RoutingScreenState extends State<RoutingScreen> {
  VietmapController? _controller;
  bool isFromOrigin = true;
  final PanelController _panelController = PanelController();
  final List<Marker> _listMarker = [];
  double panelPosition = 0.0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Future.delayed(const Duration(milliseconds: 200))
          .then((value) => _panelController.hide());
      if (ModalRoute.of(context)!.settings.arguments != null) {
        var args = ModalRoute.of(context)!.settings.arguments as VietmapModel;
        var res = await Geolocator.getCurrentPosition();
        if (!mounted) return;
        context.read<RoutingBloc>().add(RoutingEventUpdateRouteParams(
            originDescription: 'Vị trí của bạn',
            originPoint: res.toLatLng(),
            destinationDescription: args.name,
            destinationPoint: LatLng(args.lat ?? 0, args.lng ?? 0)));
      }
      var position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      context.read<RoutingBloc>().add(RoutingEventUpdateRouteParams(
          originDescription: 'Vị trí của bạn',
          originPoint: LatLng(position.latitude, position.longitude)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoutingBloc, RoutingState>(
      listener: (context, state) {
        if (state is RoutingStateGetDirectionSuccess) {
          _controller?.clearLines();
          _controller?.addPolyline(PolylineOptions(
            geometry: state.listPoint,
            polylineWidth: 4,
            polylineColor: vietmapColor,
          ));

          _controller?.animateCamera(CameraUpdate.newLatLngBounds(
              state.listPoint.first.latitude < state.listPoint.last.latitude
                  ? LatLngBounds(
                      southwest: state.listPoint.first,
                      northeast: state.listPoint.last)
                  : LatLngBounds(
                      northeast: state.listPoint.first,
                      southwest: state.listPoint.last),
              left: 0,
              right: 0,
              top: 0,
              bottom: 300));
          _panelController.show();
          setState(() {
            _listMarker.clear();
            _listMarker.add(Marker(
                width: 17,
                height: 17,
                child: DecoratedBox(
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, boxShadow: [
                      BoxShadow(color: Colors.grey.shade300, blurRadius: 0.5)
                    ]),
                    child: const Icon(Icons.circle,
                        size: 15, color: Colors.black)),
                latLng: state.listPoint.first));
            _listMarker.add(Marker(
                width: 40,
                height: 40,
                alignment: Alignment.bottomCenter,
                child:
                    const Icon(Icons.location_pin, size: 42, color: Colors.red),
                latLng: state.listPoint.last));
          });
        }
      },
      child: BlocListener<MapBloc, MapState>(
        listener: (context, state) {
          if (state is MapStateGetPlaceDetailSuccess) {
            if (isFromOrigin) {
              _listMarker.add(Marker(
                  width: 17,
                  height: 17,
                  alignment: Alignment.bottomCenter,
                  child: DecoratedBox(
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, boxShadow: [
                      BoxShadow(color: Colors.grey.shade300, blurRadius: 0.5)
                    ]),
                    child:
                        const Icon(Icons.circle, size: 15, color: Colors.black),
                  ),
                  latLng: LatLng(
                      state.response.lat ?? 0, state.response.lng ?? 0)));
              context.read<RoutingBloc>().add(RoutingEventUpdateRouteParams(
                  originDescription: state.response.name,
                  originPoint: LatLng(
                      state.response.lat ?? 0, state.response.lng ?? 0)));
            } else {
              _listMarker.add(Marker(
                  width: 40,
                  height: 40,
                  alignment: Alignment.bottomCenter,
                  child: const Icon(Icons.location_pin,
                      size: 40, color: vietmapColor),
                  latLng: LatLng(
                      state.response.lat ?? 0, state.response.lng ?? 0)));
              context.read<RoutingBloc>().add(RoutingEventUpdateRouteParams(
                  destinationDescription: state.response.name,
                  destinationPoint: LatLng(
                      state.response.lat ?? 0, state.response.lng ?? 0)));
            }
            _controller?.animateCamera(CameraUpdate.newLatLngZoom(
                LatLng(state.response.lat ?? 0, state.response.lng ?? 0), 15));
          }
        },
        child: WillPopScope(
          onWillPop: () {
            context.read<RoutingBloc>().add(RoutingEventClearDirection());
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
                    VietmapGL(
                      trackCameraPosition: true,
                      styleString: AppContext.getVietmapMapStyleUrl() ?? "",
                      initialCameraPosition: const CameraPosition(
                          target: LatLng(10.762201, 106.654213), zoom: 10),
                      onMapCreated: (controller) {
                        setState(() {
                          _controller = controller;
                        });
                      },
                    ),
                    _controller != null
                        ? MarkerLayer(
                            markers: _listMarker, mapController: _controller!)
                        : const SizedBox.shrink(),
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
