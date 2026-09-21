# ThermalForgePro 0.2.3.11 validation

Verified on 2026-09-22 on an M4 Max (Mac16,5), macOS 27.
Release source: `e654abdc2b3047fe227ff9c3db51446bc067e1c5`.
Upstream contribution: [ProducerGuy/ThermalForge #59](https://github.com/ProducerGuy/ThermalForge/pull/59), based on upstream main `8a344f63a4b832f434c833d2143b3d41fa0ddd4a`.

## Behavior

Runtime files rotate at 5 MiB and each user's runtime log directory retains at
most 50 MiB and seven calendar days, including today. Startup, per-write and
hourly maintenance remove expired/excess files, including in an idle daemon.
The app and privileged daemon have separate user/root directories. The bounded
utility queue holds at most 256 messages with an 8 KiB message budget each;
it may drop records under overload. Disk failures back off for 60 seconds.

Temporary recordings carry expiry markers from creation and a process-held
lease prevents live sessions from being deleted. Normal completion, SIGINT and
SIGTERM extend expiry to 24 hours after completion. Abrupt termination releases
the lease; an expired abandoned capture can then be reclaimed. Temporary CSV
data stops before exceeding 100 MiB per recording. Explicit `--output` and
`--no-expire` recordings remain permanent and uncapped. Unmarked legacy captures,
other files, user profiles and calibration are preserved. No custom export
locations are scanned. Cleanup is deferred while the app is not running.

## Local evidence

- All 97 tests in 16 suites pass in Debug and Release, including 12 new logging
  regressions. The standalone default-SIGPIPE regression passes 108 abandoned
  replies followed by a successful request. Localization packaging checks pass.
- The official upstream variant passes all 61 tests in nine suites in Debug and
  Release and builds in Release. Its existing profile tests used a verified
  isolated Foundation home directory to protect real user profiles.
- Actual filesystem rotation with production limits accepted 10,240 records and
  retained 52,020,592 bytes across ten files, each no larger than 5 MiB and the
  total below 50 MiB (52,428,800 bytes).
- A disposable 256 MiB HFS+ disk image was filled to provoke real ENOSPC. The
  logging process survived and resumed writing after space was freed. This probe
  shortened retry delay to 0.2 seconds; the production 60-second backoff is
  verified separately with an injected clock. The image
  was then mounted read-only: log failure did not terminate the process. The
  image was unmounted and deleted after testing; the host filesystem was not filled.
- A separate process held a capture lease across expiry. Cleanup kept the live
  directory, then removed it after that child was killed with SIGKILL.
- Both Pro and upstream CLI builds read actual SMC data for timed capture,
  SIGINT, SIGTERM, explicit output and no-expire sessions. At a 50-second sample
  interval, signal-driven termination completed within 4 ms in these runs and
  wrote valid metadata plus the expected retention marker.
- The candidate was installed as the actual app and root daemon. Synthetic old
  files were removed from real user/root log directories. The daemon startup
  record confirms maintenance initialization before any fan command is needed.
- English, Simplified Chinese and Traditional Chinese; Celsius/Fahrenheit;
  menu close/reopen; Smart selection and Launch at Login passed native checks.
  The normal menu remained 260 by 449 pt, with 10 pt top/bottom padding and 6 pt
  footer gaps. Original system language, Celsius and Smart preferences were restored.
- The candidate acceptance window contained no new application or runtime-daemon
  error records. The daemon remained running without an unexpected restart.

## Published artifact

[Source CI](https://github.com/hongyukeji/ThermalForgePro/actions/runs/35632373084)
and [release CI](https://github.com/hongyukeji/ThermalForgePro/actions/runs/35632459584)
passed for the exact release commit. The downloaded GitHub ARM64 package passed
SHA256 verification and strict code-signature verification before publication.
The installed CLI and app executable matched that downloaded package byte for
byte. CLI, app metadata and the running daemon all reported 0.2.3.11.

The downloaded artifact passed the same native three-language/unit/menu checks
and five actual-SMC capture cases. A further 100 daemon version queries all
succeeded (maximum observed response time 4.581 ms), with no new error records
in the probe window and no daemon restart. Original preferences were preserved.

The public [0.2.3.11 release](https://github.com/hongyukeji/ThermalForgePro/releases/tag/v0.2.3.11)
is marked latest. The healthy 0.2.3.10 release remains available as history.

```text
2de1e54eac5492f6cc08c9818d5549bacf79d64c195e1c56b521ca955e8e4e36  ThermalForgePro-0.2.3.11-macos-arm64.tar.gz
```

## Homebrew acceptance

Formula commit: `96e77148a20c1a780b3d23c2d0cd64d758bc25cb`.
[Homebrew CI](https://github.com/hongyukeji/homebrew-tap/actions/runs/35633050381)
and local `brew test` passed. Homebrew upgraded 0.2.3.10 to 0.2.3.11 and its
receipt still uses `version_scheme: 1`; numeric comparison logic did not change.
The temporary Homebrew developer-mode setting was restored to off.

After synchronization from Brew, the root-owned CLI and app executable matched
their Brew copies exactly. The single running app, daemon and both CLI paths
reported 0.2.3.11. The same native menu and five real-SMC capture cases passed.
Another 100 daemon queries succeeded, with maximum observed latency 1.186 ms,
no new error records in the probe window and no unexpected restart. Smart mode,
system language, Celsius and the enabled login item were preserved.

## Scope

Only logging and the maintenance version change in executable behavior. Fan
curves, safety thresholds, numeric version comparison, layout and translations
are unchanged. Long retention periods are tested with an injected clock;
this is not seven days of continuous observation. No new physical reboot,
sleep/wake or prolonged thermal stress acceptance is claimed. System unified
logs remain managed by macOS. The app continues to use an ad-hoc signature.
