import 'package:dartz/dartz.dart';
import '/data/models/vietmap_place_model.dart';

import '../../core/failures/failure.dart';
import '../../core/use_case.dart';
import '../../data/repository/vietmap_api_repository.dart';

class GetPlaceDetailUseCase extends UseCase<VietmapPlaceModel, String> {
  final VietmapApiRepository repository;

  GetPlaceDetailUseCase(this.repository);
  @override
  Future<Either<Failure, VietmapPlaceModel>> call(String params) {
    return repository.getPlaceDetail(params);
  }
}
