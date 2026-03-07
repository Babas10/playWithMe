package org.gatherli.app

import android.os.Handler
import android.os.Looper
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "org.gatherli.app/install_referrer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getReferrerString" -> fetchReferrerString(result)
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Reads the Play Install Referrer string asynchronously and delivers it
     * back to Flutter via [result].
     *
     * The referrer string is set by invite.html (Story 19.1) as
     * `invite_token=<token>` in the Play Store URL. The Play Install Referrer
     * API makes it available on first launch only.
     */
    private fun fetchReferrerString(result: MethodChannel.Result) {
        val referrerClient = InstallReferrerClient.newBuilder(this).build()

        referrerClient.startConnection(object : InstallReferrerStateListener {
            override fun onInstallReferrerSetupFinished(responseCode: Int) {
                val mainHandler = Handler(Looper.getMainLooper())
                when (responseCode) {
                    InstallReferrerClient.InstallReferrerResponse.OK -> {
                        val referrer =
                            referrerClient.installReferrer?.installReferrer
                        mainHandler.post { result.success(referrer) }
                        referrerClient.endConnection()
                    }
                    else -> {
                        // Not installed via Play Store, or referrer unavailable.
                        mainHandler.post { result.success(null) }
                        referrerClient.endConnection()
                    }
                }
            }

            override fun onInstallReferrerServiceDisconnected() {
                Handler(Looper.getMainLooper()).post { result.success(null) }
            }
        })
    }
}
