package com.example.multilingual_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

import android.app.Activity
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import android.util.DisplayMetrics
import android.view.WindowManager
import android.view.View
import android.view.WindowInsets


import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.RequiresApi
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import java.io.ByteArrayOutputStream
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicLong

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler{
    private val REQUEST_CODE_SCREEN_CAPTURE = 1001

    private lateinit var mediaProjectionManager: MediaProjectionManager
    private lateinit var activity: Activity

    private lateinit var methodChannel: MethodChannel
    private lateinit var context: Context


    private var mediaProjection: MediaProjection? = null
    private var mResultCode: Int = -2
    private var mResultData: Intent? = null
    private var currentResult: Result? = null

    private var mVirtualDisplay: VirtualDisplay? = null
    private var mImageReader: ImageReader? = null

    private var isLiving: AtomicBoolean = AtomicBoolean(false)
    private var processingTime = AtomicLong(System.currentTimeMillis())
    private var counting = AtomicLong(0)

    companion object {
        const val LOG_TAG = "Media projection api"
        const val CAPTURE_SINGLE = "MP_CAPTURE_SINGLE"
        const val CHANEL_NAME = "media_projection_api"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
//        Log.i(LOG_TAG, "Create media projection started")
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "media_projection_api")
        methodChannel.setMethodCallHandler(this)
        context = this
        activity = this
        Log.i(LOG_TAG, "Create media projection succeeded!")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            flutterEngine.platformViewsController.registry
                .registerViewFactory("transparent_overlay", TransparentViewFactory())
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.i(LOG_TAG, "call ${call.method}")
        if (call.method == "takeCapture") {
            takeCapture(call, result)
        }else if (call.method == "checkPermission") {
            checkPermission(call, result)
        } else if (call.method == "stopCapture") {
            if (mediaProjection != null) {
                mediaProjection?.stop()
                mediaProjection = null
            }
            result.success(0);
        }else if(call.method == "startCaptureStream"){
            result.success(false);
        }else {
            result.notImplemented()
        }
    }

    private fun checkPermission(call: MethodCall, result: Result){
        Log.i(LOG_TAG, "CheckPermission started")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Log.i(LOG_TAG, "SDK version OK")
            // Foreground service launching
            val serviceIntent = Intent(this, ScreenCaptureService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent)
            } else {
                startService(serviceIntent)
            }
            Log.i(LOG_TAG, "Screen Capture Service started")
            mediaProjectionManager = context.getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
            val permissionIntent = mediaProjectionManager.createScreenCaptureIntent()
            activity.startActivityForResult(permissionIntent, REQUEST_CODE_SCREEN_CAPTURE)
            Log.i(LOG_TAG, "User decision $result")
            currentResult = result

        } else {
            result.success(false) // MediaProjection is not supported on devices less than Lollipop
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (null == data) {
            return
        }
        if (requestCode == REQUEST_CODE_SCREEN_CAPTURE) {
            Log.i(LOG_TAG, "Activity callback, resultCode: $resultCode")
            if (resultCode != Activity.RESULT_OK) {
                currentResult?.success(false)
                return
            }
            mResultCode = resultCode
            mResultData = data
            Log.i(LOG_TAG, "Activity data: $data")
            mediaProjection = mediaProjectionManager.getMediaProjection(resultCode, data)
            currentResult?.success(true)
        }
    }

    @SuppressLint("WrongConstant")
    private fun takeCapture(call: MethodCall, result: Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            result.error(LOG_TAG, "Create media projection failed because system api level is lower than 21", null)
            return
        }

        if (mediaProjection == null) {
            result.error(LOG_TAG, "Must request permission before take capture", null)
            return
        }
        val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val display = windowManager.defaultDisplay
        val metrics = DisplayMetrics()
        display.getMetrics(metrics)

        val rootView = window.decorView.rootView

        val (width, height) = getScreenSizeWithoutSystemUI(rootView)
        Log.i(LOG_TAG, "Screen size: $width, $height")

        val imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 5)

        mediaProjection?.createVirtualDisplay(
            CAPTURE_SINGLE,
            width,
            height,
            1,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_PUBLIC,
            imageReader.surface,
            null,
            null,
        )
        Log.i(LOG_TAG, "Virtual Display created")

        Handler(Looper.getMainLooper()).postDelayed({
            Log.i(LOG_TAG, "Start Handler")
            val image = imageReader.acquireLatestImage() ?: return@postDelayed

            val planes = image.planes
            val buffer = planes[0].buffer
            val pixelStride = planes[0].pixelStride
            val rowStride = planes[0].rowStride
            val rowPadding = rowStride - pixelStride * width
            val padding = rowPadding / pixelStride

            var bitmap = Bitmap.createBitmap(width + padding, height, Bitmap.Config.ARGB_8888)
            bitmap.copyPixelsFromBuffer(buffer)
            Log.i(LOG_TAG, "bitmap created")

            image.close()
            mVirtualDisplay?.release()

            val region = call.arguments as Map<*, *>?
            region?.let {
                val x = it["x"] as Int + padding / 2
                val y = it["y"] as Int
                val w = it["width"] as Int
                val h = it["height"] as Int

                bitmap = bitmap.crop(x, y, w, h)
            }

            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)

            val byteArray = outputStream.toByteArray()
            Log.i(LOG_TAG, "Image created")

            result.success(
                mapOf(
                    "bytes" to byteArray,
                    "width" to bitmap.width,
                    "height" to bitmap.height,
                    "rowBytes" to bitmap.rowBytes,
                    "format" to Bitmap.Config.ARGB_8888.toString(),
                    "pixelStride" to pixelStride,
                    "rowStride" to rowStride,
                    "nv21" to getYV12(bitmap.width, bitmap.height, bitmap),
                    "time" to System.currentTimeMillis(),
                    "queue" to 1,
                )
            )
        }, 100)
    }

    private fun getScreenSizeWithoutSystemUI(view: View): Pair<Int, Int> {
        val windowInsets = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            view.rootWindowInsets
        } else {
            View.OnApplyWindowInsetsListener { v, insets ->
                v.onApplyWindowInsets(insets)
            }
            view.rootWindowInsets
        }

        val screenWidth = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            windowInsets?.displayCutout?.safeInsetLeft?.let { left ->
                windowInsets.displayCutout?.safeInsetRight?.let { right ->
                    view.width - left - right
                }
            } ?: view.width
        } else {
            view.width
        }

        val screenHeight = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            windowInsets?.displayCutout?.safeInsetTop?.let { top ->
                windowInsets.displayCutout?.safeInsetBottom?.let { bottom ->
                    view.height - top - bottom
                }
            } ?: view.height
        } else {
            view.height
        }

        return Pair(screenWidth, screenHeight)
    }

    private fun Bitmap.crop(x: Int, y: Int, width: Int, height: Int): Bitmap {
        return Bitmap.createBitmap(this, x, y, width, height, null, true)
    }

    private fun getYV12(inputWidth: Int, inputHeight: Int, scaled: Bitmap): ByteArray {
        val argb = IntArray(inputWidth * inputHeight)
        scaled.getPixels(argb, 0, inputWidth, 0, 0, inputWidth, inputHeight)
        val yuv = ByteArray(inputWidth * inputHeight * 3 / 2)
        encodeYV12(yuv, argb, inputWidth, inputHeight)
        scaled.recycle()
        return yuv
    }

    private fun encodeYV12(yuv420sp: ByteArray, argb: IntArray, width: Int, height: Int) {
        val frameSize = width * height
        var yIndex = 0
        var uIndex = frameSize
        var vIndex = frameSize + frameSize / 4
        // var a: Int
        var r: Int
        var g: Int
        var b: Int
        var y: Int
        var u: Int
        var v: Int
        var index = 0
        for (j in 0 until height) {
            for (i in 0 until width) {
                // a = argb[index] and -0x1000000 shr 24 // a is not used obviously
                r = argb[index] and 0xff0000 shr 16
                g = argb[index] and 0xff00 shr 8
                b = argb[index] and 0xff shr 0

                // well known RGB to YUV algorithm
                y = (66 * r + 129 * g + 25 * b + 128 shr 8) + 16
                u = (-38 * r - 74 * g + 112 * b + 128 shr 8) + 128
                v = (112 * r - 94 * g - 18 * b + 128 shr 8) + 128

                // YV12 has a plane of Y and two chroma plans (U, V) planes each sampled by a factor of 2
                //    meaning for every 4 Y pixels there are 1 V and 1 U.  Note the sampling is every other
                //    pixel AND every other scanline.
                yuv420sp[yIndex++] = y.toByte()
                if (j % 2 == 0 && index % 2 == 0) {
                    yuv420sp[uIndex++] = v.toByte()
                    yuv420sp[vIndex++] = u.toByte()
                }
                index++
            }
        }
    }
}
