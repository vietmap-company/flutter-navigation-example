package vn.vietmap.androidauto.service

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

interface IAndroidAutoSearchCommunicator {
    fun closeSearch(result: Result)
    fun onTextReceived(call: MethodCall, result: Result)
    fun onSearchResultSelected(call: MethodCall, result: Result)
}