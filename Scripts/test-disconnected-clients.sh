#!/bin/bash
# Keep SIGPIPE regression outside the test runner's inherited signal handling.
set -euo pipefail
cd "$(dirname "$0")/.."
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/thermalforgepro-disconnect.XXXXXX")"
trap 'rm -rf "$test_dir"' EXIT
swiftc -O Sources/ThermalForgeProCore/*.swift Tests/ProcessFixtures/DisconnectedClients.swift \
    -o "$test_dir/disconnected-clients"
"$test_dir/disconnected-clients"
