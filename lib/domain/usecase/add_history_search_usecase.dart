import 'package:dartz/dartz.dart';
import 'package:vietmap_map/core/failures/failure.dart';
import 'package:vietmap_map/core/use_case.dart';

import '../../data/models/vietmap_autocomplete_model.dart';
import '../../data/repository/history_search_repository.dart';

class AddHistorySearchUseCase extends UseCase<bool, VietmapAutocompleteModel> {
  final HistorySearchRepository historySearchRepository;

  AddHistorySearchUseCase(this.historySearchRepository);

  @override
  Future<Either<Failure, bool>> call(VietmapAutocompleteModel params) {
    return Future.value(historySearchRepository.addHistorySearch(params));
  }
}
