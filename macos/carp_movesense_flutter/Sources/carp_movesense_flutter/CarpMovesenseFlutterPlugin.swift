import Cocoa
import FlutterMacOS

public class CarpMovesenseFlutterPlugin: NSObject, FlutterPlugin, CarpMovesenseHostApi,
    CarpMovesenseScanHostApi, CarpMovesenseConnectionHostApi, CarpMovesenseRequestHostApi,
    CarpMovesenseSubscriptionHostApi, CarpMovesenseSubscriptionControlHostApi
{
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = CarpMovesenseFlutterPlugin()
        CarpMovesenseHostApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance)
        CarpMovesenseScanHostApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance)
        CarpMovesenseConnectionHostApiSetup.setUp(
            binaryMessenger: registrar.messenger, api: instance)
        CarpMovesenseRequestHostApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance)
        CarpMovesenseSubscriptionHostApiSetup.setUp(
            binaryMessenger: registrar.messenger, api: instance)
        CarpMovesenseSubscriptionControlHostApiSetup.setUp(
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
            domain: "dk.carp.carp_movesense_flutter",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Movesense MDS is not available on macOS."]
        )
    }
}
