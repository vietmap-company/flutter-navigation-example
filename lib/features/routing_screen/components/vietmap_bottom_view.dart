import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vietmap_flutter_navigation/embedded/controller.dart';
import 'package:vietmap_flutter_navigation/models/route_progress_event.dart';

class VietmapBottomActionView extends StatelessWidget {
  const VietmapBottomActionView(
      {super.key,
      this.controller,
      this.routeProgressEvent,
      required this.recenterButton,
      this.onOverviewCallback,
      this.onStopNavigationCallback});

  /// this widget use [MapNavigationViewController] to control the map (overview, finish navigation)
  final MapNavigationViewController? controller;

  /// will return overviewCallback when user click on the overview button
  final VoidCallback? onOverviewCallback;

  /// allow a custom widget to recenter the map
  final Widget recenterButton;

  /// this widget use [RouteProgressEvent] to show the information to calculate
  /// the time arrive remaining, distance remaining and estimated arrival time
  final RouteProgressEvent? routeProgressEvent;

  /// will return onStopNavigationCallback when user click on the stop navigation button
  final VoidCallback? onStopNavigationCallback;

  @override
  Widget build(BuildContext context) {
    return routeProgressEvent == null
        ? const SizedBox.shrink()
        : Hero(
            tag: 'bottomActionView',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                recenterButton,
                Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15))),
                  child: Row(children: [
                    TextButton(
                        style: ButtonStyle(overlayColor:
                            MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                          return Colors.transparent;
                        })),
                        onPressed: () {
                          if (onStopNavigationCallback != null) {
                            onStopNavigationCallback!();
                          }
                          controller?.finishNavigation();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.black45, width: 1)),
                          child: const Icon(
                            Icons.close,
                            color: Colors.black45,
                            size: 30,
                          ),
                        )),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FittedBox(
                          child: Text(
                            _getTimeArriveRemaining(),
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber[900]),
                          ),
                        ),
                        FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  _calculateTotalDistance(
                                      routeProgressEvent?.distanceRemaining),
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.black45)),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.circle_sharp,
                                size: 5,
                              ),
                              const SizedBox(width: 10),
                              Text(_calculateEstimatedArrivalTime(),
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.black45))
                            ],
                          ),
                        ),
                      ],
                    )),
                    TextButton(
                        style: ButtonStyle(overlayColor:
                            MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                          return Colors.transparent;
                        })),
                        onPressed: () {
                          controller?.overview();
                          if (onOverviewCallback != null) {
                            onOverviewCallback!();
                          }
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.black45, width: 1)),
                          child: const Icon(
                            Icons.route,
                            color: Colors.black45,
                            size: 30,
                          ),
                        ))
                  ]),
                ),
              ],
            ),
          );
  }

  _calculateEstimatedArrivalTime() {
    var data = routeProgressEvent?.durationRemaining ?? 0;
    DateTime dateTime = DateTime.now();
    DateTime estimateArriveTime = dateTime.add(Duration(seconds: data.round()));
    // check the time is tomorrow and return the date

    if (estimateArriveTime.day != dateTime.day) {
      // return DateFormat('dd/MM - hh:mm a').format(estimateArriveTime);
      return _formatDate(estimateArriveTime, 'dd/MM - hh:mm a');
    }

    return _formatTime(estimateArriveTime, 'hh mm');
  }

  _getTimeArriveRemaining() {
    var data = routeProgressEvent?.durationRemaining ?? 0;
    if (data < 60) return '${data.round()} giây';
    if (data < 3600) return '${(data / 60).round()} phút';
    if (data < 86400) {
      var hour = (data / 3600).floor();

      var minute = ((data - hour * 3600) / 60).round();
      return '${hour < 10 ? '0$hour' : hour} giờ, ${minute < 10 ? '0$minute' : minute} phút';
    }
    var day = (data / 86400).floor();
    var hour = ((data - day * 86400) / 3600).floor();

    var minute = ((data - hour * 3600 - day * 86400) / 60).round();
    return '$day ngày, ${hour < 10 ? '0$hour' : hour} giờ, ${minute < 10 ? '0$minute' : minute} phút';
  }

  _calculateTotalDistance(double? distance) {
    var data = distance ?? 0;
    if (data < 1000) return '${data.round()} mét';
    return '${(data / 1000).toStringAsFixed(2)} Km';
  }

  String _formatDate(DateTime date, String format) {
    late DateFormat dateFormat;
    if (date.day == 0) {
      dateFormat = DateFormat('hh:mm a');
    } else {
      dateFormat = DateFormat('dd/MM - hh:mm a');
    }
    var res = dateFormat.format(date);
    return res;
  }

  String _formatTime(DateTime time, String format) {
    final f = DateFormat('hh:mm a');
    return f.format(time);
  }
}
