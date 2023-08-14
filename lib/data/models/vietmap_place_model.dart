import '../../domain/entities/vietmap_model.dart';

class VietmapPlaceModel extends VietmapModel {
  String? hsNum;
  String? street;
  int? cityId;
  String? city;
  int? districtId;
  String? district;
  int? wardId;
  String? ward;
  VietmapPlaceModel({
    super.display,
    super.name,
    super.lat,
    super.lng,
    super.address,
    this.hsNum,
    this.street,
    this.cityId,
    this.city,
    this.districtId,
    this.district,
    this.wardId,
    this.ward,
  });
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
