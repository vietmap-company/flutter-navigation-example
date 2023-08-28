import 'package:hive/hive.dart';

class VietmapModel {
  @HiveField(1)
  double? lat;

  @HiveField(2)
  double? lng;

  @HiveField(3)
  String? address;

  @HiveField(4)
  String? name;

  @HiveField(5)
  String? display;
  VietmapModel({this.lat, this.lng, this.address, this.name, this.display});
}
