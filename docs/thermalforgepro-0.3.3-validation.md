# ThermalForgePro 0.3.3 validation

Verified on 2026-09-21 on a Mac16,5 (M4 Max), macOS 27.0 (26A428).
Release source: `50e7e4fd9025ae873752b9ad7ad71b3398cf58b7`.

## Defects found and fixed

- A real `set 3000 --fan 99` request crashed the 0.3.1 privileged daemon because
  the generated SMC key exceeded four bytes. Fan indices are now validated before
  hardware access, rate-limit consumption or hold recording; malformed SMC key
  lengths fail without an IOKit call. Nonfinite, negative and unrepresentable RPM
  inputs cannot trap during client serialization or daemon processing.
- Subsequent live testing found a separate SIGPIPE termination when clients
  disconnected before a reply. A standalone process reproduced it: macOS can
  reject `SO_NOSIGPIPE` with EINVAL for an already-disconnected peer. The server
  now closes such descriptors and releases their connection slots immediately.
  It never starts an asynchronous write on an unprotected descriptor.
- The native automatic menu-height correction is retained. The panel uses ideal
  content size and SwiftUI window resizability, with no fixed height or custom
  window renderer. Fan curves, monitoring cadence and safety thresholds are unchanged.

## Automated checks

- 81 tests in 15 suites passed locally in both Debug and Release configurations.
- The standalone process regression passed with default SIGPIPE handling: 8 clients
  disconnect before acceptance, 100 more abandon replies, and a subsequent request
  still succeeds. This is run by `Scripts/test.sh` outside the Swift test runner.
- Localization packaging, missing-resource protection and strict app signature
  verification passed.
- Source and release workflows run both Debug and Release tests. Tag builds create
  a draft release; the downloaded artifact must pass local acceptance before publication.

## Local acceptance

- English, Simplified Chinese and Traditional Chinese; Celsius and Fahrenheit;
  repeated menu reopening; all four profiles; Smart and Default; login-item toggle.
  Traditional Chinese keeps the literal Simplified-to-Traditional conversion policy.
- Native panel width 260 pt. Ordinary height 449 pt, CLI-hold banner height 539 pt,
  then 449 pt again after release. The top and bottom padding remain 10 pt and footer
  control gaps remain 6 pt. Relaunching the app during a CLI hold preserves the hold.
- Actual maximum control and single-fan 5777 RPM control, followed by verified Apple
  automatic control. An all-fan request for 999999 RPM correctly clamps to 5777 RPM.
- 27 invalid or malformed protocol requests plus four extreme CLI argument cases
  were rejected without daemon restart or hold changes.
- Eight stalled request headers still allowed a valid heartbeat after about one
  second. Thirty abandoned replies, oversized framing and a legacy header did not
  restart the daemon. Healthy heartbeat/state/version requests were also checked.
- A normal uninstall removed the app, daemon, socket and root-owned CLI while
  preserving preferences and a marker in the user profile directory. Reinstall
  restored the runtime. A controlled launchd service restart reconnected successfully.
- Final settings are Smart, system language, Celsius and Launch at Login enabled.

## Distribution evidence

- [Source CI](https://github.com/hongyukeji/ThermalForgePro/actions/runs/35541303704),
  [release CI](https://github.com/hongyukeji/ThermalForgePro/actions/runs/35541305462),
  and [Homebrew CI](https://github.com/hongyukeji/homebrew-tap/actions/runs/35541325020)
  all passed for the pinned release source and formula.
- Homebrew formula commit: `6f39be1546408d89deebd35afc969e0164932048`.
  Local `brew upgrade` and `brew test` passed. The Brew-installed app completed the
  language, geometry, profile, control and malformed-connection matrix.
- The downloaded GitHub ARM64 artifact completed the same UI and control matrix,
  including invalid inputs and disconnected peers. Its CLI exactly matched the
  installed root CLI during acceptance, and strict app signature checks passed.
- Healthy 75-request liveness samples peaked at 0.664 ms for the Brew runtime and
  0.613 ms for the downloaded runtime. Behind eight stalled headers, heartbeat
  latency was 1.011 s and 1.006 s respectively. These are bounded samples.
- Root CLI permissions are root:wheel 0755, launchd plist root:wheel 0644, and the
  socket is owned by the controlling user with mode 0600. The old ThermalForge
  runtime and Homebrew formula are absent.

The downloaded archive passed SHA256 verification:

```text
756027f9fda6590513c532509013067746a666830f689d8b5a26015eed1ec63f  ThermalForgePro-0.3.3-macos-arm64.tar.gz
```

## Scope

This acceptance covers the running M4 Max, packaged resources, protocol failures,
installation lifecycle and automated simulated safety/handoff regressions. It does
not establish every Apple Silicon/macOS combination, physical sleep/reboot behavior,
forced migration rollback or prolonged GPU/overtemperature behavior. No deliberate
CPU/GPU heat stress, physical restart or user-data purge was performed. The app uses
an ad-hoc signature and is not Apple-notarized.

The earlier failed tests and crash evidence were retained. The 0.3.2 candidate was
briefly published by the old automatic workflow while cancellation was racing the
publish step, then returned to draft. Versions 0.3.0–0.3.2 are withdrawn and their
release tags removed in favor of the verified 0.3.3 replacement. Commit history and
recovery backups remain.
