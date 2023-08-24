import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_map/components/map_action_button.dart';
import 'package:vietmap_map/extension/latlng_extension.dart';
import 'package:vietmap_map/features/map_screen/bloc/map_bloc.dart';
import 'package:vietmap_map/features/navigation_screen/models/navigation_params.dart';

import '../../../constants/colors.dart';
import '../../../constants/route.dart'; 
import '../bloc/map_state.dart';

class BottomSheetInfo extends StatelessWidget {
  const BottomSheetInfo({super.key, required this.onClose});
  final VoidCallback onClose;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (previous, current) =>
          current is MapStateGetPlaceDetailSuccess,
      builder: (_, state) {
        if (state is MapStateGetPlaceDetailSuccess) {
          return Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Hero(
                    tag: state.response.name ?? 'addressName',
                    child: Text(
                      state.response.name ?? '',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Hero(
                  tag: state.response.getAddress(),
                  child: Text(state.response.getAddress(),
                      style: const TextStyle(fontSize: 16)),
                ),
                const Spacer(),
                Row(
                  children: [
                    MapActionButton(
                        onPressed: () async {
                          Navigator.pushNamed(context, Routes.routingScreen,
                              arguments: state.response
                              //  VietmapRoutingScreenParams(
                              //     name: state.response.display ?? '',
                              //     coordinate: LatLng(state.response.lat ?? 0,
                              //         state.response.lng ?? 0))
                              );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.directions, color: Colors.white),
                            SizedBox(width: 5),
                            Text('Chỉ đường')
                          ],
                        )),
                    const SizedBox(width: 10),
                    MapActionButtonOutline(
                        onPressed: () async {
                          var res = await Geolocator.getCurrentPosition();

                          // ignore: use_build_context_synchronously
                          Navigator.pushNamed(context, Routes.navigationScreen,
                              arguments: NavigationScreenParams(
                                from: res.toLatLng(),
                                to: LatLng(state.response.lat ?? 0,
                                    state.response.lng ?? 0),
                              ));
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_circle_up_rounded,
                                color: vietmapColor),
                            SizedBox(width: 5),
                            Text('Bắt đầu',
                                style: TextStyle(color: vietmapColor)),
                          ],
                        ))
                  ],
                )
              ],
            ),
          );
        }
        if (state is MapStateGetLocationFromCoordinateSuccess) {
          return Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Hero(
                    tag: state.response.name ?? 'addressName',
                    child: Text(
                      state.response.name ?? '',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Hero(
                  tag: state.response.address ?? 'address',
                  child: Text(state.response.address ?? '',
                      style: const TextStyle(fontSize: 16)),
                ),
                const Spacer(),
                Row(
                  children: [
                    MapActionButton(
                        onPressed: () async {
                          Navigator.pushNamed(context, Routes.routingScreen,
                              arguments:
                              state.response
                              //  VietmapRoutingScreenParams(
                              //     name: state.response.display ?? '',
                              //     coordinate: LatLng(state.response.lat ?? 0,
                              //         state.response.lng ?? 0))
                                      );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.directions, color: Colors.white),
                            SizedBox(width: 5),
                            Text('Chỉ đường')
                          ],
                        )),
                    const SizedBox(width: 10),
                    MapActionButtonOutline(
                        onPressed: () async {
                          var res = await Geolocator.getCurrentPosition();

                          // ignore: use_build_context_synchronously
                          Navigator.pushNamed(context, Routes.navigationScreen,
                              arguments: NavigationScreenParams(
                                from: res.toLatLng(),
                                to: LatLng(state.response.lat ?? 0,
                                    state.response.lng ?? 0),
                              ));
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_circle_up_rounded,
                                color: vietmapColor),
                            SizedBox(width: 5),
                            Text('Bắt đầu',
                                style: TextStyle(color: vietmapColor)),
                          ],
                        ))
                  ],
                )
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
