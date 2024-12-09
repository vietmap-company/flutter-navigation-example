package vn.vietmap.androidauto.screens

import android.annotation.SuppressLint
import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.ScreenManager
import androidx.car.app.model.Action
import androidx.car.app.model.ActionStrip
import androidx.car.app.model.CarIcon
import androidx.car.app.model.ItemList
import androidx.car.app.model.Row
import androidx.car.app.model.SearchTemplate
import androidx.car.app.model.Template
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import vn.vietmap.androidauto.model.PlaceItem
import vn.vietmap.androidauto.service.IAndroidAutoSearchCommunicator
import vn.vietmap.androidauto.service.SearchScreenService
import vn.vietmap.androidauto.service.ServiceGenerator
import vn.vietmap.services.android.navigation.v5.location.engine.LocationEngineProvider
import vn.vietmap.vietmapsdk.location.engine.LocationEngine
import vn.vietmap.vietmapsdk.location.engine.LocationEngineCallback
import vn.vietmap.vietmapsdk.location.engine.LocationEngineResult
import java.lang.Exception

class VietMapSearchScreen(carContext: CarContext): Screen(carContext), LifecycleObserver, IAndroidAutoSearchCommunicator {
    private val searchScreenService : SearchScreenService = ServiceGenerator.createService(SearchScreenService::class.java)
    private var locationEngine: LocationEngine? = null
    private var placeItems : List<PlaceItem> = emptyList()
    private var searchMethodChannel: MethodChannel? = null
    private var flutterEngine: FlutterEngine? = null
    private var searchText: String = ""

    companion object {
        const val VIETMAP_ANDROID_AUTO_CHANNEL = "vn.vietmap.automotive/search"

        private val _searchScreenInstance = MutableStateFlow<VietMapSearchScreen?>(null)
        val searchScreenInstance: StateFlow<VietMapSearchScreen?> = _searchScreenInstance

        fun setSearchScreenInstance(screen: VietMapSearchScreen?) {
            _searchScreenInstance.value = screen
        }
    }

    init {
        lifecycle.addObserver(this)
        locationEngine = LocationEngineProvider.getBestLocationEngine(carContext)
        setSearchScreenInstance(this)
    }

    fun initFlutterEngine(flutterEngine: FlutterEngine){
        this.flutterEngine = flutterEngine
        searchMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger,VIETMAP_ANDROID_AUTO_CHANNEL)
    }

    private val searchCallback = object : SearchTemplate.SearchCallback {
        @SuppressLint("MissingPermission")
        override fun onSearchTextChanged(query: String) {
            // Handle search text change event here
            searchMethodChannel?.invokeMethod("queryTextUpdated", mapOf("query" to query))
            searchCallBackFun(query)
        }


        override fun onSearchSubmitted(query: String) {
            // Handle search submit event here
            Log.d("VietMapSearchScreen", "onSearchSubmitted: $query")
        }
    }
    private fun performSearch(query: String, latLngString: String?){
        lifecycleScope.launch {
            delay(500)
            val resp = searchScreenService.autocomplete(query, latLngString)
            setResults(if (resp.isSuccessful) resp.body() ?: emptyList() else emptyList())
        }
    }


    private fun setResults(results: List<PlaceItem>){
        placeItems = results.toList()
        val itemList = ItemList.Builder()
        results.forEach{
            itemList.addItem(
                Row.Builder()
                    .setTitle(it.name)
                    .setOnClickListener { onPlaceSelected(it) }
                    .addText(it.address)
                    .build()
            )
        }

        refreshSearchTemplate()
        searchTemplate.setItemList(itemList.build())
        invalidate()
    }

    private fun onBackPressed() {
        searchMethodChannel?.invokeMethod("closeSearch", null)
        finish()
    }

    private fun onPlaceSelected(placeItem: PlaceItem){
        // Pop back to navigation place and set destination
        lifecycleScope.launch {
            val resp = searchScreenService.getPlaceDetail(placeItem.ref_id)
            if(resp.isSuccessful){
                setResult(resp.body())
                finish()
            }
        }
    }
    private var backAction = Action.Builder()
        .setIcon(CarIcon.BACK)
        .setOnClickListener { onBackPressed() }
        .build()

    private var searchTemplate = SearchTemplate.Builder(searchCallback)
        .setActionStrip(ActionStrip.Builder().addAction(backAction).build())
        .setSearchHint("Tìm Kiếm")


    private fun refreshSearchTemplate() {
        searchTemplate = SearchTemplate.Builder(searchCallback)
            .setActionStrip(ActionStrip.Builder().addAction(backAction).build())
            .setSearchHint("Tìm Kiếm")
    }

    override fun onGetTemplate(): Template {
        return searchTemplate.build()
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    fun onDestroy(){
        setSearchScreenInstance(null)
        searchMethodChannel = null
    }

    override fun closeSearch(result: MethodChannel.Result) {
        finish()
        result.success(true)
    }

    @SuppressLint("MissingPermission")
    private fun searchCallBackFun(query: String){
        searchText = query
        if(query.isEmpty() || query.length < 2) return
        locationEngine?.getLastLocation(
            object : LocationEngineCallback<LocationEngineResult> {
                override fun onSuccess(result: LocationEngineResult?) {
                    val lat = result?.lastLocation?.latitude
                    val lng = result?.lastLocation?.longitude
                    performSearch(searchText, "$lat,$lng")
                }

                override fun onFailure(exception: Exception) {
                    performSearch(searchText, null)
                }
            }
        )
    }

    override fun onTextReceived(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as Map<*, *>
        val query = args["query"] as String?
        searchCallBackFun(query ?: "")

        if(query != null && query.length < 2) {
            searchTemplate.setItemList(
                ItemList.Builder()
                    .addItem(
                        Row.Builder()
                            .setTitle("Nhập ít nhất 2 ký tự để tìm kiếm")
                            .build()
                    )
                    .build()
            ).setInitialSearchText(query)
            invalidate()
        }

        result.success(true)
    }
}