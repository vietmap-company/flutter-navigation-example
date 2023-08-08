import '../../data/models/vietmap_routing_model.dart';

class VietMapRouting {
  String? license;
  String? code;
  String? messages;
  List<PathModel>? paths;

  VietMapRouting({this.license, this.code, this.messages, this.paths});
}

class Paths {
  num? distance;
  num? weight;
  int? time;
  int? transfers;
  bool? pointsEncoded;
  List<num?>? bbox;
  String? points;
  List<InstructionModel>? instructions;
  String? snappedWaypoints;

  Paths(
      {this.distance,
      this.weight,
      this.time,
      this.transfers,
      this.pointsEncoded,
      this.bbox,
      this.points,
      this.instructions,
      this.snappedWaypoints});
}

class Instructions {
  num? distance;
  num? heading;
  num? sign;
  List<num?>? interval;
  String? text;
  num? time;
  String? streetName;
  num? lastHeading;

  Instructions(
      {this.distance,
      this.heading,
      this.sign,
      this.interval,
      this.text,
      this.time,
      this.streetName,
      this.lastHeading});
}
