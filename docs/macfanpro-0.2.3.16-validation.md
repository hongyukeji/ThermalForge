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

只在 M4 Max 上实测；M4 核心键表来自 Stats，未在 M4 / M4 Pro 实机核对。其他芯片的 CPU 行逻辑仍为前缀分组，未验证。未测试睡眠唤醒与重新登录。

## 公开发行

- 发行源提交：`45cac23cbd98247fb4f3a0496c0a50e7b16ad7a9`，标签 `v0.2.3.16`。
- [源码 CI](https://github.com/macfanpro/macfanpro/actions/runs/35948514975)、[发行 CI](https://github.com/macfanpro/macfanpro/actions/runs/35948515100)、[Homebrew CI](https://github.com/macfanpro/homebrew-tap/actions/runs/35948847655) 均通过。
- 下载草稿附件，`SHA256SUMS` 校验通过，与 GitHub asset digest 一致：`MacFanPro-0.2.3.16-macos-arm64.tar.gz` 为 `206536a3ed37b3b730fdb7a96269473104bd20b627258e46e46fa20ce5d8800f`。CLI 与应用版本为 0.2.3.16，严格代码签名校验通过。
- 以先退出应用、同步后台、再打开的步骤安装下载产物；已安装的 CLI 与应用二进制与发行包逐字节一致。通过 CLI/daemon 将两只风扇设为 2000 RPM，实测到位后恢复 Apple 自动控制，重新打开应用；当日日志 0 条 ERROR。
- 本机 Homebrew 7.0.6 拒绝加载未受信任 tap 的配方，需先执行 `brew trust macfanpro/tap`；README 与 tap 说明已补充这一步。

