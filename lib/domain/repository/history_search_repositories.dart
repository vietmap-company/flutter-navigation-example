import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:vietmap_map/data/models/vietmap_autocomplete_model.dart';
import 'package:vietmap_map/data/repository/history_search_repository.dart';
import '../../constants/constants.dart';
import '../../core/failures/failure.dart';
import '../../core/failures/get_file_failure.dart';

class HistorySearchRepositories implements HistorySearchRepository {
  Box? _personBox;

  static final HistorySearchRepositories _singleton =
      HistorySearchRepositories._internal();

  factory HistorySearchRepositories() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(VietmapAutocompleteModelAdapter());
    }

    return _singleton;
  }
  HistorySearchRepositories._internal();
  Future _openBox() async {
    _personBox =
        await Hive.openBox<VietmapAutocompleteModel>(hiveBoxHistorySearch);
    return;
  }

  @override
  Future<Either<Failure, bool>> addHistorySearch(
      VietmapAutocompleteModel recentSearch) async {
    try {
      await _openBox();
      if (_personBox?.length == 5) {
        _personBox?.deleteAt(0);
      }
      for (int i = 0; i < (_personBox?.length ?? 0); i++) {
        if (_personBox?.getAt(i)?.refId == recentSearch.refId) {
          _personBox?.deleteAt(i);
        }
      }
      _personBox?.add(recentSearch);
      
      _personBox?.close();
      return const Right(true);
    } catch (e) {
      return Left(GetFileFailure());
    }
  }

  @override
  Future<Either<Failure, List<VietmapAutocompleteModel>>>
      getHistorySearch() async {
    try {
      await _openBox();

      final List<VietmapAutocompleteModel> list =
          List<VietmapAutocompleteModel>.from(_personBox?.values ?? []);
      _personBox?.close();
      return Right(list.reversed.toList());
    } catch (e) {
      return Left(GetFileFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> removeAllHistorySearch() async {
    try {
      await _openBox();
      _personBox?.clear();
      _personBox?.close();
      return const Right(true);
    } catch (e) {
      return Left(GetFileFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> removeHistorySearch(
      VietmapAutocompleteModel model) async {
    try {
      await _openBox();
      _personBox?.delete(model);
      _personBox?.close();
      return const Right(true);
    } catch (e) {
      return Left(GetFileFailure());
    }
  }
}
