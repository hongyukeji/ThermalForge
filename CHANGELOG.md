# Changelog

## 0.3.2

- Reject nonexistent fan indices before hardware access or hold changes. A command
  such as `thermalforgepro set 3000 --fan 99` now returns a usage error instead of
  crashing the privileged daemon, including when a hold is thermally suspended.
- Reject malformed SMC key lengths and nonfinite, negative or unrepresentable RPM
  values without trapping or writing hardware. Preserve normal RPM clamping.
- Retain the automatic native menu height fix from 0.3.1 and existing translations,
  spacing, fan curves and safety behavior.
- Run both Debug and Release regression tests before publishing releases.

Versions 0.3.0 and 0.3.1 are withdrawn because they accept invalid fan indices that
can crash the daemon. Upgrade to 0.3.2 and synchronize the installed service with
`sudo thermalforgepro install`.

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
