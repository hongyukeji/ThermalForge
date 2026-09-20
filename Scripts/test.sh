#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
# AppKit's first offscreen render can occupy the constrained macOS CI runner for
# seconds. Keep that initialization outside the socket tests' measured deadlines.
swift test --skip LocalizedPanelTests "$@"
swift test --skip-build --filter LocalizedPanelTests
