import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppContext {
  static final AppContext _singleton = AppContext._internal();
  static const MethodChannel _mapChannel =
      MethodChannel('vn.vietmap.automotive/maps');
  static const MethodChannel _searchChannel =
      MethodChannel('vn.vietmap.automotive/search');
  static const MethodChannel _navigationChannel =
      MethodChannel('vn.vietmap.automotive/navigation');

  factory AppContext() {
    return _singleton;
  }
  AppContext._internal();

  static String? getVietmapAPIKey() {
    return dotenv.env['VIETMAP_API_KEY'];
  }

  static String? getVietmapBaseUrl() {
    return 'https://maps.vietmap.vn/api/';
  }

  static String? getVietmapMapStyleUrl() {
    return "https://maps.vietmap.vn/maps/styles/tm/style.json?apikey=YOUR_API_KEY_HERE";
    // return "https://maps.vietmap.vn/api/maps/light/styles.json?apiKey=${getVietmapAPIKey()}";
  }

  static MethodChannel getMapChannel() {
    return _mapChannel;
  }

  static MethodChannel getSearchChannel() {
    return _searchChannel;
  }

  static MethodChannel getNavigationChannel() {
    return _navigationChannel;
  }
}
