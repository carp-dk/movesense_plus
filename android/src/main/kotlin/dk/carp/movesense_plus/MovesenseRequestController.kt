package dk.carp.movesense_plus

import com.movesense.mds.Mds
import com.movesense.mds.MdsException
import com.movesense.mds.MdsHeader
import com.movesense.mds.MdsResponseListener

/** Sends REST-style requests through the Android Movesense SDK. */
class MovesenseRequestController(
    private val mdsProvider: () -> Mds?,
    private val callbacks: MdsDartCallbacks
) {
    fun send(request: NativeMdsRequest) {
        val mds = mdsProvider()
        if (mds == null) {
            callbacks.request(request.requestId, false, 0, "", "MDS is not initialized.")
            return
        }
        val listener = responseListener(request.requestId)
        when (request.method.uppercase()) {
            "GET" -> mds.get(request.uri, request.contract, listener)
            "PUT" -> mds.put(request.uri, request.contract, listener)
            "POST" -> mds.post(request.uri, request.contract, listener)
            "DELETE" -> mds.delete(request.uri, request.contract, listener)
            else -> callbacks.request(request.requestId, false, 0, "", "Unsupported method.")
        }
    }

    private fun responseListener(requestId: Long): MdsResponseListener {
        return object : MdsResponseListener {
            override fun onSuccess(data: String, header: MdsHeader) {
                callbacks.request(requestId, true, header.status.toLong(), data, "")
            }

            override fun onError(exception: MdsException) {
                callbacks.request(
                    requestId,
                    false,
                    (exception.statusCode ?: 0).toLong(),
                    "",
                    exception.message ?: "$exception"
                )
            }
        }
    }
}
