import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vietmap_flutter_navigation/models/constant.dart';
import 'package:vietmap_flutter_navigation/models/route_progress_event.dart';

import '../../../constants/colors.dart';

class VietmapBannerInstructionView extends StatelessWidget {
  const VietmapBannerInstructionView({
    super.key,
    required this.routeProgressEvent,
  });

  /// this widget use [RouteProgressEvent] to show the direction icon and instruction
  final RouteProgressEvent? routeProgressEvent;

  @override
  Widget build(BuildContext context) {
    return routeProgressEvent == null
        ? const SizedBox.shrink()
        : Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: vietmapColor.withOpacity(0.7)),
            height: 100,
            width: MediaQuery.of(context).size.width - 20,
            child: Row(children: [
              const SizedBox(width: 15),
              _getInstructionImage(routeProgressEvent?.currentModifier,
                  routeProgressEvent?.currentModifierType),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routeProgressEvent?.currentStepInstruction ?? '',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    RichText(
                      text: TextSpan(text: 'Còn ', children: [
                        TextSpan(
                            text: _calculateTotalDistance(
                                routeProgressEvent?.distanceToNextTurn),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        TextSpan(
                            text: _getGuideText(
                                routeProgressEvent?.currentModifier,
                                routeProgressEvent?.currentModifierType),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ]),
                      maxLines: 2,
                    )
                  ],
                ),
              ),
            ]),
          );
  }

  _calculateTotalDistance(double? distance) {
    var data = distance ?? 0;
    if (data < 1000) return '${data.round()} mét, ';
    return '${(data / 1000).toStringAsFixed(2)} Km, ';
  }

  _getGuideText(String? modifier, String? type) {
    if (modifier != null && type != null) {
      List<String> data = [
        type.replaceAll(' ', '_'),
        modifier.replaceAll(' ', '_')
      ];

      return translationGuide[data.join('_')]?.toLowerCase() ?? '';
    }
    return '';
  }

  _getInstructionImage(String? modifier, String? type) {
    if (modifier != null && type != null) {
      List<String> data = [
        type.replaceAll(' ', '_'),
        modifier.replaceAll(' ', '_')
      ];
      String path = 'assets/navigation_symbol/${data.join('_')}.svg';
      return SvgPicture.asset(path, color: Colors.white);
    }
  }
}
