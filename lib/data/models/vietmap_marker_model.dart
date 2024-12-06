import '../../domain/entities/vietmap_model.dart';

class VietmapMarkerModel extends VietmapModel {
  String? title;
  String? snippet;

  VietmapMarkerModel(
      {super.lat,
      super.lng,
      this.title,
      this.snippet,
      super.address,
      super.name,
      super.display});

  VietmapMarkerModel.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
    title = json['title'];
    snippet = json['snippet'];
    address = json['address'];
    name = json['name'];
    display = json['display'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    data['title'] = title;
    data['snippet'] = snippet;
    data['address'] = address;
    data['name'] = name;
    data['display'] = display;
    return data;
  }
}
