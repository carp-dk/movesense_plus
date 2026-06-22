package dk.carp.carp_movesense_flutter

import kotlin.test.Test
import kotlin.test.assertEquals

/*
 * This demonstrates a simple unit test of the Kotlin portion of this plugin's implementation.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */

internal class CarpMovesenseFlutterPluginTest {
    @Test
    fun getPlatformVersion_returnsExpectedValue() {
        val plugin = CarpMovesenseFlutterPlugin()
        assertEquals("Android " + android.os.Build.VERSION.RELEASE, plugin.getPlatformVersion())
    }
}
