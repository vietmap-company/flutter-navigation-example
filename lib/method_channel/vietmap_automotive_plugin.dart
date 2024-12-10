import 'package:vietmap_flutter_navigation/vietmap_flutter_navigation.dart';
import 'package:vietmap_map/method_channel/vietmap_automotive_platform_interface.dart';

import '../data/models/vietmap_marker_model.dart';

class VietMapAutomotivePlugin {
  static final VietMapAutomotivePlugin _instance = VietMapAutomotivePlugin();

  /// get current instance of this class
  static VietMapAutomotivePlugin get instance => _instance;

  Future<num?> getDistanceToLocation({
    required LatLng location,
  }) async {
    return await VietmapAutomotivePlatformInterface.instance
        .getDistanceToLocation(
      location: location,
    );
  }

  Future<bool?> removeRoutes() async {
    return await VietmapAutomotivePlatformInterface.instance.removeRoutes();
  }

  Future<bool?> navigateToSearch() async {
    return await VietmapAutomotivePlatformInterface.instance.navigateToSearch();
  }

  Future<bool?> closeSearch() async {
    return await VietmapAutomotivePlatformInterface.instance.closeSearch();
  }

  Future<bool?> stopNavigation() async {
    return await VietmapAutomotivePlatformInterface.instance.stopNavigation();
  }

  Future<List<int>?> addMarkers({
    required List<VietmapMarkerModel> markers,
  }) async {
    return await VietmapAutomotivePlatformInterface.instance.addMarkers(
      markers: markers,
    );
  }

  Future<bool?> queryTextUpdated({
    required String query,
  }) async {
    return await VietmapAutomotivePlatformInterface.instance.queryTextUpdated(
      query: query,
    );
  }

  Future<bool?> selectSearchResult({required String refId}) async {
    final result =
        await VietmapAutomotivePlatformInterface.instance.selectSearchResult(
      refId: refId,
    );
    return result;
  }

  Future<bool?> startNavigation() async {
    return await VietmapAutomotivePlatformInterface.instance.startNavigation();
  }

  Future<bool?> createRoute() async {
    return await VietmapAutomotivePlatformInterface.instance.createRoute();
  }
}
