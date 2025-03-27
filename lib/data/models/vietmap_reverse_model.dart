import 'package:vietmap_map/domain/entities/vietmap_model.dart';

class VietmapReverseModel extends VietmapModel {
  String? refId;
  num? distance;
  num? distanceFromCurrentLocation;

  VietmapReverseModel(
      {super.lat,
      super.lng,
      this.refId,
      this.distance,
      this.distanceFromCurrentLocation,
      super.address,
      super.name,
      super.display});
  VietmapReverseModel.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
    refId = json['ref_id'];
    distance = json['distance'];
    address = json['address'];
    name = json['name'];
    display = json['display'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    data['ref_id'] = refId;
    data['distance'] = distance;
    data['address'] = address;
    data['name'] = name;
    data['display'] = display;
    return data;
  }

  VietmapReverseModel copyWith(
      {double? lat,
      double? lng,
      String? refId,
      num? distance,
      num? distanceFromCurrentLocation,
      String? address,
      String? name,
      String? display}) {
    return VietmapReverseModel(
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        refId: refId ?? this.refId,
        distance: distance ?? this.distance,
        distanceFromCurrentLocation:
            distanceFromCurrentLocation ?? this.distanceFromCurrentLocation,
        address: address ?? this.address,
        name: name ?? this.name,
        display: display ?? this.display);
  }
}
