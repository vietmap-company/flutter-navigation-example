import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vietmap_flutter_navigation/vietmap_flutter_navigation.dart';
import 'package:vietmap_map/constants/events.dart';

import '../data/models/vietmap_marker_model.dart';
import 'vietmap_automotive_platform_interface.dart';

class MethodChannelVietmapAutomotivePlugin
    extends VietmapAutomotivePlatformInterface {
  @visibleForTesting
  final methodChannel = const MethodChannel('vn.vietmap.automotive');

  @visibleForTesting
  final searchMethodChannel =
      const MethodChannel('vn.vietmap.automotive/search');

  @visibleForTesting
  final navigationChannel =
      const MethodChannel('vn.vietmap.automotive/navigation');

  @override
  Future<num?> getDistanceToLocation({
    required LatLng location,
  }) async {
    final result = await methodChannel.invokeMethod<num?>(
      Events.getDistanceToLocation,
      {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
    );
    return result;
  }

  @override
  Future<bool?> removeRoutes() async {
    final result = await methodChannel.invokeMethod<bool?>(Events.removeRoutes);
    return result;
  }

  @override
  Future<bool?> navigateToSearch() async {
    final result =
        await methodChannel.invokeMethod<bool?>(Events.navigateToSearch);
    return result;
  }

  @override
  Future<bool?> closeSearch() async {
    final result = await methodChannel.invokeMethod<bool?>(Events.closeSearch);
    return result;
  }

  @override
  Future<bool?> stopNavigation() async {
    final resp = await methodChannel.invokeMethod<bool?>(Events.stopNavigation);
    return resp;
  }

  @override
  Future<List<int>?> addMarkers({
    required List<VietmapMarkerModel> markers,
  }) {
    final List<Map<String, dynamic>> markersMap = markers
        .map((e) => {
              'latitude': e.lat,
              'longitude': e.lng,
              'title': e.title,
              'snippet': e.snippet,
            })
        .toList();
    return methodChannel.invokeListMethod<int>(
      Events.addMarkers,
      markersMap,
    );
  }

  @override
  Future<bool?> queryTextUpdated({required String query}) async {
    final result = await methodChannel.invokeMethod<bool?>(
      Events.queryTextUpdated,
      {
        'query': query,
      },
    );
    return result;
  }

  @override
  Future<bool?> selectSearchResult({required String refId}) async {
    final result =
        await methodChannel.invokeMethod<bool?>(Events.selectSearchResult, {
      'refId': refId,
    });
    return result;
  }

  @override
  Future<bool?> startNavigation() async {
    final result =
        await methodChannel.invokeMethod<bool?>(Events.onStartNavigation);
    return result;
  }

  @override
  Future<bool?> createRoute() async {
    final result =
        await methodChannel.invokeMethod<bool?>(Events.onCreateRoute);
    return result;
  }
}
