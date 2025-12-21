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

import android.util.Log


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

            //on bubble click
            setOnClickListener {

                expand()

                //open app
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

        //add button
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

        //Cancel button minimize
        expandedView.findViewById<View>(R.id.cancelBtn).setOnClickListener {

            Log.d("OVERLAY_BTN", "Cancel button clicked")

            minimize()

            // minmize app on cancel button click
            // val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            //     addCategory(Intent.CATEGORY_HOME)
            //     flags = Intent.FLAG_ACTIVITY_NEW_TASK
            // }
            // startActivity(homeIntent)
        }

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
