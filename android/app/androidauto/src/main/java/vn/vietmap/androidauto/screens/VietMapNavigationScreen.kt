package vn.vietmap.androidauto.screens

import android.annotation.SuppressLint
import android.content.DialogInterface
import android.graphics.Color
import android.graphics.PointF
import android.location.Location
import android.os.Build
import android.util.Log
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.car.app.AppManager
import androidx.car.app.CarContext
import androidx.car.app.OnScreenResultListener
import androidx.car.app.Screen
import androidx.car.app.ScreenManager
import androidx.car.app.SurfaceCallback
import androidx.car.app.model.Alert
import androidx.car.app.model.CarText
import androidx.car.app.model.Template
import androidx.car.app.navigation.model.Maneuver
import androidx.car.app.notification.CarAppExtender
import androidx.core.app.NotificationCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import com.mapbox.api.directions.v5.models.BannerInstructions
import com.mapbox.api.directions.v5.models.DirectionsResponse
import com.mapbox.api.directions.v5.models.DirectionsRoute
import com.mapbox.api.directions.v5.models.DirectionsWaypoint
import com.mapbox.geojson.Point
import com.mapbox.turf.TurfMisc
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import vn.vietmap.androidauto.car_surface.VietMapAndroidAutoSurface
import vn.vietmap.androidauto.helper.VietMapCarSurfaceHelper
import vn.vietmap.androidauto.helper.VietMapNavigationHelper
import vn.vietmap.androidauto.model.CurrentCenterPoint
import vn.vietmap.androidauto.model.PlaceDetail
import vn.vietmap.androidauto.service.IAndroidAutoNavigationCommunicator
import vn.vietmap.androidauto.vm_interface.IVietMapCarMapController
import vn.vietmap.services.android.navigation.ui.v5.camera.CameraOverviewCancelableCallback
import vn.vietmap.services.android.navigation.ui.v5.listeners.BannerInstructionsListener
import vn.vietmap.services.android.navigation.ui.v5.listeners.NavigationListener
import vn.vietmap.services.android.navigation.ui.v5.listeners.RouteListener
import vn.vietmap.services.android.navigation.ui.v5.listeners.SpeechAnnouncementListener
import vn.vietmap.services.android.navigation.ui.v5.voice.NavigationSpeechPlayer
import vn.vietmap.services.android.navigation.ui.v5.voice.SpeechAnnouncement
import vn.vietmap.services.android.navigation.ui.v5.voice.SpeechPlayer
import vn.vietmap.services.android.navigation.ui.v5.voice.SpeechPlayerProvider
import vn.vietmap.services.android.navigation.v5.location.engine.LocationEngineProvider
import vn.vietmap.services.android.navigation.v5.location.replay.ReplayRouteLocationEngine
import vn.vietmap.services.android.navigation.v5.milestone.Milestone
import vn.vietmap.services.android.navigation.v5.milestone.MilestoneEventListener
import vn.vietmap.services.android.navigation.v5.milestone.VoiceInstructionMilestone
import vn.vietmap.services.android.navigation.v5.navigation.NavigationConstants
import vn.vietmap.services.android.navigation.v5.navigation.NavigationEventListener
import vn.vietmap.services.android.navigation.v5.navigation.NavigationMapRoute
import vn.vietmap.services.android.navigation.v5.navigation.NavigationRoute
import vn.vietmap.services.android.navigation.v5.navigation.NavigationTimeFormat
import vn.vietmap.services.android.navigation.v5.navigation.VietmapNavigation
import vn.vietmap.services.android.navigation.v5.navigation.VietmapNavigationOptions
import vn.vietmap.services.android.navigation.v5.offroute.OffRouteListener
import vn.vietmap.services.android.navigation.v5.route.FasterRouteListener
import vn.vietmap.services.android.navigation.v5.route.OnRouteSelectionChangeListener
import vn.vietmap.services.android.navigation.v5.routeprogress.ProgressChangeListener
import vn.vietmap.services.android.navigation.v5.routeprogress.RouteProgress
import vn.vietmap.services.android.navigation.v5.snap.SnapToRoute
import vn.vietmap.vietmapsdk.annotations.IconFactory
import vn.vietmap.vietmapsdk.annotations.Marker
import vn.vietmap.vietmapsdk.annotations.MarkerOptions
import vn.vietmap.vietmapsdk.camera.CameraPosition
import vn.vietmap.vietmapsdk.camera.CameraUpdate
import vn.vietmap.vietmapsdk.camera.CameraUpdateFactory
import vn.vietmap.vietmapsdk.geometry.LatLng
import vn.vietmap.vietmapsdk.location.LocationComponentActivationOptions
import vn.vietmap.vietmapsdk.location.LocationComponentOptions
import vn.vietmap.vietmapsdk.location.engine.LocationEngine
import vn.vietmap.vietmapsdk.location.engine.LocationEngineCallback
import vn.vietmap.vietmapsdk.location.engine.LocationEngineResult
import vn.vietmap.vietmapsdk.location.modes.CameraMode
import vn.vietmap.vietmapsdk.location.modes.RenderMode
import vn.vietmap.vietmapsdk.maps.Style
import vn.vietmap.vietmapsdk.maps.VietMapGL
import vn.vietmap.vietmapsdk.style.layers.LineLayer
import vn.vietmap.vietmapsdk.style.layers.Property.LINE_CAP_ROUND
import vn.vietmap.vietmapsdk.style.layers.Property.LINE_JOIN_ROUND
import vn.vietmap.vietmapsdk.style.layers.PropertyFactory.lineCap
import vn.vietmap.vietmapsdk.style.layers.PropertyFactory.lineColor
import vn.vietmap.vietmapsdk.style.layers.PropertyFactory.lineJoin
import vn.vietmap.vietmapsdk.style.layers.PropertyFactory.lineWidth
import kotlin.math.round


