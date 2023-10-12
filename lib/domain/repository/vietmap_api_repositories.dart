import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:vietmap_map/di/app_context.dart';
import 'package:vietmap_map/domain/entities/vietmap_routing_params.dart';

import 'package:vietmap_map/data/models/vietmap_routing_model.dart';
import 'package:vietmap_map/extension/latlng_extension.dart';
import 'package:vietmap_map/extension/string_extension.dart';

import '/data/models/vietmap_place_model.dart';

import '/core/failures/failure.dart';
import '/data/models/vietmap_autocomplete_model.dart';
import '/data/models/vietmap_reverse_model.dart';
import '/data/repository/vietmap_api_repository.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../core/failures/api_server_failure.dart';
import '../../core/failures/api_timeout_failure.dart';
import '../../core/failures/exception_failure.dart';

class VietmapApiRepositories implements VietmapApiRepository {
  late Dio _dio;
  String baseUrl = AppContext.getVietmapBaseUrl() ?? 'https://api.vietmap.vn/';
  String apiKey = AppContext.getVietmapAPIKey() ?? '';
  VietmapApiRepositories() {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));

    if (kDebugMode) {
      // ignore: deprecated_member_use
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
  }

  @override
  Future<Either<Failure, VietmapReverseModel>> getLocationFromLatLng(
      {required double lat, required double long, int? cats}) async {
    try {
      var res = await _dio.get('reverse/v3', queryParameters: {
        'apikey': apiKey,
        'lat': lat,
        'lng': long,
        'cats': cats
      });

      if (res.statusCode == 200 && res.data.length > 0) {
        var data = VietmapReverseModel.fromJson(res.data[0]);
        return Right(data);
      } else {
        return const Left(ApiServerFailure('Có lỗi xảy ra'));
      }
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.receiveTimeout) {
        return Left(ApiTimeOutFailure());
      } else {
        return Left(ExceptionFailure(ex));
      }
    }
  }

  @override
  Future<Either<Failure, List<VietmapReverseModel>>> getLocationFromCategory(
      {required double lat, required double long, int? cats}) async {
    try {
      var res = await _dio.get('reverse/v3', queryParameters: {
        'apikey': apiKey,
        'lat': lat,
        'lng': long,
        'cats': cats,
        'radius': 1,
      });

      if (res.statusCode == 200 && res.data.length > 0) {
        var data = List<VietmapReverseModel>.from(
            res.data.map((e) => VietmapReverseModel.fromJson(e)));
        return Right(data);
      } else {
        return const Left(ApiServerFailure('Có lỗi xảy ra'));
      }
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.receiveTimeout) {
        return Left(ApiTimeOutFailure());
      } else {
        return Left(ExceptionFailure(ex));
      }
    }
  }

  @override
  Future<Either<Failure, List<VietmapAutocompleteModel>>> searchLocation(
      String keySearch) async {
    try {
      var location = await Geolocator.getCurrentPosition();
      var res = await _dio.get('autocomplete/v3', queryParameters: {
        'apikey': apiKey,
        'text': keySearch,
        'focus': location.toLatLng().toUrlValue()
      });

      if (res.statusCode == 200) {
        var data = List<VietmapAutocompleteModel>.from(
            res.data.map((e) => VietmapAutocompleteModel.fromJson(e)));
        return Right(data);
      } else {
        return const Left(ApiServerFailure('Có lỗi xảy ra'));
      }
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.receiveTimeout) {
        return Left(ApiTimeOutFailure());
      } else {
        return Left(ExceptionFailure(ex));
      }
    }
  }

  @override
  Future<Either<Failure, VietmapPlaceModel>> getPlaceDetail(
      String placeId) async {
    try {
      var res = await _dio.get('place/v3',
          queryParameters: {'apikey': apiKey, 'refid': placeId});

      if (res.statusCode == 200) {
        var data = VietmapPlaceModel.fromJson(res.data);
        return Right(data);
      } else {
        return const Left(ApiServerFailure('Có lỗi xảy ra'));
      }
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.receiveTimeout) {
        return Left(ApiTimeOutFailure());
      } else {
        return Left(ExceptionFailure(ex));
      }
    }
  }

  @override
  Future<Either<Failure, VietMapRoutingModel>> findRoute(
      VietMapRoutingParams params) async {
    try {
      String path = params.toMap().toString();

      path = path.convertJsonToUrlPath();
      path +=
          '&point=${params.originPoint?.toUrlValue()}&point=${params.destinationPoint?.toUrlValue()}';

      var res = await _dio.get('route?$path');
      if (res.statusCode == 200) {
        var data = VietMapRoutingModel.fromJson(res.data);
        return Right(data);
      } else {
        return const Left(ApiServerFailure('Có lỗi xảy ra'));
      }
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.receiveTimeout) {
        return Left(ApiTimeOutFailure());
      } else {
        return Left(ExceptionFailure(ex));
      }
    }
  }
}
