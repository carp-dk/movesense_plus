#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
plugin_dir="$(cd "$script_dir/.." && pwd)"

cd "$plugin_dir"

if command -v fvm >/dev/null 2>&1; then
  fvm dart run pigeon --input pigeons/carp_movesense_api.dart
else
  dart run pigeon --input pigeons/carp_movesense_api.dart
fi

# Pigeon emits one Swift file per invocation. The generated Swift is guarded
# with os(iOS)/os(macOS), so keep the macOS template target in sync by mirroring
# the generated Apple-platform binding.
cp \
  "$plugin_dir/ios/carp_movesense_flutter/Sources/carp_movesense_flutter/PigeonCarpMovesenseApi.g.swift" \
  "$plugin_dir/macos/carp_movesense_flutter/Sources/carp_movesense_flutter/PigeonCarpMovesenseApi.g.swift"
