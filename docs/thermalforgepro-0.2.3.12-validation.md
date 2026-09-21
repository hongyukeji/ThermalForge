# ThermalForgePro 0.2.3.12 validation

Verified on 2026-09-22. Release source:
`6ad3be4f8fc992eaa5748db84f4bc6491a72412e`.

This release reserves the menu-bar label's minimum width for an icon, two
monospaced digits and the degree sign, centering the complete group. Three-digit
readings may expand. The native menu and automatic popup height remain intact.
Fan control, sensor selection, logging and version comparison are unchanged.

The underlying implementation passed 102 tests in 17 suites in both Debug and
Release. Native candidate acceptance on M4 Max/macOS 27 includes 121 seconds of
uninterrupted real-temperature observation (100 samples), three languages,
Celsius/Fahrenheit, menu close/reopen, and 41 isolated display checks through
999 degrees. App and daemon runtime logs contained no new errors during that
acceptance window. See [the detailed display validation](menu-bar-label-validation.md)
for evidence, measurements and environment limits.

## Published package

[Source CI](https://github.com/hongyukeji/ThermalForgePro/actions/runs/35644439697)
and [release CI](https://github.com/hongyukeji/ThermalForgePro/actions/runs/35644869980)
passed for that exact commit on macOS 15. The versioned local Debug and Release
checks each passed 102 tests and the standalone 108-client SIGPIPE regression.
Resource packaging checks also passed.

The downloaded ARM64 package matched both its SHA256SUMS file and GitHub's
asset digest, and passed strict code-signature verification. The downloaded
package was installed as the actual app and privileged daemon before publication.
Both installed executables matched that package byte for byte. App metadata,
CLI and daemon all reported 0.2.3.12.

That installed package passed English/Simplified Chinese/Traditional Chinese,
Celsius/Fahrenheit, menu close/reopen, live refresh, complete footer, Smart mode
and enabled login-item checks. The popup remained 260 x 449 pt. Thirty daemon
version queries succeeded, with maximum observed latency of 3.306 ms. No new
runtime error entries or crash reports appeared during the acceptance window.

The [0.2.3.12 release](https://github.com/hongyukeji/ThermalForgePro/releases/tag/v0.2.3.12)
is public and marked latest. A subsequent unauthenticated download matched the
same checksum. Healthy 0.2.3.11 and 0.2.3.10 releases remain available.

```text
ac0fcceb6dab2c3cf9f472a431259772f9eecf3b13bef56c0a33d0e399e9851c  ThermalForgePro-0.2.3.12-macos-arm64.tar.gz
```

## Homebrew and final local installation

Formula commit: `b20dfb6a95cf03014d5081374666816d1a50e53a`.
The formula references the release tag and exact source commit above. Its
existing `version_scheme 1` remains unchanged.
[Homebrew CI](https://github.com/hongyukeji/homebrew-tap/actions/runs/35645602873)
and local `brew test` passed. Homebrew upgraded to 0.2.3.12 and the receipt
confirmed the version and `source.versions.version_scheme` value.

After synchronization from the Brew keg, the installed root CLI and application
executable matched their Brew copies exactly. The single running app, daemon,
root CLI and Brew CLI all reported 0.2.3.12. The native language/unit/menu checks
passed again; thirty daemon queries succeeded with a maximum observed latency
of 2.124 ms. No new runtime error entries or crash reports appeared in that
acceptance window. Smart mode, system language, Celsius and the enabled login
item were preserved. Homebrew developer mode was restored to its original off
state. The updated application remains installed and running.

## Limits

Physical UI verification used an M4 Max (Mac16,5), macOS 27.0 (26A428), a built-in
Retina display and LG 4K display at their current 2x scale. macOS 15 CI is build
and test coverage, not a physical desktop acceptance run. Other OS/hardware,
physical 1x screens, VoiceOver speech, sleep/wake, reboot and prolonged operation
were not verified for this release. Boundary values came from an isolated display
fixture and never entered the real fan controller. The distribution continues
to use an ad-hoc signature and is not Apple-notarized.

Local artifacts and per-stage records are in
`~/Library/Application Support/ThermalForgePro/release-0.2.3.12/`.
