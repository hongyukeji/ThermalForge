#!/bin/bash
set -euo pipefail
sudo /usr/local/bin/thermalforgepro uninstall "$@"
if command -v brew >/dev/null && brew list --formula thermalforgepro >/dev/null 2>&1; then
    brew uninstall thermalforgepro
fi
