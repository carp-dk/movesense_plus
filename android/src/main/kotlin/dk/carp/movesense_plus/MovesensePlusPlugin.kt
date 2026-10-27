package dk.carp.movesense_plus

import android.bluetooth.BluetoothManager
import android.content.Context
import android.os.Build
import com.movesense.mds.Mds
import io.flutter.embedding.engine.plugins.FlutterPlugin

/** Android entry point for the Movesense Plus plugin. */
class MovesensePlusPlugin :
    FlutterPlugin,
    MovesenseScanHostApi,
    MovesenseConnectionHostApi,
    MovesenseRequestHostApi,
    MovesenseSubscriptionHostApi,
    MovesenseSubscriptionControlHostApi {
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

        MovesenseScanHostApi.setUp(binding.binaryMessenger, this)
        MovesenseConnectionHostApi.setUp(binding.binaryMessenger, this)
        MovesenseRequestHostApi.setUp(binding.binaryMessenger, this)
        MovesenseSubscriptionHostApi.setUp(binding.binaryMessenger, this)
        MovesenseSubscriptionControlHostApi.setUp(binding.binaryMessenger, this)
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
        MovesenseSubscriptionControlHostApi.setUp(binding.binaryMessenger, null)
        MovesenseSubscriptionHostApi.setUp(binding.binaryMessenger, null)
        MovesenseRequestHostApi.setUp(binding.binaryMessenger, null)
        MovesenseConnectionHostApi.setUp(binding.binaryMessenger, null)
        MovesenseScanHostApi.setUp(binding.binaryMessenger, null)

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
