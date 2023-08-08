import 'package:geolocator/geolocator.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

extension LatLngExtension on LatLng {
  String toUrlValue() {
    return '$latitude,$longitude';
  }
}

extension LatLngBoundsExtension on Position {
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}
