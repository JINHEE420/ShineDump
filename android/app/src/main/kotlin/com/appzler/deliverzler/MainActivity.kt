package ys.com.shinedump

import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    private var pendingResult: MethodChannel.Result? = null
    private lateinit var backgroundServiceHelper: BackgroundServiceHelper

    companion object {
        private const val CHANNEL = "android_app_retain"
        private const val ALARMS_PERMISSION_REQUEST_CODE = 1001
        private const val APP_SETTINGS_REQUEST_CODE = 1002
    }

    override fun configureFlutterEngine(flutterengine: FlutterEngine) {
        super.configureFlutterEngine(flutterengine)
        GeneratedPluginRegistrant.registerWith(flutterengine)

        // Initialize background service helper
        backgroundServiceHelper = BackgroundServiceHelper(context, flutterengine)

        MethodChannel(
            flutterengine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when {
                call.method == "checkAlarmsAndRemindersPermission" -> {
                    val isGranted = checkAlarmsAndRemindersPermission()
                    result.success(isGranted)
                }
                call.method == "openAlarmsAndRemindersSettings" -> {
                    openAlarmsAndRemindersSettings(result)
                }
                call.method == "openAppSettings" -> {
                    openAppSettings(result)
                }
                call.method == "sendToBackground" -> {
                    minimizeApp()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun minimizeApp() {
        // This sends the app to background without killing services
        val intent = Intent("android.intent.action.MAIN")
        intent.addCategory("android.intent.category.HOME")
        context.startActivity(intent)
    }

    private fun checkAlarmsAndRemindersPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // For Android 12+ (API level 31+)
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.canScheduleExactAlarms()
        } else {
            // For Android 11 and below, this permission didn't exist
            true
        }
    }

    private fun openAlarmsAndRemindersSettings(result: MethodChannel.Result) {
        try {
            // Store the result to use later when the activity returns
            pendingResult = result

            val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
            } else {
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.parse("package:$packageName")
                }
            }

            // Start activity expecting a result
            startActivityForResult(intent, ALARMS_PERMISSION_REQUEST_CODE)

            // Note: Don't call result.success() here - wait for onActivityResult
        } catch (e: Exception) {
            e.printStackTrace()
            result.success(false)
            pendingResult = null
        }
    }

    private fun openAppSettings(result: MethodChannel.Result) {
        try {
            // Store the result to use later when the activity returns
            pendingResult = result

            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }

            // Start activity expecting a result
            startActivityForResult(intent, APP_SETTINGS_REQUEST_CODE)

            // Note: Don't call result.success() here - wait for onActivityResult
        } catch (e: Exception) {
            e.printStackTrace()
            result.success(false)
            pendingResult = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        when (requestCode) {
            ALARMS_PERMISSION_REQUEST_CODE -> {
                // Check if permission was granted after returning from settings
                val isPermissionGranted = checkAlarmsAndRemindersPermission()

                // Send result back to Flutter
                pendingResult?.success(isPermissionGranted)
                pendingResult = null
            }

            APP_SETTINGS_REQUEST_CODE -> {
                // Send result back to Flutter
                pendingResult?.success(null)
                pendingResult = null
            }
        }
    }
}
