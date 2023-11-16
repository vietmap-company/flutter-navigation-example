class AppContext {
  static final AppContext _singleton = AppContext._internal();

  factory AppContext() {
    return _singleton;
  }
  AppContext._internal();

  static String? getVietmapAPIKey() {
    return 'YOUR_API_KEY_HERE';
  }

  static String? getVietmapBaseUrl() {
    return 'https://maps.vietmap.vn/api/';
  }

  static String? getVietmapMapStyleUrl() {
    return 'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=YOUR_API_KEY_HERE';
  }
}
