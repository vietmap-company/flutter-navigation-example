import '/domain/entities/vietmap_autocomplete.dart';

class VietmapAutocompleteModel extends VietmapAutocomplete {
  VietmapAutocompleteModel.fromJson(Map<String, dynamic> json) {
    refId = json['ref_id'];
    address = json['address'];
    name = json['name'];
    display = json['display'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ref_id'] = refId;
    data['address'] = address;
    data['name'] = name;
    data['display'] = display;
    return data;
  }
}
