package dk.carp.carp_movesense_flutter

import android.bluetooth.BluetoothManager
import android.content.Context
import android.os.Build
import com.movesense.mds.Mds
import io.flutter.embedding.engine.plugins.FlutterPlugin

/** Android entry point for the CARP Movesense Flutter plugin. */
class CarpMovesenseFlutterPlugin :
    FlutterPlugin,
    CarpMovesenseScanHostApi,
    CarpMovesenseConnectionHostApi,
    CarpMovesenseRequestHostApi,
    CarpMovesenseSubscriptionHostApi,
    CarpMovesenseSubscriptionControlHostApi {
    private var mds: Mds? = null
    private var scanner: MovesenseBleScanner? = null
    private var connections: MovesenseConnectionController? = null
    private var requests: MovesenseRequestController? = null
    private var subscriptions: MovesenseSubscriptionController? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val callbacks = MdsDartCallbacks(binding.binaryMessenger)
        mds = Mds.Builder().build(binding.applicationContext)

        val manager = binding.applicationContext
            .getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        scanner = MovesenseBleScanner(manager.adapter, callbacks)
        connections = MovesenseConnectionController({ mds }, callbacks)
        requests = MovesenseRequestController({ mds }, callbacks)
        subscriptions = MovesenseSubscriptionController({ mds }, callbacks)

        CarpMovesenseScanHostApi.setUp(binding.binaryMessenger, this)
        CarpMovesenseConnectionHostApi.setUp(binding.binaryMessenger, this)
        CarpMovesenseRequestHostApi.setUp(binding.binaryMessenger, this)
        CarpMovesenseSubscriptionHostApi.setUp(binding.binaryMessenger, this)
        CarpMovesenseSubscriptionControlHostApi.setUp(binding.binaryMessenger, this)
    }

    override fun setScanEnabled(enabled: Boolean) {
        scanner?.setScanEnabled(enabled)
    }

    override fun setConnection(command: NativeConnectionCommand) {
        connections?.setConnection(command)
    }

    override fun sendRequest(request: NativeMdsRequest) {
        requests?.send(request)
    }

    override fun subscribe(subscription: NativeMdsSubscription) {
        subscriptions?.subscribe(subscription)
    }

    override fun unsubscribe(subscriptionId: Long) {
        subscriptions?.unsubscribe(subscriptionId)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        CarpMovesenseSubscriptionControlHostApi.setUp(binding.binaryMessenger, null)
        CarpMovesenseSubscriptionHostApi.setUp(binding.binaryMessenger, null)
        CarpMovesenseRequestHostApi.setUp(binding.binaryMessenger, null)
        CarpMovesenseConnectionHostApi.setUp(binding.binaryMessenger, null)
        CarpMovesenseScanHostApi.setUp(binding.binaryMessenger, null)

        scanner?.setScanEnabled(false)
        subscriptions?.unsubscribeAll()
        connections?.disconnectAll()
        scanner = null
        subscriptions = null
        requests = null
        connections = null
        mds = null
    }
}
