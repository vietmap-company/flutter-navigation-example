import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

import '../../constants/route.dart';
import '../../di/app_context.dart';
import 'bloc/map_bloc.dart';
import 'bloc/map_state.dart';
import 'components/bottom_info.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  VietmapController? _controller;
  List<Marker> _markers = [];
  double panelPosition = 0.0;

  final PanelController _panelController = PanelController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        _panelController.hide();
      });
      var res = await Geolocator.checkPermission();
      if (res != LocationPermission.always ||
          res != LocationPermission.whileInUse) {
        await Geolocator.requestPermission();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapState>(
      listener: (_, state) {
        if (state is MapStateGetPlaceDetailSuccess &&
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
                LatLng(state.response.lat ?? 0, state.response.lng ?? 0), 15),
          );
          _panelController.show();
          _showPanel();
        }
        if (state is MapStateGetDirectionSuccess) {
          _controller?.clearLines();
          _controller?.addPolyline(PolylineOptions(
            geometry: state.listPoint,
            polylineWidth: 4,
            polylineColor: Colors.blue,
          ));
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          if (_panelController.isPanelShown || _panelController.isPanelOpen) {
            _panelController.hide();
            return false;
          }
          return true;
        },
        child: Scaffold(
            body: Stack(
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
                    }),
                _controller == null
                    ? const SizedBox.shrink()
                    : MarkerLayer(
                        mapController: _controller!,
                        markers: _markers,
                      ),
                Positioned(
                  key: const Key('searchBarKey'),
                  top: 30,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.searchScreen);
                    },
                    child: Hero(
                      tag: 'searchBar',
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        width: MediaQuery.of(context).size.width - 40,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Image.asset(
                              'assets/images/vietmap.jpg',
                              width: 25,
                              height: 25,
                            ),
                            const SizedBox(width: 10),
                            const Text('Nhập từ khoá để tìm kiếm'),
                          ],
                        ),
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
                ? FloatingActionButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.routingScreen);
                    },
                    child: const Icon(Icons.directions),
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
