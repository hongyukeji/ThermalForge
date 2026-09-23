# Draft — not submitted

Target: ProducerGuy/ThermalForge issues. Submit only after the maintainer of
this fork has reviewed it.

---

**Title:** On M4 Max, `TG0B`/`TG0H`/`TG0V` are battery sensors, not GPU

**Hardware:** MacBook Pro Mac16,5 (M4 Max), macOS 26A428

`FanControl.thermalKeys` lists `TG0B`, `TG0H` and `TG0V` as GPU keys (ioft,
verified on M5 Max), and the menu's GPU row groups them by the `TG` prefix. On
M4 Max these three keys are the battery gas-gauge sensors:

- The IOHIDEventSystem temperature services (page `0xff00`, usage 5) publish a
  `LocationID` that decodes to a four-character sensor key. The six services
  named `gas gauge battery` decode to `TG0B`, `TG0C`, `TG0H`, `TG0V`, `TG1B` and
  `TG2B`.
- Read at the same instant, SMC `TG0V` and the HID `TG0V` battery service agree
  to 0.1°C (27.1 / 27.1, 27.2 / 27.2).
- Under a sustained Metal GPU load the GPU die sensors rose ~12°C while these
  keys rose 0.2°C; under disk I/O they moved with the battery, not the GPU.

**Impact today:** none on this machine. The GPU row takes the maximum and `Tg05`
is always hotter (0 of 104 samples differed). On a model without `Tg*` keys the
GPU row would show battery temperature, and the safety floor would read it as
GPU.

**Possible fix:** SMC metadata cannot tell the two apart (both are `ioft`, 8
bytes). Options are gating these keys by model, or excluding any SMC key whose
HID `LocationID` is published under a battery product name.

Measurement method and data: `docs/thermal-sensor-calibration-20260924.md` in
the MacFanPro fork, with the scripts in `Scripts/thermal-calibration/`.
