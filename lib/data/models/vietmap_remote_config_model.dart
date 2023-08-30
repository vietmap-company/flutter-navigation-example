import '../../domain/entities/vietmap_remote_config.dart';

class RemoteConfigModel extends RemoteConfig {
  RemoteConfigModel(
      {super.vietmapAPIKey, super.vietmapBaseUrl, super.vietmapMapStyleUrl});
  factory RemoteConfigModel.fromMap(Map json) {
    return RemoteConfigModel(
        vietmapAPIKey: json['vietmapAPIKey'],
        vietmapBaseUrl: json['vietmapBaseUrl'],
        vietmapMapStyleUrl: json['vietmapMapStyleUrl']);
  }
}
