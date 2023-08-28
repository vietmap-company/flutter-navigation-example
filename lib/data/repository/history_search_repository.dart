import 'package:dartz/dartz.dart';

import '../../core/failures/failure.dart';
import '../models/vietmap_autocomplete_model.dart';

abstract class HistorySearchRepository {
  Future<Either<Failure, List<VietmapAutocompleteModel>>> getHistorySearch();
  Future<Either<Failure, bool>> addHistorySearch(
      VietmapAutocompleteModel recentSearch);
  Future<Either<Failure, bool>> removeHistorySearch(
      VietmapAutocompleteModel model);
  Future<Either<Failure, bool>> removeAllHistorySearch();
}
