#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
plugin_dir="$(cd "$script_dir/.." && pwd)"

cd "$plugin_dir"

mkdir -p \
  "$plugin_dir/lib/src/gen/pigeon" \
  "$plugin_dir/android/src/main/kotlin/dk/carp/movesense_plus/gen" \
  "$plugin_dir/ios/movesense_plus/Sources/movesense_plus/gen" \
  "$plugin_dir/macos/movesense_plus/Sources/movesense_plus/gen"

run_pigeon() {
  local input_file="$1"

  if command -v fvm >/dev/null 2>&1; then
    fvm dart run pigeon --input "$input_file"
  else
    dart run pigeon --input "$input_file"
  fi
}

inputs=(
  "pigeons/movesense_scan_host_api.dart"
  "pigeons/movesense_scan_device_api.dart"
  "pigeons/movesense_scan_error_api.dart"
  "pigeons/movesense_connection_host_api.dart"
  "pigeons/movesense_connection_event_api.dart"
  "pigeons/movesense_request_host_api.dart"
  "pigeons/movesense_request_event_api.dart"
  "pigeons/movesense_subscription_host_api.dart"
  "pigeons/movesense_subscription_control_api.dart"
  "pigeons/movesense_subscription_event_api.dart"
)

for input in "${inputs[@]}"; do
  run_pigeon "$input"
done

for generated in \
  PigeonMovesenseScanHostApi.g.swift \
  PigeonMovesenseScanDeviceApi.g.swift \
  PigeonMovesenseScanErrorApi.g.swift \
  PigeonMovesenseConnectionHostApi.g.swift \
  PigeonMovesenseConnectionEventApi.g.swift \
  PigeonMovesenseRequestHostApi.g.swift \
  PigeonMovesenseRequestEventApi.g.swift \
  PigeonMovesenseSubscriptionHostApi.g.swift \
  PigeonMovesenseSubscriptionControlApi.g.swift \
  PigeonMovesenseSubscriptionEventApi.g.swift
do
  cp \
    "$plugin_dir/ios/movesense_plus/Sources/movesense_plus/gen/$generated" \
    "$plugin_dir/macos/movesense_plus/Sources/movesense_plus/gen/$generated"
done
