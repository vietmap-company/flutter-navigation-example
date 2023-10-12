import 'package:vietmap_map/data/models/vietmap_routing_model.dart';

import '../../domain/entities/vietmap_routing_params.dart';
import '../models/vietmap_place_model.dart';
import '/core/failures/failure.dart';
import '/data/models/vietmap_reverse_model.dart';

import 'package:dartz/dartz.dart';

import '../models/vietmap_autocomplete_model.dart';

abstract class VietmapApiRepository {
  Future<Either<Failure, VietmapReverseModel>> getLocationFromLatLng(
      {required double lat, required double long, int? cats});

  Future<Either<Failure, List<VietmapAutocompleteModel>>> searchLocation(
      String keySearch);

  Future<Either<Failure, VietmapPlaceModel>> getPlaceDetail(String placeId);

  Future<Either<Failure, VietMapRoutingModel>> findRoute(
      VietMapRoutingParams params);

  Future<Either<Failure, List<VietmapReverseModel>>> getLocationFromCategory(
      {required double lat, required double long, int? cats});
}
