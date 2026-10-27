import Flutter
import UIKit

public class MovesensePlusPlugin: NSObject, FlutterPlugin,
    MovesenseScanHostApi, MovesenseConnectionHostApi, MovesenseRequestHostApi,
    MovesenseSubscriptionHostApi, MovesenseSubscriptionControlHostApi
{
    private var scanner: IOSBleScanner?
    private var mds: IOSMDSController?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let callbacks = MDSDartCallbacks(binaryMessenger: registrar.messenger())
        let scanner = IOSBleScanner(callbacks: callbacks)
        let instance = MovesensePlusPlugin()
        instance.scanner = scanner
        instance.mds = IOSMDSController(scanner: scanner, callbacks: callbacks)

        MovesenseScanHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
        MovesenseConnectionHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(), api: instance)
        MovesenseRequestHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(), api: instance)
        MovesenseSubscriptionHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(), api: instance)
        MovesenseSubscriptionControlHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(), api: instance)
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        scanner?.setScanEnabled(false)
        mds?.shutdown()
        MovesenseSubscriptionControlHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(), api: nil)
        MovesenseSubscriptionHostApiSetup.setUp(
            binaryMessenger: registrar.messenger(), api: nil)
        MovesenseRequestHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil)
        MovesenseConnectionHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil)
        MovesenseScanHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil)
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
