import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:talker/talker.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_map/features/map_screen/components/category_marker.dart';
import '../../constants/colors.dart';
import '../../constants/route.dart';
import '../../di/app_context.dart';
import 'bloc/map_bloc.dart';
import 'bloc/map_event.dart';
import 'bloc/map_state.dart';
import 'components/bottom_info.dart';
import 'components/category_bar.dart';
import 'components/search_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  VietmapController? _controller;
  List<Marker> _markers = [];
  List<Marker> _nearbyMarker = [];
  double panelPosition = 0.0;
  bool isShowMarker = true;
  final PanelController _panelController = PanelController();
  // Position? position;
  final talker = Talker();
  @override
  void initState() {
    super.initState();
    talker.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      EasyLoading.instance
        ..displayDuration = const Duration(milliseconds: 500)
        ..animationDuration = const Duration(milliseconds: 100)
        ..indicatorType = EasyLoadingIndicatorType.fadingCube
        ..loadingStyle = EasyLoadingStyle.custom
        ..indicatorSize = 25.0
        ..radius = 10.0
        ..progressColor = vietmapColor
        ..backgroundColor = Colors.white
        ..indicatorColor = vietmapColor
        ..textColor = vietmapColor
        ..maskColor = Colors.grey.withOpacity(0.2)
        ..userInteractions = true
        ..dismissOnTap = false;
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        _panelController.hide();
      });
      var res = await Geolocator.checkPermission();
      if (res != LocationPermission.always ||
          res != LocationPermission.whileInUse) {
        await Geolocator.requestPermission();
      }
      // Geolocator.getPositionStream().listen((event) {
      //   setState(() {
      //     position = event;
      //     talker.info(position!.heading.toString());
      //   });
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapState>(
      listener: (_, state) {
        if (state is MapStateGetCategoryAddressSuccess) {
          _nearbyMarker = List<Marker>.from(state.response.map((e) => Marker(
              width: 120,
              height: 70,
              alignment: Alignment.bottomCenter,
              latLng: LatLng(e.lat ?? 0, e.lng ?? 0),
              child: CategoryMarker(model: e))));
          setState(() {});
        }
        if (state is MapStateGetLocationFromCoordinateSuccess &&
            ModalRoute.of(context)?.isCurrent == true) {
          _markers = [
            Marker(
                width: 120,
                height: 70,
                alignment: Alignment.bottomCenter,
                latLng:
                    LatLng(state.response.lat ?? 0, state.response.lng ?? 0),
                child: InkWell(
                  onTap: () {
                    _panelController.show();
                    _showPanel();
                  },
                  child: CategoryMarker(
                    model: state.response,
                    color: Colors.red,
                  ),
                )),
          ];
          _controller?.animateCamera(
            CameraUpdate.newLatLngZoom(
                LatLng(state.response.lat ?? 0, state.response.lng ?? 0),
                _controller?.cameraPosition?.zoom ?? 15),
          );
          _panelController.show();
          _showPanel();
        }
        if ((state is MapStateGetPlaceDetailSuccess) &&
            ModalRoute.of(context)?.isCurrent == true) {
          _markers = [
            Marker(
                width: 40,
                height: 40,
                alignment: Alignment.bottomCenter,
                latLng:
                    LatLng(state.response.lat ?? 0, state.response.lng ?? 0),
                child: InkWell(
                  onTap: () {
                    _panelController.show();
                    _showPanel();
                  },
                  child: const Icon(Icons.location_pin,
                      size: 40, color: Colors.red),
                )),
          ];
          _controller?.animateCamera(
            CameraUpdate.newLatLngZoom(
                LatLng(state.response.lat ?? 0, state.response.lng ?? 0),
                _controller?.cameraPosition?.zoom ?? 15),
          );
          _panelController.show();
          _showPanel();
        }
        if (state is MapStateGetDirectionSuccess) {
          _controller?.clearLines();
          _controller?.addPolyline(PolylineOptions(
            geometry: state.listPoint,
            polylineWidth: 4,
            polylineColor: vietmapColor,
          ));
        }
      },
      child: PopScope(
        onPopInvoked: (bool onPopInvoked) async {
          if (_panelController.isPanelShown || _panelController.isPanelOpen) {
            _panelController.hide();
            setState(() {
              _markers = [];
              _nearbyMarker = [];
            });
          } else {
            Navigator.pop(context);
          }
        },
        child: Scaffold(
            body: Stack(
              children: [
                VietmapGL(
                  myLocationEnabled: true,
                  myLocationTrackingMode: MyLocationTrackingMode.Tracking,
                  myLocationRenderMode: MyLocationRenderMode.NORMAL,
                  trackCameraPosition: true,
                  compassViewMargins: const Point(10, 130),
                  styleString: AppContext.getVietmapMapStyleUrl() ?? "",
                  initialCameraPosition: const CameraPosition(
                      target: LatLng(10.762201, 106.654213), zoom: 10),
                  onMapCreated: (controller) {
                    setState(() {
                      _controller = controller;
                    });
                  },
                  onMapClick: (point, coordinates) async {
                    _panelController.hide();
                    setState(() {
                      _markers = [];
                      _nearbyMarker = [];
                    });
                    var response =
                        await _controller?.queryRenderedFeatures(point: point);

                    for (var item in response ?? []) {
                      talker.good(item);

                      String? shortName = item?['properties']?['shortname'];
                      String? name = item?['properties']?['name'];
                      String? prefix = item?['properties']?['prefix'];
                      var latLng = item?['geometry']?['coordinates'];
                      var type = item?['geometry']?['type'];

                      if ((shortName != null || name != null) &&
                          latLng != null) {
                        if (!mounted) return;
                        String? nameWithPrefix =
                            ('${prefix ?? ''} ${name ?? ''}').trim();
                        if (type == 'Point') {
                          context.read<MapBloc>().add(
                              MapEventUserClickOnMapPoint(
                                  placeShortName: shortName ?? nameWithPrefix,
                                  placeName: nameWithPrefix,
                                  coordinate:
                                      LatLng(latLng.last, latLng.first)));
                        }
                        break;
                      }
                    }
                    // talker.info(response);
                  },
                  onMapLongClick: (point, coordinates) {
                    setState(() {
                      _nearbyMarker = [];
                    });
                    context
                        .read<MapBloc>()
                        .add(MapEventOnUserLongTapOnMap(coordinates));
                  },
                ),
                _controller == null
                    ? const SizedBox.shrink()
                    : MarkerLayer(
                        mapController: _controller!,
                        markers: _nearbyMarker,
                      ),
                _controller == null
                    ? const SizedBox.shrink()
                    : MarkerLayer(
                        mapController: _controller!,
                        markers: _markers,
                      ),
                Positioned(
                  key: const Key('searchBarKey'),
                  top: MediaQuery.of(context).viewPadding.top,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.searchScreen);
                    },
                    child: Hero(
                      tag: 'searchBar',
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FloatingSearchBar(),
                          CategoryBar(controller: _controller),
                        ],
                      ),
                    ),
                  ),
                ),
                SlidingUpPanel(
                    isDraggable: true,
                    controller: _panelController,
                    maxHeight: 200,
                    minHeight: 0,
                    parallaxEnabled: true,
                    parallaxOffset: .1,
                    backdropEnabled: false,
                    onPanelSlide: (position) {
                      setState(() {
                        panelPosition = position;
                      });
                    },
                    panel: BottomSheetInfo(
                      onClose: () {
                        _panelController.hide();
                      },
                    )),
              ],
            ),
            floatingActionButton: panelPosition == 0.0
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.routingScreen);
                        },
                        child: const Icon(Icons.directions),
                      ),
                    ],
                  )
                : const SizedBox.shrink()),
      ),
    );
  }

  _showPanel() {
    Future.delayed(const Duration(milliseconds: 100))
        .then((value) => _panelController.animatePanelToPosition(1.0));
  }
}
