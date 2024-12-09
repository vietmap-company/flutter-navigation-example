package vn.vietmap.androidauto.service

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

interface IAndroidAutoSearchCommunicator {
    fun closeSearch(result: MethodChannel.Result)
    fun onTextReceived(call: MethodCall, result: MethodChannel.Result)
}