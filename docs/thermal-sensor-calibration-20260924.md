# Thermal sensor calibration — Mac16,5 (M4 Max), 2026-09-24

**Outcome:** on a clean baseline, the upstream SMC temperature keys behind the
CPU / GPU / SSD / Ambient rows behave consistently and plausibly. No display
accuracy defect was demonstrated, so the sensor pipeline stays identical to
upstream. Two latent classification issues are recorded below; neither changes
a displayed value on this machine.

An earlier, uncontrolled comparison had suggested the SMC keys read ~17°C high
and anti-correlated with the IOHID die sensors. That run was taken while an
oMLX local model (MLX inference on the GPU) and Docker's Linux VM were running.
It is withdrawn. This document replaces it.

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

## Latent issues (no displayed value changed on this machine)

1. **`TG0B`, `TG0H`, `TG0V` are battery sensors here.** Their IOHID
   `LocationID`s decode to exactly these keys, published as `gas gauge battery`,
   and simultaneous readings match to the tenth of a degree. Upstream groups
   them as GPU (the `thermalKeys` comment records them as M5 Max GPU keys). The
   GPU row takes a maximum, so `Tg05` always wins: 0 of 104 samples differed.
   On a Mac whose `Tg*` keys are absent, the GPU row would show battery
   temperature. Excluding them needs a per-model distinction the SMC type does
   not provide (both generations report `ioft`, 8 bytes), so nothing was changed.
2. **`Tp*` keys pass through intermittent placeholder values** (40.0 was the
   most frequent single value across all samples, plus 1.5 and 1.9; earlier
   dumps also showed −4.0, 0.0 and 5.2). All 19 keys also report live values,
   and under the CPU row's maximum the live values win: `Tp*` raised the CPU row
   in 27 of 104 samples by up to 11.4°C, always a real hot core (`Tp06`,
   `Tp0A`) under CPU load, never a placeholder. A Mac exposing only `Tp*` could
   show a placeholder.

## Why the fans ran at maximum

With inference running, the GPU hotspot genuinely sat at 85–95°C — above the
Smart profile's 85°C ceiling, so the profile drove the fans to maximum as
designed. Whether that ceiling is more aggressive than wanted is a tuning
choice, separate from sensor accuracy, and was left at the upstream value.
