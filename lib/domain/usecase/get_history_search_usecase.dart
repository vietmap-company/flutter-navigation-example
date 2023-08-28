import 'package:dartz/dartz.dart';
import 'package:vietmap_map/core/use_case.dart';

import '../../core/failures/failure.dart';
import '../../core/no_params.dart';
import '../../data/models/vietmap_autocomplete_model.dart';
import '../../data/repository/history_search_repository.dart';

class GetHistorySearchUseCase
    extends UseCase<List<VietmapAutocompleteModel>, NoParams> {
  final HistorySearchRepository historySearchRepository;

  GetHistorySearchUseCase(this.historySearchRepository);
  @override
  Future<Either<Failure, List<VietmapAutocompleteModel>>> call(
      NoParams params) async {
    return Future.value(historySearchRepository.getHistorySearch());
  }
}
