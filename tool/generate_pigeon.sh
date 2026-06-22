#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
plugin_dir="$(cd "$script_dir/.." && pwd)"

cd "$plugin_dir"

mkdir -p \
  "$plugin_dir/lib/src/gen/pigeon" \
  "$plugin_dir/android/src/main/kotlin/dk/carp/carp_movesense_flutter/gen" \
  "$plugin_dir/ios/carp_movesense_flutter/Sources/carp_movesense_flutter/gen" \
  "$plugin_dir/macos/carp_movesense_flutter/Sources/carp_movesense_flutter/gen"

run_pigeon() {
  local input_file="$1"

  if command -v fvm >/dev/null 2>&1; then
    fvm dart run pigeon --input "$input_file"
  else
    dart run pigeon --input "$input_file"
  fi
}

inputs=(
  "pigeons/carp_movesense_scan_host_api.dart"
  "pigeons/carp_movesense_scan_device_api.dart"
  "pigeons/carp_movesense_scan_error_api.dart"
  "pigeons/carp_movesense_connection_host_api.dart"
  "pigeons/carp_movesense_connection_event_api.dart"
  "pigeons/carp_movesense_request_host_api.dart"
  "pigeons/carp_movesense_request_event_api.dart"
  "pigeons/carp_movesense_subscription_host_api.dart"
  "pigeons/carp_movesense_subscription_control_api.dart"
  "pigeons/carp_movesense_subscription_event_api.dart"
)

for input in "${inputs[@]}"; do
  run_pigeon "$input"
done

for generated in \
  PigeonCarpMovesenseScanHostApi.g.swift \
  PigeonCarpMovesenseScanDeviceApi.g.swift \
  PigeonCarpMovesenseScanErrorApi.g.swift \
  PigeonCarpMovesenseConnectionHostApi.g.swift \
  PigeonCarpMovesenseConnectionEventApi.g.swift \
  PigeonCarpMovesenseRequestHostApi.g.swift \
  PigeonCarpMovesenseRequestEventApi.g.swift \
  PigeonCarpMovesenseSubscriptionHostApi.g.swift \
  PigeonCarpMovesenseSubscriptionControlApi.g.swift \
  PigeonCarpMovesenseSubscriptionEventApi.g.swift
do
  cp \
    "$plugin_dir/ios/carp_movesense_flutter/Sources/carp_movesense_flutter/gen/$generated" \
    "$plugin_dir/macos/carp_movesense_flutter/Sources/carp_movesense_flutter/gen/$generated"
done
