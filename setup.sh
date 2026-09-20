#!/bin/bash
# Build a complete app before replacing any running installation.
set -euo pipefail
cd "$(dirname "$0")"
swift build -c release
bin_dir="$(swift build -c release --show-bin-path)"
if [ ! -f ThermalForgePro.icns ]; then
    swift Scripts/generate-icon.swift
    iconutil -c icns ThermalForgePro.iconset -o ThermalForgePro.icns
fi
"$bin_dir/thermalforgepro" build-app --binary "$bin_dir/ThermalForgeProApp" \
    --icon ThermalForgePro.icns --dest "$bin_dir/ThermalForgePro.app"
codesign --force --deep --sign - "$bin_dir/ThermalForgePro.app"
sudo "$bin_dir/thermalforgepro" install "$@"
open /Applications/ThermalForgePro.app
