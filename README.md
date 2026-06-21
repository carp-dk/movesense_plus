# CARP Movesense Flutter

A flutter plugin for Movesense devices made by [CARP](https://carp.dk)

## Native communication

The plugin uses [Pigeon](https://pub.dev/packages/pigeon) for typed Dart-to-native
communication. The source-of-truth contract is:

- `pigeons/carp_movesense_api.dart`

Generated files are checked in so consuming Flutter apps do not need to run
Pigeon:

- `lib/src/pigeon/carp_movesense_api.g.dart`
- `android/src/main/kotlin/dk/carp/carp_movesense_flutter/PigeonCarpMovesenseApi.g.kt`
- `ios/carp_movesense_flutter/Sources/carp_movesense_flutter/PigeonCarpMovesenseApi.g.swift`
- `macos/carp_movesense_flutter/Sources/carp_movesense_flutter/PigeonCarpMovesenseApi.g.swift`

Regenerate after editing the contract:

```sh
tool/generate_pigeon.sh
```

Keep generated Pigeon types out of the public package API. Public Dart methods
should live in `lib/carp_movesense_flutter.dart`, with native transport hidden
behind `lib/carp_movesense_flutter_pigeon.dart`. This keeps Pigeon generator
changes from leaking into downstream applications.

The first generated round trip is `getPlatformVersion()`. It is intentionally
small, and exists to validate the generated Dart, Kotlin, and Swift plumbing
before expanding the contract with Movesense scanning, connection, request, and
subscription APIs.
