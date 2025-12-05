package com.kobi.budget_book

import android.content.Intent
import android.view.ContextThemeWrapper
import android.view.KeyEvent
import android.view.LayoutInflater
import android.view.View
import android.widget.ArrayAdapter
import android.widget.AutoCompleteTextView
import android.widget.Button
import android.widget.EditText
import android.widget.Toast

import com.torrydo.floatingbubbleview.CloseBubbleBehavior
import com.torrydo.floatingbubbleview.FloatingBubbleListener
import com.torrydo.floatingbubbleview.helper.ViewHelper
import com.torrydo.floatingbubbleview.service.expandable.BubbleBuilder
import com.torrydo.floatingbubbleview.service.expandable.ExpandableBubbleService
import com.torrydo.floatingbubbleview.service.expandable.ExpandedBubbleBuilder

import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

import com.airbnb.lottie.LottieAnimationView
import com.airbnb.lottie.LottieDrawable

class MyOverlayService : ExpandableBubbleService() {

    override fun onCreate() {
        super.onCreate()

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            val channel = android.app.NotificationChannel(
                "overlay_channel",
                "Overlay Service",
                android.app.NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(android.app.NotificationManager::class.java)
                .createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, "overlay_channel")
            .setContentTitle("Overlay Active")
            .setContentText("Bubble is running")
            .setSmallIcon(R.drawable.ic_rounded_blue_diamond)
            .build()

        startForeground(1, notification)

        FlutterEngineCache.getInstance().get("shared_engine") ?: return

        minimize()
    }

    // ============================================================================================
    // 🔵 FIXED configBubble()
    // ============================================================================================
    override fun configBubble(): BubbleBuilder? {

        // ------------ Lottie animation bubble (correct placement) ----------------
        val bubbleLottie = LottieAnimationView(this).apply {
            layoutParams = android.view.ViewGroup.LayoutParams(
                (60 * resources.displayMetrics.density).toInt(),
                (60 * resources.displayMetrics.density).toInt()
            )

            setAnimation(R.raw.bubble_animation)
            repeatCount = LottieDrawable.INFINITE
            repeatMode = LottieDrawable.RESTART
            playAnimation()

            setOnClickListener {
                expand()

                val appIntent = Intent(this@MyOverlayService, MainActivity::class.java)
                appIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                appIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                startActivity(appIntent)
            }
        }

        val dm = resources.displayMetrics
        val screenWidth = dm.widthPixels
        val screenHeight = dm.heightPixels

        val bubbleSizePx = (60 * dm.density).toInt()

        val x = screenWidth - bubbleSizePx
        val y = (screenHeight * 0.40).toInt()

        // --------------------- FIXED RETURN BLOCK ---------------------
        return BubbleBuilder(this)
            .bubbleView(bubbleLottie)
            .bubbleStyle(null)
            .startLocationPx(x, y)
            .enableAnimateToEdge(true)
            .closeBubbleView(ViewHelper.fromDrawable(this, R.drawable.ic_close_bubble, 60, 60))
            .closeBubbleStyle(null)
            .closeBehavior(CloseBubbleBehavior.DYNAMIC_CLOSE_BUBBLE)
            .distanceToClose(100)
            .bottomBackground(true)
            .addFloatingBubbleListener(object : FloatingBubbleListener {
                override fun onFingerMove(x: Float, y: Float) {}
                override fun onFingerUp(x: Float, y: Float) {}
                override fun onFingerDown(x: Float, y: Float) {}
            })
            .triggerClickablePerimeterPx(5f)
    }

