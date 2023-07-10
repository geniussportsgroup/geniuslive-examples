package com.example.showcaseandroid

import android.annotation.SuppressLint
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.OrientationEventListener
import android.view.View
import android.view.Window
import android.view.WindowManager
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Button
import android.widget.EditText
import android.widget.FrameLayout
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.example.showcaseandroid.databinding.ActivityMainBinding
import com.geniussports.Types.VideoConfiguration
import com.geniussports.videoplayer.VideoSDK
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import java.lang.Exception

open class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    var webView: WebView? = null
    private var isReversePortrait: Boolean = false
    private var isReverseLandscape: Boolean = false

    private lateinit var etFakeFixtureId: EditText
    private lateinit var etCgFixtureId : EditText
    private lateinit var btnLoadVideo : Button

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

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        changeRequestedOrientation(newConfig)
    }

    private fun setupLayout() {
        etFakeFixtureId = findViewById(R.id.etFakeFixtureId)
        etCgFixtureId = findViewById(R.id.etFixtureId)
        btnLoadVideo = findViewById(R.id.btnLoadVideo)

        btnLoadVideo.setOnClickListener{loadWebViewPlayer()}

        webView = findViewById(R.id.webview)
        webView?.settings?.javaScriptEnabled = true
        webView?.settings?.domStorageEnabled = true
        webView?.settings?.allowFileAccess = true
        webView?.webChromeClient = MyChrome(webView, window, this)
        webView?.webViewClient = WebViewClient()

        windowInsetsController =
            WindowCompat.getInsetsController(window, window.decorView)
        windowInsetsController?.systemBarsBehavior =
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
    }

    private fun loadWebViewPlayer() {

        val configuration = VideoConfiguration().apply {
            fixtureId = etFakeFixtureId.text.toString()
            cgFixtureId = etCgFixtureId.text.toString()
            customerId = "[CustomerId]"
            apikey = "[CustomerApiKey]"
            user = "[CustomerUser]"
            password = "[CustomerPassword]"
        }

        runBlocking {
            launch {
                try {
                    val res: String = VideoSDK().getVideoStream(configuration)
                    webView?.loadDataWithBaseURL(
                        "http://www.example.com?fixtureImmersive=${etCgFixtureId.text.toString()}",
                        res,
                        "text/html",
                        "UTF-8",
                        ""
                    )
                } catch (exception: Exception)
                {
                    Log.d("Exception", exception.toString())
                }
            }
        }
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