package dk.carp.carp_movesense_flutter

import android.util.Log
import io.flutter.plugin.common.BinaryMessenger

private const val TAG = "CarpMovesense"

/** Thin wrapper around generated FlutterApi classes. */
class MdsDartCallbacks(binaryMessenger: BinaryMessenger) {
    private val scanDeviceApi = CarpMovesenseScanDeviceFlutterApi(binaryMessenger)
    private val scanErrorApi = CarpMovesenseScanErrorFlutterApi(binaryMessenger)
    private val connectionApi = CarpMovesenseConnectionFlutterApi(binaryMessenger)
    private val requestApi = CarpMovesenseRequestFlutterApi(binaryMessenger)
    private val subscriptionApi = CarpMovesenseSubscriptionFlutterApi(binaryMessenger)

    fun scanDevice(name: String?, address: String) {
        scanDeviceApi.onScanDevice(NativeScanDevice(name, address), ::logCallback)
    }

    fun scanError(code: Long, message: String) {
        scanErrorApi.onScanError(NativeScanError(code, message), ::logCallback)
    }

    fun connection(type: String, address: String?, serial: String? = null, error: String? = null) {
        val event = NativeConnectionEvent(type, address, serial, error)
        connectionApi.onConnectionEvent(event, ::logCallback)
    }

    fun request(requestId: Long, success: Boolean, statusCode: Long, body: String, error: String) {
        val event = NativeMdsRequestEvent(requestId, success, statusCode, body, error)
        requestApi.onRequestEvent(event, ::logCallback)
    }

    fun subscription(
        type: String,
        requestId: Long,
        subscriptionId: Long,
        statusCode: Long,
        body: String,
        error: String
    ) {
        val event = NativeMdsSubscriptionEvent(
            type,
            requestId,
            subscriptionId,
            statusCode,
            body,
            error
        )
        subscriptionApi.onSubscriptionEvent(event, ::logCallback)
    }

    private fun logCallback(result: Result<Unit>) {
        result.exceptionOrNull()?.let {
            Log.w(TAG, "Dart callback failed", it)
        }
    }
}
