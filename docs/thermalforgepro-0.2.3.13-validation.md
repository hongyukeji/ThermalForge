# ThermalForgePro 0.2.3.13 validation

Verified on 2026-09-22. Release source: `38f9f9001c3c0b6c630c81dd934a2ddff9c410d5`.

The footer now separates Quit from preferences with a full-width divider and
6 pt above and below it. English displays “Quit”; both Chinese variants display
“退出”. The native menu, automatic height, temperature label, sensors and fan
control remain unchanged. The README contains a fresh capture of the installed
candidate, including the short Quit label.

## Checks

- Local Debug and Release each passed 102 tests in 17 suites, plus the standalone
  108-disconnected-client regression in each configuration. Resource packaging
  and missing-resource protection passed.
- [Source CI](https://github.com/hongyukeji/ThermalForgePro/actions/runs/35650387806)
  and [release CI](https://github.com/hongyukeji/ThermalForgePro/actions/runs/35650391656)
  passed for the exact release source on macOS 15.
- The local candidate, downloaded release package and final Homebrew installation
  each passed native English/Simplified Chinese/Traditional Chinese, Celsius and
  Fahrenheit, menu close/reopen, footer visibility and 20 live-refresh samples.
  The menu measured 260 × 456 pt, retaining 10 pt top/bottom margins. Preference
  rows retain 6 pt gaps; the final row-to-Quit gap is 13 pt (6 + divider + 6).
- App and daemon logs had no new error entries or crash reports during those
  acceptance windows. The prior divider candidate's Quit test also verified
  process exit and release of the app-owned fan hold before reopening the app.
  Shortening the label did not change that action.

## Distribution and final installation

The [public release](https://github.com/hongyukeji/ThermalForgePro/releases/tag/v0.2.3.13)
was published after installing and testing the downloaded package. Its archive
matched SHA256SUMS and GitHub's asset digest; the application passed strict code
signature verification. An unauthenticated download after publication matched:

```text
7b606c60a1a3a4dcf586f2368edfeeeacb51a1bfad6e2e6a21372d563ad6f3ab  ThermalForgePro-0.2.3.13-macos-arm64.tar.gz
```

The formula pins the release source above, preserving `version_scheme 1`.
Formula commit: `5805bc7b26cabcd83b2248ec5a38215b15439747`.
Local `brew test` passed; the [Homebrew CI run](https://github.com/hongyukeji/homebrew-tap/actions/runs/35650987833)
records the remote build and test result.

After synchronization, the installed app and root CLI matched the final Homebrew
executables byte for byte. App metadata, Brew CLI, root CLI and the running daemon
all reported 0.2.3.13. Thirty daemon queries succeeded, with maximum observed
latency 3.209 ms. Smart mode, system language, Celsius and enabled
Launch at Login were preserved. Homebrew developer mode was restored to off.
The final application remains running.

## Limits

Native UI checks used the local M4 Max on macOS 27.0 with a 2× display. macOS 15 CI
is build/test coverage, not physical desktop acceptance. Other OS/hardware,
physical 1× screens, VoiceOver speech, sleep/wake, reboot and prolonged operation
were not newly verified for this cosmetic release. The app retains its ad-hoc
signature and is not Apple-notarized.

Detailed records: `~/Library/Application Support/ThermalForgePro/release-0.2.3.13/`.
