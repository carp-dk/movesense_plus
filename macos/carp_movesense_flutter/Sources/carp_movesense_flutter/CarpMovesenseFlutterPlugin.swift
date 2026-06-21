import Cocoa
import FlutterMacOS

public class CarpMovesenseFlutterPlugin: NSObject, FlutterPlugin, CarpMovesenseHostApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = CarpMovesenseFlutterPlugin()
    CarpMovesenseHostApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance)
  }

  public func getPlatformVersion() throws -> String {
    return "macOS " + ProcessInfo.processInfo.operatingSystemVersionString
  }
}
