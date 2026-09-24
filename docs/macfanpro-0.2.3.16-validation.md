# MacFanPro 0.2.3.16 验证记录

## 修改范围

- CPU 行只取核心温度键：M4 系列使用 Stats 的核心键映射（E 核 `Te05`/`Te0S`/`Te09`/`Te0H`，P 核 `Tp01`/`Tp05`/`Tp09`/`Tp0D`/`Tp0V`/`Tp0Y`/`Tp0b`/`Tp0e`），其他芯片保持前缀分组；不再把 SoC 热点键（`TCDX`、`TCMb`）和非核心键（`Tp02`、`Tp06`、`Tp0A`）算作 CPU。
- 菜单栏温度改为 CPU、GPU 两行中的较高值，与面板一致。
- 通过 IOHID 识别电池传感器，剔除被上游归为 GPU 的 `TG0B`/`TG0H`/`TG0V`；过滤 CPU/GPU 键低于 10°C 的占位值。
- 风扇曲线、95°C 安全阈值、daemon 安全采样和界面布局未改变。上游文件改动见 [upstream-divergence.md](upstream-divergence.md)。

## 本机候选版

环境：M4 Max MacBook Pro（Mac16,5），macOS 27.0（26A428），源码构建安装。

- Debug、Release 各 114 项测试通过；断连检查 108 次通过。应用严格签名校验通过。
- 以 `macfanpro auto --stop-app` → `sudo macfanpro install` → 打开应用的顺序安装；CLI、daemon、应用版本均为 0.2.3.16，今日日志 0 条 ERROR，菜单栏无后台版本不一致标记。
- 面板仍为 CPU / GPU / RAM / SSD / 环境 五行，布局与 0.2.3.15 相同。
- 与 Stats 3.0.17 对照（两个面板依次截图，间隔约 7 秒）：

| 状态 | MacFanPro CPU | Stats 最热 CPU | MacFanPro GPU | Stats 最热 GPU |
|---|---|---|---|---|
| 空载 | 49.4 | 49.4 | 48.5 | 48.5 |
| CPU 满载 | 64.5 | 64.2 | 54.5 | 55.5 |
| GPU 满载 | 62.7 | 63.2 | 69.9 | 70.2 |

  修复前（0.2.3.15）GPU 满载时 CPU 行为 73.3–75.2，Stats 最热 CPU 为 62.3–62.9。
- 逐键对照：同一时刻 NAND/`TH0x`、电池/`TB0T`、`Tg0L`、`Tg0j` 与 Stats 一致到 0.1°C。
- `macfanpro status` 不再包含 `TG0B`/`TG0H`/`TG0V`；CPU/GPU 读数与修复前相同。

测量方法与完整数据：[thermal-sensor-calibration-20260924.md](thermal-sensor-calibration-20260924.md)。

## 验证边界

未公开发行，未经过 CI、Homebrew 与下载产物验证。只在 M4 Max 上实测；M4 核心键表来自 Stats，未在 M4 / M4 Pro 实机核对。其他芯片的 CPU 行逻辑仍为前缀分组，未验证。未测试睡眠唤醒与重新登录。Homebrew 安装的 `macfanpro`（`/opt/homebrew/bin`）仍为 0.2.3.15，本机 CLI 以 `/usr/local/bin/macfanpro` 为准。
