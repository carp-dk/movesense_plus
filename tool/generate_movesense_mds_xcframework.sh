#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Generate the MovesenseMDS.xcframework used by the iOS SwiftPM plugin target.

Defaults assume this script is run from the carp_movesense_flutter plugin
checkout inside the wider carp-movesense-flutter workspace.

Usage:
  tool/generate_movesense_mds_xcframework.sh [options]

Options:
  --lib PATH       Path to the source libmds.a fat static library.
  --headers PATH   Path to the directory containing MDS.h.
  --output PATH    Output .xcframework path.
  --sign IDENTITY  Optional code signing identity for the XCFramework bundle.
                   Use an Apple/self-signed identity for distribution; "-" only
                   creates an ad-hoc signature for local validation.
  --help           Show this help.
USAGE
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
plugin_dir="$(cd "$script_dir/.." && pwd)"
workspace_dir="$(cd "$plugin_dir/.." && pwd)"

source_lib="$workspace_dir/movesense-mobile-lib/IOS/Movesense/Release-iphoneos/libmds.a"
source_headers="$workspace_dir/movesense-mobile-lib/IOS/Movesense/include"
output_path="$plugin_dir/ios/carp_movesense_flutter/Vendor/MovesenseMDS.xcframework"
sign_identity=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lib)
      source_lib="${2:?Missing value for --lib}"
      shift 2
      ;;
    --headers)
      source_headers="${2:?Missing value for --headers}"
      shift 2
      ;;
    --output)
      output_path="${2:?Missing value for --output}"
      shift 2
      ;;
    --sign)
      sign_identity="${2:?Missing value for --sign}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Required tool not found: $1" >&2
    exit 1
  fi
}

require_tool lipo
require_tool xcodebuild
if [[ -n "$sign_identity" ]]; then
  require_tool codesign
fi

if [[ ! -f "$source_lib" ]]; then
  echo "Source library not found: $source_lib" >&2
  exit 1
fi

if [[ ! -f "$source_headers/MDS.h" ]]; then
  echo "MDS.h not found in headers directory: $source_headers" >&2
  exit 1
fi

arch_info="$(lipo -info "$source_lib")"
if [[ "$arch_info" != *"arm64"* ]]; then
  echo "Source library must contain an arm64 iOS device slice: $source_lib" >&2
  echo "$arch_info" >&2
  exit 1
fi

if [[ "$arch_info" != *"x86_64"* ]]; then
  echo "Source library must contain an x86_64 iOS simulator slice: $source_lib" >&2
  echo "$arch_info" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

device_dir="$tmpdir/ios-arm64"
sim_dir="$tmpdir/ios-x86_64-simulator"
headers_dir="$tmpdir/Headers"

mkdir -p "$device_dir" "$sim_dir" "$headers_dir"

cp "$source_headers/MDS.h" "$headers_dir/MDS.h"
cat > "$headers_dir/module.modulemap" <<'MODULEMAP'
module MovesenseMDS {
  header "MDS.h"
  export *
}
MODULEMAP

lipo "$source_lib" -thin arm64 -output "$device_dir/libmds.a"
lipo "$source_lib" -thin x86_64 -output "$sim_dir/libmds.a"

mkdir -p "$(dirname "$output_path")"
rm -rf "$output_path"

xcodebuild -create-xcframework \
  -library "$device_dir/libmds.a" \
  -headers "$headers_dir" \
  -library "$sim_dir/libmds.a" \
  -headers "$headers_dir" \
  -output "$output_path"

if [[ -n "$sign_identity" ]]; then
  codesign --force --timestamp --sign "$sign_identity" "$output_path"
  codesign --verify --verbose=2 "$output_path"
fi

echo "Generated $output_path"
