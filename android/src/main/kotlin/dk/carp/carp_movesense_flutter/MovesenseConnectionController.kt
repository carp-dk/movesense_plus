package dk.carp.carp_movesense_flutter

import android.annotation.SuppressLint
import com.movesense.mds.Mds
import com.movesense.mds.MdsConnectionListener
import com.movesense.mds.MdsException

/** Owns Android MDS connection lifecycle calls and callbacks. */
class MovesenseConnectionController(
    private val mdsProvider: () -> Mds?,
    private val callbacks: MdsDartCallbacks
) {
    private val connectedOrConnecting = linkedSetOf<String>()

    fun setConnection(command: NativeConnectionCommand) {
        if (command.connect) connect(command.address) else disconnect(command.address)
    }

    @SuppressLint("MissingPermission")
    private fun connect(address: String) {
        val mds = mdsProvider()
        if (mds == null) {
            callbacks.connection("error", address, error = "MDS is not initialized.")
            return
        }
        if (!connectedOrConnecting.add(address)) {
            callbacks.connection("error", address, error = "Already connected to $address")
            return
        }
        mds.connect(address, object : MdsConnectionListener {
            override fun onConnect(address: String) {
                callbacks.connection("bleConnected", address)
            }

            override fun onConnectionComplete(address: String, serial: String) {
                callbacks.connection("connected", address, serial = serial)
            }

            override fun onDisconnect(address: String) {
                connectedOrConnecting.remove(address)
                callbacks.connection("disconnected", address)
            }

            override fun onError(exception: MdsException) {
                connectedOrConnecting.remove(address)
                callbacks.connection("error", address, error = exception.message ?: "$exception")
            }
        })
    }

    fun disconnect(address: String) {
        connectedOrConnecting.remove(address)
        mdsProvider()?.disconnect(address)
    }

    fun disconnectAll() {
        connectedOrConnecting.toList().forEach(::disconnect)
    }
}
