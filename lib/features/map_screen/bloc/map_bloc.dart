import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_map/domain/repository/vietmap_api_repositories.dart';
import 'package:vietmap_map/domain/usecase/search_address_usecase.dart';

import '../../../di/app_context.dart';
import '../../../domain/entities/vietmap_routing_params.dart';
import '../../../domain/usecase/get_direction_usecase.dart';
import '../../../domain/usecase/get_location_from_latlng_usecase.dart';
import '../../../domain/usecase/get_place_detail_usecase.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapStateInitial()) {
    on<MapEventSearchAddress>(_onMapEventSearchAddress);
    on<MapEventGetDetailAddress>(_onMapEventGetDetailAddress);
    on<MapEventGetDirection>(_onMapEventGetDirection);
    on<MapEventGetAddressFromCoordinate>(_onMapEventGetAddressFromCoordinate);
  }
  _onMapEventGetAddressFromCoordinate(
      MapEventGetAddressFromCoordinate event, Emitter<MapState> emit) async {
    emit(MapStateLoading());
    EasyLoading.show();
    var response = await GetLocationFromLatLngUseCase(VietmapApiRepositories())
        .call(LocationPoint(
            lat: event.coordinate.latitude, long: event.coordinate.longitude));
    log(response.toString());
    EasyLoading.dismiss();
    response.fold((l) => emit(MapStateGetLocationFromCoordinateError('Error')),
        (r) => emit(MapStateGetLocationFromCoordinateSuccess(r)));
  }

  _onMapEventGetDirection(
      MapEventGetDirection event, Emitter<MapState> emit) async {
    emit(MapStateLoading());
    EasyLoading.show();
    var response = await GetDirectionUseCase(VietmapApiRepositories()).call(
        VietMapRoutingParams(
            originPoint: event.from,
            destinationPoint: event.to,
            apiKey: AppContext.getVietmapAPIKey() ?? ''));
    response.fold((l) => MapStateGetDirectionError('Error'), (r) {
      var locs =
          PolylinePoints().decodePolyline(r.paths!.first.points!).map((e) {
        return LatLng(e.latitude, e.longitude);
      }).toList();
      emit(MapStateGetDirectionSuccess(r, locs));
    });
    EasyLoading.dismiss();
  }

  _onMapEventGetDetailAddress(
      MapEventGetDetailAddress event, Emitter<MapState> emit) async {
    emit(MapStateLoading());
    EasyLoading.show();
    var response = await GetPlaceDetailUseCase(VietmapApiRepositories())
        .call(event.placeId);
    EasyLoading.dismiss();
    response.fold((l) => emit(MapStateGetPlaceDetailError('Error')), (r) {
      emit(MapStateGetPlaceDetailSuccess(r));
    });
  }

  _onMapEventSearchAddress(
      MapEventSearchAddress event, Emitter<MapState> emit) async {
    emit(MapStateLoading());
    EasyLoading.show();
    var response = await SearchAddressUseCase(VietmapApiRepositories())
        .call(event.address);
    EasyLoading.dismiss();
    response.fold((l) => emit(MapStateSearchAddressError('Error')),
        (r) => emit(MapStateSearchAddressSuccess(r)));
  }
}
