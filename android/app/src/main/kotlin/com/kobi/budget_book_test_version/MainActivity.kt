package com.kobi.budget_book

import android.net.Uri
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.provider.Settings
import android.view.accessibility.AccessibilityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel   // <-- YOU FORGOT THIS IMPORT
import android.util.Log
import com.kobi.budget_book.MyAccessibilityService
import com.kobi.budget_book.MyOverlayService

import android.os.Build
import androidx.annotation.RequiresApi



/// ============================================================================
/// 🏠 MainActivity (Kotlin → Flutter Bridge)
/// ----------------------------------------------------------------------------
/// This activity:
///   • Creates the main Flutter engine
///   • Initializes MethodChannel (Flutter → Android)
///   • Initializes EventChannel (Android → Flutter)
///   • Manages accessibility + overlay permissions
///   • Starts Android overlay service
///
/// NOTHING HAS BEEN MODIFIED — only comments + formatting added.
/// ============================================================================
class MainActivity : FlutterActivity() {

    companion object {
        // ---------------------------------------------------------------------
        // STATIC eventSink → Required because accessibility events may come
        // from services OUTSIDE the activity.
        //
        // Flutter must be able to receive events even when MainActivity is not visible.
        // ---------------------------------------------------------------------
        var eventSink: EventChannel.EventSink? = null   // <-- MUST BE STATIC
    }

    private val CHANNEL = "accessibility_channel"      // MethodChannel name
    private val EVENT_CHANNEL = "accessibility_events" // EventChannel name


    /// ==========================================================================
    /// ⚙️ configureFlutterEngine()
    /// --------------------------------------------------------------------------
    /// Called when Flutter attaches the FlutterEngine to this Activity.
    /// Here we:
    ///   ✔ Share the engine using FlutterEngineCache
    ///   ✔ Execute Dart entrypoint (VERY IMPORTANT!)
    ///   ✔ Set up MethodChannel handlers
    ///   ✔ Set up EventChannel handler
    /// ==========================================================================
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ⭐ Share the engine so background services can use the same engine
        FlutterEngineCache.getInstance().put("shared_engine", flutterEngine)

        // ⭐ Required — ensures Dart code actually runs (overlay entrypoint too)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        // ==========================================================================
        // 🔵 METHOD CHANNEL — Flutter → Android (commands)
        // ==========================================================================
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                // -------------------------------------------------------------
                // Open Android overlay permission settings page
                // -------------------------------------------------------------
                "openOverlaySettings" -> {
                    openOverlayPermission()
                    result.success(null)
                }

                // -------------------------------------------------------------
                // Check if overlay permission granted
                // -------------------------------------------------------------
                "isOverlayEnabled" -> {
                    val enabled = Settings.canDrawOverlays(this)
                    result.success(enabled)
                }

                // -------------------------------------------------------------
                // Open Accessibility Settings
                // -------------------------------------------------------------
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(null)
                }

                // -------------------------------------------------------------
                // Check if our accessibility service is enabled
                // -------------------------------------------------------------
                "isServiceEnabled" -> {
                    val enabled =
                        isAccessibilityServiceEnabled(MyAccessibilityService::class.java)
                    result.success(enabled)
                }

                // -------------------------------------------------------------
                // Start overlay service (floating bubble UI)
                // -------------------------------------------------------------
                "startOverlay" -> {
                    val intent = Intent(this, MyOverlayService::class.java)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    // startService(intent)
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
        startForegroundService(intent)
    } else {
        startService(intent)
    }
                    result.success(true)
                }

                "requestSpecialUsePermission" -> {
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                        requestSpecialUsePermission()
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }

                "openNotificationSettings" -> {
    openNotificationSettings()
    result.success(null)
}


                // -------------------------------------------------------------
                // Unknown method
                // -------------------------------------------------------------
                else -> result.notImplemented()
            }
        }


        // ==========================================================================
        // 🔴 EVENT CHANNEL — Android → Flutter (real-time events)
        // ==========================================================================
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {

            // When Flutter starts listening
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events  // Save for later use (from AccessibilityService)
            }

            // When Flutter stops listening (widget disposed)
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }


    /// ==========================================================================
    /// 🟣 Check if a specific accessibility service is enabled
    /// --------------------------------------------------------------------------
    /// Returns TRUE if the given service class is found in enabled list.
    /// ==========================================================================
    private fun isAccessibilityServiceEnabled(service: Class<*>): Boolean {
        val am = getSystemService(ACCESSIBILITY_SERVICE) as AccessibilityManager

        val enabledList =
            am.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)

        return enabledList.any {
            it.resolveInfo.serviceInfo.name.endsWith(service.simpleName)
        }
    }


    /// ==========================================================================
    /// 🟡 Open the "Display Over Other Apps" permission page
    /// --------------------------------------------------------------------------
    /// EXACT CODE LEFT UNCHANGED — your commented block preserved.
    /// ==========================================================================
    private fun openOverlayPermission() {
        // if (!Settings.canDrawOverlays(this)) {
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:$packageName")
        )
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
        // } else {
        //     Log.d("KOBI_DEBUG", "openOverlaySettings are on")
        // }
    }


    @RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
private fun requestSpecialUsePermission() {
    val intent = Intent("android.settings.MANAGE_FOREGROUND_SERVICE_SPECIAL_USE")
    intent.data = Uri.fromParts("package", packageName, null)
    startActivity(intent)
}

private fun openNotificationSettings() {
    val intent = Intent()

    // Android 8.0+ (Oreo and above)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        intent.action = Settings.ACTION_APP_NOTIFICATION_SETTINGS
        intent.putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
    } 
    // Android 5–7
    else {
        intent.action = "android.settings.APP_NOTIFICATION_SETTINGS"
        intent.putExtra("app_package", packageName)
        intent.putExtra("app_uid", applicationInfo.uid)
    }

    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    startActivity(intent)
}


}
