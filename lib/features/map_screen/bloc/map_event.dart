import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_map/data/models/vietmap_autocomplete_model.dart';

import '../../../data/models/vietmap_reverse_model.dart';

class MapEvent {}

class MapEventSearchAddress extends MapEvent {
  final String address;
  MapEventSearchAddress({required this.address});
}

class MapEventGetDetailAddress extends MapEvent {
  final VietmapAutocompleteModel model;

  MapEventGetDetailAddress(this.model);
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

class MapEventOnUserLongTapOnMap extends MapEvent {
  final LatLng coordinate;

  MapEventOnUserLongTapOnMap(this.coordinate);
}

class MapEventGetHistorySearch extends MapEvent {}

class MapEventGetAddressFromCategory extends MapEvent {
  final int categoryCode;
  final LatLng? latLng;
  MapEventGetAddressFromCategory({this.latLng, required this.categoryCode});
}

class MapEventShowPlaceDetail extends MapEvent {
  final VietmapReverseModel model;

  MapEventShowPlaceDetail(this.model);
}
