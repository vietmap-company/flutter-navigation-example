package vn.vietmap.androidauto.car_surface

import android.content.Intent
import androidx.car.app.Screen
import androidx.car.app.Session
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import vn.vietmap.androidauto.screens.VietMapNavigationScreen
import vn.vietmap.vietmapsdk.Vietmap

class VietMapCarAppSession: Session() {
    companion object {
        private val _navigationScreenInstance = MutableStateFlow<VietMapNavigationScreen?>(null)
        val navigationScreenInstance: StateFlow<VietMapNavigationScreen?> = _navigationScreenInstance

        fun setNavigationScreenInstance(screen: VietMapNavigationScreen) {
            _navigationScreenInstance.value = screen
        }
    }
    override fun onCreateScreen(intent: Intent): Screen {
        Vietmap.getInstance(carContext)
        val mNavigationCarSurface = VietMapAndroidAutoSurface(carContext, lifecycle)
//        val screenMap = VietMapCarAppScreen(carContext,mNavigationCarSurface)
//        return screenMap
        val screen =  VietMapNavigationScreen(carContext,mNavigationCarSurface)
        setNavigationScreenInstance(screen)
        return screen
    }
}