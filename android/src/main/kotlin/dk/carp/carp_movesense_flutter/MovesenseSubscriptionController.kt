package dk.carp.carp_movesense_flutter

import com.movesense.mds.Mds
import com.movesense.mds.MdsException
import com.movesense.mds.MdsHeader
import com.movesense.mds.MdsNotificationListener
import com.movesense.mds.MdsResponseListener
import com.movesense.mds.MdsSubscription
import org.json.JSONObject

/** Owns MDS subscriptions and adapts Android EventListener contracts. */
class MovesenseSubscriptionController(
    private val mdsProvider: () -> Mds?,
    private val callbacks: MdsDartCallbacks
) {
    private val subscriptions = mutableMapOf<Long, MdsSubscription>()

    fun subscribe(subscription: NativeMdsSubscription) {
        val mds = mdsProvider()
        if (mds == null) {
            subscribeError(subscription, 0, "MDS is not initialized.")
            return
        }
        val contract = eventListenerContract(subscription.uri, subscription.contract)
        if (contract == null) {
            subscribeError(subscription, 0, "Invalid subscription contract JSON.")
            return
        }
        val nativeSubscription = mds.subscribe(
            Mds.URI_EVENTLISTENER,
            contract,
            notificationListener(subscription),
            responseListener(subscription)
        )
        subscriptions[subscription.subscriptionId] = nativeSubscription
    }

    fun unsubscribe(subscriptionId: Long) {
        subscriptions.remove(subscriptionId)?.unsubscribe()
    }

    fun unsubscribeAll() {
        subscriptions.keys.toList().forEach(::unsubscribe)
    }

    private fun responseListener(subscription: NativeMdsSubscription): MdsResponseListener {
        return object : MdsResponseListener {
            override fun onSuccess(data: String, header: MdsHeader) {
                callbacks.subscription(
                    "subscribed",
                    subscription.requestId,
                    subscription.subscriptionId,
                    header.status.toLong(),
                    data,
                    ""
                )
            }

            override fun onError(exception: MdsException) {
                subscriptions.remove(subscription.subscriptionId)
                subscribeError(
                    subscription,
                    (exception.statusCode ?: 0).toLong(),
                    exception.message ?: "$exception"
                )
            }
        }
    }

    private fun notificationListener(subscription: NativeMdsSubscription): MdsNotificationListener {
        return object : MdsNotificationListener {
            override fun onNotification(data: String) {
                callbacks.subscription("notification", 0, subscription.subscriptionId, 0, data, "")
            }

            override fun onError(exception: MdsException) {
                callbacks.subscription(
                    "error",
                    0,
                    subscription.subscriptionId,
                    (exception.statusCode ?: 0).toLong(),
                    "",
                    exception.message ?: "$exception"
                )
            }
        }
    }

    private fun subscribeError(subscription: NativeMdsSubscription, status: Long, error: String) {
        callbacks.subscription(
            "subscribeError",
            subscription.requestId,
            subscription.subscriptionId,
            status,
            "",
            error
        )
    }

    private fun eventListenerContract(uri: String, contract: String): String? {
        return try {
            val json = if (contract.isBlank()) JSONObject() else JSONObject(contract)
            json.put("Uri", uri)
            json.toString()
        } catch (error: Exception) {
            null
        }
    }
}
