# Upstream follow-ups: 2026-09-21

Fork build **0.2.3.5**, based on the hardware-tested **0.2.3.2** repair (`97a8a83`). Installed on the local M4 Max on 2026-09-21, after the installation checks below exposed and corrected two issues in the intermediate 0.2.3.4 build. This is not an official upstream release.

## Changes and provenance

| Upstream reference | Adopted scope |
| --- | --- |
| [PR #30](https://github.com/ProducerGuy/ThermalForge/pull/30) | Attempt every automatic-mode/Ftst write. On rejection, fresh readback after the full release must confirm automatic/system mode (0/3) or cleared Ftst (0); unreadable, manual or unknown states still throw. Advisory target resets stay best-effort. Seven injected-write tests cover failures, already-released hardware and post-Ftst read ordering. |
| [PR #47](https://github.com/ProducerGuy/ThermalForge/pull/47) | Profile persistence accepts an optional directory. Tests use a UUID scratch directory instead of Application Support. The menu/CLI do not gain custom profiles. |
| [PR #44](https://github.com/ProducerGuy/ThermalForge/pull/44) | Explicit profile buttons replace Picker writes; selecting the active profile preserves its ramp, while Silent uses the acknowledged Default reset. The proposed 85°C danger-zone rule is excluded. |
| [PR #48](https://github.com/ProducerGuy/ThermalForge/pull/48) | Wake execution re-reads the live hold after the delay under the SMC lock, preserving app/CLI holds and safety suspension. Smart releases below its existing 50°C stop point despite stale positive rate history, and approaches hardware minimum in its existing 50–53°C band instead of using an out-of-band calibration sample. |
| [PR #11](https://github.com/ProducerGuy/ThermalForge/pull/11) | Cache successful SMC key sizes per connection under a lock. Values remain fresh; missing, failed or rejected metadata is not cached. No sampling-rate or sensor-family changes. |
| [PR #51](https://github.com/ProducerGuy/ThermalForge/pull/51), [PR #50](https://github.com/ProducerGuy/ThermalForge/pull/50) | Retained NSStatusItem/NSPopover, fixed three-column temperature image, stable accessibility identifier and changing accessibility value. Preserve the profile panel, temperature units, state icons and daemon mismatch badge. Offscreen inspection corrected glyph spacing and preserved the warning symbol's cutout. |

The wake implementation intentionally differs from #48: it does not simply stop restoring supervised app holds, which could miss a steady hot target after wake. It also does not force-reset every observed manual fan: hardware mode alone does not identify the writer, and clearing it can destroy a fresh CLI hold before the app's next ownership poll. Seven simulated recovery tests cover the actual monitor tick and the delayed execution policy; they do not suspend the real machine.

## Preserved behavior

The built-in profile definitions, CPU/GPU sensor list, 100ms thermal cadence, 95°C threshold and daemon thermal-floor invariants retain their official values. The prior 30-second hardware-command timeout, shared 20-second acquisition budget, two-second liveness queries, separate frame I/O deadlines and SIGPIPE handling remain in place.

No custom 70/80°C full-speed target, power-mode switching, inference restriction, custom-profile editor or timed profile revert was added. oMLX, OpenCode, model settings, Smart selection, temperature units, login registration and launchd configuration were not changed. The intermediate SwiftUI Settings scene wrote a window-frame preference; the final AppKit entry point no longer creates that window.

## Local validation

- `swift test --jobs 2`: **78 tests in 13 suites passed**. Tests use fake fan/SMC writes or isolated sockets, directories and offscreen rendering; they do not launch the application or claim real fan ownership.
- The test suite includes the original eight slow-handoff/transport tests, seven release tests, seven recovery tests, five cache tests and two status-image tests.
- `swift build -c release --jobs 2`: passed; CLI and assembled application report **0.2.3.5**.
- Status images rendered with two- and three-digit Celsius/Fahrenheit-sized values, all three state symbols and the mismatch badge. This is offscreen rendering/build verification, not interactive menu-manager compatibility acceptance.
- Built-in curve definitions and daemon threshold invariants were compared against official v0.2.3. The existing profile tests verify their exact parameters.

Real sleep/wake, reboot, prolonged loaded inference and interactive menu-bar-manager compatibility remain untested. The earlier two cold handoff runs belong to 0.2.3.2; this installation received new hardware tests.

## Installation follow-up

Initial installation of 0.2.3.4 exposed an empty 900x450 Settings window from the placeholder SwiftUI scene. The app now starts an AppKit `NSApplication` with a retained delegate and hosts SwiftUI only in its status-item popover. The installed 0.2.3.5 process has no ordinary on-screen window at launch.

A subsequent update attempt also returned `F0Md` write failure while stopped fans already reported system mode. Installation aborted and reopened 0.2.3.4 before replacing it. The final release helper verifies fresh mode/Ftst readback after attempting every write, accepting confirmed automatic state without suppressing real failures. Four new tests cover automatic/system modes, manual/unknown states, readback after Ftst reset, and an uncleared diagnostic flag.

The final application, CLI and running daemon all report 0.2.3.5. The app has an ad-hoc local signature. Binary hashes and the unchanged launchd plist were verified; the CLI link still resolves to the daemon binary and login registration remains enabled. Backups of both 0.2.3.2 and the intermediate build are retained locally.

Two new cold-handoff tests first confirmed both physical fans at 0 RPM and then issued maximum speed without a compute workload:

| Metric | Run 1 | Run 2 |
| --- | ---: | ---: |
| Handoff command duration, including polling interval | 14.614 s | 7.951 s |
| Concurrent version/state/heartbeat requests | 282, no errors | 153, no errors |
| Maximum query duration | 2.042 ms | 2.775 ms |
| Actual RPM after five seconds at maximum | 5,789 / 5,802 | 5,747 / 5,756 |
| Repeated target writes, including CLI launch | 15.020–19.659 ms | 15.667–21.094 ms |

Both runs restored Smart, cleared the CLI hold and returned both fans to system mode at 0 RPM. An earlier preparation attempt was stopped because the machine did not cool below its conservative 50°C preparation threshold; it restored Smart and did not proceed with its maximum-speed command. The completed tests define a cold handoff by actual 0 RPM and retain a 70°C maintenance ceiling; these are test preconditions, not changes to everyday control policy.


A subsequent 30-second Metal matrix workload left Smart in control throughout. GPU temperature rose from 42.3°C to a sampled peak of 73.7°C (CPU peak 76.3°C). Fans first registered nonzero RPM at 13.1 seconds, reached manual control at 15.3 seconds and peaked at 4,677 RPM during the load. This reflects the sustained trigger and physical acquisition delay; it is not instant fan response. The configured 88°C test stop was not reached.

After the load, Smart ramped down to its 1,350 RPM minimum in the 50–53°C band, released control below 50°C at about 59 seconds, and both fans were stopped by about 61 seconds. At 67 seconds the sampled peak was 49.9°C with both fans in system mode at 0 RPM. No CLI fan command or extra heartbeat was used during this load/cooldown test. All 120 concurrent version/state queries succeeded (maximum 0.959ms); the app and daemon PIDs stayed unchanged. Three later redundant `auto` commands succeeded in 8.044–8.815ms, including CLI launch.

The final daemon remained at launchd `runs = 1`, with no exit. No application `[ERROR]` entry appeared during the installed final-build tests. This is bounded functional validation, not a sustained inference benchmark, reboot/sleep test or a promise of a 73.7°C temperature ceiling.

## Read-only SMC cache measurement

On the M4 Max, an optimized standalone harness read the same 50 temperature keys for ten warm-up sweeps and then 200 measured sweeps. Both implementations found the same 35 readable keys. Baseline and candidate used the corresponding SMCConnection source, the same SMCKeys source and identical harness. The installed controller kept running. A baseline/cached/cached/baseline comparison measured per-process user+system CPU time with `getrusage`:

| Run | CPU ms / 200 sweeps | Median sweep ms | P95 sweep ms |
| --- | ---: | ---: | ---: |
| Baseline 1 | 147.380 | 9.288 | 10.410 |
| Cached 1 | 130.374 | 8.208 | 11.918 |
| Cached 2 | 129.849 | 8.356 | 11.044 |
| Baseline 2 | 141.175 | 8.738 | 9.913 |

Mean CPU cost fell from 144.278ms to 130.112ms, about **9.8% in this read microbenchmark**. Earlier wall-time-only rounds were variable and did not show a consistent improvement; the P95 values above also do not establish a latency improvement. This is not a measurement of application idle CPU, GPU temperature, fan noise or inference throughput. Metadata caching reduces repeated kernel calls; it does not change the control curve.

## Official contribution

The original slow-handoff repair was submitted independently as [ProducerGuy/ThermalForge PR #54](https://github.com/ProducerGuy/ThermalForge/pull/54), branch `hongyukeji:codex/m4-fan-handoff-transport`, commit `246d1bd`.

Its six implementation/test files match the original repair at `97a8a83`; the upstream application version and README are unchanged. Its review checkout passed a release build and 56 tests. The one pre-existing persistence test was excluded there because it writes real user configuration; the separate isolation fix is included in this fork. The PR contains historical hardware measurements and their limits. Submission is not upstream acceptance or CI success.
