import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../data/models/vietmap_remote_config_model.dart';
import '../di/app_context.dart';

class FirebaseRemoteConfigure {
  static initConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
  }

  static Future<Map<String, String>> getAllRemoteConfigValues() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.activate();
    await remoteConfig.fetchAndActivate();

    var data = remoteConfig.getAll();
    Map<String, String> result = {};
    data.forEach((key, value) {
      result.addAll({key: value.asString()});
    });
    print(result);

    AppContext.setRemoteConfigValue(RemoteConfigModel.fromMap(result));
    return result;
  }
}
