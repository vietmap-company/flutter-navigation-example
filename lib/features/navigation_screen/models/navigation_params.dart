import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

import 'package:vietmap_map/domain/entities/vietmap_routing_params.dart';

class NavigationScreenParams {
  final LatLng? to;
  final LatLng? from;
  final VehicleType? profile;

  NavigationScreenParams({this.profile, this.to, this.from});
}
