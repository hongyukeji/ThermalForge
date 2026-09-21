# ThermalForgePro 0.3.0 validation

Historical record only: 0.3.0 was withdrawn after later testing found menu sizing
and daemon crash defects. See the [0.2.3.9 validation](thermalforgepro-0.2.3.9-validation.md)
for the current replacement; the old release link below is retained as historical context.

Verified on 2026-09-21. Release source: `3907bc5523b1d04f880788a47f9390a1a8792920`.

## Published artifacts

- [Release v0.3.0](https://github.com/hongyukeji/ThermalForgePro/releases/tag/v0.3.0)
- [Source CI](https://github.com/hongyukeji/ThermalForgePro/actions/runs/35537038649): build, all 76 tests, localization packaging and missing-resource protection passed.
- [Release CI](https://github.com/hongyukeji/ThermalForgePro/actions/runs/35537129076): all 76 tests, release build, packaging and publication passed.
- [Homebrew CI](https://github.com/hongyukeji/homebrew-tap/actions/runs/35537149513): formula installation and `brew test` passed on a macOS 15 runner.

The downloaded ARM64 archive was independently checked against SHA256SUMS:

```text
8adbe29daa9164e8257ed3d9b74c67616adc83e5e5a2a4850f12f71a6de47441  ThermalForgePro-0.3.0-macos-arm64.tar.gz
```

Its CLI reports 0.3.0, its app passes `codesign --verify --deep --strict`, and its license notices are included. The app uses an ad-hoc signature, without Apple notarization.

## Local acceptance

Hardware: Mac16,5, M4 Max; macOS 27. This pre-release OS is outside Homebrew's primary support tier.

- All 76 tests passed locally, including a fresh build after renaming the repository directory.
- `brew tap hongyukeji/tap`, `brew install thermalforgepro` and `brew test thermalforgepro` passed. The formula pins the exact release commit and Swift dependency resolution.
- Migrated the installed ThermalForge 0.2.3.8 runtime with `install --migrate-thermalforge`. Old runtime files were backed up; language, temperature units and selected profile were preserved. A migration attempt without the explicit flag refused before changing the old runtime.
- Synchronized the Brew-built runtime using `sudo thermalforgepro install`. The root-owned CLI exactly matches the Brew binary, and the installed app signature and launchd service were verified. The old app, CLI, daemon, socket, Homebrew formula and tap were removed.
- English, Simplified Chinese and Traditional Chinese were exercised in the running app. Fan 1, Ambient and Max each have 5 pt clearance above their following divider. Footer control gaps are all 6 pt. Panel width remains 260 pt. Traditional Chinese retains the Simplified-to-Traditional conversion policy.
- The real maximum-speed command set both target registers to their reported 5777 RPM maximum. During the hold, 75 version/state/heartbeat requests succeeded; maximum observed latency was 1.928 ms. This is a bounded local sample, not a performance guarantee.
- Quitting and relaunching the app preserved the CLI hold and the selected English/Fahrenheit settings. Login at launch remained enabled. `auto` successfully returned both fans to automatic control; Smart, system language and Celsius were then restored.
- The update endpoint resolves to this repository's 0.3.0 release. Upstream PRs #54–#58 remain open with unchanged contribution commit IDs after the repository rename.

## Test execution and limits

`Scripts/test.sh` explicitly disables parallel test-case execution. Blocking socket clients could stall the small cloud runner when all cases ran concurrently. Separating AppKit initialization alone did not resolve those failures; serial execution passed locally and in both source and release CI. Concurrent server connections are still exercised inside the socket tests, with the original deadlines unchanged.

No fan curves, sensor selection, monitor interval or thermal safety threshold were changed for the Pro rename. This acceptance does not establish compatibility with every Apple Silicon model or macOS version. Forced migration rollback, sleep/reboot recovery and prolonged GPU workloads were not exercised in this release acceptance.
