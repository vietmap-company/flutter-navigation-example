package vn.vietmap.androidauto.helper

import vn.vietmap.androidauto.R
import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.car.app.model.Action
import androidx.car.app.model.ActionStrip
import androidx.car.app.model.CarColor
import androidx.car.app.model.CarIcon
import androidx.car.app.model.CarText
import androidx.car.app.model.DateTimeWithZone
import androidx.car.app.navigation.model.Maneuver
import androidx.car.app.navigation.model.NavigationTemplate
import androidx.car.app.navigation.model.RoutingInfo
import androidx.car.app.navigation.model.Step
import androidx.car.app.navigation.model.TravelEstimate
import androidx.core.graphics.drawable.IconCompat
import com.mapbox.api.directions.v5.models.BannerInstructions
import vn.vietmap.androidauto.vm_interface.IVietMapCarMapController
import vn.vietmap.services.android.navigation.v5.routeprogress.RouteProgress
import java.time.Duration
import java.time.ZonedDateTime

class VietMapCarSurfaceHelper(
    private var behaviorHandler: IVietMapCarMapController,
    private var carContext: Context,
) {

    private var actionStripBuilder = ActionStrip.Builder()
    var navigationTemplateBuilder = NavigationTemplate.Builder()
    private var travelEstimate: TravelEstimate.Builder? = null
    private var maneuver: Maneuver.Builder? = null
    private var step: Step.Builder? = null
    private var routingInfo: RoutingInfo.Builder? = null

    init {
        initNavigationTemplate()
    }

    fun refreshNavigationTemplate() {
        navigationTemplateBuilder = NavigationTemplate.Builder()
        initNavigationTemplate()
    }

    fun initNavigationTemplate() {
//        navigationTemplateBuilder = NavigationTemplate.Builder()
        navigationTemplateBuilder.setBackgroundColor(CarColor.DEFAULT)
        actionStripBuilder = ActionStrip.Builder()
        actionStripBuilder.addAction(
            Action.Builder()
                .setIcon(
                    CarIcon.Builder(
                        IconCompat.createWithResource(
                            carContext,
                            R.drawable.baseline_search_24
                        )
                    ).build()
                )
                .setOnClickListener {
                    // Push to search screen
                    behaviorHandler.pushToSearchScreen()
                }
                .build()

        )
        val panIconBuilder = CarIcon.Builder(
            IconCompat.createWithResource(
                carContext,
                R.drawable.minus
            )
        )
        navigationTemplateBuilder.setMapActionStrip(
            ActionStrip.Builder()
                .addAction(
                    Action.Builder(Action.PAN)
                        .setIcon(panIconBuilder.build())
                        .build()
                )
                .addAction(
                    Action.Builder()
                        .setIcon(
                            CarIcon.Builder(
                                IconCompat.createWithResource(
                                    carContext,
                                    R.drawable.add
                                )
                            )
                                .build()
                        )
                        .setOnClickListener {
                            behaviorHandler.zoomIn()
                        }
                        .build())
                .addAction(
                    Action.Builder()
                        .setIcon(
                            CarIcon.Builder(
                                IconCompat.createWithResource(
                                    carContext,
                                    R.drawable.minus
                                )
                            )
                                .build()
                        )
                        .setOnClickListener {
                            behaviorHandler.zoomOut()
                        }
                        .build())
                .build())
        navigationTemplateBuilder.setActionStrip(actionStripBuilder.build())
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun updateTravelEstimate(
        distanceEstimate: Double,
        durationEstimate: Long,
        descriptionText: String,
    ) {
        travelEstimate = TravelEstimate.Builder(
            VietMapNavigationHelper.getDisplayDistance(distanceEstimate),
            DateTimeWithZone.create(
                ZonedDateTime.now().plusSeconds(durationEstimate)
            )
        )
        travelEstimate?.setRemainingTime(Duration.ofMinutes(durationEstimate))
        travelEstimate?.setTripText(CarText.create(descriptionText))
        travelEstimate?.build()?.let {
            navigationTemplateBuilder.setDestinationTravelEstimate(
                it
            )
        }
    }

    fun updateManeuver(routeProgress: RouteProgress?) {
        val maneuverType = getManeuver(routeProgress)
        if (maneuverType.isEmpty()) return
        maneuver = Maneuver.Builder(Maneuver.TYPE_TURN_NORMAL_RIGHT)
            .setIcon(
                CarIcon.Builder(
                    IconCompat.createWithResource(
                        carContext,
                        VietMapNavigationHelper.getDrawableResId(maneuverType)
                    )
                ).build()
            )
    }

    private fun getManeuver(routeProgress: RouteProgress?): String {
        val bannerInstructionsList: List<BannerInstructions>? =
            routeProgress?.currentLegProgress()?.currentStep()?.bannerInstructions()
        if (bannerInstructionsList?.isEmpty() == true) return ""
        val currentModifier = bannerInstructionsList?.get(0)?.primary()?.modifier()
        val currentModifierType = bannerInstructionsList?.get(0)?.primary()?.type()
        return listOf(currentModifierType, currentModifier).joinToString("_").replace(" ", "_")
    }

    fun updateOnStartNavigationTemplate() {
        actionStripBuilder = ActionStrip.Builder()
        // Set the action strip.
        actionStripBuilder.addAction(
            Action.Builder()
                .setTitle("Thoát")
                .setOnClickListener {
                    behaviorHandler.stopNavigation()
                }
                .build()
        )

        actionStripBuilder.addAction(
            Action.Builder()
                .setIcon(
                    CarIcon.Builder(
                        IconCompat.createWithResource(
                            carContext,
                            R.drawable.overview_route
                        )
                    ).build()
                )
                .setOnClickListener {
                    behaviorHandler.overviewRoute()
                }
                .build()
        )

        actionStripBuilder.addAction(
            Action.Builder()
                .setIcon(
                    CarIcon.Builder(
                        IconCompat.createWithResource(
                            carContext,
                            R.drawable.recenter
                        )
                    ).build()
                )
                .setOnClickListener {
                    behaviorHandler.recenter()
                }
                .build()
        )

        navigationTemplateBuilder.setActionStrip(actionStripBuilder.build())

        // Set the map action strip with the pan and zoom buttons.
        val panIconBuilder = CarIcon.Builder(
            IconCompat.createWithResource(
                carContext,
                R.drawable.minus
            )
        )
        navigationTemplateBuilder.setMapActionStrip(
            ActionStrip.Builder()
                .addAction(
                    Action.Builder(Action.PAN)
                        .setIcon(panIconBuilder.build())
                        .build()
                )
                .addAction(
                    Action.Builder()
                        .setIcon(
                            CarIcon.Builder(
                                IconCompat.createWithResource(
                                    carContext,
                                    R.drawable.add
                                )
                            )
                                .build()
                        )
                        .setOnClickListener {
                            behaviorHandler.zoomIn()
                        }
                        .build())
                .addAction(
                    Action.Builder()
                        .setIcon(
                            CarIcon.Builder(
                                IconCompat.createWithResource(
                                    carContext,
                                    R.drawable.minus
                                )
                            )
                                .build()
                        )
                        .setOnClickListener {
                            behaviorHandler.zoomOut()
                        }
                        .build())
                .build())
    }

    fun updateOnSingleMarkerChosen() {
        actionStripBuilder = ActionStrip.Builder()

        actionStripBuilder.addAction(
            Action.Builder()
                .setTitle("Chỉ đường")
                .setOnClickListener {
                    behaviorHandler.initiateRouteFromMarker(false)
                }
                .build()
        )
        actionStripBuilder.addAction(
            Action.Builder()
                .setTitle("Di chuyển")
                .setOnClickListener {
                    behaviorHandler.initiateRouteFromMarker(true)
                }
                .build()
        )
        actionStripBuilder.addAction(
            Action.Builder()
                .setIcon(
                    CarIcon.Builder(
                        IconCompat.createWithResource(
                            carContext,
                            R.drawable.recenter
                        )
                    ).build()
                )
                .setOnClickListener {
                    behaviorHandler.recenter()
                }
                .build()
        )

        actionStripBuilder.addAction(
            Action.Builder()
                .setIcon(
                    CarIcon.Builder(
                        IconCompat.createWithResource(
                            carContext,
                            R.drawable.close
                        )
                    ).build()
                )
                .setOnClickListener {
                    behaviorHandler.stopNavigation()
                }
                .build()
        )


        navigationTemplateBuilder.setActionStrip(actionStripBuilder.build())

        // Set the map action strip with the pan and zoom buttons.
        val panIconBuilder = CarIcon.Builder(
            IconCompat.createWithResource(
                carContext,
                R.drawable.minus
            )
        )

        navigationTemplateBuilder.setMapActionStrip(
            ActionStrip.Builder()
                .addAction(
                    Action.Builder(Action.PAN)
                        .setIcon(panIconBuilder.build())
                        .build()
                )
                .addAction(
                    Action.Builder()
                        .setIcon(
                            CarIcon.Builder(
                                IconCompat.createWithResource(
                                    carContext,
                                    R.drawable.add
                                )
                            )
                                .build()
                        )
                        .setOnClickListener {
                            behaviorHandler.zoomIn()
                        }
                        .build())
                .addAction(
                    Action.Builder()
                        .setIcon(
                            CarIcon.Builder(
                                IconCompat.createWithResource(
                                    carContext,
                                    R.drawable.minus
                                )
                            )
                                .build()
                        )
                        .setOnClickListener {
                            behaviorHandler.zoomOut()
                        }
                        .build())
                .build())

    }

    fun updateOnRouteBuiltTemplate() {
        actionStripBuilder = ActionStrip.Builder()
        // Set the action strip.
        actionStripBuilder.addAction(
            Action.Builder()
                .setTitle("Bắt đầu")
                .setOnClickListener {
                    behaviorHandler.startNavigation()
                }
                .build()
        )

        actionStripBuilder.addAction(
            Action.Builder()
                .setIcon(
                    CarIcon.Builder(
                        IconCompat.createWithResource(
                            carContext,
                            R.drawable.overview_route
                        )
                    ).build()
                )
                .setOnClickListener {
                    behaviorHandler.overviewRoute()
                }
                .build()

        )

        actionStripBuilder.addAction(
            Action.Builder()
                .setIcon(
                    CarIcon.Builder(
                        IconCompat.createWithResource(
                            carContext,
                            R.drawable.recenter
                        )
                    ).build()
                )
                .setOnClickListener {
                    behaviorHandler.recenter()
                }
                .build()

        )


        actionStripBuilder.addAction(
            Action.Builder()
                .setIcon(
                    CarIcon.Builder(
                        IconCompat.createWithResource(
                            carContext,
                            R.drawable.close
                        )
                    ).build()
                )
                .setOnClickListener {
                    behaviorHandler.stopNavigation()
                }
                .build()
        )
        navigationTemplateBuilder.setActionStrip(actionStripBuilder.build())

        // Set the map action strip with the pan and zoom buttons.
        val panIconBuilder = CarIcon.Builder(
            IconCompat.createWithResource(
                carContext,
                R.drawable.minus
            )
        )
        navigationTemplateBuilder.setMapActionStrip(
            ActionStrip.Builder()
                .addAction(
                    Action.Builder(Action.PAN)
                        .setIcon(panIconBuilder.build())
                        .build()
                )
                .addAction(
                    Action.Builder()
                        .setIcon(
                            CarIcon.Builder(
                                IconCompat.createWithResource(
                                    carContext,
                                    R.drawable.add
                                )
                            )
                                .build()
                        )
                        .setOnClickListener {
                            behaviorHandler.zoomIn()
                        }
                        .build())
                .addAction(
                    Action.Builder()
                        .setIcon(
                            CarIcon.Builder(
                                IconCompat.createWithResource(
                                    carContext,
                                    R.drawable.minus
                                )
                            )
                                .build()
                        )
                        .setOnClickListener {
                            behaviorHandler.zoomOut()
                        }
                        .build())
                .build())
    }

    fun updateStep(cueGuide: String) {
        step = maneuver?.let {
            Step.Builder()
                .setManeuver(it.build())
                .setCue(cueGuide)
        }

    }

    fun updateRoutingInfo(distanceToNextTurn: Double) {
        routingInfo = step?.let {
            RoutingInfo.Builder()
                .setLoading(false)
                .setCurrentStep(
                    it.build(),
                    VietMapNavigationHelper.getDisplayDistance(distanceToNextTurn)
                )
        }

        routingInfo?.let {
            navigationTemplateBuilder.setNavigationInfo(
                it.build()
            )
        }
    }
}