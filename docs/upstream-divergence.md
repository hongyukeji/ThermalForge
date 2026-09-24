# Temperature changes relative to upstream

What MacFanPro changes in upstream ThermalForge's temperature code, and how to
re-apply it after merging an upstream release. Scope: the 0.2.3.16 sensor
fixes only. The product rename and earlier fork changes are recorded in
`docs/upstream-followups-20260921.md` and the changelog.

The logic lives in new files so merges touch as few upstream lines as possible:

| New file | Purpose |
|---|---|
| `Sources/MacFanProCore/SMCSensorFilter.swift` | Drops SMC keys that IOHID identifies as battery sensors, and die readings below 10°C |
| `Sources/MacFanProCore/ThermalStatus+Display.swift` | CPU row = per-core keys (Stats' M4 map on the M4 generation); headline = hotter of CPU and GPU rows |
| `Tests/MacFanProTests/SMCSensorFilterTests.swift`, `DisplayedTemperatureTests.swift` | Coverage for both |

## Upstream lines changed

| File | Change | Why |
|---|---|---|
| `Sources/MacFanProCore/FanControl.swift`, `readTemp` | +1 line: `guard SMCSensorFilter.accepts(key, temp) else { return nil }` after the 0–150°C range check | Single choke point shared by `status()` and the daemon's safety sweep |
| `Sources/MacFanProCore/FanControl.swift`, `thermalKeys` | +2 lines after the `Tp*` block: comment and `"Tp0V", "Tp0Y", "Tp0e", "Te05", "Te0S", "Te09", "Te0H"` | M4 core keys upstream does not probe |
| `Sources/MacFanProApp/MenuBarView.swift`, CPU `TemperatureRow` | `peakTemp(prefixes: ["TC", "Tp"])` → `appState.latestStatus?.displayedCPUTemp` | CPU row uses core keys, not hotspot keys |
| `Sources/MacFanProApp/AppState.swift`, `startMonitoring` `onUpdate` | The `displayPrefixes` filter → `self?.maxTemp = status.displayedPeakTemp` | Headline matches the panel |

Deliberately **not** changed: `ThermalStatus.safetyPeakTemp`,
`FanControl.safetyTempKeys`, the daemon's safety sweep, `ThermalMonitor`, the
profile curves and the 95°C threshold. Fan control keeps following the hottest
key, including `TCDX`/`TCMb`/`Tp06`.

## Re-applying after an upstream merge

1. Resolve conflicts in the four places above by keeping upstream's code and
   re-applying the listed one-line changes.
2. If upstream edits `thermalKeys`, keep the M4 key line; drop any key upstream
   now lists itself.
3. If upstream changes how the CPU row or headline is computed, compare with
   `ThermalStatus+Display.swift` and keep whichever matches the Stats key map;
   `DisplayedTemperatureTests` encodes the measured M4 Max case.
4. Run `Scripts/test.sh` and `Scripts/test.sh -c release`, then compare the CPU
   and GPU rows with Stats under CPU and GPU load
   (`Scripts/thermal-calibration/`).
