package dk.carp.movesense_plus

import kotlin.test.Test
import kotlin.test.assertNotNull

/*
 * Unit tests of the Kotlin portion of the plugin. Run them with
 * `./gradlew testDebugUnitTest` in the `example/android/` directory after building the example app.
 */
internal class MovesensePlusPluginTest {
    @Test
    fun plugin_canBeInstantiated() {
        assertNotNull(MovesensePlusPlugin())
    }
}
