import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vietmap_map/components/map_action_button.dart';
import 'package:vietmap_map/features/map_screen/bloc/map_bloc.dart';

import '../../../constants/colors.dart';
import '../../../constants/route.dart';
import '../../routing_screen/models/routing_params_model.dart';
import '../bloc/map_state.dart';

class BottomSheetInfo extends StatelessWidget {
  const BottomSheetInfo(
      {super.key,
      required this.onClose,
      required this.onCreateRouteCallback,
      required this.onStartNavigationCallback});
  final VoidCallback onClose;
  final VoidCallback onCreateRouteCallback;
  final VoidCallback onStartNavigationCallback;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (previous, current) =>
          current is MapStateGetPlaceDetailSuccess ||
          current is MapStateGetLocationFromCoordinateSuccess,
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
                  child: Text(
                    state.response.name ?? '',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),
                Text(state.response.getAddress(),
                    style: const TextStyle(fontSize: 16)),
                const Spacer(),
                Row(
                  children: [
                    MapActionButton(
                        onPressed: () async {
                          onCreateRouteCallback();
                          EasyLoading.show();
                          Navigator.pushNamed(context, Routes.routingScreen,
                              arguments: RoutingParamsModel.fromVietmapModel(
                                  state.response, false));
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
                        onPressed: () {
                          onStartNavigationCallback();
                          Navigator.pushNamed(context, Routes.routingScreen,
                              arguments: RoutingParamsModel.fromVietmapModel(
                                  state.response, true));
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.navigation_sharp, color: vietmapColor),
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
                  child: Text(
                    state.response.name ?? '',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),
                Text(state.response.address ?? '',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text(
                    'Khoảng cách: ${state.response.distanceFromCurrentLocation?.toStringAsFixed(2) ?? 0} km',
                    style: const TextStyle(fontSize: 16)),
                const Spacer(),
                Row(
                  children: [
                    MapActionButton(
                        onPressed: () async {
                          onCreateRouteCallback();
                          EasyLoading.show();
                          Navigator.pushNamed(context, Routes.routingScreen,
                              arguments: RoutingParamsModel.fromVietmapModel(
                                  state.response, false));
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
                        onPressed: () {
                          onStartNavigationCallback();
                          Navigator.pushNamed(context, Routes.routingScreen,
                              arguments: RoutingParamsModel.fromVietmapModel(
                                  state.response, true));
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.navigation_sharp, color: vietmapColor),
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
