package vn.vietmap.androidauto.car_surface

import android.animation.Animator
import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.PixelFormat
import android.graphics.PointF
import android.graphics.Rect
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Surface
import android.view.TextureView
import android.view.View
import android.view.WindowManager
import android.view.animation.DecelerateInterpolator
import androidx.annotation.MainThread
import androidx.car.app.AppManager
import androidx.car.app.CarContext
import androidx.car.app.SurfaceCallback
import androidx.car.app.SurfaceContainer
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import timber.log.Timber.Forest.e
import vn.vietmap.androidauto.helper.VietMapNavigationHelper
import vn.vietmap.vietmapsdk.Vietmap
import vn.vietmap.vietmapsdk.constants.VietMapConstants
import vn.vietmap.vietmapsdk.maps.MapView
import vn.vietmap.vietmapsdk.maps.OnMapReadyCallback
import vn.vietmap.vietmapsdk.maps.Style
import vn.vietmap.vietmapsdk.maps.VietMapGL
import vn.vietmap.vietmapsdk.maps.VietMapGLOptions
import kotlin.math.ln

class VietMapAndroidAutoSurface(private val mCarContext: CarContext, lifecycle: Lifecycle) :
    DefaultLifecycleObserver {

    var mSurface: Surface? = null
    private var mapView: MapView? = null
    private var surfaceWidth: Int? = null
    private var surfaceHeight: Int? = null
    private var isMoving = false
    private var scaleAnimator: Animator? = null
    private var vietMapGL: VietMapGL? = null
    private var isSurfaceAvailable = false
    private var listSurfaceCallback = mutableListOf<SurfaceCallback>()
    private var styleBuilder: Style.Builder? = null
    private var onStyleLoadedCallback: Style.OnStyleLoaded? = null
    private var onMapReadyCallback: OnMapReadyCallback? = null
    private val mSurfaceCallback: SurfaceCallback = object : SurfaceCallback {
        override fun onSurfaceAvailable(surfaceContainer: SurfaceContainer) {

            Log.d("VietMapAndroidAutoSurface", "onSurfaceAvailable")

            synchronized(this@VietMapAndroidAutoSurface) {

                if (mSurface != null) {
                    mSurface!!.release()
                }
                mSurface = surfaceContainer.surface
                doRenderFrame()
            }

            for (surfaceCallback in listSurfaceCallback) {
                surfaceCallback.onSurfaceAvailable(surfaceContainer)
            }
            isSurfaceAvailable = true
        }


        override fun onVisibleAreaChanged(visibleArea: Rect) {
            for (surfaceCallback in listSurfaceCallback) {
                surfaceCallback.onVisibleAreaChanged(visibleArea)
            }
            synchronized(this@VietMapAndroidAutoSurface) {
                doRenderFrame()
            }
        }

        override fun onStableAreaChanged(stableArea: Rect) {
            for (surfaceCallback in listSurfaceCallback) {
                surfaceCallback.onStableAreaChanged(stableArea)
            }
            synchronized(this@VietMapAndroidAutoSurface) {
                doRenderFrame()
            }
        }

        override fun onSurfaceDestroyed(surfaceContainer: SurfaceContainer) {
            isSurfaceAvailable = false
            for (surfaceCallback in listSurfaceCallback) {
                surfaceCallback.onSurfaceDestroyed(surfaceContainer)
            }
            Log.d("VietMapAndroidAutoSurface", "onSurfaceDestroyed")
            synchronized(this@VietMapAndroidAutoSurface) {
                if (mSurface != null) {
                    mSurface!!.release()
                    mSurface = null
                }
            }
        }

        override fun onClick(x: Float, y: Float) {
            for (surfaceCallback in listSurfaceCallback) {
                surfaceCallback.onClick(x, y)
            }
            super.onClick(x, y)
        }

        override fun onFling(velocityX: Float, velocityY: Float) {
            for (surfaceCallback in listSurfaceCallback) {
                surfaceCallback.onFling(velocityX, velocityY)
            }
            doRenderFrame()
            isMoving = false
            super.onFling(velocityX, velocityY)
        }


        override fun onScroll(distanceX: Float, distanceY: Float) {
            for (surfaceCallback in listSurfaceCallback) {
                surfaceCallback.onScroll(distanceX, distanceY)
            }
            // first move event is often delivered with no displacement
            if (!java.lang.Float.isNaN(distanceX) && !java.lang.Float.isNaN(distanceY) && (distanceX != 0f || distanceY != 0f)) {
                // dispatching camera start event only when the movement actually occurred

                // Disable scrolling horizontal if not allowed

                // Scroll the map
                vietMapGL?.scrollBy(-distanceX, -distanceY, 0 /*no duration*/)
            } else {
                e("Could not call onMove with parameters %s,%s", distanceX, distanceY)
            }
        }

        override fun onScale(focusX: Float, focusY: Float, scaleFactor: Float) {
            for (surfaceCallback in listSurfaceCallback) {
                surfaceCallback.onScale(focusX, focusY, scaleFactor)
            }
            if (scaleFactor == 2.0f) {
                zoomAnimated(true, PointF(focusX, focusY))
            } else {
                val zoomBy =
                    (ln(
                        scaleFactor.toDouble()
                    ) / ln(Math.PI / 2)) * VietMapConstants.ZOOM_RATE * 1.0f
                vietMapGL?.zoomBy(zoomBy, PointF(focusX, focusY))
            }

            doRenderFrame()
        }
    }

    fun addOnSurfaceCallbackListener(surfaceCallback: SurfaceCallback) {
        listSurfaceCallback.add(surfaceCallback)
    }

    fun getMapView(): MapView? {
        return mapView
    }

    private fun createScaleAnimator(
        currentZoom: Double, zoomAddition: Double,
        animationFocalPoint: PointF?, animationTime: Long,
    ): Animator {

        val animator =
            ValueAnimator.ofFloat(currentZoom.toFloat(), (currentZoom + zoomAddition).toFloat())
        animator.setDuration(animationTime)
        animator.interpolator = DecelerateInterpolator()
        animator.addUpdateListener { animation ->
            animationFocalPoint?.let {
                vietMapGL?.setZoom(
                    (animation.animatedValue as Float).toDouble(),
                    it
                )
            }
        }

        return animator
    }

    // Zoom in/out the map
    private fun zoomAnimated(zoomIn: Boolean, zoomFocalPoint: PointF?) {
        //canceling here as well, because when using a button it will not be canceled automatically by onDown()
        cancelAnimator(scaleAnimator)

        val currentZoom = vietMapGL?.zoom
        currentZoom?.let {
            scaleAnimator = createScaleAnimator(
                it,
                (if (zoomIn) 1 else -1).toDouble(),
                zoomFocalPoint,
                VietMapConstants.ANIMATION_DURATION.toLong()
            )
            scaleAnimator!!.start()

        }
    }

    private fun cancelAnimator(animator: Animator?) {
        if (animator != null && animator.isStarted) {
            animator.cancel()
        }
    }

    init {
        lifecycle.addObserver(this)
    }

    override fun onDestroy(owner: LifecycleOwner) {
        Log.d("VietMapAndroidAutoSurface", "onLifecycleDestroy")
        Handler(Looper.getMainLooper()).post {
            mapView?.onDestroy()
            mapView?.run {
                onStop()
                onDestroy()
                mCarContext.windowManager.removeView(this)
            }
            mapView = null
        }
        super.onDestroy(owner)
    }

    override fun onStart(owner: LifecycleOwner) {
        Log.d("VietMapAndroidAutoSurface", "onLifecycleStart")
        mapView?.onStart()
    }

    override fun onResume(owner: LifecycleOwner) {
        Log.d("VietMapAndroidAutoSurface", "onLifecycleResume")
        mapView?.onResume()
    }

    override fun onPause(owner: LifecycleOwner) {
        Log.d("VietMapAndroidAutoSurface", "onLifecyclePause")
        mapView?.onPause()
    }

    override fun onStop(owner: LifecycleOwner) {
        Log.d("VietMapAndroidAutoSurface", "onLifecycleStop")
        mapView?.onStop()
    }

    private fun initVietMapSDK() {
        Log.d("VietMapAndroidAutoSurface", "initVietMapSDK")
        Handler(Looper.getMainLooper()).post {
            Vietmap.getInstance(mCarContext)

            mapView = createMapViewInstance().apply {
                // Add the mapView to a window using the windowManager. This is needed for the mapView to start rendering.
                // The mapView is not actually shown on any screen, but acts as though it is visible.
                mCarContext.windowManager.addView(
                    this,
                    getWindowManagerLayoutParams()
                )

                onStart()
                getMapAsync {
                    vietMapGL = it
                    Handler().postDelayed({
                        doRenderFrame()
                    }, 1000)
                }
                addOnDidBecomeIdleListener { doRenderFrame() }
                addOnWillStartRenderingFrameListener {
                    doRenderFrame()
                }
            }
        }

        mCarContext.getCarService(AppManager::class.java).setSurfaceCallback(mSurfaceCallback)
    }

    @SuppressLint("SuspiciousIndentation")
    override fun onCreate(owner: LifecycleOwner) {

        Log.d("VietMapAndroidAutoSurface", "onLifecycleCreate")
        Vietmap.getInstance(mCarContext)
        initVietMapSDK()
    }

    private fun getWindowManagerLayoutParams() = WindowManager.LayoutParams(
        surfaceWidth ?: WindowManager.LayoutParams.MATCH_PARENT,
        surfaceHeight ?: WindowManager.LayoutParams.MATCH_PARENT,
        WindowManager.LayoutParams.TYPE_PRIVATE_PRESENTATION,
        WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
        PixelFormat.RGBX_8888
    )

    private fun createMapViewInstance() =
        MapView(mCarContext, VietMapGLOptions.createFromAttributes(mCarContext).apply {
            // Set the textureMode to true, so a TextureView is created
            // We can extract this TextureView to draw on the Android Auto surface
            textureMode(true)
        }).apply {
            setLayerType(View.LAYER_TYPE_HARDWARE, Paint())
        }

    fun init(
        styleBuilder: Style.Builder,
        onStyleLoadedCallback: Style.OnStyleLoaded,
        onMapReadyCallback: OnMapReadyCallback,
    ) {
        /// Run on main thread
        Handler(Looper.getMainLooper()).post {
            this.styleBuilder = styleBuilder
            this.onStyleLoadedCallback = onStyleLoadedCallback
            this.onMapReadyCallback = onMapReadyCallback
            mapView?.getMapAsync {
                onMapReadyCallback.onMapReady(vietMapGL!!)
                vietMapGL = it
                vietMapGL?.setStyle(
                    styleBuilder
                ) { style: Style? ->
                    if (style != null) {
                        onStyleLoadedCallback.onStyleLoaded(style)
                    }
                }
            }
        }
    }

    private fun init(
        onStyleLoadedCallback: Style.OnStyleLoaded?,
        styleBuilder: Style.Builder?,
        onMapReadyCallback: OnMapReadyCallback?,
    ) {
        /// Run on main thread
        Handler(Looper.getMainLooper()).post {
            mapView?.getMapAsync {
                onMapReadyCallback?.onMapReady(vietMapGL!!)
                vietMapGL = it
                vietMapGL?.setStyle(
                    styleBuilder
                ) { style: Style? ->
                    if (style != null) {
                        onStyleLoadedCallback?.onStyleLoaded(style)
                    }
                }
            }
        }
    }

    fun init(styleBuilder: Style.Builder, onMapReadyCallback: OnMapReadyCallback) {

        this.styleBuilder = styleBuilder
        this.onMapReadyCallback = onMapReadyCallback
        /// Run on main thread
        Handler(Looper.getMainLooper()).post {
            mapView?.getMapAsync {
                onMapReadyCallback.onMapReady(vietMapGL!!)
                vietMapGL = it
                vietMapGL?.setStyle(
                    styleBuilder
                ) { style: Style? ->
                }
            }
        }
    }

    fun init(styleBuilder: Style.Builder, onStyleLoadedCallback: Style.OnStyleLoaded) {

        this.styleBuilder = styleBuilder
        this.onStyleLoadedCallback = onStyleLoadedCallback
        /// Run on main thread
        Handler(Looper.getMainLooper()).post {
            mapView?.getMapAsync {
                vietMapGL = it
                vietMapGL?.setStyle(
                    styleBuilder
                ) { style: Style? ->
                    if (style != null) {
                        onStyleLoadedCallback.onStyleLoaded(style)
                    }
                }
            }
        }
    }

    fun init(styleBuilder: Style.Builder) {

        this.styleBuilder = styleBuilder
        /// Run on main thread
        Handler(Looper.getMainLooper()).post {
            mapView?.getMapAsync {
                vietMapGL = it
                vietMapGL?.setStyle(
                    styleBuilder
                ) { style: Style? ->
                }
            }
        }
    }

    private val Context.windowManager: WindowManager
        get() = getSystemService(Context.WINDOW_SERVICE) as WindowManager


    @MainThread
    private fun doRenderFrame() {
        if (!isSurfaceAvailable) {
            return
        }
        try {
            renderLayout()
        } catch (e: Exception) { 
        }
    }

    private fun renderLayout() {
        val canvas: Canvas? = mSurface?.lockCanvas(null)
        canvas?.let {
            mapView?.let { it1 -> drawMapOnCanvas(it1, it) }
            mSurface?.unlockCanvasAndPost(it)
        }
    }

    private fun drawMapOnCanvas(mapView: MapView, canvas: Canvas) {
        val mapViewTextureView = mapView.takeIf { it.childCount > 0 }?.getChildAt(0) as? TextureView
        mapViewTextureView?.bitmap?.let {
            canvas.drawBitmap(it, 0f, 0f, Paint())
        }
    }
}
