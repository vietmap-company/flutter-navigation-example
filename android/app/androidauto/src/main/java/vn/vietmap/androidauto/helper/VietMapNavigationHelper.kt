package vn.vietmap.androidauto.helper

import android.content.res.AssetManager
import android.location.Location
import androidx.car.app.CarContext
import androidx.car.app.model.Distance
import androidx.core.content.ContextCompat.getString
import com.mapbox.geojson.Point
import vn.vietmap.androidauto.R
import vn.vietmap.vietmapsdk.camera.CameraPosition
import vn.vietmap.vietmapsdk.camera.CameraUpdate
import vn.vietmap.vietmapsdk.camera.CameraUpdateFactory
import vn.vietmap.vietmapsdk.camera.CameraUpdateFactory.newLatLngBounds
import vn.vietmap.vietmapsdk.geometry.LatLng
import vn.vietmap.vietmapsdk.geometry.LatLngBounds
import java.io.File
import java.util.Locale
import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt


class VietMapNavigationHelper {
    companion object {
        var apiKey = ""
        fun getApiKey(carContext: CarContext): String {
            try {
                apiKey = getString(carContext, vn.vietmap.androidauto.R.string.vietmap_api_key)
                return getString(carContext, vn.vietmap.androidauto.R.string.vietmap_api_key)
            }catch (e: Exception){
                throw Throwable( "Create a string resource with the name 'vietmap_api_key' in your vietmap_api_key.xml file. Follow the instructions in the README.md file.")
            }
        }


        fun buildResetCameraUpdate(): CameraUpdate {
            val resetPosition: CameraPosition =
                CameraPosition.Builder().tilt(0.0).bearing(0.0).build()
            return CameraUpdateFactory.newCameraPosition(resetPosition)
        }

        fun buildOverviewCameraUpdate(
            padding: IntArray, routePoints: List<Point>,
        ): CameraUpdate {
            if(routePoints.size < 2) return buildResetCameraUpdate()
            val routeBounds = convertRoutePointsToLatLngBounds(routePoints)
            return newLatLngBounds(
                routeBounds, padding[0], padding[1], padding[2], padding[3]
            )
        }

        private fun convertRoutePointsToLatLngBounds(routePoints: List<Point>): LatLngBounds {
            val latLngs: MutableList<LatLng> = java.util.ArrayList()
            for (routePoint in routePoints) {
                latLngs.add(LatLng(routePoint.latitude(), routePoint.longitude()))
            }
            return LatLngBounds.Builder().includes(latLngs).build()
        }

        fun calculateDistanceBetween2Point(location1: Location, location2: Location): Double {
            val radius = 6371000.0 // meters

            val dLat = (location2.latitude - location1.latitude) * PI / 180.0
            val dLon = (location2.longitude - location1.longitude) * PI / 180.0

            val a =
                sin(dLat / 2.0) * sin(dLat / 2.0) + cos(location1.latitude * PI / 180.0) * cos(
                    location2.latitude * PI / 180.0
                ) * sin(
                    dLon / 2.0
                ) * sin(dLon / 2.0)
            val c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a))

