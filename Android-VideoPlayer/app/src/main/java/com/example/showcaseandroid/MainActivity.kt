package com.example.showcaseandroid

import android.annotation.SuppressLint
import android.app.Dialog
import android.content.Context
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.graphics.Bitmap
import android.os.Bundle
import android.util.DisplayMetrics
import android.view.Gravity
import android.view.LayoutInflater
import android.view.OrientationEventListener
import android.view.View
import android.view.Window
import android.view.WindowManager
import android.webkit.CookieManager
import android.webkit.JavascriptInterface
import android.webkit.PermissionRequest
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Button
import android.widget.FrameLayout
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.example.Template.Template.Companion.geniusTemplate
import com.example.showcaseandroid.databinding.ActivityMainBinding
import org.json.JSONObject


open class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    var webView: WebView? = null
    private var isReversePortrait: Boolean = false
    private var isReverseLandscape: Boolean = false

    var orientationEventListener: OrientationEventListener? = null
    var windowInsetsController : WindowInsetsControllerCompat? = null

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupLayout()
        loadWebViewPlayer()

        orientationEventListener = object : OrientationEventListener(this) {
            override fun onOrientationChanged(orientation: Int) {
                handleOrientationChange(orientation)
            }
        }
    }

    override fun onResume() {
        super.onResume()
        orientationEventListener?.enable()
    }

    override fun onPause() {
        super.onPause()
        orientationEventListener?.disable()
    }
    override fun onDestroy() {
        super.onDestroy()
        // Remove the FLAG_KEEP_SCREEN_ON flag
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        // This script closes the video to avoid leaking HTTP request.
        // Feel free to incorporate this code where needed to ensure a clean handling of resources.
        // For example, you may want to close the video when changing between tabs or navigating around
        val scriptFunction = "javascript:" +
                """
                if (window.GeniusLivePlayer?.player) {
                        window.GeniusLivePlayer.player.close()
                }
            """.trimIndent()
        webView!!.loadUrl(scriptFunction)
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        changeRequestedOrientation(newConfig)
    }

    internal class JavaScriptInterface(private val context: Context) {
        var dialogTop: Double = 0.0
        var dialogWidth: Double = 0.0
        var dialogHeight: Double = 0.0
        var dialogLeft: Double = 0.0
        @JavascriptInterface
        fun postSelectedMarket(betslipItem: String) {

            val jsonObject = JSONObject(betslipItem)

            // Extract fields from the JSON object

            val command: String = jsonObject.optString("command", "")
            val sportsbookFixtureId: String = jsonObject.optString("sportsbookFixtureId", "")
            val sportsbookSelectionId: String = jsonObject.optString("sportsbookSelectionId", "")
            val marketId: String = jsonObject.optString("marketId", "")
            val sportsbookMarketId: String = jsonObject.optString("sportsbookMarketId", "")
            val sportsbookMarketContext: String = jsonObject.optString("sportsbookMarketContext", "")
            val decimalPrice: String = jsonObject.optString("decimalPrice", "")
            val stake: String = jsonObject.optString("stake", "")

            val dialogView = LayoutInflater.from(context).inflate(R.layout.betslip, null)

            val dialog = Dialog(context)
            dialog.setContentView(dialogView)
            dialog.setCanceledOnTouchOutside(false);
            dialog.setTitle("Customer Betslip")
            val widthToUse = dialogWidth * context.getResources().getDisplayMetrics().density
            val heightToUse = dialogHeight * context.getResources().getDisplayMetrics().density

            dialog.window?.apply {
                setLayout(WindowManager.LayoutParams.WRAP_CONTENT, WindowManager.LayoutParams.WRAP_CONTENT)
                setGravity(Gravity.TOP or Gravity.START)
                clearFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)
                attributes = attributes.apply {
                    this.x = (dialogLeft * context.getResources().getDisplayMetrics().density).toInt() - 36
                    this.y = (dialogTop * context.getResources().getDisplayMetrics().density).toInt() - 36
                    this.width = widthToUse.toInt() + 72
                    this.height = heightToUse.toInt() + 72
                }
            }

            //var commandTextView: TextView =  dialogView.findViewById(R.id.commandTextView)
            //var sportsbookFixtureIdTextView: TextView =  dialogView.findViewById(R.id.sportsbookFixtureIdTextView)
            //var sportsbookSelectionIdTextView: TextView =  dialogView.findViewById(R.id.sportsbookSelectionIdTextView)
            //var marketIdTextView: TextView =  dialogView.findViewById(R.id.marketIdTextView)
            //var sportsbookMarketIdTextView: TextView =  dialogView.findViewById(R.id.sportsbookMarketIdTextView)
            //var sportsbookMarketContextTextView: TextView =  dialogView.findViewById(R.id.sportsbookMarketContextTextView)
            //var decimalPriceTextView: TextView =  dialogView.findViewById(R.id.decimalPriceTextView)
            //var stakeTextView: TextView =  dialogView.findViewById(R.id.stakeTextView)

            val addToBetslipButton: Button = dialogView.findViewById(R.id.addbetslip_button)
            val cancelButton: Button = dialogView.findViewById(R.id.cancel_button)

            commandTextView.text = "command: ${command}"
            sportsbookFixtureIdTextView.text = "sportsbookFixtureId: ${sportsbookFixtureId}"
            sportsbookSelectionIdTextView.text = "sportsbookSelectionId: ${sportsbookSelectionId}"
            marketIdTextView.text = "marketId: ${marketId}"
            sportsbookMarketIdTextView.text = "sportsbookMarketId: ${sportsbookMarketId}"
            sportsbookMarketContextTextView.text = "sportsbookMarketContext: ${sportsbookMarketContext}"
            decimalPriceTextView.text = "decimalPrice: ${decimalPrice}"
            stakeTextView.text = "stake: ${stake}"

            cancelButton.setOnClickListener {
                dialog.dismiss()
            }

            addToBetslipButton.setOnClickListener {
                val duration = Toast.LENGTH_SHORT

                val toast = Toast.makeText(context, "BET PLACED!!", duration)
                toast.show()
                dialog.dismiss()
            }

            dialog.show()
        }

        @JavascriptInterface
        fun postWindowSetup(setup: String) {

            val jsonObject = JSONObject(setup)

            dialogTop = jsonObject.optDouble("top", 0.0)
            dialogLeft = jsonObject.optDouble("left", 0.0)
            dialogWidth = jsonObject.optDouble("width", 0.0)
            dialogHeight = jsonObject.optDouble("height", 0.0)
        }
    }

    private fun setupLayout() {

        webView = findViewById(R.id.playerWebView)
        webView?.settings?.javaScriptEnabled = true
        webView?.settings?.domStorageEnabled = true
        webView?.settings?.allowFileAccess = true
        webView?.webChromeClient = MyChrome(webView, window, this)
        webView?.webViewClient = WebViewClient()
        webView?.addJavascriptInterface(JavaScriptInterface(this), "AndroidVideoPlayerBridge")

        if (android.os.Build.VERSION.SDK_INT >= 21) {
            CookieManager.getInstance().setAcceptThirdPartyCookies(webView, true)
        } else {
            CookieManager.getInstance().setAcceptCookie(true)
        }

        windowInsetsController =
            WindowCompat.getInsetsController(window, window.decorView)
        windowInsetsController?.systemBarsBehavior =
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE

        // Keep the screen on
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    private fun loadWebViewPlayer() {

        val baseGeniusLivePlayerUrl = "https://genius-live-player-uat.betstream.betgenius.com/widgetLoader?"
        val customerId: String = "0000"
        val fixtureId: String = "20000062994"
        val betVisionFixtureId: String = "9889284"
        val userSessionId: String = "123456"
        val region: String? = "CO"
        val device: String = "DESKTOP"
        val controlsEnabled: Boolean = true
        val audioEnabled: Boolean = true
        val autoplayEnabled: Boolean = true
        val allowFullScreen: Boolean = true
        val playerWidth: String = "100vw"
        val playerHeight: String = "100vh"
        val bufferLength: Int = 2
        val minWidth: String = "100px"

        val htmlTemplate = geniusTemplate

        val htmlTemplateMapped = htmlTemplate
            .replace("%{baseGeniusLivePlayerUrl}", baseGeniusLivePlayerUrl)
            .replace("%{customerId}", customerId)
            .replace("%{fixtureId}", fixtureId)
            .replace("%{userSessionId}", userSessionId)
            .replace("%{region}", region.toString())
            .replace("%{device}", device)
            .replace("%{audioEnabled}", audioEnabled.toString())
            .replace("%{controlsEnabled}", controlsEnabled.toString())
            .replace("%{autoplayEnabled}", autoplayEnabled.toString())
            .replace("%{allowFullScreen}", allowFullScreen.toString())
            .replace("%{playerWidth}", playerWidth)
            .replace("%{playerHeight}", playerHeight)
            .replace("%{bufferLength}", bufferLength.toString())
            .replace("%{minWidth}", minWidth)

        webView?.loadDataWithBaseURL(
            "https://www.example.com?fixtureImmersive=${betVisionFixtureId}",
            htmlTemplateMapped,
            "text/html",
            "UTF-8",
            ""
        )
    }

    private fun handleOrientationChange(orientation: Int) {
        val newConfig = resources.configuration
        when (orientation) {
            in 0..60, in 330..359 -> {
                newConfig.orientation = Configuration.ORIENTATION_PORTRAIT
                isReversePortrait = false
                isReverseLandscape = false
            }
            in 90..150 -> {
                newConfig.orientation = Configuration.ORIENTATION_LANDSCAPE
                isReversePortrait = false
                isReverseLandscape = true
            }
            in 180..210 -> {
                newConfig.orientation = Configuration.ORIENTATION_PORTRAIT
                isReversePortrait = true
                isReverseLandscape = false
            }
            in 240..300 -> {
                newConfig.orientation = Configuration.ORIENTATION_LANDSCAPE
                isReversePortrait = false
                isReverseLandscape = false
            }
        }
        onConfigurationChanged(newConfig)
    }

    private fun handlePortraitOrientation() {
        val scriptFunction = "javascript:" +
                "var isFullScreen = document.fullscreenElement;" +
                "if(isFullScreen) { document.querySelector('.full-screen-btn').click()}"
        windowInsetsController?.show(WindowInsetsCompat.Type.systemBars())
        webView?.loadUrl(scriptFunction)
    }

    private fun handleLandscapeOrientation() {
        val scriptFunction = "javascript:" +
                "var isFullScreen = document.fullscreenElement; " +
                "if(!isFullScreen) { document.querySelector('.full-screen-btn').click()}"
        windowInsetsController?.hide(WindowInsetsCompat.Type.systemBars())
        webView?.loadUrl(scriptFunction)
    }

    private fun changeRequestedOrientation(newConfig: Configuration) {
        if (newConfig.orientation == Configuration.ORIENTATION_PORTRAIT) {
            requestedOrientation = getPortraitOrientation()
            handlePortraitOrientation()
        } else if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            requestedOrientation = getLandscapeOrientation()
            handleLandscapeOrientation()
        }
    }

    private fun getPortraitOrientation(): Int {
        return if (isReversePortrait) {
            ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT
        } else {
            ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT
        }
    }

    private fun getLandscapeOrientation(): Int {
        return if (isReverseLandscape) {
            ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE
        } else {
            ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE
        }
    }

    private class MyChrome() : WebChromeClient() {
        var webView: WebView? = null
        var window: Window? = null
        var mainActivity: MainActivity? = null

        constructor(webView: WebView?, window: Window, mainActivity: MainActivity) : this() {
            this.webView = webView
            this.window = window
            this.mainActivity = mainActivity
        }

        override fun getDefaultVideoPoster(): Bitmap? {
            return Bitmap.createBitmap(10, 10, Bitmap.Config.ARGB_8888)
        }

        override fun onPermissionRequest(request: PermissionRequest) {
            request.grant(request.resources)
        }

        var fullscreen: View? = null
        override fun onHideCustomView() {
            fullscreen!!.visibility = View.GONE
            webView?.visibility = View.VISIBLE
        }

        override fun onShowCustomView(view: View, callback: CustomViewCallback) {
            webView?.visibility = View.GONE
            if (fullscreen != null) {
                (window?.decorView as FrameLayout).removeView(fullscreen)
            }
            fullscreen = view
            (window?.decorView as FrameLayout).addView(
                fullscreen,
                FrameLayout.LayoutParams(-1, -1)
            )
            fullscreen!!.visibility = View.VISIBLE
        }
    }
}