import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_map/features/routing_screen/bloc/routing_event.dart';
import 'package:vietmap_map/features/routing_screen/bloc/routing_state.dart';

import '../../../data/models/vietmap_routing_model.dart';
import '../../../di/app_context.dart';
import '../../../domain/entities/vietmap_routing_params.dart';
import '../../../domain/repository/vietmap_api_repositories.dart';
import '../../../domain/usecase/get_direction_usecase.dart';

class RoutingBloc extends Bloc<RoutingEvent, RoutingState> {
  RoutingBloc() : super(RoutingStateInitial()) {
    on<RoutingEventGetDirection>(_onRoutingEventGetDirection);
    on<RoutingEventUpdateRouteParams>(_onRoutingEventUpdateRouteParams);
    on<RoutingEventClearDirection>(_onRoutingEventClearDirection);
    on<RoutingEventReverseDirection>(_onRoutingEventReverseDirection);
  }
  _onRoutingEventReverseDirection(
      RoutingEventReverseDirection event, Emitter<RoutingState> emit) {
    var params = state.routingParams;
    if (params != null) {
      var temp = params.originPoint;
      var tempDes = params.originDescription;
      var tempDesPoint = params.destinationPoint;
      var tempDesDes = params.destinationDescription;
      params.originPoint = tempDesPoint;
      params.originDescription = tempDesDes;
      params.destinationPoint = temp;
      params.destinationDescription = tempDes;

      emit(RoutingState(
          listPoint: <LatLng>[...(state.listPoint ?? [])],
          routingModel: VietMapRoutingModel.copyWith(state.routingModel),
          routingParams: params));
      add(RoutingEventGetDirection(
          from: params.originPoint!, to: params.destinationPoint!));
    }
  }

  _onRoutingEventClearDirection(
      RoutingEventClearDirection event, Emitter<RoutingState> emit) {
    emit(RoutingStateInitial());
  }

  _onRoutingEventUpdateRouteParams(
      RoutingEventUpdateRouteParams event, Emitter<RoutingState> emit) {
    emit(RoutingStateLoading(state));
    VietMapRoutingParams? params = state.routingParams ??
        VietMapRoutingParams(
            vehicle: event.vehicle ?? VehicleType.car,
            apiKey: AppContext.getVietmapAPIKey() ?? '',
            originPoint: null,
            destinationPoint: null);
    params.vehicle = event.vehicle ?? params.vehicle;
    params.destinationPoint = event.destinationPoint ?? params.destinationPoint;
    params.originPoint = event.originPoint ?? params.originPoint;
    params.originDescription =
        event.originDescription ?? params.originDescription;
    params.destinationDescription =
        event.destinationDescription ?? params.destinationDescription;
    if (params.originPoint != null && params.destinationPoint != null) {
      emit(RoutingState(
          listPoint: <LatLng>[...(state.listPoint ?? [])],
          routingModel: VietMapRoutingModel.copyWith(state.routingModel),
          routingParams: params));
      add(RoutingEventGetDirection(
          from: params.originPoint!, to: params.destinationPoint!));
    }
  }

  _onRoutingEventGetDirection(
      RoutingEventGetDirection event, Emitter<RoutingState> emit) async {
    //RoutingStateGetDirectionSuccess

    emit(RoutingStateLoading(state));
    var routingParams = state.routingParams ??
        VietMapRoutingParams(
            originPoint: event.from,
            destinationPoint: event.to,
            apiKey: AppContext.getVietmapAPIKey() ?? '');
    routingParams.originPoint = event.from;
    routingParams.destinationPoint = event.to;
    EasyLoading.show();
    var response =
        await GetDirectionUseCase(VietmapApiRepositories()).call(routingParams);
    EasyLoading.dismiss();
    response.fold(
        (l) => RoutingStateGetDirectionError(message: 'Error', state: state),
        (r) {
      if (r.paths?.isNotEmpty != true) {
        emit(RoutingStateGetDirectionError(message: 'Error', state: state));
      } else {
        var locs =
            PolylinePoints().decodePolyline(r.paths!.first.points!).map((e) {
          return LatLng(e.latitude, e.longitude);
        }).toList();
        emit(RoutingStateGetDirectionSuccess(
            response: r, listPoint: locs, routingParams: routingParams));
      }
    });
  }
}