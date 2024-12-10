package vn.vietmap.androidauto.vm_interface

import com.mapbox.api.directions.v5.models.DirectionsRoute

interface IVietMapCarMapController {
    fun overviewRoute()
    fun initiateRouteFromMarker(startNavigation: Boolean)
    fun zoomIn()
    fun zoomOut()
    fun recenter()
    fun startNavigation()
    fun stopNavigation()
    fun setRoute(route: DirectionsRoute)
    fun pushToSearchScreen()
}