import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker/talker.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_map/components/debouncer_search.dart';
import 'package:vietmap_map/features/map_screen/bloc/map_state.dart';

import '../../di/app_context.dart';
import '../../domain/entities/vietmap_picker_data.dart';
import '../map_screen/bloc/map_bloc.dart';
import '../map_screen/bloc/map_event.dart';

class PickAddressScreen extends StatefulWidget {
  const PickAddressScreen({super.key});

  @override
  State<PickAddressScreen> createState() => _PickAddressScreenState();
}

class _PickAddressScreenState extends State<PickAddressScreen> {
  VietmapController? _controller;
  late PreferredSizeWidget appBar;
  final Debounce _debounce =
      Debounce(delay: const Duration(milliseconds: 1000));
  final talker = Talker();
  @override
  void initState() {
    appBar = AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black)),
      title: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Chọn địa chỉ',
            style: TextStyle(color: Colors.black),
          ),
          FittedBox(
            child: Text(
              'Xoay và thu phóng để chọn điểm đến',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
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
            },
            onCameraIdle: () {
              if (!mounted) return;
              _debounce.run(() {
                if (_controller?.cameraPosition != null) {
                  try {
                    context.read<MapBloc>().add(
                        MapEventGetAddressFromCoordinate(
                            coordinate: _controller!.cameraPosition!.target));
                  } catch (e) {
                    talker.handle(e.toString());
                  }
                }
              });
            },
          ),
          Positioned(
            top: (MediaQuery.of(context).size.height -
                        appBar.preferredSize.height -
                        MediaQuery.of(context).padding.top) /
                    2 -
                40,
            left: MediaQuery.of(context).size.width / 2 - 20,
            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
          ),
          Positioned(
            bottom: 0,
            child: BlocBuilder<MapBloc, MapState>(
                buildWhen: (previous, current) =>
                    current is MapStateGetLocationFromCoordinateSuccess ||
                    current is MapStateGetLocationFromCoordinateError,
                builder: (_, state) {
                  if (state is MapStateGetLocationFromCoordinateSuccess) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5))
                          ]),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Text(
                            state.response.display ?? '',
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w500),
                          ),
                          const Divider(),
                          TextButton(
                              onPressed: () {
                                if (_controller?.cameraPosition != null) {
                                  VietMapPickerData pickerData =
                                      VietMapPickerData(
                                          _controller!.cameraPosition!.target,
                                          state.response.display);
                                  Navigator.pop(context, pickerData);
                                }
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Chọn'),
                                ],
                              )),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
          )
        ],
      ),
    );
  }
}
