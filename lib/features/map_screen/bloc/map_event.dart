import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_map/data/models/vietmap_autocomplete_model.dart';

import '../../../data/models/vietmap_reverse_model.dart';
import '../components/select_map_tiles_modal.dart';

class MapEvent {}

class MapEventSearchAddress extends MapEvent {
  final String address;
  MapEventSearchAddress({required this.address});
}

class MapEventGetDetailAddress extends MapEvent {
  final VietmapAutocompleteModel model;

  MapEventGetDetailAddress(this.model);
}

class MapEventGetDetailAddressById extends MapEvent {
  final String refId;

  MapEventGetDetailAddressById(this.refId);
}

class MapEventGetEntryPointDetailAddress extends MapEvent {
  final String refId;

  MapEventGetEntryPointDetailAddress(this.refId);
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

class MapEventUserClickOnMapPoint extends MapEvent {
  final String placeName;
  final LatLng coordinate;
  final String placeShortName;
  final bool isSendingEvent;

  MapEventUserClickOnMapPoint({
    required this.placeName,
    required this.placeShortName,
    required this.coordinate,
    this.isSendingEvent = true,
  });
}

class MapEventChangeMapTiles extends MapEvent {
  final MapTiles mapType;

  MapEventChangeMapTiles(this.mapType);
}

class MapEventReceiveCreateRoute extends MapEvent {
  
}