import Flutter
import UIKit

public class CarpMovesenseFlutterPlugin: NSObject, FlutterPlugin, CarpMovesenseHostApi {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = CarpMovesenseFlutterPlugin()
        CarpMovesenseHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    }

    public func getPlatformVersion() throws -> String {
        return "iOS " + UIDevice.current.systemVersion
    }
}
