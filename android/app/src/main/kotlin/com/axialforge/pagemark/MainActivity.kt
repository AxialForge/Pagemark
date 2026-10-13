package com.axialforge.pagemark

import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FragmentActivity is required by local_auth (biometric prompt).
class MainActivity : FlutterFragmentActivity() {
    private var intentChannel: MethodChannel? = null

    /** What the Share sheet or a launcher shortcut asked for, until Dart picks it up (once). */
    private var pending: Map<String, String>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Only a fresh start counts: after process death Android replays the old intent, which must not re-open a share.
        if (savedInstanceState == null) pending = describe(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val m = describe(intent) ?: return
        setIntent(Intent()) // consumed
        intentChannel?.invokeMethod("incoming", m)
    }

    /** Shared text (untrusted, capped) or one of the two launcher shortcuts; anything else is ignored. */
    private fun describe(i: Intent?): Map<String, String>? {
        if (i == null) return null
        return when (i.action) {
            Intent.ACTION_SEND ->
                if (i.type?.startsWith("text/") == true) {
                    val text = (i.getStringExtra(Intent.EXTRA_TEXT) ?: i.getStringExtra(Intent.EXTRA_SUBJECT) ?: "").take(1000)
                    if (text.isBlank()) null else mapOf("type" to "text", "text" to text)
                } else null
            "com.axialforge.pagemark.ADD" -> mapOf("type" to "shortcut", "name" to "add")
            "com.axialforge.pagemark.READING" -> mapOf("type" to "shortcut", "name" to "reading")
            else -> null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        intentChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pagemark/intent").also { ch ->
            ch.setMethodCallHandler { call, result ->
                if (call.method == "take") {
                    val m = pending
                    pending = null
                    result.success(m)
                } else {
                    result.notImplemented()
                }
            }
        }
        // FLAG_SECURE: no screenshots / screen recording, blank thumbnail in recents.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pagemark/secure")
            .setMethodCallHandler { call, result ->
                if (call.method == "setSecure") {
                    val on = call.arguments as? Boolean ?: false
                    runOnUiThread {
                        if (on) window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        else window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
