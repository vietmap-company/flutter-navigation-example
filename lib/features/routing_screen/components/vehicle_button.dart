import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vietmap_map/domain/entities/vietmap_routing_params.dart';

import '../../../constants/colors.dart';

class VehicleButton extends StatelessWidget {
  const VehicleButton(
      {super.key,
      required this.vehicleType,
      required this.currentVehicleType,
      required this.onPressed,
      this.estimatedTime});
  final VehicleType vehicleType;
  final VehicleType currentVehicleType;
  final VoidCallback onPressed;
  final String? estimatedTime;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 60),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        height: 40,
        decoration: BoxDecoration(
            color: vehicleType == currentVehicleType
                ? vietmapColor.withOpacity(0.1)
                : CupertinoColors.white,
            border: Border.all(
                color: vehicleType == currentVehicleType
                    ? vietmapColor.withOpacity(0.5)
                    : CupertinoColors.black.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(40)),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: Padding(
              child: _getIcon(),
              padding: const EdgeInsets.symmetric(horizontal: 10)),
        ),
      ),
    );
  }

  _getIcon() {
    switch (vehicleType) {
      case VehicleType.car:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_rounded,
                color: vehicleType == currentVehicleType
                    ? vietmapColor
                    : CupertinoColors.black),
            vehicleType == currentVehicleType &&
                    estimatedTime?.isNotEmpty == true
                ? Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(estimatedTime ?? ''))
                : const SizedBox.shrink()
          ],
        );
      case VehicleType.bike:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bike_rounded,
                color: vehicleType == currentVehicleType
                    ? vietmapColor
                    : CupertinoColors.black),
            vehicleType == currentVehicleType &&
                    estimatedTime?.isNotEmpty == true
                ? Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(estimatedTime ?? ''))
                : const SizedBox.shrink()
          ],
        );
      case VehicleType.foot:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_walk_rounded,
                color: vehicleType == currentVehicleType
                    ? vietmapColor
                    : CupertinoColors.black),
            vehicleType == currentVehicleType &&
                    estimatedTime?.isNotEmpty == true
                ? Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(estimatedTime ?? ''))
                : const SizedBox.shrink()
          ],
        );
      case VehicleType.motorcycle:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.motorcycle_rounded,
                color: vehicleType == currentVehicleType
                    ? vietmapColor
                    : CupertinoColors.black),
            vehicleType == currentVehicleType &&
                    estimatedTime?.isNotEmpty == true
                ? Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(estimatedTime ?? ''))
                : const SizedBox.shrink()
          ],
        );
    }
  }
}
