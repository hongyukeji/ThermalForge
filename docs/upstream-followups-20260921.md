# Upstream follow-ups: 2026-09-21

Fork source build **0.2.3.4**, based on the installed, hardware-tested **0.2.3.2** repair (`97a8a83`). This maintenance build has not replaced the installed app or daemon. It is not an official upstream release.

## Changes and provenance

| Upstream reference | Adopted scope |
| --- | --- |
| [PR #30](https://github.com/ProducerGuy/ThermalForge/pull/30) | Required automatic-mode/Ftst write failures throw after attempting every fan. Advisory target resets stay best-effort. Three injected-write tests cover partial failures and non-Ftst hardware. |
| [PR #47](https://github.com/ProducerGuy/ThermalForge/pull/47) | Profile persistence accepts an optional directory. Tests use a UUID scratch directory instead of Application Support. The menu/CLI do not gain custom profiles. |
| [PR #44](https://github.com/ProducerGuy/ThermalForge/pull/44) | Explicit profile buttons replace Picker writes; selecting the active profile preserves its ramp, while Silent uses the acknowledged Default reset. The proposed 85°C danger-zone rule is excluded. |
| [PR #48](https://github.com/ProducerGuy/ThermalForge/pull/48) | Wake execution re-reads the live hold after the delay under the SMC lock, preserving app/CLI holds and safety suspension. Smart releases below its existing 50°C stop point despite stale positive rate history, and approaches hardware minimum in its existing 50–53°C band instead of using an out-of-band calibration sample. |
| [PR #11](https://github.com/ProducerGuy/ThermalForge/pull/11) | Cache successful SMC key sizes per connection under a lock. Values remain fresh; missing, failed or rejected metadata is not cached. No sampling-rate or sensor-family changes. |
| [PR #51](https://github.com/ProducerGuy/ThermalForge/pull/51), [PR #50](https://github.com/ProducerGuy/ThermalForge/pull/50) | Retained NSStatusItem/NSPopover, fixed three-column temperature image, stable accessibility identifier and changing accessibility value. Preserve the profile panel, temperature units, state icons and daemon mismatch badge. Offscreen inspection corrected glyph spacing and preserved the warning symbol's cutout. |

The wake implementation intentionally differs from #48: it does not simply stop restoring supervised app holds, which could miss a steady hot target after wake. It also does not force-reset every observed manual fan: hardware mode alone does not identify the writer, and clearing it can destroy a fresh CLI hold before the app's next ownership poll. Seven simulated recovery tests cover the actual monitor tick and the delayed execution policy; they do not suspend the real machine.

## Preserved behavior

The built-in profile definitions, CPU/GPU sensor list, 100ms thermal cadence, 95°C threshold and daemon thermal-floor invariants retain their official values. The prior 30-second hardware-command timeout, shared 20-second acquisition budget, two-second liveness queries, separate frame I/O deadlines and SIGPIPE handling remain in place.

No custom 70/80°C full-speed target, power-mode switching, inference restriction, custom-profile editor or timed profile revert was added. oMLX, OpenCode, model settings, installed preferences, login items and launchd configuration were not changed.

## Local validation

- `swift test --jobs 2`: **74 tests in 13 suites passed**. Tests use fake fan/SMC writes or isolated sockets, directories and offscreen rendering; they do not launch the application or claim real fan ownership.
- The test suite includes the original eight slow-handoff/transport tests, three release tests, seven recovery tests, five cache tests and two status-image tests.
- `swift build -c release --jobs 2`: passed; CLI and assembled application report **0.2.3.4**.
- Status images rendered with two- and three-digit Celsius/Fahrenheit-sized values, all three state symbols and the mismatch badge. This is offscreen rendering/build verification, not interactive menu-manager compatibility acceptance.
- Built-in curve definitions and daemon threshold invariants were compared against official v0.2.3. The existing profile tests verify their exact parameters.

Real sleep/wake, prolonged loaded inference and interactive menu-bar-manager compatibility remain untested for 0.2.3.4. The earlier two cold handoff runs belong to 0.2.3.2 and are not reused as acceptance of this build. No installation, stress workload or sleep cycle was performed for this maintenance work.

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
