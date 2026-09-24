# Thermal sensor calibration — Mac16,5 (M4 Max), 2026-09-24

**Outcome:** the individual SMC readings are correct — key for key they match
Stats to 0.1°C. The CPU row's *selection* of keys was wrong on M4: it included
SoC hotspot keys (`TCDX`, `TCMb`) and per-core keys that are not the core
temperature (`Tp02`, `Tp06`, `Tp0A`), so under GPU load it reported 73–75°C
while every CPU core read 60–63°C. 0.2.3.16 fixes the CPU row selection,
drops the battery keys misgrouped as GPU and filters die placeholders; fan
control and the safety floor are unchanged. See "Comparison with Stats".

This document went through two earlier conclusions that were wrong:
1. An uncontrolled run (oMLX inference on the GPU and Docker's VM running)
   suggested the SMC keys read ~17°C high and anti-correlated with the IOHID
   die sensors. Withdrawn: the machine was genuinely hot, and the comparison
   was between hotspot sensors and PMU die-average sensors.
2. The clean run below then concluded the displayed values had no defect,
   because `TCDX`/`Tg05` tracked load consistently. That missed that `TCDX`
   and `Tp06` are not CPU core temperatures — only a per-key comparison with a
   curated sensor map (Stats) showed it.

## Method

- macOS 26A428, MacFanPro 0.2.3.15. The MacFanPro app was quit so the fans
  stayed under Apple's own control (`mode=system`, 0 RPM at idle) — the baseline
  a fan curve has to sit above.
- oMLX and Docker (including its Virtualization VM) were stopped. Still running:
  Thunder (active download, 10–30% CPU), browser and editor processes;
  load average 2.2–3.1 during the baseline.
- Reference: the IOHIDEventSystem temperature services (page `0xff00`,
  usage 5), read unprivileged. Each physical sensor is published twice; the
  duplicates share a `LocationID`, which decodes to a four-character sensor key
  (`PMU tdie3` → `TP3b`, `NAND CH0 temp` → `TN0n`). `RegistryID` differs between
  duplicates, so it is not an identity. 26 unique sensors remain.
- Each load run records its own pre-load baseline and compares the settled tail
  against it, so incomplete cooldown between runs does not skew deltas.
- Scripts: `Scripts/thermal-calibration/` (`hid-sample.swift`, `gpu-load.swift`,
  `log.sh`).

## Idle baseline (fans off under Apple control, 15 samples)

| Sensor | Mean °C | σ |
|---|---|---|
| `PMU tdie1`–`tdie10` (`TP1b`…`TPab`) | 39.5–40.1 | 0.3–0.5 |
| tdie peak | 40.49 | 0.24 |
| `PMU tdev1/2/6/7` | 34.6–36.1 | ≤ 0.3 |
| `PMU tdev3/4/5/8` | 28.9–33.9 | ≤ 0.1 |
| `PMU tcal` (`TP0Z`) | 51.85 | 0 — constant in every run; a calibration reference, not a temperature |
| `NAND CH0 temp` | 28.1 | 0.3 |
| `gas gauge battery` ×6 | 26.0–27.2 | ≤ 0.04 |

## Domain response (Δ from each run's own pre-load baseline)

| Sensor | CPU (12× `yes`) | GPU (Metal FMA) | Memory copy | Disk I/O |
|---|---|---|---|---|
| tdie1–10 | +5.8 … +6.8 | +11.4 … +12.7 | falling¹ | ~0 |
| tdev7 | +11.1 | +21.7 | ~0 | — |
| tdev2 / tdev6 | +5.5 / +6.4 | +10.8 / +11.5 | falling¹ | — |
| tdev3 | +0.2 | +1.6 | −0.3 | **+4.4** |
| NAND CH0 | −0.1 | +1.2 | 0 | **+12.6** |
| battery | +0.1 | +0.2 … +1.0 | +0.4 … +1.0 | +0.3 … +0.8 |

¹ Still shedding heat from the preceding GPU run; memory load added none measurably.

The ten `tdie` sensors cannot be split into CPU and GPU groups: every one has a
GPU/CPU response ratio between 1.84 and 2.02. They behave as die-wide sensors.
No sensor responded specifically to memory bandwidth.

## SMC keys versus the IOHID sensors (means per state)

| State | tdie peak | `TCDX` | `TCMb` | `Tp*` max | `Tg05` | `TG0V` | `TH0x` | `TAOL` |
|---|---|---|---|---|---|---|---|---|
| Idle | 40.5 | 38.5 | 45.3 | 37.5 | 41.3 | 27.2 | 27.9 | 25.3 |
| CPU load | 47.1 | 60.9 | 67.2 | 69.9 | 56.3 | 27.3 | 27.9 | 25.4 |
| GPU load | 59.3 | 88.0 | 92.1 | 47.4 | 90.0 | 27.7 | 30.1 | 25.6 |
| Disk load | 48.5 | 46.6 | 53.4 | 40.0 | 49.2 | 29.4 | 40.9 | 26.8 |

- `TCDX`, `TCMb` and `Tg05` track the die sensors in the same direction, agree
  with them at idle, and rise far faster under load — the shape of hotspot
  sensors. `Tg05` separates the workloads (56.3 under CPU load, 90.0 under GPU
  load); no IOHID sensor does. Replacing these keys with the `tdie` peak would
  read ~30°C cooler than the hotspot under GPU load and would move the fan curve
  and the 95°C safety floor onto a cooler measurement. That was rejected.
- `TH0x` rises 13°C under disk I/O alongside `NAND CH0`: a genuine SSD sensor.
- `TAOL` stays within 25.3–26.8 across all loads: a plausible ambient sensor.
- Apple's own control first spun the fans (to ~1350 RPM) during the GPU run when
  tdie reached ~58°C and `TCDX`/`Tg05` ~85–88°C.

## Classification issues

1. **`TG0B`, `TG0H`, `TG0V` are battery sensors here.** Their IOHID
   `LocationID`s decode to exactly these keys, published as `gas gauge battery`,
   and simultaneous readings match to the tenth of a degree. Upstream groups
   them as GPU (the `thermalKeys` comment records them as M5 Max GPU keys). The
   GPU row takes a maximum, so `Tg05` always wins: 0 of 104 samples differed.
   On a Mac whose `Tg*` keys are absent, the GPU row would show battery
   temperature. The SMC type cannot tell them apart (both generations report
   `ioft`, 8 bytes), so 0.2.3.16 asks IOHID which keys are batteries and drops
   those; where the keys are GPU sensors nothing changes.
2. **`Tp*` keys pass through intermittent placeholder values** (40.0 when a
   core is gated, plus 1.5 and 1.9; earlier dumps also showed −4.0, 0.0 and
   5.2). Values below 10°C are now dropped for die keys; 40.0 is kept because
   it is indistinguishable from a real reading.
3. **Not every `Tp*` key is a core temperature.** An earlier draft of this
   section called `Tp06`/`Tp0A` "a real hot core" because they led the CPU row
   under CPU load. The Stats comparison below shows they are not the core key
   of their group. Fixed in the CPU row.

## Why the fans ran at maximum

With inference running, the hotspot keys genuinely sat at 85–95°C — above the
Smart profile's 85°C ceiling, so the profile drove the fans to maximum as
designed. Whether that ceiling is more aggressive than wanted is a tuning
choice, separate from sensor accuracy, and was left at the upstream value.

## Comparison with Stats (exelban/stats 3.0.17)

Stats maps sensors per chip generation (`Modules/Sensors/values.swift`). For
the M4 generation: efficiency cores `Te05` `Te0S` `Te09` `Te0H`, performance
cores `Tp01` `Tp05` `Tp09` `Tp0D` `Tp0V` `Tp0Y` `Tp0b` `Tp0e`, GPU `Tg0G`
`Tg0H` `Tg0K` `Tg0L` `Tg0d` `Tg0e` `Tg0j` `Tg0k`.

**Per-key readings agree.** Read at the same moment, every shared key matched
to 0.1°C: NAND/`TH0x` 31.8, Battery 1/`TB0T` 30.5, GPU/`Tg0L` 42.6,
`Tg0j` 42.9, performance cores 40.0 (the gated-core placeholder, shown by
both tools).

**The CPU row's key selection did not.** The `Tp*` keys come in groups of
four per core; Stats uses one key per group. Another key in the group
(`Tp02`, `Tp06`, `Tp0A`) reads 0.0 while the core is gated and runs 10–13°C
above the core temperature under load. Upstream's list includes those keys and
the SoC hotspot keys under the CPU prefixes:

| Load (0.2.3.15) | MacFanPro CPU row | Stats hottest CPU | Source of MacFanPro value |
|---|---|---|---|
| CPU | 69.7 | 63.7 | `Tp06` |
| GPU | 73.3 | 62.9 | `TCDX` |
| GPU (repeat) | 75.2 | 62.3 | `Tp06` |

Under a GPU-only load that made a CPU key hotter than any GPU sensor (69.0).

**After the fix (0.2.3.16), read from both panels** (Stats captured ~7 s after
MacFanPro, so load drift of up to ~1°C is expected):

| State | MacFanPro CPU | Stats hottest CPU | MacFanPro GPU | Stats hottest GPU |
|---|---|---|---|---|
| Idle | 49.4 | 49.4 | 48.5 | 48.5 |
| CPU load | 64.5 | 64.2 | 54.5 | 55.5 |
| GPU load | 62.7 | 63.2 | 69.9 | 70.2 |

The CPU row now takes the Stats core keys on the M4 generation (prefix
grouping elsewhere). The menu bar headline is the hotter of the two rows.
`status()` and `safetyPeakTemp` still include every key, so the fan curve and
the safety floor keep following the hottest point on the die.

