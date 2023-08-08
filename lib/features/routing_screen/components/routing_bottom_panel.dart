import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vietmap_map/extension/num_extension.dart';

import '../bloc/routing_bloc.dart';
import '../bloc/routing_state.dart';

class RoutingBottomPanel extends StatelessWidget {
  const RoutingBottomPanel(
      {super.key,
      required this.onStartNavigation,
      required this.onViewListStep,
      required this.panelPosition});
  final VoidCallback onStartNavigation;
  final VoidCallback onViewListStep;
  final double panelPosition;
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
              buildWhen: (previous, current) =>
                  current is RoutingStateGetDirectionSuccess,
              builder: (context, state) {
                if (state is RoutingStateGetDirectionSuccess) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: state.routingModel?.paths?.first.time
                                      ?.convertSecondsToString() ??
                                  '',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 17)),
                          TextSpan(
                              text:
                                  ' (${state.routingModel?.paths?.first.distance?.distanceToString() ?? ''})',
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
                                                color: Colors.blue)))),
                                child: panelPosition == 0.0
                                    ? Row(
                                        children: const [
                                          Icon(Icons.menu, color: Colors.blue),
                                          SizedBox(width: 10),
                                          Text('Các chặng'),
                                        ],
                                      )
                                    : Row(
                                        children: const [
                                          Icon(Icons.map, color: Colors.blue),
                                          SizedBox(width: 10),
                                          Text('Bản đồ'),
                                        ],
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
                                                color: Colors.blue)))),
                                child: SizedBox(
                                  height: 40,
                                  child: Row(
                                    children: const [
                                      Icon(Icons.turn_right_outlined,
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
            buildWhen: (previous, current) =>
                current is RoutingStateGetDirectionSuccess,
            builder: (context, state) {
              if (state is RoutingStateGetDirectionSuccess) {
                return ListView.builder(
                  itemBuilder: (_, index) => ListTile(
                    title: Text(state.routingModel?.paths?[0]
                            .instructions?[index].text ??
                        ""),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                            '${state.routingModel?.paths?[0].instructions?[index].distance?.toString() ?? ''} mét'),
                        const Divider(),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                  itemCount:
                      state.routingModel?.paths?.first.instructions?.length ??
                          0,
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