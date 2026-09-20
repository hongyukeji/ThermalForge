# Changelog

## 0.3.1

- Automatically resize the native menu window to its measured content height.
  Removing a temporary banner now shrinks the window again, fixing excess
  background space and square content edges inside the retained larger window.
- Preserve the native window appearance, top anchor, existing row spacing and
  all fan-control behavior. Use SwiftUI's content-size window policy and ideal
  content height; no fixed panel height or custom window renderer is needed.

## 0.3.0

First independent ThermalForgePro release, derived from the locally validated
ThermalForge 0.2.3.8 maintenance build.

- Rename the app, CLI, modules, IPC, service and resource identifiers to Pro.
- Use the hongyukeji/ThermalForgePro release channel and Homebrew tap.
- Add explicit backed-up migration from ThermalForge and preserve data on normal uninstall.
- Keep English, Simplified Chinese and Traditional Chinese, native menu spacing,
  M4 handoff/transport fixes, checked automatic release and isolated profile tests.
- Preserve upstream attribution and include the MIT license in the app and distribution.

This release does not change fan curves, sensor selection, the 100 ms monitor
interval or the upstream 95°C safety threshold.
