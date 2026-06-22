import Flutter
import UIKit

public class CarpMovesenseFlutterPlugin: NSObject, FlutterPlugin, CarpMovesenseHostApi,
    CarpMovesenseScanHostApi, CarpMovesenseConnectionHostApi, CarpMovesenseRequestHostApi,
    CarpMovesenseSubscriptionHostApi, CarpMovesenseSubscriptionControlHostApi
{
    private var scanner: IosBleScanner?
    private var mds: IosMdsController?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let callbacks = MdsDartCallbacks(binaryMessenger: registrar.messenger())
        let scanner = IosBleScanner(callbacks: callbacks)
        let instance = CarpMovesenseFlutterPlugin()
        instance.scanner = scanner
        instance.mds = IosMdsController(scanner: scanner, callbacks: callbacks)

        CarpMovesenseHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
        CarpMovesenseScanHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
        CarpMovesenseConnectionHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(), api: instance)
        CarpMovesenseRequestHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(), api: instance)
        CarpMovesenseSubscriptionHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(), api: instance)
        CarpMovesenseSubscriptionControlHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(), api: instance)
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        scanner?.setScanEnabled(false)
        mds?.shutdown()
        CarpMovesenseSubscriptionControlHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(), api: nil)
        CarpMovesenseSubscriptionHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(), api: nil)
        CarpMovesenseRequestHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil)
        CarpMovesenseConnectionHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil)
        CarpMovesenseScanHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil)
        CarpMovesenseHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil)
    }

    func setScanEnabled(enabled: Bool) throws {
        scanner?.setScanEnabled(enabled)
    }

    func setConnection(command: NativeConnectionCommand) throws {
        mds?.setConnection(command)
    }

    func sendRequest(request: NativeMdsRequest) throws {
        mds?.sendRequest(request)
    }

    func subscribe(subscription: NativeMdsSubscription) throws {
        mds?.subscribe(subscription)
    }

    func unsubscribe(subscriptionId: Int64) throws {
        mds?.unsubscribe(subscriptionId)
    }
}
