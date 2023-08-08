import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

import '../../../data/models/vietmap_autocomplete_model.dart';
import '../../../data/models/vietmap_place_model.dart';
import '../../../data/models/vietmap_reverse_model.dart';
import '../../../data/models/vietmap_routing_model.dart';

class MapState {}

class MapStateInitial extends MapState {}

class MapStateLoading extends MapState {}

class MapStateSearchAddressSuccess extends MapState {
  final List<VietmapAutocompleteModel> response;

  MapStateSearchAddressSuccess(this.response);
}

class MapStateSearchAddressError extends MapState {
  final String message;

  MapStateSearchAddressError(this.message);
}

class MapStateGetPlaceDetailSuccess extends MapState {
  final VietmapPlaceModel response;

  MapStateGetPlaceDetailSuccess(this.response);
}

class MapStateGetPlaceDetailError extends MapState {
  final String message;

  MapStateGetPlaceDetailError(this.message);
}

class MapStateGetDirectionSuccess extends MapState {
  final VietMapRoutingModel response;
  final List<LatLng> listPoint;
  MapStateGetDirectionSuccess(this.response, this.listPoint);
}

class MapStateGetDirectionError extends MapState {
  final String message;

  MapStateGetDirectionError(this.message);
}

class MapStateGetLocationFromCoordinateSuccess extends MapState {
  final VietmapReverseModel response;

  MapStateGetLocationFromCoordinateSuccess(this.response);
}

class MapStateGetLocationFromCoordinateError extends MapState {
  final String message;

  MapStateGetLocationFromCoordinateError(this.message);
}
