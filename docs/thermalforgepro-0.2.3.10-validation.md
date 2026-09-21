# ThermalForgePro 0.2.3.10 validation

Verified on 2026-09-21 on the M4 Max running macOS 27.
Release source: `9b0d68b562e298430b65298b763d1b2cb72edc51`.
Homebrew formula: `244cd81a911a40b7e930d46bd310c637794f8c78`.

## Correction

The release comparator previously contained exceptions for 0.3.0–0.3.3 and
four-component versions at or above 0.2.3.9. These exceptions violated numeric
ordering and even treated 0.3.3.0 as newer than the equivalent 0.3.3.

The exceptions are removed. App update checks and CLI automatic re-sync compare
valid numeric components from left to right, with an omitted component equal to
zero. In particular, 0.2.3.10 > 0.2.3.9 and 0.2.3.10 < 0.3.3. Daemon protocol
capability comparison is unchanged.

Homebrew retains its supported `version_scheme 1` metadata for the historical
numbering migration. Existing 0.3.x installations must use Homebrew or explicitly
install a downloaded package; the application does not redefine numeric order.

## Regression evidence

- Before the correction, the new tests reproduced 32 failed expectations across
  three cases, including the equivalent-version error.
- After the correction, all 85 tests in 15 suites passed in both Debug and Release.
  The ordering matrix checks every pair among 12 three- and four-component versions;
  separate cases cover equivalent zero revisions and malformed tags.
- The standalone process regression passed with 108 abandoned replies followed
  by a successful request, using the default SIGPIPE disposition.
- ARM64 packaging, strict app signature verification, localization resources and
  missing-resource protection passed.
- The locally packaged candidate ran on the Mac. CLI, app and daemon reported
  0.2.3.10. English, Simplified Chinese and Traditional Chinese, Celsius/Fahrenheit
  and menu reopening passed. The normal menu measured 260 × 449 pt, with 10 pt
  top/bottom padding and 6 pt footer gaps. Smart mode, system language, Celsius
  and Launch at Login were preserved.
- [Source CI](https://github.com/hongyukeji/ThermalForgePro/actions/runs/35561738718)
  and [release CI](https://github.com/hongyukeji/ThermalForgePro/actions/runs/35561741584)
  passed for the exact release commit.
- The downloaded GitHub artifact passed SHA256 and strict signature verification,
  and the same native UI/runtime checks passed on its installed app and daemon.
  The test harness needed real mouse clicks with press/release delays and visible
  state polling for menu reopening; accessibility press alone did not reliably
  toggle the native panel. No application UI code was changed for this.
- Homebrew upgraded the installed 0.2.3.9 keg to 0.2.3.10. Local `brew test` and
  [Homebrew CI](https://github.com/hongyukeji/homebrew-tap/actions/runs/35562129496)
  passed. The receipt retains `version_scheme: 1`.
- After synchronizing from Brew, the installed root-owned CLI and app executable
  match their Brew copies exactly; CLI, app metadata and the single running daemon
  report 0.2.3.10. The same three-language/native-window checks passed again.
- GitHub lists only 0.2.3.10 as a public release. The superseded 0.2.3.9 release
  and tag were withdrawn; obsolete Pro 0.3.x releases/tags remain absent. Historical
  commits and validation records, and inherited upstream tags, remain intact.

The downloaded ARM64 archive checksum is:

```text
175f8dfca1cf7d71962227a352077eca32eac6922a67dcdd71e396bea26dd009  ThermalForgePro-0.2.3.10-macos-arm64.tar.gz
```

## Scope

This correction changes release comparison and the maintenance revision only.
Fan curves, hardware control, safety thresholds, native menu layout and
translations are unchanged. This run does not repeat physical reboot, sleep or
prolonged heat-load scenarios. The app continues to use an ad-hoc signature.
