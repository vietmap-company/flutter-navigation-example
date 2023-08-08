import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

class MapEvent {}

class MapEventSearchAddress extends MapEvent {
  final String address;
  MapEventSearchAddress({required this.address});
}

class MapEventGetDetailAddress extends MapEvent {
  final String placeId;
  MapEventGetDetailAddress({required this.placeId});
}

class MapEventGetDirection extends MapEvent {
  final LatLng from;
  final LatLng to;
  MapEventGetDirection({required this.from, required this.to});
}

class MapEventGetAddressFromCoordinate extends MapEvent {
  final LatLng coordinate;
  MapEventGetAddressFromCoordinate({required this.coordinate});
}
