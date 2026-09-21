# Changelog

## 0.2.3.13

- Separate Quit from the preference controls with a full-width
  divider and equal 6 pt spacing above and below it. Preserve automatic popup
  height, menu interactions and the centered temperature label.
- Shorten the footer action to Quit in English and 退出 in both Chinese variants.

## 0.2.3.12

- Reserve a minimum menu-bar label width for the fan icon and a two-digit
  temperature. Center the complete group; allow three-digit readings to expand
  naturally without shrinking or truncating the text.
- Preserve native MenuBarExtra interactions, automatic popup height, localized
  accessibility text, idle/active/safety symbols and the orange update badge.
- Add five display regressions covering width, centering, appearance, units and
  missing data. Validate display boundaries through 999 degrees without sending
  synthetic inputs to the controller. Fan control and temperature collection
  are unchanged.

## 0.2.3.11

- Bound runtime logs to 5 MiB per file and 50 MiB per process user's log
  directory, retaining at most seven calendar days. Clean at startup, during
  writes and hourly while running, including an idle daemon.
- Move runtime file I/O off control callers into a bounded background queue.
  Back off on write errors and tolerate full or read-only storage.
- Mark temporary captures at creation and protect live recordings with a
  process lease. Ctrl-C and SIGTERM finalize metadata and extend expiry to
  24 hours after completion; abandoned captures can also be reclaimed.
- Stop temporary recordings at 100 MiB of CSV data. Explicit `--output` and
  `--no-expire` recordings remain permanent and uncapped. Preserve unmarked
  legacy recordings and unrelated files.
- Add 12 isolated logging regressions. Fan curves, safety behavior, release
  comparison, menu layout and translations are unchanged.

## 0.2.3.10

- Remove hardcoded release-order exceptions for the retired 0.3.x versions.
  App update checks and CLI automatic re-sync use ordinary dotted-numeric order.
- Fix inconsistent ordering across three- and four-component versions, including
  incorrectly treating 0.3.3.0 as newer than the equivalent 0.3.3.
- Cover numeric order across both formats and equivalent zero revisions. Keep
  the numbering migration in Homebrew's supported `version_scheme` metadata.
- Withdraw the superseded 0.2.3.9 public release and tag. The previously removed
  0.3.x releases remain withdrawn; historical commits and records are preserved.

## 0.2.3.9

The version-specific comparison exceptions in this release are corrected in 0.2.3.10.

- Use `<upstream version>.<Pro revision>`: this release is based on ThermalForge
  0.2.3 and continues the earlier local maintenance sequence after 0.2.3.8.
- Supersede Pro 0.3.3 without reverting its fixes. Release comparisons recognize
  the numbering transition; daemon protocol capability checks remain numeric.
- Remove the obsolete 0.3.x public releases and tags; 0.2.3.9 is the sole public
  release. Historical commits and validation records remain available.
- Homebrew uses `version_scheme 1` so `brew upgrade` recognizes 0.2.3.9 as the
  successor to 0.3.3. Existing 0.3.x apps need this first upgrade through Homebrew
  or the release download because their built-in comparator predates this scheme.

## 0.3.3

- Drop disconnected clients if macOS cannot enable `SO_NOSIGPIPE`, before starting
  an asynchronous reply. This prevents an abandoned request from terminating the
  daemon and releases the connection slot immediately.
- Add a standalone process regression with the default SIGPIPE disposition. It
  exercises clients that disconnect before acceptance and while replies are being
  prepared, then verifies that subsequent requests still succeed.
- Include the invalid-input protection from 0.3.2 and the automatic menu height
  correction from 0.3.1, with unchanged fan curves and Chinese wording.

Versions 0.3.0–0.3.2 are withdrawn. Upgrade to 0.3.3 and run
`sudo thermalforgepro install` to synchronize the app and privileged daemon.

## 0.3.2

- Reject nonexistent fan indices before hardware access or hold changes. A command
  such as `thermalforgepro set 3000 --fan 99` now returns a usage error instead of
  crashing the privileged daemon, including when a hold is thermally suspended.
- Reject malformed SMC key lengths and nonfinite, negative or unrepresentable RPM
  values without trapping or writing hardware. Preserve normal RPM clamping.
- Retain the automatic native menu height fix from 0.3.1 and existing translations,
  spacing, fan curves and safety behavior.
- Run both Debug and Release regression tests before publishing releases.

This candidate fixed invalid fan indices, but was superseded by 0.3.3 after live
testing found the disconnected-client failure described above.

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
