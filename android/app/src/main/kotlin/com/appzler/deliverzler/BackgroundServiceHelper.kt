package ys.com.shinedump

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class BackgroundServiceHelper(private val context: Context, flutterEngine: FlutterEngine) {
    private var wakeLock: PowerManager.WakeLock? = null
    private val channelId = "location_notification_channel"
    private val notificationId = 1001
    
    init {
        // Create notification channel for Android O+
        createNotificationChannel()
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ys.com.shinedump/background_services")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "acquireWakeLock" -> {
                        acquireWakeLock()
                        result.success(true)
                    }
                    "releaseWakeLock" -> {
                        releaseWakeLock()
                        result.success(true)
                    }
                    "updateNotification" -> {
                        val text = call.argument<String>("text") ?: "Trip in progress"
                        updateNotification(text)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Location Updates"
            val descriptionText = "Used for tracking trip location"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(channelId, name, importance).apply {
                description = descriptionText
                setShowBadge(false)
            }
            
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    fun updateNotification(text: String) {
        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.notification_icon)
            .setContentTitle("Location Tracking")
            .setContentText(text)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setOngoing(true)
            .setSound(null)
            
        try {
            with(NotificationManagerCompat.from(context)) {
                notify(notificationId, builder.build())
            }
        } catch (e: SecurityException) {
            e.printStackTrace()
        }
    }
    
    private fun acquireWakeLock() {
        releaseWakeLock() // Release any existing wake lock
        
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "ShineDump::LocationWakeLock"
        ).apply {
            setReferenceCounted(false)
            acquire(30*60*1000L) // 30 minutes max
        }
    }
    
    private fun releaseWakeLock() {
        wakeLock?.let {
            if (it.isHeld) {
                it.release()
            }
        }
        wakeLock = null
    }
}