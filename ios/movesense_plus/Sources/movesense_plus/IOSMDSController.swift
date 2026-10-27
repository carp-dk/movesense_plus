import Foundation
import MovesenseMDS

final class IOSMDSController {
    private let scanner: IOSBleScanner
    private let callbacks: MDSDartCallbacks
    private let mds = MDSWrapper()
    private var subscriptions = [Int64: String]()
    private var serialToAddress = [String: String]()

    init(scanner: IOSBleScanner, callbacks: MDSDartCallbacks) {
        self.scanner = scanner
        self.callbacks = callbacks
        subscribeConnectedDevices()
    }

    func shutdown() {
        subscriptions.values.forEach { mds.doUnsubscribe($0) }
        subscriptions.removeAll()
        mds.deactivate()
    }

    func setConnection(_ command: NativeConnectionCommand) {
        command.connect ? connect(command.address) : disconnect(command.address)
    }

    func sendRequest(_ request: NativeMdsRequest) {
        guard let contract = dictionary(from: request.contract) else {
            callbacks.request(
                requestId: request.requestId, success: false, statusCode: 0, body: "",
                error: "Invalid contract JSON.")
            return
        }
        let completion: MDSResponseBlock = { [weak self] response in
            self?.handle(response: response, requestId: request.requestId)
        }
        switch request.method.uppercased() {
        case "GET": mds.doGet(request.uri, contract: contract, completion: completion)
        case "PUT": mds.doPut(request.uri, contract: contract, completion: completion)
        case "POST": mds.doPost(request.uri, contract: contract, completion: completion)
        case "DELETE": mds.doDelete(request.uri, contract: contract, completion: completion)
        default:
            callbacks.request(
                requestId: request.requestId, success: false, statusCode: 0, body: "",
                error: "Unsupported method.")
        }
    }

    func subscribe(_ subscription: NativeMdsSubscription) {
        guard let contract = dictionary(from: subscription.contract) else {
            subscriptionEvent("subscribeError", subscription, 0, "", "Invalid contract JSON.")
            return
        }
        mds.doSubscribe(
            subscription.uri, contract: contract,
            response: { [weak self] response in
                guard let self else { return }
                if response.statusCode < 300 {
                    subscriptions[subscription.subscriptionId] = subscription.uri
                    subscriptionEvent(
                        "subscribed", subscription, response.statusCode, json(response.bodyData), ""
                    )
                } else {
                    subscriptionEvent(
                        "subscribeError", subscription, response.statusCode, "", reason(response))
                }
            },
            onEvent: { [weak self] event in
                self?.subscriptionEvent(
                    "notification", subscription, 0, self?.json(event.bodyData) ?? "", "")
            })
    }

    func unsubscribe(_ subscriptionId: Int64) {
        guard let uri = subscriptions.removeValue(forKey: subscriptionId) else { return }
        mds.doUnsubscribe(uri)
    }

    private func connect(_ address: String) {
        guard let uuid = UUID(uuidString: address) else {
            callbacks.connection(type: "error", address: address, error: "Invalid device UUID.")
            return
        }
        scanner.setScanEnabled(false)
        mds.connectPeripheral(with: uuid)
        scanner.connectForBleEvent(address: address)
    }

    private func disconnect(_ address: String) {
        guard let uuid = UUID(uuidString: address) else { return }
        _ = mds.disconnectPeripheral(with: uuid)
        scanner.disconnectForBleEvent(address: address)
    }

    private func handle(response: MDSResponse, requestId: Int64) {
        if response.statusCode < 300 {
            callbacks.request(
                requestId: requestId, success: true, statusCode: Int64(response.statusCode),
                body: json(response.bodyData), error: "")
        } else {
            callbacks.request(
                requestId: requestId, success: false, statusCode: Int64(response.statusCode),
                body: "", error: reason(response))
        }
    }
}

extension IOSMDSController {
    fileprivate func subscribeConnectedDevices() {
        mds.doSubscribe(
            "MDS/ConnectedDevices", contract: [:], response: { _ in },
            onEvent: { [weak self] event in
                self?.handleConnectedDevicesEvent(event.bodyData)
            })
    }

    fileprivate func handleConnectedDevicesEvent(_ data: Data) {
        guard
            let root = object(from: data) as? [String: Any],
            let method = root["Method"] as? String,
            let body = root["Body"] as? [String: Any]
        else { return }

        if method == "POST" {
            let deviceInfo = body["DeviceInfo"] as? [String: Any]
            let connection = body["Connection"] as? [String: Any]
            let serial = deviceInfo?["serial"] as? String ?? deviceInfo?["Serial"] as? String
            let address = connection?["UUID"] as? String
            if let serial, let address {
                serialToAddress[serial] = address
                callbacks.connection(type: "connected", address: address, serial: serial)
            }
        } else if method == "DEL" {
            guard let serial = body["Serial"] as? String else { return }
            let address = serialToAddress.removeValue(forKey: serial)
            callbacks.connection(type: "disconnected", address: address, serial: serial)
        }
    }

    fileprivate func subscriptionEvent(
        _ type: String,
        _ subscription: NativeMdsSubscription,
        _ statusCode: Int,
        _ body: String,
        _ error: String
    ) {
        let event = NativeMdsSubscriptionEvent(
            type: type,
            requestId: type == "notification" ? 0 : subscription.requestId,
            subscriptionId: subscription.subscriptionId,
            statusCode: Int64(statusCode),
            body: body,
            error: error
        )
        callbacks.subscription(event)
    }

    fileprivate func dictionary(from text: String) -> [String: Any]? {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return [:]
        }
        guard let data = text.data(using: .utf8) else { return nil }
        return object(from: data) as? [String: Any]
    }

    fileprivate func json(_ data: Data) -> String {
        guard !data.isEmpty else { return "" }
        guard let parsed = object(from: data), JSONSerialization.isValidJSONObject(parsed) else {
            return String(data: data, encoding: .utf8) ?? ""
        }
        guard
            let encoded = try? JSONSerialization.data(withJSONObject: parsed),
            let text = String(data: encoded, encoding: .utf8)
        else { return "" }
        return text
    }

    fileprivate func reason(_ response: MDSResponse) -> String {
        return response.header["Reason"] as? String
            ?? response.header["Uri"] as? String
            ?? "MDS request failed."
    }

    fileprivate func object(from data: Data) -> Any? {
        return try? JSONSerialization.jsonObject(with: data, options: [])
    }
}
