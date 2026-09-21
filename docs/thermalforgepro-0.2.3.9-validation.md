# ThermalForgePro 0.2.3.9 validation

Historical record: the version-specific comparison exceptions tested here were
subsequently found to violate numeric ordering. This release and its tag have
been withdrawn; see the correction and [current validation](thermalforgepro-0.2.3.10-validation.md).

Verified on 2026-09-21 on the M4 Max running macOS 27.
Release source: `d5fc6aec845dc5b5230fcdd6ab9c32430cd6fb1a`.
Homebrew formula: `25c5c067f7740c7440287c6c575ddc617b1ce6fc`.

## Numbering and provenance

`0.2.3.9` means upstream ThermalForge `0.2.3`, Pro maintenance revision `9`.
The upstream tag points to `3fbaa527aee05a5a0ed2606f00b50254df9d614f`, verified
as an ancestor of the release. Revision 9 continues the branch's earlier 0.2.3.8
maintenance sequence and supersedes the temporary independent Pro 0.3.3 numbering.

Only actual integration of a new upstream release changes the first three
components. Further fixes on this base become 0.2.3.10, 0.2.3.11, etc.; the first
revision after integrating upstream 0.2.4 becomes 0.2.4.1.

The new release comparator recognizes this transition and does not offer old
0.3.3 as an update to 0.2.3.9. Daemon protocol capability checks remain ordinary
numeric comparisons. Existing 0.3.x binaries retain their old comparator, so the
first transition requires Homebrew or the release download.

## Verification

- 84 tests passed locally in both Debug and Release, including the transition
  from 0.3.0–0.3.3, fourth-component numeric order, changes in the upstream base,
  malformed tags, and unchanged protocol compatibility.
- The separate process test passed with 108 abandoned client replies and default
  SIGPIPE handling. Existing crash, safety, handoff and localization regressions
  remain in the suite.
- [Source CI](https://github.com/hongyukeji/ThermalForgePro/actions/runs/35560486381),
  [release CI](https://github.com/hongyukeji/ThermalForgePro/actions/runs/35560488238)
  and [Homebrew CI](https://github.com/hongyukeji/homebrew-tap/actions/runs/35560533163)
  passed.
- With 0.3.3 installed, `brew outdated --json=v2 thermalforgepro` reported
  0.2.3.9 as the available upgrade. `brew upgrade` completed the transition and
  `brew test` passed. The installed receipt records `version_scheme: 1`.
- Both the Brew build and downloaded GitHub artifact ran on the Mac. CLI, daemon,
  CFBundleVersion and CFBundleShortVersionString all report 0.2.3.9. Three languages,
  Celsius/Fahrenheit and menu reopening passed. Normal menu height remains 449 pt,
  with 10 pt top/bottom padding and 6 pt footer gaps.
- Smart mode, system language, Celsius and Launch at Login remained enabled.
  After package acceptance, the installed runtime was resynchronized from Brew;
  the root-owned CLI matches the Brew binary exactly and the app signature passes
  strict verification.
- GitHub explicitly marks 0.2.3.9 as latest and the sole public release. The 0.3.3
  release and tag were removed after renumbering, and previously withdrawn
  0.3.0–0.3.2 remain absent. Homebrew also removed the local 0.3.3 keg on upgrade.

The downloaded ARM64 archive passed SHA256 verification:

```text
5e2b874b04cb9cbeb8cc9c9d7ef26abcc2f8e51fb5a16c4b286c0319036794a2  ThermalForgePro-0.2.3.9-macos-arm64.tar.gz
```

## Scope

This change concerns release numbering, comparison and distribution. It retains
all fixes from the [0.3.3 control and recovery acceptance](thermalforgepro-0.3.3-validation.md).
The current run verifies version migration and UI/runtime consistency; it does
not repeat physical restart, sleep or prolonged heat-load scenarios. The app
continues to use an ad-hoc signature rather than Apple notarization.
