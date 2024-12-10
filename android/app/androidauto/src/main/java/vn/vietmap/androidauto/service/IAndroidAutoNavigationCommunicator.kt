package vn.vietmap.androidauto.service

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

interface IAndroidAutoNavigationCommunicator {
    fun getDistanceToLocation(methodCall: MethodCall, result: Result)
    fun navigateToSearch(result: Result)
    fun removeRoutes(result: Result)
    fun addMarkers(call: MethodCall, result: Result)
    fun onStartNavigation(call: MethodCall, result: Result)
    fun onCreateRoute(result: Result)
}