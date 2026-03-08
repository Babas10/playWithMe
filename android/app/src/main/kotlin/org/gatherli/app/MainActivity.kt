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
     *
     * A 5-second timeout prevents the app from hanging at startup if the
     * Play Store service is unavailable (e.g. airplane mode, no Play Store).
     */
    private fun fetchReferrerString(result: MethodChannel.Result) {
        val mainHandler = Handler(Looper.getMainLooper())
        val referrerClient = InstallReferrerClient.newBuilder(this).build()

        // Track whether the result has already been delivered to avoid
        // calling result.success() twice (once from callback, once from timeout).
        var resultDelivered = false

        // Safety timeout: deliver null if the Play Store service never responds.
        val timeoutRunnable = Runnable {
            if (!resultDelivered) {
                resultDelivered = true
                result.success(null)
                try { referrerClient.endConnection() } catch (_: Exception) {}
            }
        }
        mainHandler.postDelayed(timeoutRunnable, 5_000L)

        referrerClient.startConnection(object : InstallReferrerStateListener {
            override fun onInstallReferrerSetupFinished(responseCode: Int) {
                mainHandler.removeCallbacks(timeoutRunnable)
                if (resultDelivered) return
                resultDelivered = true

                val referrer = if (responseCode == InstallReferrerClient.InstallReferrerResponse.OK) {
                    referrerClient.installReferrer?.installReferrer
                } else {
                    null // Not installed via Play Store, or referrer unavailable.
                }
                mainHandler.post { result.success(referrer) }
                referrerClient.endConnection()
            }

            override fun onInstallReferrerServiceDisconnected() {
                mainHandler.removeCallbacks(timeoutRunnable)
                if (resultDelivered) return
                resultDelivered = true
                mainHandler.post { result.success(null) }
            }
        })
    }
}
