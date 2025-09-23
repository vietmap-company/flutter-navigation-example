import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vietmap_map/data/models/vietmap_marker_model.dart';
// import 'package:geolocator/geolocator.dart';

import 'package:vietmap_map/data/models/vietmap_reverse_model.dart';
import 'package:vietmap_map/domain/repository/history_search_repositories.dart';
import 'package:vietmap_map/domain/repository/vietmap_api_repositories.dart';
import 'package:vietmap_map/domain/usecase/search_address_usecase.dart';
import 'package:vietmap_map/method_channel/vietmap_automotive_plugin.dart';
import '../../../core/no_params.dart';
import '../../../di/app_context.dart';
import '../../../domain/entities/vietmap_routing_params.dart';
import '../../../domain/usecase/add_history_search_usecase.dart';
import '../../../domain/usecase/get_direction_usecase.dart';
import '../../../domain/usecase/get_history_search_usecase.dart';
import '../../../domain/usecase/get_location_from_latlng_usecase.dart';
import '../../../domain/usecase/get_place_detail_usecase.dart';
import '../../../domain/usecase/get_point_from_category_usecase.dart';
import 'map_event.dart';
import 'map_state.dart';
import 'package:vietmap_gl_platform_interface/vietmap_gl_platform_interface.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final VietMapAutomotivePlugin _vietMapAutomotivePlugin =
      VietMapAutomotivePlugin.instance;
  MapBloc() : super(const MapStateInitial()) {
    on<MapEventSearchAddress>(_onMapEventSearchAddress);
    on<MapEventGetDetailAddress>(_onMapEventGetDetailAddress);
    on<MapEventGetDetailAddressById>(_onMapEventGetDetailAddressById);
    on<MapEventGetEntryPointDetailAddress>(
        _onMapEventGetEntryPointDetailAddress);

    on<MapEventGetDirection>(_onMapEventGetDirection);
    on<MapEventGetAddressFromCoordinate>(_onMapEventGetAddressFromCoordinate);
    on<MapEventOnUserLongTapOnMap>(_onMapEventOnUserLongTapOnMap);
    on<MapEventGetHistorySearch>(_onMapEventGetHistorySearch);
    on<MapEventGetAddressFromCategory>(_onMapEventGetAddressFromCategory);
    on<MapEventShowPlaceDetail>(_onMapEventShowPlaceDetail);
    on<MapEventUserClickOnMapPoint>(_onMapEventUserClickOnMapPoint);
    on<MapEventChangeMapTiles>(_onMapEventChangeMapTiles);
  }

  _onMapEventChangeMapTiles(
      MapEventChangeMapTiles event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    emit(MapStateChangeMapTilesSuccess(event.mapType, state));
  }

  _onMapEventUserClickOnMapPoint(
      MapEventUserClickOnMapPoint event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    num? distanceToLocation;

    await Future.wait(
      [
        // _vietMapAutomotivePlugin
        //     .getDistanceToLocation(
        //   location:
        //       LatLng(event.coordinate.latitude, event.coordinate.longitude),
        // )
        //     .then(
        //   (result) {
        //     distanceToLocation = result;
        //   },
        // ),
        // if (event.isSendingEvent)
        //   _vietMapAutomotivePlugin.addMarkers(
        //     markers: [
        //       VietmapMarkerModel(
        //         lat: event.coordinate.latitude,
        //         lng: event.coordinate.longitude,
        //         title: event.placeName,
        //         snippet: event.placeShortName,
        //       )
        //     ],
        //   )
      ],
    );
    VietmapReverseModel r = VietmapReverseModel(
      lat: event.coordinate.latitude,
      lng: event.coordinate.longitude,
      address: event.placeName,
      name: event.placeShortName,
      distanceFromCurrentLocation: distanceToLocation,
    );
    emit(MapStateGetLocationFromCoordinateSuccess(r, state));
  }

  _onMapEventShowPlaceDetail(
      MapEventShowPlaceDetail event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    emit(MapStateGetLocationFromCoordinateSuccess(event.model, state));
  }

  _onMapEventGetAddressFromCategory(
      MapEventGetAddressFromCategory event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();

    var response =
        await GetLocationFromCategoryUseCase(VietmapApiRepositories()).call(
            LocationPoint(
                lat: event.latLng?.latitude ?? 0,
                long: event.latLng?.longitude ?? 0,
                category: event.categoryCode));
    EasyLoading.dismiss();
    response.fold((l) => emit(MapStateSearchAddressError('Error', state)),
        (r) => emit(MapStateGetCategoryAddressSuccess(r, state)));
  }

  _onMapEventGetHistorySearch(
      MapEventGetHistorySearch event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();
    var response = await GetHistorySearchUseCase(HistorySearchRepositories())
        .call(NoParams());
    EasyLoading.dismiss();
    response.fold((l) => emit(MapStateGetHistorySearchError('Error', state)),
        (r) => emit(MapStateGetHistorySearchSuccess(r, state)));
  }

  _onMapEventOnUserLongTapOnMap(
      MapEventOnUserLongTapOnMap event, Emitter<MapState> emit) async {
    add(MapEventGetAddressFromCoordinate(coordinate: event.coordinate));
  }

  _onMapEventGetAddressFromCoordinate(
      MapEventGetAddressFromCoordinate event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();
    var response = await GetLocationFromLatLngUseCase(VietmapApiRepositories())
        .call(LocationPoint(
            lat: event.coordinate.latitude, long: event.coordinate.longitude));
    EasyLoading.dismiss();
    response.fold(
        (l) => emit(MapStateGetLocationFromCoordinateError('Error', state)),
        (r) async {
      emit(MapStateGetLocationFromCoordinateSuccess(r, state));

      // await _vietMapAutomotivePlugin.addMarkers(
      //   markers: [
      //     VietmapMarkerModel(
      //       lat: event.coordinate.latitude,
      //       lng: event.coordinate.longitude,
      //       title: r.name,
      //       snippet: r.address,
      //     )
      //   ],
      // );
    });
  }

  _onMapEventGetDirection(
      MapEventGetDirection event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();
    var response = await GetDirectionUseCase(VietmapApiRepositories()).call(
        VietMapRoutingParams(
            originPoint: event.from,
            destinationPoint: event.to,
            apiKey: AppContext.getVietmapAPIKey() ?? ''));
    response.fold((l) => MapStateGetDirectionError('Error', state), (r) {
      var locs = VietmapPolylineDecoder.decodePolyline(r.paths!.first.points!)
          .map((e) {
        return LatLng(e.latitude, e.longitude);
      }).toList();
      emit(MapStateGetDirectionSuccess(r, locs, state));
    });
    EasyLoading.dismiss();
  }

  _onMapEventGetEntryPointDetailAddress(
      MapEventGetEntryPointDetailAddress event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();
    var response =
        await GetPlaceDetailUseCase(VietmapApiRepositories()).call(event.refId);
    EasyLoading.dismiss();
    response.fold((l) => emit(MapStateGetPlaceDetailError('Error', state)),
        (r) {
      emit(MapStateGetPlaceDetailSuccess(r, state));
    });
  }

  _onMapEventGetDetailAddress(
      MapEventGetDetailAddress event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();
    AddHistorySearchUseCase(HistorySearchRepositories()).call(event.model);
    var response;
    await Future.wait(
      [
        GetPlaceDetailUseCase(VietmapApiRepositories())
            .call(event.model.refId ?? '')
            .then(
          (value) {
            response = value;
          },
        ),
        // _vietMapAutomotivePlugin.selectSearchResult(
        //   refId: event.model.refId ?? '',
        // ),
      ],
    );
    await EasyLoading.dismiss();
    response.fold((l) => emit(MapStateGetPlaceDetailError('Error', state)),
        (r) {
      emit(MapStateGetPlaceDetailSuccess(r, state));
    });
  }

  _onMapEventGetDetailAddressById(
      MapEventGetDetailAddressById event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();
    var response =
        await GetPlaceDetailUseCase(VietmapApiRepositories()).call(event.refId);
    EasyLoading.dismiss();
    response.fold((l) => emit(MapStateGetPlaceDetailError('Error', state)),
        (r) {
      emit(MapStateGetPlaceDetailSuccess(r, state));
    });
  }

  _onMapEventSearchAddress(
      MapEventSearchAddress event, Emitter<MapState> emit) async {
    emit(MapStateLoading(state));
    EasyLoading.show();
    var response = await SearchAddressUseCase(VietmapApiRepositories())
        .call(event.address);
    EasyLoading.dismiss();
    response.fold((l) => emit(MapStateSearchAddressError('Error', state)),
        (r) => emit(MapStateSearchAddressSuccess(r, state)));
  }
}
