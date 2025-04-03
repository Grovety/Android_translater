package com.example.multilingual_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.pm.ServiceInfo
import android.content.Intent
import android.os.Build
import android.os.IBinder


import io.flutter.embedding.engine.FlutterEngine

class ScreenCaptureService : Service() {

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForegroundService()
    }

//    private fun createChannel(){
//        val methodChannel = MethodChannel(MyApplication.flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
//
//        methodChannel.setMethodCallHandler { call, result ->
//            if (call.method == "runCommand") {
//                val command = call.argument<String>("command")
//                runSomeCommand(command)
//                result.success(null)
//            } else {
//                result.notImplemented()
//            }
//        }
//    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "screen_capture_channel",
//                "media_projection_api",
                "Screen Capture",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun startForegroundService() {
        val notification = Notification.Builder(this, "screen_capture_channel")
//        val notification = Notification.Builder(this, "media_projection_api")
            .setContentTitle("Screen Capture")
            .setContentText("Capturing screen...")
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(1, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION)
        } else {
            startForeground(1, notification)
        }
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}



//package com.example.multilingual_app
//
//import android.app.Service
//import android.content.Intent
//import android.graphics.Bitmap
//import android.hardware.display.VirtualDisplay
//import android.media.projection.MediaProjection
//import android.media.projection.MediaProjectionManager
//import android.os.Binder
//import android.os.IBinder
//import android.util.DisplayMetrics
//import android.view.WindowManager
//
//class ScreenshotService : Service()  {
//    private var mediaProjection: MediaProjection? = null
//    private var virtualDisplay: VirtualDisplay? = null
//
//    inner class LocalBinder : Binder() {
//        fun getService(): ScreenshotService = this@ScreenshotService
//    }
//
//    private val binder = LocalBinder()
//
//    override fun onBind(intent: Intent?): IBinder {
//        return binder
//    }
//
//    fun startProjection(resultCode: Int, data: Intent) {
//        val projectionManager = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
//        mediaProjection = projectionManager.getMediaProjection(resultCode, data)
//
//        val window = getSystemService(WINDOW_SERVICE) as WindowManager
//        val metrics = DisplayMetrics()
//        window.defaultDisplay.getMetrics(metrics)
//
//        val width = metrics.widthPixels
//        val height = metrics.heightPixels
//        val density = metrics.densityDpi
//
//        // Настроить VirtualDisplay и сделать скриншот...
//    }
//}