
// package com.kobi.budget_book

// import android.app.Application
// import io.flutter.embedding.engine.FlutterEngine
// import io.flutter.embedding.engine.dart.DartExecutor
// import io.flutter.embedding.engine.FlutterEngineCache

// /// ============================================================================
// /// 🏁 MyApplication
// /// ----------------------------------------------------------------------------
// /// This is a custom Application class used to:
// ///   ✔ Pre-initialize a FlutterEngine at app startup  
// ///   ✔ Execute Dart entrypoint *before* any activity or service runs  
// ///   ✔ Store the engine inside FlutterEngineCache so:
// ///        • MainActivity
// ///        • MyOverlayService
// ///        • AccessibilityService
// ///     can all access and share the SAME Flutter engine.
// ///
// /// WHY THIS IS IMPORTANT:
// ///   • Prevents multiple engines from spawning
// ///   • Saves memory
// ///   • Speeds up overlay launching
// ///   • Ensures MethodChannel/EventChannel remain consistent
// ///
// /// NOTHING has been changed — only comments added.
// /// ============================================================================
// class MyApplication : Application() {

//     override fun onCreate() {
//         super.onCreate()

//         // ---------------------------------------------------------------------
//         // 1️⃣ Create a FlutterEngine for the entire app.
//         //    This engine can run dart code even before any Activity is shown.
//         // ---------------------------------------------------------------------
//         val engine = FlutterEngine(this)

//         // ---------------------------------------------------------------------
//         // 2️⃣ Start running Dart code inside this engine.
//         //    This triggers the default Dart entrypoint (main.dart).
//         // ---------------------------------------------------------------------
//         // engine.dartExecutor.executeDartEntrypoint(
//         //     DartExecutor.DartEntrypoint.createDefault()
//         // )

//         val bundlePath = io.flutter.embedding.engine.loader.FlutterLoader().findAppBundlePath()
// val entrypoint = DartExecutor.DartEntrypoint(bundlePath, "overlayEntryPoint")
// engine.dartExecutor.executeDartEntrypoint(entrypoint)


//         // ---------------------------------------------------------------------
//         // 3️⃣ Save the engine in FlutterEngineCache so it can be reused globally.
//         //
//         //    Accessible using:
//         //       FlutterEngineCache.getInstance().get("shared_engine")
//         //
//         //    This avoids engine recreation and ensures synchronization between:
//         //       • MainActivity
//         //       • Overlay Service
//         //       • Accessibility Service
//         // ---------------------------------------------------------------------
//         FlutterEngineCache
//             .getInstance()
//             .put("shared_engine", engine)
//     }
// }

package com.kobi.budget_book

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.embedding.engine.FlutterEngineCache
import android.util.Log

class MyApplication : Application() {

    override fun onCreate() {
    super.onCreate()

    val loader = FlutterLoader()
    loader.startInitialization(this)
    loader.ensureInitializationComplete(this, null)

    val entryPoint = DartExecutor.DartEntrypoint(
        loader.findAppBundlePath(),
        "overlayEntryPoint"
    )

    val engine = FlutterEngine(this)
    engine.dartExecutor.executeDartEntrypoint(entryPoint)

    FlutterEngineCache.getInstance().put("shared_engine", engine)
}

}

