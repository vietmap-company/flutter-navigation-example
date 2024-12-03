package vn.vietmap.androidauto.screens

import android.annotation.SuppressLint
import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.ScreenManager
import androidx.car.app.model.Action
import androidx.car.app.model.ItemList
import androidx.car.app.model.Row
import androidx.car.app.model.SearchTemplate
import androidx.car.app.model.Template
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import vn.vietmap.androidauto.model.PlaceItem
import vn.vietmap.androidauto.service.SearchScreenService
import vn.vietmap.androidauto.service.ServiceGenerator
import vn.vietmap.services.android.navigation.v5.location.engine.LocationEngineProvider
import vn.vietmap.vietmapsdk.location.engine.LocationEngine
import vn.vietmap.vietmapsdk.location.engine.LocationEngineCallback
import vn.vietmap.vietmapsdk.location.engine.LocationEngineResult
import java.lang.Exception
class VietMapSearchScreen(carContext: CarContext): Screen(carContext) {
    private val searchScreenService : SearchScreenService = ServiceGenerator.createService(SearchScreenService::class.java)
    private var locationEngine: LocationEngine? = null
    private var placeItems : List<PlaceItem> = emptyList()

    init {
        locationEngine = LocationEngineProvider.getBestLocationEngine(carContext)
    }

    private val searchCallback = object : SearchTemplate.SearchCallback {
        @SuppressLint("MissingPermission")
        override fun onSearchTextChanged(query: String) {
            // Handle search text change event here
            locationEngine?.getLastLocation(
                object : LocationEngineCallback<LocationEngineResult> {
                    override fun onSuccess(result: LocationEngineResult?) {
                        val lat = result?.lastLocation?.latitude
                        val lng = result?.lastLocation?.longitude
                        performSearch(query, "$lat,$lng")
                    }

                    override fun onFailure(exception: Exception) {
                        performSearch(query, null)
                    }
                }
            )
        }

        private fun performSearch(query: String, latLngString: String?){
            lifecycleScope.launch {
                delay(500)
                val resp = searchScreenService.autocomplete(query, latLngString)
                setResults(if (resp.isSuccessful) resp.body() ?: emptyList() else emptyList())
            }
        }

        override fun onSearchSubmitted(query: String) {
            // Handle search submit event here
            Log.d("VietMapSearchScreen", "onSearchSubmitted: $query")
        }
    }



    private fun setResults(results: List<PlaceItem>) {
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

        searchTemplate = SearchTemplate.Builder(searchCallback)
            .setHeaderAction(Action.BACK)
            .setItemList(itemList.build())
            .setSearchHint("Search")
            .build()
        invalidate()
    }


    private fun onPlaceSelected(placeItem: PlaceItem){
        // Pop back to navigation place and set destination
        lifecycleScope.launch {
            val resp = searchScreenService.getPlaceDetail(placeItem.ref_id)
            if(resp.isSuccessful){
                setResult(resp.body())
                val screenManager: ScreenManager =
                    carContext.getCarService(ScreenManager::class.java)
                screenManager.pop()
            }
        }
    }

    private var searchTemplate = SearchTemplate.Builder(searchCallback)
        .setHeaderAction(Action.BACK)
        .setSearchHint("Search")
        .build()
    override fun onGetTemplate(): Template {
        return searchTemplate
    }
}