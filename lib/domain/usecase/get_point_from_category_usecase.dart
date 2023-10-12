import 'package:dartz/dartz.dart';

import '../../core/failures/failure.dart';
import '../../core/use_case.dart';
import '../../data/models/vietmap_reverse_model.dart';
import '../../data/repository/vietmap_api_repository.dart';
import 'get_location_from_latlng_usecase.dart';

class GetLocationFromCategoryUseCase
    extends UseCase<List<VietmapReverseModel>, LocationPoint> {
  final VietmapApiRepository repository;

  GetLocationFromCategoryUseCase(this.repository);
  @override
  Future<Either<Failure, List<VietmapReverseModel>>> call(
      LocationPoint params) {
    return repository.getLocationFromCategory(
        lat: params.lat, long: params.long, cats: params.category);
  }
}
