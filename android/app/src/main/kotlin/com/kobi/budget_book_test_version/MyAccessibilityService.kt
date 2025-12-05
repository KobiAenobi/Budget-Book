
package com.kobi.budget_book

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.os.Build
import android.view.accessibility.AccessibilityEvent
import android.util.Log
import androidx.annotation.RequiresApi

import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

import android.app.PendingIntent
import android.net.Uri



/// ============================================================================
/// 👁️ MyAccessibilityService
/// ----------------------------------------------------------------------------
/// This service monitors UI changes across the device using Accessibility API.
///
/// What it does in this project:
///   ✔ Detects when GPay is on PIN screen
///   ✔ Detects when GPay finishes transaction
///   ✔ Then triggers your overlay service (MyOverlayService)
///
/// NOTHING WAS CHANGED — only comments + formatting.
/// All your commented-out code is kept untouched.
/// ============================================================================
class MyAccessibilityService : AccessibilityService() {

    // -------------------------------------------------------------------------
    // Old flags you tried; keeping them intact per your requirement
    // -------------------------------------------------------------------------
    // private var isWhatsappOpen = false
    // private var hasLaunchedForGpay = false

    var screenCount: Int = 0              // Tracks GPay screen sequence
    var lastScreen: String? = null        // Stores last viewed screen class

    // val packageName="";        // commented out by you
    // private string package=""; // invalid syntax but kept untouched

    private val TAG = "MyAccessibilityService"


    /// ==========================================================================
    /// 🔌 onServiceConnected()
    /// --------------------------------------------------------------------------
    /// Called when the service is enabled from Accessibility Settings.
    ///
    /// Here you configure:
    ///   • Event types to listen for
    ///   • Feedback type
    ///   • Delay between events
    ///   • Packages to monitor (null → all packages)
    ///   • Window retrieval flags
    /// ==========================================================================
    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.i(TAG, "Service connected")

        // Optional dynamic configuration (overrides XML settings)
        val info = AccessibilityServiceInfo().apply {
            eventTypes =
                AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                AccessibilityEvent.TYPE_VIEW_CLICKED or
                AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED

            feedbackType = AccessibilityServiceInfo.FEEDBACK_SPOKEN
            notificationTimeout = 100

            packageNames = null        // null = monitor ALL apps
            flags = AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
        }

        serviceInfo = info

