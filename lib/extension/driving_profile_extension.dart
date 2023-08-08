import 'package:vietmap_flutter_navigation/embedded/controller.dart';

import '../domain/entities/vietmap_routing_params.dart';

extension DrivingProfileExtension on DrivingProfile? {
  VehicleType convertToVehicleType() {
    if (this == null) return VehicleType.car;
    switch (this!) {
      case DrivingProfile.drivingTraffic:
        return VehicleType.car;
      case DrivingProfile.cycling:
        return VehicleType.bike;
      case DrivingProfile.walking:
        return VehicleType.foot;
      case DrivingProfile.motorcycle:
        return VehicleType.motorcycle;
    }
  }
}

extension VehicleTypeExtension on VehicleType? {
  DrivingProfile convertToDrivingProfile() {
    if (this == null) return DrivingProfile.drivingTraffic;
    switch (this!) {
      case VehicleType.car:
        return DrivingProfile.drivingTraffic;
      case VehicleType.bike:
        return DrivingProfile.cycling;
      case VehicleType.foot:
        return DrivingProfile.walking;
      case VehicleType.motorcycle:
        return DrivingProfile.motorcycle;
    }
  }
}
