import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

import '../data/models/vietmap_marker_model.dart';
import 'vietmap_automotive_method_channel.dart';

abstract class VietmapAutomotivePlatformInterface extends PlatformInterface {
  VietmapAutomotivePlatformInterface() : super(token: _token);

  static final Object _token = Object();

  static VietmapAutomotivePlatformInterface _instance =
      MethodChannelVietmapAutomotivePlugin();

  static VietmapAutomotivePlatformInterface get instance => _instance;

  static set instance(VietmapAutomotivePlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<num?> getDistanceToLocation({
    required LatLng location,
  }) {
    throw UnimplementedError(
        'getDistanceToLocation() has not been implemented.');
  }

  Future<bool?> removeRoutes() {
    throw UnimplementedError('removeRoutes() has not been implemented.');
  }

  Future<bool?> navigateToSearch() {
    throw UnimplementedError('navigateToSearch() has not been implemented.');
  }

  Future<bool?> closeSearch() {
    throw UnimplementedError('closeSearch() has not been implemented.');
  }

  Future<bool?> stopNavigation() {
    throw UnimplementedError('stopNavigation() has not been implemented.');
  }

  Future<List<int>?> addMarkers({
    required List<VietmapMarkerModel> markers,
  }) {
    throw UnimplementedError('addMarkers() has not been implemented.');
  }

  Future<bool?> queryTextUpdated({
    required String query,
  }) {
    throw UnimplementedError('removeMarkers() has not been implemented.');
  }

  Future<bool?> selectSearchResult({
    required String refId,
  }) {
    throw UnimplementedError('selectSearchResult() has not been implemented.');
  }

  Future<bool?> startNavigation() {
    throw UnimplementedError('startNavigation() has not been implemented.');
  }

  Future<bool?> createRoute() {
    throw UnimplementedError('createRoute() has not been implemented.');
  }

  Future<bool?> cancelNavigation() {
    throw UnimplementedError('cancelNavigation() has not been implemented.');
  }

  Future<void> recenter() {
    throw UnimplementedError('recenter() has not been implemented.');
  }
  Future<void> overview() {
    throw UnimplementedError('overview() has not been implemented.');
  }
}