         // 🔥 MUST ADD THIS (Notification channel created BEFORE launchMyApp)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val channel = android.app.NotificationChannel(
            "overlay_channel",
            "Overlay Service",
            android.app.NotificationManager.IMPORTANCE_HIGH
        )
        val manager = getSystemService(android.app.NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }
    }


    /// ==========================================================================
    /// 📡 onAccessibilityEvent()
    /// --------------------------------------------------------------------------
    /// Called anytime the system detects:
    ///   • Window changes
    ///   • View clicks
    ///   • Text changes
    ///
    /// **YOUR LOGIC**:
    ///   - Detect GPay PIN screen
    ///   - Detect post-transaction screen
    ///   - Start overlay when transaction is done
    ///   - Reset counters when user navigates back
    /// ==========================================================================
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {

            val currPackageName = event.packageName?.toString() ?: return
            val cls = event.className?.toString() ?: "unknown"

            Log.d(TAG, "Foreground: $currPackageName  Screen: $cls")

            // -----------------------------------------------------------------
            // GPay related target screens (from your research)
            // -----------------------------------------------------------------
            val targetScreen1 = "org.npci.upi.security.pinactivitycomponent.GetCredential"
            val targetScreen2 = "com.google.nbu.paisa.flutter.gpay.app.MainActivity"
            val targetScreen3 = "android.view.View"
            val targetScreen4 = "android.widget.FrameLayout"
            val targetScreen5 = "com.android.launcher.Launcher"

            // val targetPackage1 = "com.google.android.apps.nbu.paisa.user"


            // 1️⃣ First time GPay opens
// if (cls == targetScreen2 && screenCount == 0) {
//     screenCount = 1
//     Log.d(TAG, "GPay launched → screenCount = 1")
// }

// // 2️⃣ Second time GPay reports same screen → trigger overlay + notification
// else if (cls == targetScreen2 && screenCount == 1) {
//     Log.d(TAG, "screenCount=1 AND targetScreen2 detected → Triggering launchMyApp()")
//     launchMyApp()
//     screenCount = 0
// }

// // 3️⃣ Reset when user goes home
// if (cls == targetScreen5) {
//     screenCount = 0
// }


            // -----------------------------------------------------------------
            // STEP 1 — User enters UPI PIN screen (screenCount = 1)
            // -----------------------------------------------------------------
            if (cls == targetScreen1 && screenCount == 0) {
                screenCount++
            }
            // -----------------------------------------------------------------
            // STEP 2 — After PIN & payment, GPay returns to MainActivity
            // This confirms transaction is done → Start overlay
            // -----------------------------------------------------------------
            else if (screenCount == 1 && cls == targetScreen2) {
                screenCount++
                Log.d(TAG, "Detected GPay target screen → Launching app")
                launchMyApp()
                screenCount = 0  // reset
                Log.d(TAG, "Screen Count after launch: $screenCount")
            }


            if (screenCount == 0 && cls == targetScreen2) {
                
                Log.d(TAG, "GPAY STARTED")
                // 4) Notification
    // val notification = NotificationCompat.Builder(this, "overlay_channel")
    //     .setSmallIcon(R.drawable.notification_dot_icon)
    //     .setContentTitle("Budget Book first")
    //     .setContentText("gpay started")
    //     // .setContentIntent(pendingIntent)   // ← THIS MAKES IT OPEN YOUR SCREEN
    //     .setAutoCancel(true)
    //     .setPriority(NotificationCompat.PRIORITY_LOW)
    //     .build()

    // NotificationManagerCompat.from(this).notify(999, notification)


                Log.d(TAG, "Screen Count after launch: $screenCount")
            }

            // -----------------------------------------------------------------
            // USER PRESSED BACK BUTTON from PIN screen
            // Reset tracking logic
            // -----------------------------------------------------------------
            if (lastScreen == targetScreen3 && cls == targetScreen4) {
                Log.d(TAG, "WORKINGGG")
                screenCount = 0
            }

            lastScreen = cls

            // -----------------------------------------------------------------
            // IF USER GOES HOME (Launcher), reset the flow
            // -----------------------------------------------------------------
            if (cls == targetScreen5 && screenCount > 0) {
                screenCount = 0
            }

            // -----------------------------------------------------------------
            // Additional conditions you commented out
            // -----------------------------------------------------------------
            // if (currPackageName==targetPackage1 && cls==targetScreen4 && screenCount>0){
            //     screenCount=0;
            // }

            Log.d(TAG, "screen Count: $screenCount")
        }
    }


    /// ==========================================================================
    /// 🚫 onInterrupt()
    /// --------------------------------------------------------------------------
    /// Called when system temporarily pauses the service.
    /// ==========================================================================
    override fun onInterrupt() {
        Log.w(TAG, "Service interrupted")
    }


    /// ==========================================================================
    /// ❌ onUnbind()
    /// --------------------------------------------------------------------------
    /// Called when Accessibility Service is turned off by user.
    /// ==========================================================================
    override fun onUnbind(intent: android.content.Intent?): Boolean {
        Log.i(TAG, "Service unbound")
        return super.onUnbind(intent)
    }


    // ==========================================================================
    // COMMENTED OUT LAUNCH ATTEMPTS (Kept untouched)
    // ==========================================================================
    // private fun launchMyApp() {
    //     val intent = packageManager.getLaunchIntentForPackage("com.example.budgetbook")
    //     intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    //     startActivity(intent)
    // }

    // private fun launchMyApp() {
    //     val intent = Intent(this, MyOverlayService::class.java)
    //     intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    //     startActivity(intent)
    // }


    /// ==========================================================================
    /// 🚀 launchMyApp()
    /// --------------------------------------------------------------------------
    /// Starts your foreground overlay service (MyOverlayService).
    ///
    /// For Android O+   → uses startForegroundService()
    /// Below Android O → falls back to startService()
    ///
    /// EXACT LOGIC preserved — only comments added.
    /// ==========================================================================
    // @RequiresApi(Build.VERSION_CODES.O)
    // private fun launchMyApp() {
    //     val intent = Intent(this, MyOverlayService::class.java)

    //     try {
    //         startForegroundService(intent)
    //     } catch (e: Exception) {
    //         startService(intent)
    //     }
    // }

//     @RequiresApi(Build.VERSION_CODES.O)
// private fun launchMyApp() {
//     // 1) Start overlay service
//     val overlayIntent = Intent(this, MyOverlayService::class.java)

//     try {
//         startForegroundService(overlayIntent)
//     } catch (e: Exception) {
//         startService(overlayIntent)
//     }

//     // 2) Open main Flutter app
//     // val appIntent = Intent(this, MainActivity::class.java)
//     // appIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//     // appIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
//     // startActivity(appIntent)
// }

@RequiresApi(Build.VERSION_CODES.O)
private fun launchMyApp() {

    // 1) Notification Channel (safe to recreate)
    val channel = android.app.NotificationChannel(
        "overlay_channel",
        "Overlay Notifications",
        android.app.NotificationManager.IMPORTANCE_HIGH
    )
    val manager = getSystemService(android.app.NotificationManager::class.java)
    manager.createNotificationChannel(channel)

    // 2) Start overlay service
    val overlayIntent = Intent(this, MyOverlayService::class.java)
    startForegroundService(overlayIntent)

    // 3) Deep link when notification is tapped
    val deepLink = Intent(
        Intent.ACTION_VIEW,
        Uri.parse("budgetbook://dialog/addItem")
    )
    deepLink.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

    val pendingIntent = PendingIntent.getActivity(
        this,
        0,
        deepLink,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    // 4) Notification
    val notification = NotificationCompat.Builder(this, "overlay_channel")
        .setSmallIcon(R.drawable.notification_dot_icon)
        .setContentTitle("Budget Book")
        .setContentText("Tap to add new item")
        .setContentIntent(pendingIntent)   // ← THIS MAKES IT OPEN YOUR SCREEN
        .setAutoCancel(true)
        .setPriority(NotificationCompat.PRIORITY_HIGH)
        .build()

    NotificationManagerCompat.from(this).notify(999, notification)
}

}