package dk.carp.carp_movesense_flutter

import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin

/** Android entry point for the CARP Movesense Flutter plugin. */
class CarpMovesenseFlutterPlugin :
    FlutterPlugin,
    CarpMovesenseHostApi {
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        CarpMovesenseHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
    }

    override fun getPlatformVersion(): String {
        return "Android ${Build.VERSION.RELEASE}"
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        CarpMovesenseHostApi.setUp(binding.binaryMessenger, null)
    }
}