            return radius * c
        }

        fun snapLocationToClosestLatLng(targetLocation: LatLng, latLngList: List<LatLng>): LatLng? {
            var closestLatLng: LatLng? = null
            var closestDistance = Double.MAX_VALUE

            for (latLng in latLngList) {
                val distance = calculateHaversineDistance(targetLocation, latLng)
                if (distance < closestDistance) {
                    closestDistance = distance
                    closestLatLng = latLng
                }
            }

            return closestLatLng
        }

        private fun calculateHaversineDistance(point1: LatLng, point2: LatLng): Double {
            val lat1 = Math.toRadians(point1.latitude)
            val lon1 = Math.toRadians(point1.longitude)
            val lat2 = Math.toRadians(point2.latitude)
            val lon2 = Math.toRadians(point2.longitude)

            val dLat = lat2 - lat1
            val dLon = lon2 - lon1

            val a = sin(dLat / 2).pow(2) + cos(lat1) * cos(lat2) * sin(dLon / 2).pow(2)
            val c = 2 * atan2(sqrt(a), sqrt(1 - a))

            // Radius of the Earth in kilometers (mean value)
            val earthRadius = 6371.0
            return earthRadius * c
        }

        fun getDisplayDistance(distance: Double): Distance {
            return if (distance > 1000) {
                Distance.create(distance / 1000, Distance.UNIT_KILOMETERS)
            } else {
                Distance.create(distance, Distance.UNIT_METERS)
            }
        }

        fun getDisplayDuration(durationInMinutes: Double): String {
            return if (durationInMinutes < 60) {
                String.format(Locale.getDefault(), "%.0f phút", durationInMinutes)
            } else if (durationInMinutes < 60 * 24) {
                val hours = durationInMinutes.toInt() / 60
                val minutes = durationInMinutes.toInt() % 60
                String.format(Locale.getDefault(), "%d giờ %d phút", hours, minutes)
            } else {
                val days = durationInMinutes.toInt() / (60 * 24)
                val hours = (durationInMinutes.toInt() % (60 * 24)) / 60
                String.format(Locale.getDefault(), "%d ngày %d giờ", days, hours)
            }
        }

        fun getDrawableResId(maneuver: String): Int {
            return when (maneuver) {
                "arrive" -> R.drawable.arrive
                "arrive_left" -> R.drawable.arrive_left
                "arrive_right" -> R.drawable.arrive_right
                "arrive_straight" -> R.drawable.arrive_straight
                "close" -> R.drawable.close
                "continue" -> R.drawable.continue_img
                "continue_left" -> R.drawable.continue_left
                "continue_right" -> R.drawable.continue_right
                "continue_slight_left" -> R.drawable.continue_slight_left
                "continue_slight_right" -> R.drawable.continue_slight_right
                "continue_straight" -> R.drawable.continue_straight
                "continue_uturn" -> R.drawable.continue_uturn
                "depart" -> R.drawable.depart
                "depart_left" -> R.drawable.depart_left
                "depart_right" -> R.drawable.depart_right
                "depart_straight" -> R.drawable.depart_straight
                "end_of_road_left" -> R.drawable.end_of_road_left
                "end_of_road_right" -> R.drawable.end_of_road_right
                "fork_left" -> R.drawable.fork_left
                "fork_right" -> R.drawable.fork_right
                "fork_slight_left" -> R.drawable.fork_slight_left
                "fork_slight_right" -> R.drawable.fork_slight_right
                "fork_straight" -> R.drawable.fork_straight
                "invalid" -> R.drawable.invalid
                "invalid_left" -> R.drawable.invalid_left
                "invalid_right" -> R.drawable.invalid_right
                "invalid_slight_left" -> R.drawable.invalid_slight_left
                "invalid_slight_right" -> R.drawable.invalid_slight_right
                "invalid_straight" -> R.drawable.invalid_straight
                "invalid_uturn" -> R.drawable.invalid_uturn
                "merge_left" -> R.drawable.merge_left
                "merge_right" -> R.drawable.merge_right
                "merge_slight_left" -> R.drawable.merge_slight_left
                "merge_slight_right" -> R.drawable.merge_slight_right
                "new_name_left" -> R.drawable.new_name_left
                "new_name_right" -> R.drawable.new_name_right
                "new_name_slight_left" -> R.drawable.new_name_slight_left
                "new_name_slight_right" -> R.drawable.new_name_slight_right
                "new_name_sharp_left" -> R.drawable.new_name_sharp_left
                "new_name_sharp_right" -> R.drawable.new_name_sharp_right
                "new_name_straight" -> R.drawable.new_name_straight
                "notification_left" -> R.drawable.notification_left
                "notification_right" -> R.drawable.notification_right
                "notification_sharp_left" -> R.drawable.notification_sharp_left
                "notification_sharp_right" -> R.drawable.notificaiton_sharp_right
                "notification_slight_left" -> R.drawable.notification_slight_left
                "notification_slight_right" -> R.drawable.notification_slight_right
                "notification_straight" -> R.drawable.notification_straight
                "off_ramp_left" -> R.drawable.off_ramp_left
                "off_ramp_right" -> R.drawable.off_ramp_right
                "off_ramp_slight_left" -> R.drawable.off_ramp_slight_left
                "off_ramp_slight_right" -> R.drawable.off_ramp_slight_right
                "on_ramp_left" -> R.drawable.on_ramp_left
                "on_ramp_right" -> R.drawable.on_ramp_right
                "on_ramp_sharp_left" -> R.drawable.on_ramp_sharp_left
                "on_ramp_sharp_right" -> R.drawable.on_ramp_sharp_right
                "on_ramp_slight_left" -> R.drawable.on_ramp_slight_left
                "on_ramp_slight_right" -> R.drawable.on_ramp_slight_right
                "on_ramp_straight" -> R.drawable.on_ramp_straight
                "rotary_left" -> R.drawable.rotary_left
                "rotary_right" -> R.drawable.rotary_right
                "rotary_sharp_left" -> R.drawable.rotary_sharp_left
                "rotary_sharp_right" -> R.drawable.rotary_sharp_right
                "rotary_slight_left" -> R.drawable.rotary_slight_left
                "rotary_slight_right" -> R.drawable.rotary_slight_right
                "rotary_straight" -> R.drawable.rotary_straight
                "roundabout_left" -> R.drawable.roundabout_left
                "roundabout_right" -> R.drawable.roundabout_right
                "roundabout_sharp_left" -> R.drawable.roundabout_sharp_left
                "roundabout_sharp_right" -> R.drawable.roundabout_sharp_right
                "roundabout_slight_left" -> R.drawable.roundabout_slight_left
                "roundabout_slight_right" -> R.drawable.roundabout_slight_right
                "roundabout_straight" -> R.drawable.roundabout_straight
                "turn_left" -> R.drawable.turn_left
                "turn_right" -> R.drawable.turn_right
                "turn_sharp_left" -> R.drawable.turn_sharp_left
                "turn_sharp_right" -> R.drawable.turn_sharp_right
                "turn_slight_left" -> R.drawable.turn_slight_left
                "turn_slight_right" -> R.drawable.turn_slight_right
                "turn_straight" -> R.drawable.turn_straight
                "uturn" -> R.drawable.uturn
                else -> R.drawable.invalid
            }
        }
    }
}