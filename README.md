# ThermalForgePro

[![CI](https://github.com/hongyukeji/ThermalForgePro/actions/workflows/ci.yml/badge.svg)](https://github.com/hongyukeji/ThermalForgePro/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/hongyukeji/ThermalForgePro)](https://github.com/hongyukeji/ThermalForgePro/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

面向 Apple Silicon Mac 的免费开源风扇控制工具，提供菜单栏应用、命令行和独立后台服务。

ThermalForgePro 是基于 [ThermalForge](https://github.com/ProducerGuy/ThermalForge) 的独立衍生发行，由 hongyukeji 维护，使用自己的版本、安装名称和更新渠道。上游版权与 MIT 许可完整保留，详见 [来源说明](NOTICE.md)。

## 功能

- 根据 CPU/GPU 温度自动控制风扇，保留上游 Smart 与内置温控模式。
- 保留已在 M4 Max 上验证的慢速风扇接管、后台通信及自动控制恢复修复。
- 英语、简体中文、繁体中文界面；支持跟随系统和立即切换，繁体由简体按字形转换。
- 原生菜单栏界面，统一分区和控件间距。
- 独立的 `thermalforgepro` 命令、应用标识、后台服务、日志和配置目录。

需要 macOS 14 或更高版本。源码构建需要 Xcode 16 或更高版本。实机验证以 M4 Max 为主，其他 Apple Silicon 型号需要各自实测。

## Homebrew 安装

```bash
brew tap hongyukeji/tap
brew install thermalforgepro
sudo thermalforgepro install
open /Applications/ThermalForgePro.app
```

也可以用完整名称首次安装：`brew install hongyukeji/tap/thermalforgepro`。Homebrew 管理下载和构建，`sudo thermalforgepro install` 将后台程序复制到 root 所有的路径、注册服务并安装菜单栏应用。应用与普通控制命令之后无需 sudo。需要开机启动时，在应用中开启“登录时启动”。

## 从 ThermalForge 迁移

先关闭旧应用的“登录时启动”，然后运行：

```bash
brew tap hongyukeji/tap
brew install thermalforgepro
sudo thermalforgepro install --migrate-thermalforge
brew uninstall thermalforge
open /Applications/ThermalForgePro.app
```

迁移会备份旧应用、CLI 和后台配置，停止旧控制器、恢复 Apple 自动控制，再安装 Pro。语言、温控模式、温度单位、校准、用户模式及研究日志会复制到 Pro；已有 Pro 配置优先，旧数据不会删除。安装过程中失败会尝试恢复旧运行程序，终端会显示备份位置。迁移后在新应用中开启“登录时启动”。

原来的 `thermalforge` 配方与命令不再用于维护 Pro。确认旧配方卸载后，可用 `brew untap producerguy/tap` 移除旧源。

## 更新和卸载

```bash
brew update
brew upgrade thermalforgepro
sudo thermalforgepro install
```

最后一步同步 root 后台副本和 `/Applications` 中的应用。应用内更新提示也只跟踪本仓库发行版。

```bash
sudo thermalforgepro uninstall
brew uninstall thermalforgepro
```

普通卸载保留用户数据。只有明确需要删除 Pro 的模式、校准和日志时，才使用 `sudo thermalforgepro uninstall --purge-data`。

## 命令行

```bash
thermalforgepro status
thermalforgepro max
thermalforgepro set 3000
thermalforgepro auto
thermalforgepro --help
```

`auto` 恢复 Apple 自动控制；如需同时退出菜单栏应用，使用 `thermalforgepro auto --stop-app`。应用仍运行时，选择的自动模式可以再次接管风扇。GUI 语言设置不改变命令、协议或数值含义。

## 源码与发行包

```bash
git clone https://github.com/hongyukeji/ThermalForgePro.git
cd ThermalForgePro
./setup.sh
# 替换旧版时：./setup.sh --migrate-thermalforge
```

也可在 [Releases](https://github.com/hongyukeji/ThermalForgePro/releases/latest) 下载完整应用与 CLI。解压后执行 `sudo ./bin/thermalforgepro install`，迁移旧版时加上 `--migrate-thermalforge`。

开发验证：`swift test`、`swift build -c release`、`bash Scripts/check-localization-package.sh`。语言资源维护见 [GUI localization](docs/gui-localization.md)。`docs/upstream/` 与早期验收文档保留历史记录，不代表当前发行版或所有机型的测试结论。