class VietMapNavigationScreen(
    carContext: CarContext,
    private val mSurfaceRenderer: VietMapAndroidAutoSurface,
) : Screen(carContext), ProgressChangeListener,
    OffRouteListener, MilestoneEventListener, NavigationEventListener, NavigationListener,
    FasterRouteListener, SpeechAnnouncementListener, BannerInstructionsListener, RouteListener,
    IVietMapCarMapController, IAndroidAutoNavigationCommunicator, LifecycleObserver{

    private var routeClicked: Boolean = false
    private var currentRoute: DirectionsRoute? = null
    private var locationEngine: LocationEngine? = null
    private var navigationMapRoute: NavigationMapRoute? = null
    private var directionsRoutes: List<DirectionsRoute>? = null
    private var markers: List<Marker>? = null

    private var mapMethodChannel: MethodChannel? = null
    private var navigationMethodChannel: MethodChannel? = null
    private var flutterEngine: FlutterEngine? = null

    private var distanceToOffRoute = 30 //distance in meter
    private val navigationOptions =
        VietmapNavigationOptions.builder().maxTurnCompletionOffset(30.0).maneuverZoneRadius(40.0)
            .maximumDistanceOffRoute(50.0).deadReckoningTimeInterval(5.0)
            .maxManipulatedCourseAngle(25.0).userLocationSnapDistance(20.0).secondsBeforeReroute(3)
            .enableOffRouteDetection(true).enableFasterRouteDetection(false).snapToRoute(false)
            .manuallyEndNavigationUponCompletion(false).defaultMilestonesEnabled(true)
            .minimumDistanceBeforeRerouting(10.0).metersRemainingTillArrival(20.0)
            .isFromNavigationUi(false).isDebugLoggingEnabled(false)
            .roundingIncrement(NavigationConstants.ROUNDING_INCREMENT_FIFTY)
            .timeFormatType(NavigationTimeFormat.NONE_SPECIFIED)
            .locationAcceptableAccuracyInMetersThreshold(100).build()
    private var navigation: VietmapNavigation? = null
    private var isDisposed = false
    private var isRefreshing = false
    private var isBuildingRoute = false
    private var isNavigationInProgress = false
    private var isNavigationCanceled = false
    private var isPreviewingRoute = false
    private var isOverviewing = false
    private var isNextTurnHandling = false
    private val snapEngine = SnapToRoute()
    private var apikey: String? = null
    private var speechPlayer: SpeechPlayer? = null
    private var routeProgress: RouteProgress? = null
    private var primaryRouteIndex = 0

    private var currentCenterPoint: CurrentCenterPoint? = null
    val vietMapCarSurfaceHelper: VietMapCarSurfaceHelper = VietMapCarSurfaceHelper(this, carContext)

    companion object {
        var profile: String = "driving-traffic"
        var simulateRoute = false
        var zoom = 20.0
        var bearing = 0.0
        var tilt = 45.0
        var distanceRemaining: Double? = null
        var durationRemaining: Double? = null
        var animateBuildRoute = true
        var originPoint: Point? = null
        var destinationPoint: Point? = null
        var soleMarkerPoint: Point? = null
        var isRunning: Boolean = false

        var padding: IntArray = intArrayOf(300, 200, 30, 30)
        const val VIETMAP_ANDROID_AUTO_CHANNEL = "vn.vietmap.automotive/maps"
        const val VIETMAP_ANDROID_NAVIGATION_CHANNEL = "vn.vietmap.automotive/navigation"
    }

    fun initFlutterEngine(flutterEngine: FlutterEngine){
        this.flutterEngine = flutterEngine
        mapMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VIETMAP_ANDROID_AUTO_CHANNEL)
        navigationMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VIETMAP_ANDROID_NAVIGATION_CHANNEL)
    }

    private fun playVoiceAnnouncement(milestone: Milestone?) {
        if (milestone is VoiceInstructionMilestone) {
            val announcement = SpeechAnnouncement.builder()
                .voiceInstructionMilestone(milestone as VoiceInstructionMilestone?).build()
            speechPlayer!!.play(announcement)
        }
    }

    private fun configSpeechPlayer() {
        var speechPlayerProvider = SpeechPlayerProvider(carContext, "vi", true)
        this.speechPlayer = NavigationSpeechPlayer(speechPlayerProvider)
    }

    private var vietmapGL: VietMapGL? = null
    private var vietmapInfoWindowAdapter: VietMapGL.InfoWindowAdapter? = null


    private fun clearRoute() {
        if (navigationMapRoute != null) {
            navigationMapRoute?.removeRoute()
        }
        currentRoute = null
        invalidate()
    }
    
    private fun onStopNavigationFunction() {
        vietMapCarSurfaceHelper.refreshNavigationTemplate()
        navigation?.stopNavigation()
        navigationMapRoute?.removeRoute()
        isRunning = false
        currentRoute = null
        animateBuildRoute = true
        isNavigationInProgress = false
        isNavigationCanceled = true
        isOverviewing = true
        isNextTurnHandling = false
        tilt = 0.0
        zoom = 15.0
        bearing = 0.0
        vietmapGL?.locationComponent?.locationEngine = locationEngine
        moveCamera(
            LatLng(originPoint?.latitude() ?: 0.0, originPoint?.longitude() ?: 0.0),
            null
        )
        invalidate()
    }

    override fun stopNavigation() {
        isPreviewingRoute = false
        mapMethodChannel?.invokeMethod("stopNavigation", null)
        navigationMethodChannel?.invokeMethod("stopNavigation", null)
        onStopNavigationFunction()
        removeMarkers()
    }

    override fun setRoute(route: DirectionsRoute) {
        currentRoute = route
        isNavigationInProgress = true
    }

    override fun pushToSearchScreen() {
        mapMethodChannel?.invokeMethod("navigateToSearch", null)
        goToSearchScreen()
    }

    private fun goToSearchScreen() {
        val screenManager: ScreenManager =
            carContext.getCarService(ScreenManager::class.java)
        screenManager.pushForResult(VietMapSearchScreen(carContext), OnScreenResultListener {
                result ->
            if(result != null && result is PlaceDetail){
                Log.d("VietMapNavigationScreen", "PlaceDetail: $result")
                clearRoute()
                removeMarkers()

                val position = LatLng(result.lat, result.lng)
                val icon = IconFactory.getInstance(carContext).fromResource(vn.vietmap.services.android.navigation.ui.v5.R.drawable.vietmap_marker_icon_default)
                val markerOption = MarkerOptions().icon(icon).title(result.name).snippet(result.address).position(position)
                val marker = vietmapGL!!.addMarker(markerOption)
                addMarkersToMap(vietmapGL!!.markers.toList())
            }
        })
    }

    override fun startNavigation() {
        navigationMethodChannel?.invokeMethod("startNavigation", null)
        tilt = 45.0
        zoom = 19.0
        isOverviewing = false
        isNavigationCanceled = false
        vietmapGL?.locationComponent?.cameraMode = CameraMode.TRACKING_GPS_NORTH

        if (currentRoute != null) {
            if (simulateRoute) {
                val mockLocationEngine = ReplayRouteLocationEngine()
                mockLocationEngine.assign(currentRoute)
                navigation?.locationEngine = mockLocationEngine
            } else {
                locationEngine?.let {
                    navigation?.locationEngine = it
                }
            }
            isRunning = true
            vietmapGL?.locationComponent?.locationEngine = null
            navigation?.addNavigationEventListener(this)
            navigation?.addFasterRouteListener(this)
            navigation?.addMilestoneEventListener(this)
            navigation?.addOffRouteListener(this)
            navigation?.addProgressChangeListener(this)
            navigation?.snapEngine = snapEngine
            currentRoute?.let {
                isNavigationInProgress = true
                navigation?.startNavigation(currentRoute!!)
                vietMapCarSurfaceHelper.updateOnStartNavigationTemplate()
                invalidate()
                recenterFunc()
            }
        }
    }

    override fun overviewRoute() {
        navigationMethodChannel?.invokeMethod("overview", null)
        overviewRouteFunc()
    }

    private fun overviewRouteFunc() {
        isOverviewing = true
        if (currentRoute != null) {
            val routePoints: List<Point> =
                currentRoute?.routeOptions()?.coordinates() as List<Point>
            animateVietmapGLForRouteOverview(padding, routePoints)
        }
    }

    override fun initiateRouteFromMarker(startNavigation: Boolean) {
        val destinationMarker =  markers?.firstOrNull()
        val methodChannelParams = mapOf(
            "latitude" to destinationMarker?.position?.latitude,
            "longitude" to destinationMarker?.position?.longitude,
            "title" to destinationMarker?.title,
            "snippet" to destinationMarker?.snippet
        )
        if(startNavigation){
            mapMethodChannel?.invokeMethod("startNavigation", methodChannelParams)
        }
        else{
            mapMethodChannel?.invokeMethod("createRoute", methodChannelParams)
        }
        destinationPoint = Point.fromLngLat(soleMarkerPoint?.longitude() ?: 0.0, soleMarkerPoint?.latitude() ?: 0.0)
        animateBuildRoute = true
        fetchRouteWithBearing(startNavigation, profile)
    }

    override fun zoomIn() {
        vietmapGL?.animateCamera(CameraUpdateFactory.zoomIn())
    }

    override fun zoomOut() {
        vietmapGL?.animateCamera(CameraUpdateFactory.zoomBy(-1.0))
    }

    override fun recenter() {
        mapMethodChannel?.invokeMethod("recenter", null)
        navigationMethodChannel?.invokeMethod("recenter", null)
        recenterFunc()
    }

    private fun recenterFunc() {
        isOverviewing = false
        if (currentCenterPoint != null) {
            moveCamera(
                LatLng(currentCenterPoint!!.latitude, currentCenterPoint!!.longitude),
                currentCenterPoint!!.bearing
            )
        } else {
            vietmapGL?.locationComponent?.lastKnownLocation?.let {
                moveCamera(
                    LatLng(it.latitude, it.longitude),
                    it.bearing
                )
            }
        }
    }

    private fun finishNavigation(isOffRouted: Boolean = false) {
        zoom = 15.0
        bearing = 0.0
        tilt = 0.0
        isNavigationCanceled = true

        if (!isOffRouted) {
            isNavigationInProgress = false
        }

        if (currentRoute != null) {
            isRunning = false
            navigation?.stopNavigation()
            navigation?.removeFasterRouteListener(this)
            navigation?.removeMilestoneEventListener(this)
            navigation?.removeNavigationEventListener(this)
            navigation?.removeOffRouteListener(this)
            navigation?.removeProgressChangeListener(this)
        }
    }

    private val mSurfaceCallback: SurfaceCallback = object : SurfaceCallback {
        override fun onClick(x: Float, y: Float) {
            super.onClick(x, y)
            val clickedLatLng = vietmapGL?.projection?.fromScreenLocation(PointF(x, y))
            clickedLatLng?.let {
                navigationMapRoute?.onMapClick(it)
            }
            if(isRunning || isPreviewingRoute) return
            mapMethodChannel?.invokeMethod("stopNavigation", null)
            clearRoute()
            removeMarkers()
            val feature = vietmapGL?.queryRenderedFeatures(PointF(x, y))
            if (!feature.isNullOrEmpty() && feature.firstOrNull()
                    ?.getStringProperty("name") != null
            ) {
                feature.forEach {
                    val coordinates = it.geometry()?.let { geo ->
                        if (geo.type() == "Point") {
                            geo as Point
                        } else {
                            null
                        }
                    }
                    if (coordinates == null) {
                        return@forEach
                    }
                    val locationName = it.getStringProperty("name")
                    val locationPrefix = it.getStringProperty("prefix")

                    val position = LatLng(coordinates.latitude(), coordinates.longitude())
                    val icon = IconFactory.getInstance(carContext)
                        .fromResource(vn.vietmap.services.android.navigation.ui.v5.R.drawable.vietmap_marker_icon_default)
                    val markerOption = MarkerOptions().icon(icon).title(locationName).snippet(
                        "${locationPrefix ?: ""} ${locationName ?: ""}"
                    ).position(position)
                    vietmapGL!!.addMarker(markerOption)
                }
                if (vietmapGL!!.markers.isNotEmpty()) {
                    addMarkersToMap(vietmapGL!!.markers.toList())
                    mapMethodChannel?.invokeMethod(
                        "onFeatureClicked",
                        vietmapGL?.markers?.first()?.let {
                            mapOf(
                                "title" to it.title,
                                "snippet" to it.snippet,
                                "latitude" to it.position.latitude,
                                "longitude" to it.position.longitude
                            )
                        },
                    )
                }
            }
            if (vietmapGL!!.markers.isEmpty()) {
                vietMapCarSurfaceHelper.refreshNavigationTemplate()
                invalidate()
            }
        }

        override fun onScroll(distanceX: Float, distanceY: Float) {
            isOverviewing = true
            super.onScroll(distanceX, distanceY)
        }

        override fun onScale(focusX: Float, focusY: Float, scaleFactor: Float) {
            isOverviewing = true
            super.onScale(focusX, focusY, scaleFactor)
        }
    }

    init {
        lifecycle.addObserver(this)
        locationEngine = if (simulateRoute) {
            ReplayRouteLocationEngine()
        } else {
            LocationEngineProvider.getBestLocationEngine(carContext)
        }
        apikey = VietMapNavigationHelper.getApiKey(carContext)
        navigation = VietmapNavigation(
            carContext, navigationOptions, locationEngine!!
        )
        mSurfaceRenderer.addOnSurfaceCallbackListener(mSurfaceCallback)
        mSurfaceRenderer.init(
            Style.Builder()
                .fromUri("https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${apikey}"),
            {

                val routeLineLayer = LineLayer("line-layer-id", "source-id")
                routeLineLayer.setProperties(
                    lineWidth(9f),
                    lineColor(Color.RED),
                    lineCap(LINE_CAP_ROUND),
                    lineJoin(LINE_JOIN_ROUND)
                )
                it.addLayer(routeLineLayer)
                enableLocationComponent(it)

                initMapRoute()
            }, {
                vietmapGL = it
                vietmapInfoWindowAdapter = VietMapGL.InfoWindowAdapter {
                    m ->
                    m.infoWindow?.view
                }
                vietmapGL?.infoWindowAdapter = vietmapInfoWindowAdapter
                vietmapGL?.setOnMarkerClickListener {
                        m ->
                    Log.d("VietMapNavigationScreen", "Marker clicked: ${m.title}")
                    m.showInfoWindow(vietmapGL!!, mSurfaceRenderer.getMapView()!!)
                    true
                }
            }

        )
        try {
            configSpeechPlayer()
        } catch (e: Exception) {
            Log.e("VietMapNavigationScreen", e.message.toString())
        }
    }

    private fun initMapRoute() {
        if (vietmapGL != null) {
            navigationMapRoute =
                NavigationMapRoute(
                    mSurfaceRenderer.getMapView()!!,
                    vietmapGL!!,
                    "vmadmin_province"
                )
        }

        navigationMapRoute?.setOnRouteSelectionChangeListener {
            routeClicked = true

            currentRoute = it

            val routePoints: List<Point> =
                currentRoute?.routeOptions()?.coordinates() as List<Point>
            animateVietmapGLForRouteOverview(padding, routePoints)
            primaryRouteIndex = try {
                it.routeIndex()?.toInt() ?: 0
            } catch (e: Exception) {
                0
            }
            if (isRunning) {
                finishNavigation(isOffRouted = true)
                startNavigation()
            }
        }

    }

    @SuppressLint("MissingPermission")
    private fun enableLocationComponent(loadedMapStyle: Style) {
        val customLocationComponentOptions =
            LocationComponentOptions.builder(carContext).pulseEnabled(true)
                .maxZoomIconScale(2.5f)
                .minZoomIconScale(2.0f)
                .padding(intArrayOf(300, 0, 0, 0))
//                .backgroundDrawable()
                /// If you want to customize the Location icon, you can set a custom drawable here
                .build()
        vietmapGL?.locationComponent?.let { locationComponent ->
            locationComponent.activateLocationComponent(
                LocationComponentActivationOptions.builder(carContext, loadedMapStyle)
                    .locationComponentOptions(customLocationComponentOptions)
                    .locationEngine(locationEngine).build()
            )

            locationComponent.setCameraMode(
                CameraMode.TRACKING_GPS_NORTH,
                750L,
                zoom,
                locationComponent.lastKnownLocation?.bearing?.toDouble() ?: 0.0,
                tilt,
                null
            )
            locationComponent.zoomWhileTracking(18.0)
            locationComponent.renderMode = RenderMode.GPS

            /// set custom icon

            locationComponent.locationEngine = locationEngine

            if (!simulateRoute) {
                locationComponent.isLocationComponentEnabled = true
            }
        }
        invalidate()

    }

    private fun updateRoutingInfo(distanceToNextTurn: Double) {
        vietMapCarSurfaceHelper.updateRoutingInfo(distanceToNextTurn)
        invalidate()
    }

    private fun updateStep(cueGuide: String) {
        vietMapCarSurfaceHelper.updateStep(cueGuide)
        invalidate()
    }


    // Update turn icon guide for next turn
    private fun updateManeuver() {
        vietMapCarSurfaceHelper.updateManeuver(routeProgress)
        invalidate()
    }

    // Update to give options to preview route or start navigation
    private fun updateOnSingleMarkerChosen() {
        vietMapCarSurfaceHelper.updateOnSingleMarkerChosen()
        invalidate()
    }

    // DistanceEstimate: meters
    // DurationEstimate: minutes
    @RequiresApi(Build.VERSION_CODES.O)
    fun updateTravelEstimate(
        distanceEstimate: Double,
        durationEstimate: Long,
        descriptionText: String,
    ) {
        vietMapCarSurfaceHelper.updateTravelEstimate(
            distanceEstimate,
            durationEstimate,
            descriptionText
        )
        invalidate()
    }


    @RequiresApi(Build.VERSION_CODES.O)
    @SuppressLint("MissingPermission")
    override fun onGetTemplate(): Template {
        return vietMapCarSurfaceHelper.getDesignatedTemplate()
    }

    private fun getRoute(
        isStartNavigation: Boolean, bearing: Float?, profile: String,
    ) {

        val br = bearing ?: 0.0
        val builder = NavigationRoute.builder(carContext)
            .apikey(apikey ?: VietMapNavigationHelper.getApiKey(carContext))
            .origin(originPoint!!, 60.0, br.toDouble()).destination(destinationPoint!!)
            .alternatives(true)
            ///driving-traffic
            ///cycling
            ///walking
            ///motorcycle
            .profile(profile).build()
        builder.getRoute(object : Callback<DirectionsResponse> {
            override fun onResponse(
                call: Call<DirectionsResponse?>, response: Response<DirectionsResponse?>,
            ) {
                if (response.body() == null || response.body()!!.routes().size < 1) {
                    return
                }
                directionsRoutes = response.body()!!.routes()
                currentRoute = if (directionsRoutes!!.size <= primaryRouteIndex) {
                    directionsRoutes!![0]
                } else {
                    directionsRoutes!![primaryRouteIndex]
                }

                // Draw the route on the map
                if (navigationMapRoute != null) {
                    navigationMapRoute?.removeRoute()
                } else {
                    navigationMapRoute = NavigationMapRoute(
                        mSurfaceRenderer.getMapView()!!,
                        vietmapGL!!,
                        "vmadmin_province"
                    )
                }

                //show multiple route to map
                if (response.body()!!.routes().size > 1) {
                    navigationMapRoute?.let{
                        it.addRoutes(directionsRoutes!!)
                        it.showAlternativeRoutes(true)
                    }
                } else {
                    navigationMapRoute?.addRoute(currentRoute)
                }


                isBuildingRoute = false
                // get route point from current route
                val routePoints: List<Point> =
                    currentRoute?.routeOptions()?.coordinates() as List<Point>
                animateVietmapGLForRouteOverview(padding, routePoints)
                vietMapCarSurfaceHelper.updateOnRouteBuiltTemplate(
                    directionsRoutes ?: emptyList(),
                ){

                }
                invalidate()
                //Start Navigation again from new Point, if it was already in Progress
                if (isNavigationInProgress || isStartNavigation) {
                    startNavigation()
                }
            }

            override fun onFailure(call: Call<DirectionsResponse?>, throwable: Throwable) {
                isBuildingRoute = false

            }
        })
    }

    private fun animateVietmapGLForRouteOverview(padding: IntArray, routePoints: List<Point>) {
        isOverviewing = true
        if (routePoints.size <= 1) {
            return
        }
        val resetUpdate: CameraUpdate = VietMapNavigationHelper.buildResetCameraUpdate()
        val overviewUpdate: CameraUpdate =
            VietMapNavigationHelper.buildOverviewCameraUpdate(padding, routePoints)
        vietmapGL?.animateCamera(
            resetUpdate, 150, CameraOverviewCancelableCallback(overviewUpdate, vietmapGL)
        )
    }

    override fun willDisplay(instructions: BannerInstructions?): BannerInstructions {
        return instructions!!
    }

    override fun onCancelNavigation() {
        navigation?.stopNavigation()
        isRunning = false
    }

    override fun onNavigationFinished() {
        vietmapGL?.locationComponent?.locationEngine = locationEngine
    }

    override fun onNavigationRunning() {
    }

    override fun allowRerouteFrom(offRoutePoint: Point?): Boolean {
        return true
    }

    override fun onOffRoute(offRoutePoint: Point?) {
        doOnNewRoute(offRoutePoint)
    }

    override fun onRerouteAlong(directionsRoute: DirectionsRoute?) {

        refreshNavigation(directionsRoute)
    }

    private fun refreshNavigation(directionsRoute: DirectionsRoute?, shouldCancel: Boolean = true) {
        directionsRoute?.let {

            if (shouldCancel) {

                currentRoute = directionsRoute
                finishNavigation()
                startNavigation()
            }
        }
    }

    override fun onFailedReroute(errorMessage: String?) {
    }

    override fun onArrival() {

        vietmapGL?.locationComponent?.locationEngine = locationEngine
        vietMapCarSurfaceHelper.refreshNavigationTemplate()
        invalidate()
    }

    override fun willVoice(announcement: SpeechAnnouncement?): SpeechAnnouncement {
        return announcement!!
    }

    override fun onMilestoneEvent(
        routeProgress: RouteProgress?,
        instruction: String?,
        milestone: Milestone?,
    ) {
//        playVoiceAnnouncement(milestone)
    }

    override fun onRunning(running: Boolean) {
    }

    override fun userOffRoute(location: Location) {
        if (checkIfUserOffRoute(location)) {
            speechPlayer?.onOffRoute()
            doOnNewRoute(Point.fromLngLat(location.longitude, location.latitude))
        }
    }

    private fun checkIfUserOffRoute(location: Location): Boolean {
        if (routeProgress?.currentStepPoints() != null) {
            val snapLocation: Location = snapEngine.getSnappedLocation(location, routeProgress)
            val distance: Double =
                VietMapNavigationHelper.calculateDistanceBetween2Point(location, snapLocation)
            return distance > this.distanceToOffRoute && checkIfUserIsDrivingToOtherRoute(location)
//                && areBearingsClose(
//            location.bearing.toDouble(), snapLocation.bearing.toDouble()
//        )
        }
        return false
    }

    private fun checkIfUserIsDrivingToOtherRoute(location: Location): Boolean {
        directionsRoutes?.forEach {
            //get list point
            snapLocationLatLng(
                location,
                it.routeOptions()?.coordinates() as List<Point>
            )?.let { snapLocation ->
                val distance: Double =
                    VietMapNavigationHelper.calculateDistanceBetween2Point(location, snapLocation)
                if (distance < 30) {
                    if (it != currentRoute) {
                        currentRoute = it
                    }

                }
            }
        }
        return true
    }


    private fun snapLocationLatLng(location: Location, stepCoordinates: List<Point>): Location? {
        val snappedLocation = Location(location)
        val locationToPoint = Point.fromLngLat(location.longitude, location.latitude)
        if (stepCoordinates.size > 1) {
            val feature = TurfMisc.nearestPointOnLine(locationToPoint, stepCoordinates)
            val point = feature.geometry() as Point?
            snappedLocation.longitude = point!!.longitude()
            snappedLocation.latitude = point.latitude()
        }
        return snappedLocation
    }


    override fun fasterRouteFound(directionsRoute: DirectionsRoute?) {
    }

    private fun doOnNewRoute(offRoutePoint: Point?) {
        if (!isBuildingRoute) {
            isBuildingRoute = true

            offRoutePoint?.let {

                finishNavigation(isOffRouted = true)
                // println("MoveCamera3")

                moveCamera(LatLng(it.latitude(), it.longitude()), null)
            }


            originPoint = offRoutePoint
            isNavigationInProgress = true
            fetchRouteWithBearing(false, profile)
        }
    }

    @SuppressLint("MissingPermission")
    private fun fetchRouteWithBearing(isStartNavigation: Boolean, profile: String) {
        isPreviewingRoute = true
        locationEngine?.getLastLocation(object : LocationEngineCallback<LocationEngineResult> {
            override fun onSuccess(result: LocationEngineResult) {

                val location = result.lastLocation
                location?.let {
                    originPoint = Point.fromLngLat(it.longitude, it.latitude)
                }
                if (location != null) {
                    getRoute(isStartNavigation, location.bearing, profile)
                } else {
                    getRoute(isStartNavigation, null, profile)
                }
            }

            override fun onFailure(exception: Exception) {
                getRoute(isStartNavigation, null, profile)
            }
        })
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onProgressChange(location: Location?, routeProgress: RouteProgress?) {

        var currentSpeed = location?.speed
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            currentSpeed = location?.speedAccuracyMetersPerSecond
        }
        if (!isNavigationCanceled) {
            try {
                val noRoutes: Boolean = directionsRoutes?.isEmpty() ?: true
                if (primaryRouteIndex >= (directionsRoutes?.size ?: 0)) {
                    primaryRouteIndex = directionsRoutes?.size?.minus(1) ?: 0
                }
                val newCurrentRoute: Boolean = !routeProgress!!.directionsRoute()
                    .equals(directionsRoutes?.get(primaryRouteIndex))
                val isANewRoute: Boolean = noRoutes || newCurrentRoute
                if (!isANewRoute) {
                    distanceRemaining = routeProgress.distanceRemaining()
                    durationRemaining = routeProgress.durationRemaining()

                    if (!isDisposed && !isBuildingRoute) {
                        val snappedLocation: Location =
                            snapEngine.getSnappedLocation(location, routeProgress)

                        currentCenterPoint =
                            CurrentCenterPoint(
                                snappedLocation.latitude,
                                snappedLocation.longitude,
                                snappedLocation.bearing
                            )
                        if (!isOverviewing) {
                            this.routeProgress = routeProgress
                            if (currentSpeed!! > 0) {
                                animateBuildRoute = false
                                moveCamera(
                                    LatLng(snappedLocation.latitude, snappedLocation.longitude),
                                    snappedLocation.bearing
                                )
                            }
                        }

                        vietmapGL?.locationComponent?.forceLocationUpdate(snappedLocation)
                    }

                    //                    if (simulateRoute && !isDisposed && !isBuildingRoute) {
                    //                        vietmapGL?.locationComponent?.forceLocationUpdate(location)
                    //                    }

                    if (!isRefreshing) {
                        isRefreshing = true
                    }
                }

                handleProgressChange(routeProgress, location!!)
            } catch (e: java.lang.Exception) {
                Log.e("onProgressChange", e.message.toString())
                e.printStackTrace()
            }
        }
    }

    private fun moveCamera(location: LatLng, bearing: Float?) {
        val cameraPosition = CameraPosition.Builder().target(location).zoom(zoom).tilt(tilt)

        if (bearing != null) {
            cameraPosition.bearing(bearing.toDouble())
        }

        var duration = 1000
        if (!animateBuildRoute) duration = 3000
        vietmapGL?.easeCamera(
            CameraUpdateFactory.newCameraPosition(cameraPosition.build()), duration
        )
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun handleProgressChange(routeProgress: RouteProgress, location: Location) {
        // println("handleProgressChange")
        if (location.speed < 1) return
        // println("start handleProgressChange")

        val distanceRemainingToNextTurn =
            routeProgress.currentLegProgress()?.currentStepProgress()?.distanceRemaining()
        val turnGuideText: String =
            routeProgress.currentLegProgress()?.currentStep()?.maneuver()?.instruction().toString()

        val distanceToNextTurn =
            routeProgress.currentLegProgress()?.currentStepProgress()?.distanceRemaining().let {
                if (it != null) {
                    round(it)
                } else {
                    0.0
                }
            }
        val distanceEstimate = round(routeProgress.distanceRemaining())
        val durationEstimate = round(routeProgress.durationRemaining())
        val durationRemaining = round(routeProgress.durationRemaining())
        updateTravelEstimate(
            distanceEstimate,
            durationEstimate.toLong(),
            "Còn ${VietMapNavigationHelper.getDisplayDuration(durationRemaining / 60)}"
        )
        updateManeuver()
        updateStep(turnGuideText)

        updateRoutingInfo(distanceToNextTurn)
        if (isOverviewing) return
        if (distanceRemainingToNextTurn != null && distanceRemainingToNextTurn < 30) {
            isNextTurnHandling = true
            val resetPosition: CameraPosition =
                CameraPosition.Builder().tilt(tilt).zoom(17.0).bearing(bearing).build()
            val cameraUpdate = CameraUpdateFactory.newCameraPosition(resetPosition)
            vietmapGL?.animateCamera(
                cameraUpdate, 1000
            )
        } else {
            if (routeProgress.currentLegProgress().currentStepProgress()
                    .distanceTraveled() > 30 && !isOverviewing
            ) {
                isNextTurnHandling = false
            }
        }
    }

    private fun removeMarkers() {
        markers?.forEach {
            vietmapGL?.removeMarker(it)
        }
        markers = null
    }


    @SuppressLint("MissingPermission")
    override fun getDistanceToLocation(
        methodCall: MethodCall,
        result: MethodChannel.Result
    ) {
        val args = methodCall.arguments as Map<*, *>
        val lat = args["latitude"] as Double?
        val lng = args["longitude"] as Double?
        val destination = Location("destination").apply {
            latitude = lat ?: 0.0
            longitude = lng ?: 0.0
        }
        if(originPoint?.latitude() == null || originPoint?.longitude() == null){
            locationEngine?.getLastLocation(
                object : LocationEngineCallback<LocationEngineResult> {
                    override fun onSuccess(locationResult: LocationEngineResult) {
                        val location = locationResult.lastLocation
                        originPoint = Point.fromLngLat(location?.longitude ?: 0.0  , location?.latitude ?: 0.0)
                        val distanceInMeters = VietMapNavigationHelper.calculateDistanceBetween2Point(
                            Location("origin").apply {
                                latitude = originPoint?.latitude() ?: 0.0
                                longitude = originPoint?.longitude() ?: 0.0
                            },
                            destination
                        )
                        result.success(distanceInMeters/1000)
                    }

                    override fun onFailure(exception: Exception) {
                        result.success(0.0)
                    }
                }
            )
            return
        }
        val distanceInMeters = VietMapNavigationHelper.calculateDistanceBetween2Point(
            Location("origin").apply {
                latitude = originPoint?.latitude() ?: 0.0
                longitude = originPoint?.longitude() ?: 0.0
            },
            destination
        )
        result.success(distanceInMeters/1000)
    }

    override fun navigateToSearch(result: MethodChannel.Result) {
        goToSearchScreen()
        result.success(true)
    }

    override fun removeRoutes(result: MethodChannel.Result) {
        clearRoute()
        removeMarkers()
        vietMapCarSurfaceHelper.refreshNavigationTemplate()
        result.success(true)
    }

    @SuppressLint("MissingPermission")
    override fun addMarkers(call: MethodCall, result: MethodChannel.Result) {
        removeMarkers()
        val data = call.arguments as List<Map<*,*>>
        val listMarkerId = ArrayList<Long>()
        try {
            data.forEach {
                val markerData = it
                val position = LatLng(markerData["latitude"] as Double, markerData["longitude"] as Double)
                val icon = IconFactory.getInstance(carContext).fromResource(vn.vietmap.services.android.navigation.ui.v5.R.drawable.vietmap_marker_icon_default)
                val markerOption = MarkerOptions().icon(icon).title((markerData["title"] ?: "") as String)
                    .snippet((markerData["snippet"] ?: "") as String).position(position)

                val marker: Marker = vietmapGL!!.addMarker(markerOption)

                listMarkerId.add(marker.id)
            }
            addMarkersToMap(vietmapGL!!.markers.toList(), onSuccessCallback = {
                result.success(listMarkerId)
            }, onFailureCallback = {
                result.success(listMarkerId)
            })
        }catch(e: Exception){
            e.printStackTrace()
            result.success(listMarkerId)
        }
    }

    override fun onStartNavigation(call: MethodCall, result: MethodChannel.Result) {
        destinationPoint = Point.fromLngLat(soleMarkerPoint?.longitude() ?: 0.0, soleMarkerPoint?.latitude() ?: 0.0)
        fetchRouteWithBearing(true, profile)
        result.success(true)
    }

    override fun onCreateRoute(result: MethodChannel.Result) {
        destinationPoint = Point.fromLngLat(soleMarkerPoint?.longitude() ?: 0.0, soleMarkerPoint?.latitude() ?: 0.0)
        animateBuildRoute = true
        fetchRouteWithBearing(false, profile)
        result.success(true)
    }

    @SuppressLint("MissingPermission")
    override fun onStopNavigation(result: MethodChannel.Result) {
        isPreviewingRoute = false
        onStopNavigationFunction()
        result.success(true)
    }

    @SuppressLint("MissingPermission")
    override fun onCancelNavigation(result: MethodChannel.Result) {
        vietMapCarSurfaceHelper.updateOnRouteBuiltTemplate(
            directionsRoutes ?: emptyList()
        ){

        }
        navigation?.stopNavigation()
        isRunning = false
        isNavigationInProgress = false
        isNavigationCanceled = true
        isOverviewing = true
        isNextTurnHandling = false
        tilt = 0.0
        zoom = 15.0
        bearing = 0.0
        vietmapGL?.locationComponent?.locationEngine = locationEngine
        moveCamera(
            LatLng(originPoint?.latitude() ?: 0.0, originPoint?.longitude() ?: 0.0),
            null
        )
        invalidate()
        result.success(true)
    }

    override fun onRecenter() {
        recenterFunc()
    }

    override fun onOverview() {
        overviewRouteFunc()
    }

    @SuppressLint("MissingPermission")
    private fun addMarkersToMap(markerList: List<Marker>,
                                onSuccessCallback: (() -> Unit)? = null,
                                onFailureCallback: (() -> Unit)? = null
    ){
        val coordinatesList = ArrayList<Point>()
        for (marker in markerList){
            val position = LatLng(marker.position.latitude, marker.position.longitude)
            coordinatesList.add(Point.fromLngLat(position.longitude, position.latitude))
        }
        vietmapGL?.locationComponent?.locationEngine?.getLastLocation(
            object : LocationEngineCallback<LocationEngineResult> {
                override fun onSuccess(locationResult: LocationEngineResult) {
                    val location = locationResult.lastLocation
                    if (location != null) {
                        markers = markerList.toList()
                        coordinatesList.add(0, Point.fromLngLat(location.longitude, location.latitude))
                        animateVietmapGLForRouteOverview(padding, coordinatesList)
                    }
                    onSuccessCallback?.invoke()
                }
                override fun onFailure(exception: Exception) {
                    onFailureCallback?.invoke()
                }
            }
        )
        if(markerList.size == 1){
            val marker = markerList.first()
            soleMarkerPoint = Point.fromLngLat(marker.position.longitude, marker.position.latitude)
            updateOnSingleMarkerChosen()
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    fun onDestroy() {
        mapMethodChannel = null
    }
}