import 'package:vietmap_map/domain/entities/vietmap_model.dart';

class RoutingParamsModel extends VietmapModel {
  final bool isStartNavigation;

  RoutingParamsModel(
      {super.lat,
      super.lng,
      super.address,
      super.name,
      super.display,
      required this.isStartNavigation});
  factory RoutingParamsModel.fromVietmapModel(
      VietmapModel model, bool isStartNavigation) {
    return RoutingParamsModel(
        lat: model.lat,
        lng: model.lng,
        address: model.address,
        name: model.name,
        display: model.display,
        isStartNavigation: isStartNavigation);
  }
}
