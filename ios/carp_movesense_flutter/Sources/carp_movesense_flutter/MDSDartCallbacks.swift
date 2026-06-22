import Flutter
import Foundation

final class MDSDartCallbacks {
    private let scanDeviceApi: CarpMovesenseScanDeviceFlutterApi
    private let scanErrorApi: CarpMovesenseScanErrorFlutterApi
    private let connectionApi: CarpMovesenseConnectionFlutterApi
    private let requestApi: CarpMovesenseRequestFlutterApi
    private let subscriptionApi: CarpMovesenseSubscriptionFlutterApi

    init(binaryMessenger: FlutterBinaryMessenger) {
        scanDeviceApi = CarpMovesenseScanDeviceFlutterApi(binaryMessenger: binaryMessenger)
        scanErrorApi = CarpMovesenseScanErrorFlutterApi(binaryMessenger: binaryMessenger)
        connectionApi = CarpMovesenseConnectionFlutterApi(binaryMessenger: binaryMessenger)
        requestApi = CarpMovesenseRequestFlutterApi(binaryMessenger: binaryMessenger)
        subscriptionApi = CarpMovesenseSubscriptionFlutterApi(binaryMessenger: binaryMessenger)
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
