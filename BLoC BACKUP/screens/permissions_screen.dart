import 'dart:async';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================================
/// 📌 PermissionsScreen SCREEN
/// ----------------------------------------------------------------------------
/// This screen is responsible for:
/// - Communicating with native Android via MethodChannel & EventChannel
/// - Opening accessibility settings
/// - Opening overlay permission screen
/// - Starting the overlay bubble/service
/// - Listening to real-time accessibility events from Android
///
/// NOTHING has been changed. Only formatted + commented.
/// ============================================================================
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  /// MethodChannel for calling native Android methods
  /// (open settings, check permissions, start overlay, etc.)
  static const platform = MethodChannel('accessibility_channel');

  /// EventChannel for receiving continuous callback events
  /// (like detecting UPI transactions or accessibility stream)
  static const eventChannel = EventChannel('accessibility_events');

  /// Subscription to the event stream
  StreamSubscription? _subscription;

  /// Shows the latest event received from Android
  /// Useful for debugging and checking if service is active
  String latestEvent = "No events yet";

  /// ==========================================================================
  /// 🔄 initState()
  /// --------------------------------------------------------------------------
  /// Called when the widget is created.
  /// Here we start listening to the event stream from Android.
  /// ==========================================================================
  @override
  void initState() {
    super.initState();

    // Listen to accessibility/overlay broadcast stream
    _subscription = eventChannel.receiveBroadcastStream().listen((event) {
      setState(() {
        latestEvent = event.toString();
      });
    });
  }

  /// ==========================================================================
  /// 🧹 dispose()
  /// --------------------------------------------------------------------------
  /// Always cancel StreamSubscription to avoid memory leaks.
  /// ==========================================================================
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// ==========================================================================
  /// ⚙️ openAccessibilitySettings()
  /// --------------------------------------------------------------------------
  /// Opens Android's Accessibility Settings where user enables the service.
  /// ==========================================================================
  Future<void> openAccessibilitySettings() async {
    await platform.invokeMethod('openAccessibilitySettings');
  }

  /// ==========================================================================
  /// 🔍 isEnabled()
  /// --------------------------------------------------------------------------
  /// Returns TRUE if accessibility service is enabled on Android.
  /// ==========================================================================
  Future<bool> isEnabled() async {
    final result = await platform.invokeMethod('isServiceEnabled');
    return result;
  }

  /// ==========================================================================
  /// ⚙️ openOverlaySettings()
  /// --------------------------------------------------------------------------
  /// Opens Android's "Display over other apps" permission screen.
  /// ==========================================================================
  Future<void> openOverlaySettings() async {
    await platform.invokeMethod('openOverlaySettings');
  }

  /// ==========================================================================
  /// 🔍 isOverlayEnabled()
  /// --------------------------------------------------------------------------
  /// Checks if overlay permission is granted on Android.
  /// ==========================================================================
  Future<bool> isOverlayEnabled() async {
    final result = await platform.invokeMethod('isOverlayEnabled');
    return result;
  }

  // ============================================================================
  // (KEPT COMMENTED OUT EXACTLY AS YOU WROTE)
  // Legacy version of startOverlay() without permission checks.
  // ============================================================================

  // Future<void> showOverlay() async {
  //   try {
  //     await platform.invokeMethod('startOverlay');
  //   } catch (e) {
  //     log("Error starting overlay: $e");
  //   }
  // }

  /// ==========================================================================
  /// 🎯 showOverlay()
  /// --------------------------------------------------------------------------
  /// Safer version:
  /// 1. Check if overlay permission exists
  /// 2. If not → open settings
  /// 3. If yes → start Android overlay service
  /// ==========================================================================
  Future<void> showOverlay() async {
    try {
      log("showOverlay function called");
      bool overlayAllowed = await isOverlayEnabled(); // CHECK permission first

      if (!overlayAllowed) {
        log("Overlay permission NOT granted");
        await openOverlaySettings(); // open settings
        return; // DO NOT start overlay yet
      }

      // Permission granted → start overlay bubble
      await platform.invokeMethod('startOverlay');
    } catch (e) {
      log("Error starting overlay: $e");
    }
  }

  Future<void> openNotificationSettings() async {
    await platform.invokeMethod('openNotificationSettings');
  }

  /// ==========================================================================
  /// 🖥️ BUILD UI
  /// --------------------------------------------------------------------------
  /// Provides buttons:
  /// - Enable Accessibility Service
  /// - Enable Overlay Service
  /// - Show Overlay
  /// Shows the latest event from Android at the bottom.
  /// ==========================================================================
  @override
  Widget build(BuildContext context) {
    final mythemevar = Theme.of(context);
    return Scaffold(
      backgroundColor: mythemevar.cardColor,
      appBar: AppBar(
        backgroundColor: mythemevar.cardColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Permissions",
          style: TextStyle(
            fontFamily: GoogleFonts.workSans().fontFamily,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Button → Open accessibility settings
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 216, 162, 0),
                ),
                onPressed: openAccessibilitySettings,
                child: Text("Enable Accessibility Service"),
              ),

              SizedBox(height: 20),

              /// Button → Open overlay settings
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      mythemevar.colorScheme.secondary, // Button color
                  foregroundColor: Colors.white70, // Text/Icon color
                ),
                onPressed: openOverlaySettings,
                child: Text("Enable Overlay Service"),
              ),

              SizedBox(height: 20),

              /// Button → Trigger overlay bubble
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      mythemevar.colorScheme.secondary, // Button color
                  foregroundColor: Colors.white70, // Text/Icon color
                ),
                onPressed: showOverlay,
                child: Text("Show Overlay"),
              ),

              SizedBox(height: 20),

              /// Button → Trigger overlay bubble
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      mythemevar.colorScheme.secondary, // Button color
                  foregroundColor: Colors.white70, // Text/Icon color
                ),
                onPressed: openNotificationSettings,
                child: Text("openNotificationSettings"),
              ),

              SizedBox(height: 20),

              /// Section title
              Text(
                "Latest Event:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              /// Display the last received event update
              Text(latestEvent, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
