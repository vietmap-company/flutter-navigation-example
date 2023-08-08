import '../data/models/vietmap_remote_config_model.dart';

class AppContext {
  static Map tiles = {};
  static final AppContext _singleton = AppContext._internal();

  static RemoteConfigModel? _remoteConfigModel;
  factory AppContext() {
    return _singleton;
  }
  AppContext._internal();
  static void setRemoteConfigValue(RemoteConfigModel data) {
    _remoteConfigModel = data;
  }

  static RemoteConfigModel? getRemoteConfigValue() {
    return _remoteConfigModel;
  }

  static String? getVietmapAPIKey() {
    return _remoteConfigModel?.vietmapAPIKey;
  }

  static String? getVietmapBaseUrl() {
    return _remoteConfigModel?.vietmapBaseUrl;
  }

  static String? getVietmapMapStyleUrl() {
    return _remoteConfigModel?.vietmapMapStyleUrl;
  }
}
