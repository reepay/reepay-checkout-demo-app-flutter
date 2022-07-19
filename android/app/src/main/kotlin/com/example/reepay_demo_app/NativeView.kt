package com.example.reepay_demo_app

import android.app.Activity
import android.content.Context
import android.content.res.AssetManager
import android.graphics.Color
import android.os.Build
import android.view.View
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebSettings.LOAD_DEFAULT
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.TextView
import android.widget.Toast
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.File
import java.io.InputStream

internal class NativeView(context: Context?, id: Int, creationParams: Map<String, Any>?) : PlatformView {

    private val webView: WebView? = context?.let { WebView(it) };


    override fun getView(): View? {
        webView!!.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                return false
            }

            override fun doUpdateVisitedHistory(view: WebView?, url: String?, isReload: Boolean) {
                println("updated");
                println(url);

                print(MainActivity.flutterEngineInstance);

            var channel = MethodChannel(MainActivity.flutterEngineInstance!!.dartExecutor.binaryMessenger, "TEST_CHANNEL")
            channel.invokeMethod("test", "lol")





                super.doUpdateVisitedHistory(view, url, isReload)
            }
        }
        return webView
    }

//    private val textView: TextView
//    override fun getView(): View? {
//        return textView
//    }

    override fun dispose() {}

    init {
        webView?.settings?.allowFileAccess = false;
        webView?.settings?.allowFileAccessFromFileURLs = false;
        webView?.settings?.allowUniversalAccessFromFileURLs = false;
        webView?.settings?.setAppCacheEnabled(true); // make you able to run the website w/o an internet connection
        webView?.settings?.cacheMode = LOAD_DEFAULT;

        webView?.settings?.setSupportZoom(false);
        webView?.settings?.builtInZoomControls = false;
        webView?.settings?.displayZoomControls = false;

        webView?.settings?.textZoom = 100;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            webView?.settings?.safeBrowsingEnabled = true  // api 26
        }

        webView?.settings?.useWideViewPort = true
        webView?.settings?.loadWithOverviewMode = true

        webView?.getSettings()?.setJavaScriptEnabled(true)
        //webView?.loadUrl("https://angular-reepay-demo.herokuapp.com/")
        //webView?.loadUrl("https://checkout.reepay.com/#/cs_8c855ce8a9005bce32dfa7ee141c1de4")
        //webView?.loadUrl("http://localhost:4200/")
        webView?.loadUrl("file:///android_asset/www/index.html");

//        textView = TextView(context)
//        textView.textSize = 42f
//        textView.setBackgroundColor(Color.rgb(255, 255, 255))
//        textView.text = "Rendered on a native Android view (id: $id)"
    }
}

