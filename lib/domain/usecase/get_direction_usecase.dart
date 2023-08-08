import 'package:dartz/dartz.dart';
import 'package:vietmap_map/data/models/vietmap_routing_model.dart';
import 'package:vietmap_map/domain/entities/vietmap_routing_params.dart';

import '../../core/failures/failure.dart';
import '../../core/use_case.dart';
import '../../data/repository/vietmap_api_repository.dart';

class GetDirectionUseCase
    extends UseCase<VietMapRoutingModel, VietMapRoutingParams> {
  final VietmapApiRepository repository;

  GetDirectionUseCase(this.repository);
  @override
  Future<Either<Failure, VietMapRoutingModel>> call(
      VietMapRoutingParams params) {
    return repository.findRoute(params);
  }
}
