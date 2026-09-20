#!/bin/bash
# Produce the same signed app + CLI layout used by Homebrew and source installs.
set -euo pipefail
cd "$(dirname "$0")/.."
swift build -c release
bin_dir="$(swift build -c release --show-bin-path)"
version="$("$bin_dir/thermalforgepro" --version)"
architecture="$(uname -m)"
test "$architecture" = arm64
if [ -n "${RELEASE_TAG:-}" ]; then test "$RELEASE_TAG" = "v$version"; fi
output_dir="${1:-$PWD/dist}"
mkdir -p "$output_dir"
output_dir="$(cd "$output_dir" && pwd)"
stage="$(mktemp -d "${TMPDIR:-/tmp}/thermalforgepro-release.XXXXXX")"
trap 'rm -rf "$stage"' EXIT
name="ThermalForgePro-$version-macos-$architecture"
mkdir -p "$stage/$name/bin"
cp "$bin_dir/thermalforgepro" "$stage/$name/bin/thermalforgepro"
"$bin_dir/thermalforgepro" build-app --binary "$bin_dir/ThermalForgeProApp" \
    --icon ThermalForgePro.icns --dest "$stage/$name/ThermalForgePro.app"
cp LICENSE NOTICE.md README.md "$stage/$name/"
cp -R ThirdPartyNotices "$stage/$name/"
codesign --force --deep --sign - "$stage/$name/ThermalForgePro.app"
codesign --verify --deep --strict "$stage/$name/ThermalForgePro.app"
COPYFILE_DISABLE=1 tar -czf "$output_dir/$name.tar.gz" -C "$stage" "$name"
(cd "$output_dir" && shasum -a 256 "$name.tar.gz" > SHA256SUMS)
printf 'Packaged %s\n' "$output_dir/$name.tar.gz"
