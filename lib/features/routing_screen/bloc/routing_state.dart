// ignore_for_file: overridden_fields

import 'package:equatable/equatable.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_flutter_navigation/models/direction_route.dart';
import 'package:vietmap_map/domain/entities/vietmap_routing_params.dart';

import '../../../data/models/vietmap_routing_model.dart';
import '../../../di/app_context.dart';

class RoutingState extends Equatable {
  final VietMapRoutingModel? routingModel;
  final List<LatLng>? listPoint;
  final DirectionRoute? directionRoute;
  final VietMapRoutingParams? routingParams;
  const RoutingState(
      {this.routingParams,
      this.directionRoute,
      this.routingModel,
      this.listPoint});

  @override
  List<Object?> get props =>
      [routingModel, routingParams, listPoint, directionRoute];
}

class RoutingStateInitial extends RoutingState {
  RoutingStateInitial()
      : super(
            routingParams: VietMapRoutingParams(
              vehicle: VehicleType.car,
              apiKey: AppContext.getVietmapAPIKey() ?? '',
              originPoint: null,
              destinationPoint: null,
            ),
            routingModel: null,
            listPoint: []);
}

class RoutingStateLoading extends RoutingState {
  RoutingStateLoading(RoutingState state)
      : super(
            routingModel: state.routingModel,
            routingParams: state.routingParams,
            listPoint: state.listPoint);
}

class RoutingStateGetDirectionSuccess extends RoutingState {
  final VietMapRoutingModel response;
  final RoutingState state;
  @override
  final List<LatLng> listPoint;
  @override
  final VietMapRoutingParams? routingParams;
  RoutingStateGetDirectionSuccess(this.state,
      {required this.response, required this.listPoint, this.routingParams})
      : super(
            routingParams: routingParams ?? state.routingParams,
            routingModel: response,
            directionRoute: state.directionRoute,
            listPoint: listPoint);
  @override
  List<Object?> get props =>
      [routingModel, routingParams, listPoint, directionRoute];
}

class RoutingStateGetDirectionError extends RoutingState {
  final String message;
  final RoutingState state;

  RoutingStateGetDirectionError({required this.message, required this.state})
      : super(
            routingModel: state.routingModel,
            routingParams: state.routingParams,
            directionRoute: state.directionRoute,
            listPoint: state.listPoint);
}

class RoutingStateNativeRouteBuilt extends RoutingState {
  final DirectionRoute response;

  RoutingStateNativeRouteBuilt(RoutingState state, this.response)
      : super(
            routingParams: state.routingParams,
            routingModel: state.routingModel,
            listPoint: state.listPoint,
            directionRoute: response);
  @override
  List<Object?> get props =>
      [routingModel, routingParams, listPoint, directionRoute];
}
