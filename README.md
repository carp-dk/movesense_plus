# CARP Movesense Flutter

A Flutter plugin for Movesense devices made by [CARP](https://carp.dk).

## API shape

The primary API is `CarpMovesenseFlutter`, exported from
`package:carp_movesense_flutter/carp_movesense_flutter.dart`.

It supports:

- BLE scan start/stop and scan result stream.
- Connect/disconnect by Android MAC address or Apple UUID.
- MDS `GET`, `PUT`, `POST`, and `DELETE` requests.
- MDS subscriptions as Dart streams.

The package also exports `Mds` and `MdsAsync` compatibility wrappers for code
migrating from `mdsflutter`.

## Native communication

The plugin uses [Pigeon](https://pub.dev/packages/pigeon) for typed Dart/native
transport. Generated Pigeon files are checked in so consuming apps do not need
to run Pigeon.

Generated bindings are always written under `gen/` folders:

- `lib/src/gen/pigeon/`
- `android/src/main/kotlin/dk/carp/carp_movesense_flutter/gen/`
- `ios/carp_movesense_flutter/Sources/carp_movesense_flutter/gen/`
- `macos/carp_movesense_flutter/Sources/carp_movesense_flutter/gen/`

Pigeon contracts live in `pigeons/` and are split by responsibility:

- `carp_movesense_api.dart` for platform metadata.
- `carp_movesense_scan_*` for BLE scan commands and callbacks.
- `carp_movesense_connection_*` for connection commands and callbacks.
- `carp_movesense_request_*` for MDS request commands and responses.
- `carp_movesense_subscription_*` for subscriptions and notifications.

Regenerate after editing a contract:

```sh
tool/generate_pigeon.sh
```

The original callback message schema has been ported to
`protos/carp_movesense_mds.proto` for reference and interoperability. Runtime
Flutter/native transport uses Pigeon DTOs instead of protobuf byte arrays.

## Platform notes

Android uses the vendored Movesense `mdslib` AAR under `android/vendor`.

iOS uses the vendored `MovesenseMDS.xcframework` under
`ios/carp_movesense_flutter/Vendor`.

macOS registers the same Pigeon channels but returns unsupported errors for
Movesense operations because no macOS Movesense MDS binary is bundled.
