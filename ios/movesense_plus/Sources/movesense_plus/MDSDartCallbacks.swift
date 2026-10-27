import Flutter
import Foundation

final class MDSDartCallbacks {
    private let scanDeviceApi: MovesenseScanDeviceFlutterApi
    private let scanErrorApi: MovesenseScanErrorFlutterApi
    private let connectionApi: MovesenseConnectionFlutterApi
    private let requestApi: MovesenseRequestFlutterApi
    private let subscriptionApi: MovesenseSubscriptionFlutterApi

    init(binaryMessenger: FlutterBinaryMessenger) {
        scanDeviceApi = MovesenseScanDeviceFlutterApi(binaryMessenger: binaryMessenger)
        scanErrorApi = MovesenseScanErrorFlutterApi(binaryMessenger: binaryMessenger)
        connectionApi = MovesenseConnectionFlutterApi(binaryMessenger: binaryMessenger)
        requestApi = MovesenseRequestFlutterApi(binaryMessenger: binaryMessenger)
        subscriptionApi = MovesenseSubscriptionFlutterApi(binaryMessenger: binaryMessenger)
    }

    func scanDevice(name: String?, address: String) {
        scanDeviceApi.onScanDevice(device: NativeScanDevice(name: name, address: address)) { _ in }
    }

    func scanError(code: Int64, message: String) {
        scanErrorApi.onScanError(error: NativeScanError(code: code, message: message)) { _ in }
    }

    func connection(type: String, address: String?, serial: String? = nil, error: String? = nil) {
        let event = NativeConnectionEvent(
            type: type, address: address, serial: serial, error: error)
        connectionApi.onConnectionEvent(event: event) { _ in }
    }

    func request(requestId: Int64, success: Bool, statusCode: Int64, body: String, error: String) {
        let event = NativeMdsRequestEvent(
            requestId: requestId,
            success: success,
            statusCode: statusCode,
            body: body,
            error: error
        )
        requestApi.onRequestEvent(event: event) { _ in }
    }

    func subscription(_ event: NativeMdsSubscriptionEvent) {
        subscriptionApi.onSubscriptionEvent(event: event) { _ in }
    }
}
