package com.example.js_native_android

import android.annotation.SuppressLint
import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.webkit.*
import android.widget.Toast
import androidx.appcompat.app.ActionBar
import java.time.Duration
import java.util.Date
import kotlin.math.log

class MainActivity : AppCompatActivity() {
    private var mWebView: WebView? = null
    @SuppressLint("JavascriptInterface")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_main)

        val webView = findViewById<WebView>(R.id.webView)
        val settings = webView.settings
        settings.javaScriptEnabled = true
        settings.allowFileAccess = true

        // 用于验证 JavascriptInterface 方式 H5 -> NA 通信
        webView.addJavascriptInterface(MyJSInterface(this), "jsinterface")

        // 用于验证 URL Router 方式 H5 -> NA 通信
        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                request?.let { req ->
                    Log.d("js_to_na", "url router 端能力耗时：${System.currentTimeMillis() - req.url.host!!.toLong()}ms")

                    if (req.url.scheme.equals("myapp")) {
                        Toast.makeText(applicationContext, " from JS : url router ${req.url}", Toast.LENGTH_LONG).show()
                        Thread.sleep(2000)
                        return true
                    }
                    webView.loadUrl(req.url.toString())
                }
                return true
            }
        }

        // 用于验证 Js Prompt 方式 H5 -> NA 通信
        webView.webChromeClient = object : WebChromeClient() {
            override fun onJsPrompt(view: WebView?, url: String?, message: String?, defaultValue: String?, result: JsPromptResult?): Boolean {
                defaultValue?.let {
                    Log.d("js_to_na", "onJsPrompt 端能力耗时：${System.currentTimeMillis() - it.toLong()}ms")
                }

                Toast.makeText(applicationContext, " from JS : js prompt ${message ?: "空 url"}, defaultValue : $defaultValue", Toast.LENGTH_LONG).show()
//                Thread.sleep(2000)
                result?.confirm("js prompt ok  ")
                return true
            }
        }
        webView.loadUrl("file:///android_asset/TestJS-Native.html")
        mWebView = webView
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.action_bar, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when(item.itemId) {
            R.id.action_load -> {
                Log.d("js_to_na", "action_load")
                mWebView?.loadUrl("javascript: methodFromNA(\"action_load\");")
                Log.d("js_to_na", "after action_load")
                return true
            }
            R.id.action_inject -> {
                Log.d("js_to_na", "action_inject")
                mWebView?.evaluateJavascript("methodFromNAForInject(\"action_inject\");") { res ->
                    Log.d("js_to_na", "callback: $res")
                }
                Log.d("js_to_na", "after action_inject")
                return true
            }
        }
        return super.onOptionsItemSelected(item)
    }
}

class MyJSInterface(private val mContext: Context) {
    @JavascriptInterface
    fun showToast(text: String) {
        Log.d("js_to_na", "java interface 端能力耗时：${System.currentTimeMillis() - text.toLong()}ms")
        Toast.makeText(mContext, " from JS : $text", Toast.LENGTH_LONG).show()
//        Thread.sleep(2000)
    }
}