import 'package:vietmap_map/domain/entities/vietmap_routing.dart';

class VietMapRoutingModel extends VietMapRouting {
  VietMapRoutingModel({
    required String? license,
    required String? code,
    required String? messages,
    required List<PathModel>? paths,
  }) : super(license: license, code: code, messages: messages, paths: paths);
  factory VietMapRoutingModel.copyWith(VietMapRoutingModel? model) {
    return VietMapRoutingModel(
      license: model?.license,
      code: model?.code,
      messages: model?.messages,
      paths: model?.paths,
    );
  }

  VietMapRoutingModel.fromJson(Map<String, dynamic> json) {
    license = json['license'];
    code = json['code'];
    messages = json['messages'];
    if (json['paths'] != null) {
      paths = <PathModel>[];
      json['paths'].forEach((v) {
        paths!.add(PathModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['license'] = license;
    data['code'] = code;
    data['messages'] = messages;
    if (paths != null) {
      data['paths'] = paths!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PathModel extends Paths {
  PathModel.fromJson(Map<String, dynamic> json) {
    distance = json['distance'];
    weight = json['weight'];
    time = json['time'];
    transfers = json['transfers'];
    pointsEncoded = json['points_encoded'];
    bbox = json['bbox'].cast<double>();
    points = json['points'];
    if (json['instructions'] != null) {
      instructions = <InstructionModel>[];
      json['instructions'].forEach((v) {
        instructions!.add(InstructionModel.fromJson(v));
      });
    }
    snappedWaypoints = json['snapped_waypoints'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distance'] = distance;
    data['weight'] = weight;
    data['time'] = time;
    data['transfers'] = transfers;
    data['points_encoded'] = pointsEncoded;
    data['bbox'] = bbox;
    data['points'] = points;
    if (instructions != null) {
      data['instructions'] = instructions!.map((v) => v.toJson()).toList();
    }
    data['snapped_waypoints'] = snappedWaypoints;
    return data;
  }
}

class InstructionModel extends Instructions {
  InstructionModel.fromJson(Map<String, dynamic> json) {
    distance = json['distance'];
    heading = json['heading'];
    sign = json['sign'];
    interval = json['interval'].cast<int>();
    text = json['text'];
    time = json['time'];
    streetName = json['street_name'];
    lastHeading = json['last_heading'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distance'] = distance;
    data['heading'] = heading;
    data['sign'] = sign;
    data['interval'] = interval;
    data['text'] = text;
    data['time'] = time;
    data['street_name'] = streetName;
    data['last_heading'] = lastHeading;
    return data;
  }
}
