# MacFanPro changelog

## 0.2.3.17

- Write runtime log lines without rescanning the log directory. Each line previously listed the directory twice and cost 0.7–1.1 ms in the background, growing with the number of log files; it now costs about 57 µs regardless of file count. The background service writes up to ~22 lines per second while fans ramp. Size and retention limits are unchanged.
- `sudo macfanpro uninstall --purge-data` also removes the background service's logs in `/var/root/Library/Logs/MacFanPro/`, which were previously left behind. Plain `uninstall` still keeps logs.
- README: how to read the background service log, when runtime logs are pruned, and why unmarked captures from earlier versions are kept.

## 0.2.3.16

- Show the hottest CPU core in the CPU row. On M4 the row also picked up SoC hotspot keys (`TCDX`, `TCMb`) and per-core keys that are not the core temperature (`Tp02`, `Tp06`, `Tp0A`), so under GPU load it read 73–75°C while every CPU core read 60–63°C. It now uses the per-core keys Stats maps for the M4 generation; under GPU load MacFanPro and Stats now agree within 0.5°C. Other chips keep the previous grouping.
- The menu bar reading is now the hotter of the CPU and GPU rows, so it always matches the panel.
- Stop reporting the battery gas-gauge sensors as GPU temperatures. On M4 Max the SMC keys `TG0B`, `TG0H` and `TG0V` are battery sensors; MacFanPro asks the system's thermal sensor services which keys are batteries and leaves them out.
- Drop placeholder readings (below 10°C) from CPU/GPU die keys in `macfanpro status` and recorded logs.
- Fan control and the 95°C safety floor are unchanged: they still follow the hottest point on the chip, including the hotspot keys.

## 0.2.3.15

- Simplify installation by removing the retired product's migration flag and product-selection layer.
- Remove the old Homebrew package-name mapping; maintain MacFanPro's current version ordering.
- Present MacFanPro installation, usage and updates consistently across documentation and release notes.
- Keep upstream attribution and copyright notices.

## 0.2.3.14

- Provide the MacFanPro menu bar app, `macfanpro` CLI and background service for Apple Silicon Macs.
- Publish releases through `macfanpro/macfanpro` and Homebrew packages through `macfanpro/tap`.
- Include English, Simplified Chinese and Traditional Chinese interfaces, with immediate language switching.
- Keep the native menu, automatic panel height, centered minimum-width temperature label and localized Quit footer.
- Document installation, updates and removal, with a screenshot of the installed app in the README.
