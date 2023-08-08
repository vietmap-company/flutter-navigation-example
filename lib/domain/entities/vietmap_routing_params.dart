import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

enum VehicleType { car, bike, foot, motorcycle }

class VietMapRoutingParams {
  String apiKey;
  LatLng? originPoint;
  String? originDescription;
  String? destinationDescription;
  LatLng? destinationPoint;
  VehicleType vehicle;
  bool optimize;

  VietMapRoutingParams(
      {required this.apiKey,
      this.originDescription,
      this.destinationDescription,
      required this.originPoint,
      required this.destinationPoint,
      this.vehicle = VehicleType.car,
      this.optimize = false});
  toMap() {
    return {
      'api-version': '1.1',
      'apikey': apiKey,
      // 'point': originPoint.toUrlValue(),
      // 'point': destinationPoint.toUrlValue(),
      'vehicle': vehicle.name,
      'optimize': optimize
    };
  }
}
