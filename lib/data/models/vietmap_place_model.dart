import '/domain/entities/vietmap_place.dart';

class VietmapPlaceModel extends VietmapPlace {
  VietmapPlaceModel.fromJson(Map<String, dynamic> json) {
    display = json['display'];
    name = json['name'];
    hsNum = json['hs_num'];
    street = json['street'];
    address = json['address'];
    cityId = json['city_id'];
    city = json['city'];
    districtId = json['district_id'];
    district = json['district'];
    wardId = json['ward_id'];
    ward = json['ward'];
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['display'] = display;
    data['name'] = name;
    data['hs_num'] = hsNum;
    data['street'] = street;
    data['address'] = address;
    data['city_id'] = cityId;
    data['city'] = city;
    data['district_id'] = districtId;
    data['district'] = district;
    data['ward_id'] = wardId;
    data['ward'] = ward;
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }

  String getAddress() {
    var data = [hsNum, street, ward, district, city];
    return data
        .where((element) => element != null && element.isNotEmpty)
        .join(', ');
  }
}
