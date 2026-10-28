import Cocoa
import FlutterMacOS

public class MovesensePlusPlugin: NSObject, FlutterPlugin,
    MovesenseScanHostApi, MovesenseConnectionHostApi, MovesenseRequestHostApi,
    MovesenseSubscriptionHostApi, MovesenseSubscriptionControlHostApi
{
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = MovesensePlusPlugin()
        MovesenseScanHostApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance)
        MovesenseConnectionHostApiSetup.setUp(
            binaryMessenger: registrar.messenger, api: instance)
        MovesenseRequestHostApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance)
        MovesenseSubscriptionHostApiSetup.setUp(
            binaryMessenger: registrar.messenger, api: instance)
        MovesenseSubscriptionControlHostApiSetup.setUp(
            binaryMessenger: registrar.messenger,
            api: instance
        )
    }

    func setScanEnabled(enabled: Bool) throws {
        if enabled { throw unsupported() }
    }

    func setConnection(command: NativeConnectionCommand) throws {
        throw unsupported()
    }

    func sendRequest(request: NativeMdsRequest) throws {
        throw unsupported()
    }

    func subscribe(subscription: NativeMdsSubscription) throws {
        throw unsupported()
    }

    func unsubscribe(subscriptionId: Int64) throws {
        // No-op: macOS cannot create subscriptions without a Movesense MDS binary.
    }

    private func unsupported() -> Error {
        return NSError(
            domain: "dk.carp.movesense_plus",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Movesense MDS is not available on macOS."]
        )
    }
}
