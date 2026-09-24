# Drafts — not submitted

Target: ProducerGuy/ThermalForge issues. Submit only after the maintainer of
this fork has reviewed them. Measurements: `docs/thermal-sensor-calibration-20260924.md`.

---

## 1. CPU temperature on M4 includes hotspot and non-core keys

**Hardware:** MacBook Pro Mac16,5 (M4 Max), macOS 26A428

The menu's CPU row is the maximum of every `TC*`/`Tp*` key. On M4 that set
includes keys that are not CPU core temperatures:

- `TCDX` and `TCMb` behave as SoC-level hotspot keys. Under a Metal-only GPU
  load `TCDX` read 73.3°C while every CPU core read 60–63°C and the hottest GPU
  sensor 69°C.
- The `Tp*` keys come in groups of four per core. Stats maps one key per group
  as the core temperature (`Tp01`, `Tp05`, `Tp09`, `Tp0D`, `Tp0V`, `Tp0Y`,
  `Tp0b`, `Tp0e`). Others in the list (`Tp02`, `Tp06`, `Tp0A`) read 0.0 while
  the core is gated and 10–13°C above the core under load; `Tp06` read 75.2°C
  during that GPU load.
- The M4 efficiency-core keys (`Te05`, `Te0S`, `Te09`, `Te0H`) are not probed.

Side by side with Stats 3.0.17 (same moment):

| Load | CPU row | Stats hottest CPU |
|---|---|---|
| CPU | 69.7 (`Tp06`) | 63.7 |
| GPU | 73.3 (`TCDX`) | 62.9 |

Every individual key matches Stats to 0.1°C; only the selection differs.

**Suggested change:** show the per-core keys in the CPU row (a per-generation
table, as Stats keeps), and leave the hotspot keys in `safetyPeakTemp` so fan
control still follows the hottest point. The MacFanPro fork does this in
`ThermalStatus+Display.swift`; after it, the CPU row and Stats agree within
0.5°C under CPU and GPU load.

---

## 2. On M4 Max, `TG0B`/`TG0H`/`TG0V` are battery sensors, not GPU

`thermalKeys` lists these as GPU keys (ioft, verified on M5 Max). On M4 Max the
IOHIDEventSystem temperature services (page `0xff00`, usage 5) publish a
`LocationID` that decodes to a four-character key; the six `gas gauge battery`
services decode to `TG0B`, `TG0C`, `TG0H`, `TG0V`, `TG1B` and `TG2B`. SMC
`TG0V` and the HID battery service read the same value at the same instant.
Under GPU load the GPU sensors rose ~12°C while these rose 0.2°C.

**Impact:** none on M4 Max today — the GPU row takes the maximum and a `Tg*`
key always wins. On a model without `Tg*` keys the GPU row, and the safety
floor, would read battery temperature. SMC metadata cannot tell the two apart
(both `ioft`, 8 bytes); the fork asks IOHID which keys are batteries
(`SMCSensorFilter.swift`).
