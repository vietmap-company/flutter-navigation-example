import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_map/domain/entities/vietmap_routing_params.dart';

class RoutingEvent {}

class RoutingEventGetDirection extends RoutingEvent {
  final LatLng from;
  final LatLng to;
  RoutingEventGetDirection({required this.from, required this.to});
}

class RoutingEventUpdateRouteParams extends RoutingEvent {
  final LatLng? originPoint;
  final LatLng? destinationPoint;
  final String? originDescription;
  final String? destinationDescription;
  final VehicleType? vehicle;

  RoutingEventUpdateRouteParams(
      {this.originPoint,
      this.destinationPoint,
      this.vehicle,
      this.originDescription,
      this.destinationDescription});
}

class RoutingEventUpdateVehicleType extends RoutingEvent {
  final VehicleType vehicleType;
  RoutingEventUpdateVehicleType({required this.vehicleType});
}

class RoutingEventClearDirection extends RoutingEvent {}

class RoutingEventReverseDirection extends RoutingEvent {}