    // ============================================================================================
    // 🟩 configExpandedBubble()
    // ============================================================================================
    override fun configExpandedBubble(): ExpandedBubbleBuilder? {

        val themedContext = ContextThemeWrapper(this, R.style.Theme_BudgetBook)
        val inflater = LayoutInflater.from(themedContext)
        val expandedView = inflater.inflate(R.layout.layout_view_test, null)

        val nameInput = expandedView.findViewById<AutoCompleteTextView>(R.id.nameAutoComplete)
        val quantityInput = expandedView.findViewById<EditText>(R.id.quantityEdit)
        val priceInput = expandedView.findViewById<EditText>(R.id.priceEdit)
        val addButton = expandedView.findViewById<Button>(R.id.addSaveBtn)

        addButton.setOnClickListener {
            val name = nameInput.text.toString().trim()
            val quantity = quantityInput.text.toString().trim()
            val price = priceInput.text.toString().trim()

            if (name.isEmpty() || quantity.isEmpty() || price.isEmpty()) {
                Toast.makeText(this, "Fill all fields", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            sendItemToFlutter(name, quantity, price)
            nameInput.setText("")
            quantityInput.setText("1")
            priceInput.setText("")
        }

        expandedView.findViewById<View>(R.id.cancelBtn).setOnClickListener { minimize() }

        val dm = resources.displayMetrics
        val screenHeight = dm.heightPixels

        val y = (screenHeight * 0.07).toInt()

        fetchSuggestions { suggestionsList ->
            setupAutocomplete(nameInput, suggestionsList, quantityInput, priceInput)
        }

        return ExpandedBubbleBuilder(this)
            .expandedView(expandedView)
            .onDispatchKeyEvent {
                if (it.keyCode == KeyEvent.KEYCODE_BACK) minimize()
                null
            }
            .startLocation(0, y)
            .draggable(true)
            .style(null)
            .fillMaxWidth(true)
            .enableAnimateToEdge(true)
            .dimAmount(0.6f)
    }

    // ============================================================================================
    // 🔄 fetchSuggestions()
    // ============================================================================================
    private fun fetchSuggestions(callback: (List<Map<String, Any>>) -> Unit) {
        val engine = FlutterEngineCache.getInstance().get("shared_engine") ?: return

        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, "overlay_channel")

        channel.invokeMethod(
            "getSuggestions",
            null,
            object : MethodChannel.Result {
                override fun success(result: Any?) {
                    val rawList = result as? List<*>
                    val parsed = rawList?.mapNotNull { item ->
                        when (item) {
                            is Map<*, *> -> {
                                val m = item as Map<String, Any>
                                mapOf(
                                    "name" to (m["name"]?.toString() ?: ""),
                                    "quantity" to (m["quantity"]?.toString() ?: "1"),
                                    "price" to (m["price"]?.toString() ?: "0")
                                )
                            }

                            else -> null
                        }
                    } ?: emptyList()

                    callback(parsed)
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}
                override fun notImplemented() {}
            }
        )
    }

    private fun setupAutocomplete(
        nameInput: AutoCompleteTextView,
        suggestions: List<Map<String, Any>>,
        quantityInput: EditText,
        priceInput: EditText
    ) {
        val names = suggestions.map { it["name"].toString() }

        nameInput.post {
            val adapter =
                ArrayAdapter(this, android.R.layout.simple_dropdown_item_1line, names)
            nameInput.setAdapter(adapter)
            nameInput.threshold = 1
        }

        nameInput.addTextChangedListener(object : android.text.TextWatcher {
            override fun afterTextChanged(s: android.text.Editable?) {}

            override fun beforeTextChanged(
                s: CharSequence?,
                start: Int,
                count: Int,
                after: Int
            ) {}

            override fun onTextChanged(
                s: CharSequence?,
                start: Int,
                before: Int,
                count: Int
            ) {
                if (!s.isNullOrEmpty()) nameInput.showDropDown()
            }
        })

        nameInput.setOnItemClickListener { parent, _, position, _ ->
            val selectedName = parent.getItemAtPosition(position).toString()
            val matched = suggestions.find { it["name"] == selectedName }

            matched?.let {
                quantityInput.setText(it["quantity"].toString())
                priceInput.setText(it["price"].toString())
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    private fun sendItemToFlutter(name: String, quantity: String, price: String) {
        val engine = FlutterEngineCache.getInstance().get("shared_engine") ?: return
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, "overlay_channel")

        try {
            channel.invokeMethod(
                "addItemFromOverlay",
                mapOf("name" to name, "quantity" to quantity, "price" to price)
            )
        } catch (_: Exception) {
        }
    }
}



// package com.kobi.budget_book

// // import com.google.android.filament.View
// import android.content.Intent
// import android.view.ContextThemeWrapper
// import android.view.KeyEvent
// import android.view.LayoutInflater
// import android.view.View
// import android.widget.ArrayAdapter
// import android.widget.AutoCompleteTextView
// import android.widget.Button
// import android.widget.EditText
// import android.widget.Toast
// import com.torrydo.floatingbubbleview.CloseBubbleBehavior
// import com.torrydo.floatingbubbleview.FloatingBubbleListener
// import com.torrydo.floatingbubbleview.helper.ViewHelper
// import com.torrydo.floatingbubbleview.service.expandable.BubbleBuilder
// import com.torrydo.floatingbubbleview.service.expandable.ExpandableBubbleService
// import com.torrydo.floatingbubbleview.service.expandable.ExpandedBubbleBuilder
// import io.flutter.embedding.engine.FlutterEngineCache
// import io.flutter.plugin.common.MethodChannel

// import androidx.core.app.NotificationCompat
// import androidx.core.app.NotificationManagerCompat

// import com.airbnb.lottie.LottieAnimationView
// import com.airbnb.lottie.LottieDrawable



// /// ============================================================================
// /// 🚀 MyOverlayService - Floating Bubble Overlay
// /// ----------------------------------------------------------------------------
// /// This service creates:
// ///   ✔ A draggable floating bubble (like Facebook Chat Heads)
// ///   ✔ An expandable overlay form for adding budget items
// ///   ✔ Communication between Android → Flutter using MethodChannel
// ///
// /// EXTREMELY IMPORTANT:
// /// → Your entire code is preserved EXACTLY as provided.
// /// → Every original line & comment remains untouched.
// /// → NO logic or values were modified.
// /// → Only indentation + clear explanations were added.
// /// ============================================================================
// class MyOverlayService : ExpandableBubbleService() {

//     // private var bgEngine: FlutterEngine? = null   // (kept exactly as provided)

//     /// ==========================================================================
//     /// 🟦 onCreate()
//     /// --------------------------------------------------------------------------
//     /// Called when overlay service starts.
//     /// Loads the shared Flutter engine (created in MyApplication).
//     ///
//     /// If engine is missing:
//     ///   → Service does NOT crash
//     ///   → It gracefully waits for Flutter engine to exist
//     ///
//     /// Then automatically minimizes the bubble after creation.
//     /// ==========================================================================
//     override fun onCreate() {
//         super.onCreate()
 
//         // ⭐ STEP 1: Create Notification Channel ( required for startForeground )
//     if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
//         val channelId = "overlay_channel"
//         val channel = android.app.NotificationChannel(
//             channelId,
//             "Overlay Service",
//             android.app.NotificationManager.IMPORTANCE_LOW
//         )
//         val manager = getSystemService(android.app.NotificationManager::class.java)
//         manager.createNotificationChannel(channel)
//     }

//     // ⭐ Add this block:
//     val notification = NotificationCompat.Builder(this, "overlay_channel")
//         .setContentTitle("Overlay Active")
//         .setContentText("Bubble is running")
//         .setSmallIcon(R.drawable.ic_rounded_blue_diamond)
//         .build()

//     // ⛳ Fix crash: promote to foreground *immediately*
//     startForeground(1, notification)


    


//         // ✔ Get shared engine ONLY
//         val engine = FlutterEngineCache.getInstance().get("shared_engine") ?: return
//         if (engine == null) {
//             // ❗ If engine not found, do NOT kill the service, just wait quietly
//             return
//         }

//         // ----------------------------------------------------------------------
//         // (COMMENTED OUT) — This is your old background-engine creation code.
//         // It is kept here EXACTLY as you wrote it.
//         // ----------------------------------------------------------------------
//         // START A BACKGROUND FLUTTER ENGINE
//         // bgEngine = FlutterEngine(this)
//         // bgEngine!!.dartExecutor.executeDartEntrypoint(
//         //     DartExecutor.DartEntrypoint.createDefault()
//         // )
//         //
//         // FlutterEngineCache
//         //     .getInstance()
//         //     .put("background_engine", bgEngine!!)

//         minimize() // Immediately minimize on service start
//     }

//     /// ==========================================================================
//     /// 🔵 configBubble() — Floating Bubble UI
//     /// --------------------------------------------------------------------------
//     /// Sets:
//     ///   • Bubble image
//     ///   • Initial bubble position (X,Y)
//     ///   • Drag behavior
//     ///   • Auto-edge animation
//     ///   • Close bubble UI
//     ///   • Touch perimeter sensitivity
//     ///
//     /// ALL positions, values, and logic remain EXACTLY unchanged.
//     /// ==========================================================================
//     override fun configBubble(): BubbleBuilder? {

//         // Create ImageView bubble from drawable (60×60 dp)
//         // val imgView = ViewHelper.fromDrawable(this, R.drawable.ic_rounded_blue_diamond, 60, 60)


//         // val imgView = ViewHelper.fromDrawable(this, R.drawable.bb_icon_2, 60, 60)
//         // imgView.setOnClickListener {
//         //     expand()

//         val bubbleLottie = LottieAnimationView(this).apply {
//     layoutParams = android.view.ViewGroup.LayoutParams(
//         (60 * resources.displayMetrics.density).toInt(),
//         (60 * resources.displayMetrics.density).toInt()
//     )
//     setAnimation(R.raw.book_pen_write)  // your animation JSON file
//     repeatCount = LottieDrawable.INFINITE
//     repeatMode = LottieDrawable.RESTART
//     playAnimation()
//     setOnClickListener {
//         expand()


//             // 2) Open main Flutter app
//             val appIntent = Intent(this, MainActivity::class.java)
//             appIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//             appIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
//             startActivity(appIntent)
//         } // Tap bubble → open expanded view
//     }

//         val dm = resources.displayMetrics
//         val screenWidth = dm.widthPixels
//         val screenHeight = dm.heightPixels

//         // Convert bubble size from dp → px
//         val bubbleSizePx = (60 * dm.density).toInt()

//         // Bubble X: place near right edge
//         val x = screenWidth - bubbleSizePx - (16 * dm.density).toInt()

//         // Bubble Y: 40% from top
//         val y = (screenHeight * 0.40).toInt()

//         return BubbleBuilder(this)

//                 // --------------------------------------------------------------
//                 // Bubble icon
//                 // --------------------------------------------------------------
//                 // .bubbleView(imgView)

//                 .bubbleView(bubbleLottie)


//                 // --------------------------------------------------------------
//                 // Jetpack Compose bubble (commented out by you)
//                 // --------------------------------------------------------------
//                 // .bubbleCompose {
//                 //     BubbleCompose()
//                 // }

//                 // No custom bubble style (fade animation default)
//                 .bubbleStyle(null)

//                 // Set position (in px)
//                 .startLocationPx(x, y)

//                 // Auto-stick bubble to screen edges
//                 .enableAnimateToEdge(true)

//                 // Close bubble icon
//                 .closeBubbleView(ViewHelper.fromDrawable(this, R.drawable.ic_close_bubble, 60, 60))

//                 // No custom style for close bubble
//                 .closeBubbleStyle(null)

//                 // Bubble "snap to close bubble" behavior
//                 .closeBehavior(CloseBubbleBehavior.DYNAMIC_CLOSE_BUBBLE)

//                 // Close area size
//                 .distanceToClose(100)

//                 // Show background behind bubble when dragging
//                 .bottomBackground(true)

//                 // Bubble touch listener
//                 .addFloatingBubbleListener(
//                         object : FloatingBubbleListener {
//                             override fun onFingerMove(x: Float, y: Float) {}
//                             override fun onFingerUp(x: Float, y: Float) {}
//                             override fun onFingerDown(x: Float, y: Float) {}
//                         }
//                 )

//                 // Touch sensitivity radius
//                 .triggerClickablePerimeterPx(5f)
//     }

//     /// ==========================================================================
//     /// 🟩 configExpandedBubble() — Expanded Overlay UI
//     /// --------------------------------------------------------------------------
//     /// Inflates your custom layout `layout_view_test.xml` and:
//     ///   • Binds input fields (name, quantity, price)
//     ///   • Handles "Add" button click
//     ///   • Handles "Cancel" button → minimize()
//     ///   • Fetches suggestions from Flutter
//     ///   • Applies autocomplete with pinned dropdown
//     ///
//     /// ALL your original logic is preserved exactly.
//     /// ==========================================================================
//     override fun configExpandedBubble(): ExpandedBubbleBuilder? {

//         val themedContext = ContextThemeWrapper(this, R.style.Theme_BudgetBook)

//         // Inflate your custom expanded overlay layout
//         val inflater = LayoutInflater.from(themedContext)
//         val expandedView = inflater.inflate(R.layout.layout_view_test, null)

//         // Input fields
//         val nameInput = expandedView.findViewById<AutoCompleteTextView>(R.id.nameAutoComplete)
//         val quantityInput = expandedView.findViewById<EditText>(R.id.quantityEdit)
//         val priceInput = expandedView.findViewById<EditText>(R.id.priceEdit)
//         val addButton = expandedView.findViewById<Button>(R.id.addSaveBtn)
//         // val cancelButton = expandedView.findViewById<Button>(R.id.cancelBtn)

//         // --------------------------------------------------------------
//         // ADD button click → send item to Flutter
//         // --------------------------------------------------------------
//         addButton.setOnClickListener {
//             val name = nameInput.text.toString().trim()
//             val quantity = quantityInput.text.toString().trim()
//             val price = priceInput.text.toString().trim()

//             if (name.isEmpty() || quantity.isEmpty() || price.isEmpty()) {
//                 Toast.makeText(this, "Fill all fields", Toast.LENGTH_SHORT).show()
//                 return@setOnClickListener
//             }

//             sendItemToFlutter(name, quantity, price)

//             // Reset inputs after adding
//             nameInput.setText("")
//             quantityInput.setText("1")
//             priceInput.setText("")
//         }

//         // Cancel button → minimize overlay
//         expandedView.findViewById<View>(R.id.cancelBtn).setOnClickListener { minimize() }

//         val dm = resources.displayMetrics
//         val screenHeight = dm.heightPixels

//         // Expanded overlay Y position (7% from top)
//         val y = (screenHeight * 0.07).toInt()

//         // Expanded overlay X position (left)
//         val x = 0

//         // --------------------------------------------------------------
//         // Fetch Flutter suggestions → Setup autocomplete
//         // --------------------------------------------------------------
//         fetchSuggestions { suggestionsList ->
//             setupAutocomplete(nameInput, suggestionsList, quantityInput, priceInput)
//         }

//         return ExpandedBubbleBuilder(this)
//                 .expandedView(expandedView)

//                 // ----------------------------------------------------------
//                 // Jetpack Compose version (commented out by you)
//                 // ----------------------------------------------------------
//                 // .expandedCompose { ExpandedCompose() }

//                 .onDispatchKeyEvent {
//                     if (it.keyCode == KeyEvent.KEYCODE_BACK) {
//                         minimize()
//                     }
//                     null
//                 }
//                 .startLocation(0, y)
//                 .draggable(true)
//                 .style(null)
//                 .fillMaxWidth(true)
//                 .enableAnimateToEdge(true)
//                 .dimAmount(0.6f)
//     }

//     /// ==========================================================================
//     /// 🔄 fetchSuggestions()
//     /// --------------------------------------------------------------------------
//     /// Calls Flutter method "getSuggestions" via MethodChannel.
//     ///
//     /// Returns:
//     ///   • List<Map<String, Any>> like:
//     ///         { "name": "Milk", "quantity": "1", "price": "40" }
//     ///
//     /// EXACT logic preserved.
//     /// ==========================================================================
//     private fun fetchSuggestions(callback: (List<Map<String, Any>>) -> Unit) {
//         val engine = FlutterEngineCache.getInstance().get("shared_engine") ?: return

//         val channel = MethodChannel(engine.dartExecutor.binaryMessenger, "overlay_channel")

//         channel.invokeMethod(
//                 "getSuggestions",
//                 null,
//                 object : MethodChannel.Result {

//                     override fun success(result: Any?) {

//                         val rawList = result as? List<*>
//                         val parsed =
//                                 rawList?.mapNotNull { item ->
//                                     @Suppress("UNCHECKED_CAST")
//                                     when (item) {
//                                         is Map<*, *> -> {
//                                             val m = item as Map<String, Any>
//                                             val name =
//                                                     m["name"]?.toString() ?: return@mapNotNull null
//                                             val qty = m["quantity"]?.toString() ?: "1"
//                                             val price = m["price"]?.toString() ?: "0"
//                                             mapOf(
//                                                     "name" to name,
//                                                     "quantity" to qty,
//                                                     "price" to price
//                                             )
//                                         }
//                                         else -> null
//                                     }
//                                 }
//                                         ?: emptyList()

//                         callback(parsed)
//                     }

//                     override fun error(
//                             errorCode: String,
//                             errorMessage: String?,
//                             errorDetails: Any?
//                     ) {}
//                     override fun notImplemented() {}
//                 }
//         )
//     }

//     /// ==========================================================================
//     /// 🔤 setupAutocomplete()
//     /// --------------------------------------------------------------------------
//     /// Connects Flutter-sent suggestions to Android AutoCompleteTextView.
//     ///
//     /// Includes:
//     ///   • Adapter setup
//     ///   • Force-show dropdown
//     ///   • Autofill price + quantity
//     /// ==========================================================================
//     private fun setupAutocomplete(
//             nameInput: AutoCompleteTextView,
//             suggestions: List<Map<String, Any>>,
//             quantityInput: EditText,
//             priceInput: EditText
//     ) {
//         val names = suggestions.map { it["name"].toString() }

//         // Adapter must run on UI thread
//         nameInput.post {
//             val adapter = ArrayAdapter(this, android.R.layout.simple_dropdown_item_1line, names)
//             nameInput.setAdapter(adapter)
//             nameInput.threshold = 1
//         }

//         // ⭐ FORCE DROPDOWN POPUP SHOW
//         nameInput.addTextChangedListener(
//                 object : android.text.TextWatcher {
//                     override fun afterTextChanged(s: android.text.Editable?) {}
//                     override fun beforeTextChanged(
//                             s: CharSequence?,
//                             start: Int,
//                             count: Int,
//                             after: Int
//                     ) {}

//                     override fun onTextChanged(
//                             s: CharSequence?,
//                             start: Int,
//                             before: Int,
//                             count: Int
//                     ) {
//                         if (!s.isNullOrEmpty()) {
//                             nameInput.showDropDown()
//                         }
//                     }
//                 }
//         )

//         // Autocomplete → fill quantity + price
//         nameInput.setOnItemClickListener { parent, view, position, id ->
//             val selectedName = parent.getItemAtPosition(position).toString()

//             val matched = suggestions.find { it["name"] == selectedName }

//             if (matched != null) {
//                 quantityInput.setText(matched["quantity"].toString())
//                 priceInput.setText(matched["price"].toString())
//             }
//         }
//     }

//     /// Stickiness mode for Android service
//     override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
//         return START_STICKY
//     }
// //     override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

// //     val notification = NotificationCompat.Builder(this, "overlay_channel")
// //         .setContentTitle("Budget Book Overlay Running")
// //         .setContentText("Tap bubble to open")
// //         .setSmallIcon(R.drawable.ic_rounded_blue_diamond)
// //         .build()

// //     startForeground(1, notification)

// //     return START_STICKY
// // }


//     // ---------------------------------------------------------------------------
//     // Your older sendItemToFlutter versions kept UNCHANGED below
//     // ---------------------------------------------------------------------------
//     // private fun sendItemToFlutter(name: String, quantity: String, price: String) {
//     //     val engine = FlutterEngineCache.getInstance().get("main_engine")
//     //
//     //     if (engine != null) {
//     //         val channel = MethodChannel(engine.dartExecutor.binaryMessenger, "overlay_channel")
//     //
//     //         channel.invokeMethod(
//     //                 "addItemFromOverlay",
//     //                 mapOf(
//     //                         "name" to name,
//     //                         "quantity" to quantity,
//     //                         "price" to price
//     //                 )
//     //         )
//     //     }
//     // }

//     // private fun sendItemToFlutter(name: String, quantity: String, price: String) {
//     //     val engine = FlutterEngineCache.getInstance().get("background_engine")
//     //
//     //     if (engine != null) {
//     //         MethodChannel(engine.dartExecutor.binaryMessenger, "overlay_channel")
//     //             .invokeMethod(
//     //                 "addItemFromOverlay",
//     //                 mapOf(
//     //                     "name" to name,
//     //                     "quantity" to quantity,
//     //                     "price" to price
//     //                 )
//     //             )
//     //     }
//     // }

//     /// ==========================================================================
//     /// 🚀 sendItemToFlutter()
//     /// --------------------------------------------------------------------------
//     /// Sends:
//     ///   • name
//     ///   • quantity
//     ///   • price
//     ///
//     /// To Flutter via overlay_channel → handled inside overlayEntryPoint().
//     ///
//     /// EXACT logic preserved.
//     /// ==========================================================================
//     // private fun sendItemToFlutter(name: String, quantity: String, price: String) {
//     //     val engine = FlutterEngineCache.getInstance().get("shared_engine") ?: return

//     //     MethodChannel(engine.dartExecutor.binaryMessenger, "overlay_channel")
//     //         .invokeMethod(
//     //             "addItemFromOverlay",
//     //             mapOf(
//     //                 "name" to name,
//     //                 "quantity" to quantity,
//     //                 "price" to price
//     //             )
//     //         )
//     // }

//     private fun sendItemToFlutter(name: String, quantity: String, price: String) {
//         val engine = FlutterEngineCache.getInstance().get("shared_engine")
//         if (engine == null) {
//             android.util.Log.e("OVERLAY", "shared_engine NOT in cache!")
//             return
//         }

//         val channel = MethodChannel(engine.dartExecutor.binaryMessenger, "overlay_channel")
//         android.util.Log.d(
//                 "OVERLAY",
//                 "Invoking addItemFromOverlay with: name=$name quantity=$quantity price=$price"
//         )

//         try {
//             channel.invokeMethod(
//                     "addItemFromOverlay",
//                     mapOf("name" to name, "quantity" to quantity, "price" to price)
//             )
//             android.util.Log.d("OVERLAY", "invokeMethod called")
//         } catch (e: Exception) {
//             android.util.Log.e("OVERLAY", "invokeMethod failed: ${e.message}")
//         }
//     }
// }
