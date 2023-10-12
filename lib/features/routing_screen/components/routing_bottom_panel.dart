import 'package:flutter/material.dart'; 
import 'package:vietmap_map/extension/num_extension.dart';

import '../../../constants/colors.dart';
import '../bloc/bloc.dart'; 

class RoutingBottomPanel extends StatelessWidget {
  const RoutingBottomPanel(
      {super.key,
      required this.onStartNavigation,
      required this.onViewListStep,
      required this.panelPosition,
      required this.routingBloc});
  final VoidCallback onStartNavigation;
  final VoidCallback onViewListStep;
  final double panelPosition;
  final RoutingBloc routingBloc;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 10),
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BlocBuilder<RoutingBloc, RoutingState>(
              bloc: routingBloc,
              buildWhen: (previous, current) =>
                  current is RoutingStateNativeRouteBuilt,
              builder: (context, state) {
                if (state is RoutingStateNativeRouteBuilt) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: state.directionRoute?.duration
                                      ?.convertNativeResponseSecondsToString() ??
                                  '',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 17)),
                          TextSpan(
                              text:
                                  ' (${state.directionRoute?.distance?.distanceToString() ?? ''})',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 17)),
                        ])),
                        const Text('Tuyến đường tốt nhất',
                            style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Row(
                          children: [
                            TextButton(
                                onPressed: onViewListStep,
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            side: const BorderSide(
                                                color: vietmapColor)))),
                                child: panelPosition == 0.0
                                    ? const Hero(
                                        tag: 'listStep',
                                        child: Row(
                                          children: [
                                            Icon(Icons.menu,
                                                color: vietmapColor),
                                            SizedBox(width: 10),
                                            Text('Các chặng'),
                                          ],
                                        ),
                                      )
                                    : const Hero(
                                        tag: 'listStep',
                                        child: Row(
                                          children: [
                                            Icon(Icons.map,
                                                color: vietmapColor),
                                            SizedBox(width: 10),
                                            Text('Bản đồ'),
                                          ],
                                        ),
                                      )),
                            const SizedBox(width: 20),
                            ElevatedButton(
                                onPressed: onStartNavigation,
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            side: const BorderSide(
                                                color: vietmapColor)))),
                                child: const SizedBox(
                                  height: 40,
                                  child: Row(
                                    children: [
                                      Icon(Icons.navigation_sharp,
                                          color: Colors.white),
                                      SizedBox(width: 10),
                                      Text('Bắt đầu',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ))
                          ],
                        )
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
          Expanded(
              child: BlocBuilder<RoutingBloc, RoutingState>(
            bloc: routingBloc,
            buildWhen: (previous, current) =>
                current is RoutingStateNativeRouteBuilt,
            builder: (context, state) {
              if (state is RoutingStateNativeRouteBuilt) {
                return ListView.builder(
                  itemBuilder: (_, index) => ListTile(
                    title: Text(
                        state.directionRoute?.legs?.first.steps?[index].name ??
                            ""),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(state.directionRoute?.legs?.first.steps?[index]
                                .distance
                                ?.distanceToString() ??
                            ''),
                        const Divider(),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                  itemCount:
                      state.directionRoute?.legs?.first.steps?.length ?? 0,
                );
              }
              return const SizedBox.shrink();
            },
          ))
        ],
      ),
    );
  }
}
