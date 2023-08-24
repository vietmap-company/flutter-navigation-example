// ignore_for_file: overridden_fields

import 'package:equatable/equatable.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_map/domain/entities/vietmap_routing_params.dart';

import '../../../data/models/vietmap_routing_model.dart';
import '../../../di/app_context.dart';

class RoutingState extends Equatable {
  final VietMapRoutingModel? routingModel;
  final List<LatLng>? listPoint;
  final VietMapRoutingParams? routingParams;
  const RoutingState({this.routingParams, this.routingModel, this.listPoint});

  @override
  List<Object?> get props => [routingModel, routingParams, listPoint];
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

  @override
  final List<LatLng> listPoint;
  @override
  final VietMapRoutingParams? routingParams;
  const RoutingStateGetDirectionSuccess(
      {required this.response, required this.listPoint, this.routingParams})
      : super(
            routingParams: routingParams,
            routingModel: response,
            listPoint: listPoint);
  @override
  List<Object?> get props => [routingModel, routingParams, listPoint];
}

class RoutingStateGetDirectionError extends RoutingState {
  final String message;
  final RoutingState state;

  RoutingStateGetDirectionError({required this.message, required this.state})
      : super(
            routingModel: state.routingModel,
            routingParams: state.routingParams,
            listPoint: state.listPoint);
}
