package vn.vietmap.vietmap_map

import android.annotation.SuppressLint
import android.location.Location
import android.os.Bundle
import android.util.Log
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch
import vn.vietmap.androidauto.car_surface.VietMapCarAppSession
import vn.vietmap.androidauto.screens.VietMapSearchScreen
import vn.vietmap.androidauto.service.IAndroidAutoNavigationCommunicator
import vn.vietmap.androidauto.service.IAndroidAutoSearchCommunicator


class MainActivity: FlutterActivity(), LifecycleObserver {
    private var androidAutoCommunicator: IAndroidAutoNavigationCommunicator? = null
    private var androidAutoSearchCommunicator: IAndroidAutoSearchCommunicator? = null
    private lateinit var methodChannel: MethodChannel

    companion object{
        const val VIETMAP_ANDROID_AUTO_CHANNEL = "vn.vietmap.automotive"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        lifecycle.addObserver(this)
    }

    @SuppressLint("MissingPermission")
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        lifecycleScope.launch {
            VietMapCarAppSession.navigationScreenInstance.collect { screen ->
                if (screen != null) {
                    androidAutoCommunicator = screen
                    screen.initFlutterEngine(flutterEngine)
                }
            }
        }
        lifecycleScope.launch {
            VietMapSearchScreen.searchScreenInstance.collect { screen ->
                if(screen != null) {
                    androidAutoSearchCommunicator = screen
                    screen.initFlutterEngine(flutterEngine)
                }
            }
        }
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VIETMAP_ANDROID_AUTO_CHANNEL)

        methodChannel.setMethodCallHandler { call, result ->
            when(call.method){
                "getDistanceToLocation" -> {
                    androidAutoCommunicator?.getDistanceToLocation(
                        call,
                        result
                    )
                }
                "removeRoutes" -> {
                    androidAutoCommunicator?.removeRoutes(result)
                }
                "navigateToSearch" -> {
                    Log.d("MainActivity", "navigateToSearch")
                    androidAutoCommunicator?.navigateToSearch(result)
                }
                "addMarkers" -> {
                    androidAutoCommunicator?.addMarkers(call,result)
                }
                "closeSearch" -> {
                    androidAutoSearchCommunicator?.closeSearch(result)
                }
                "queryTextUpdated" -> {
                    androidAutoSearchCommunicator?.onTextReceived(call, result)
                }
                "selectSearchResult" -> {
                    androidAutoSearchCommunicator?.onSearchResultSelected(call, result)
                }
                "startNavigation" -> {
                    androidAutoCommunicator?.onStartNavigation(call, result)
                }
                "createRoute" -> {
                    androidAutoCommunicator?.onCreateRoute(result)
                }
                else -> result.notImplemented()
            }
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    private fun doDestroy() {
        methodChannel.setMethodCallHandler(null)
        androidAutoCommunicator = null
        androidAutoSearchCommunicator = null
    }
}