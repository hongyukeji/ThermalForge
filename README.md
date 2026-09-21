# MacFanPro

[![CI](https://github.com/macfanpro/macfanpro/actions/workflows/ci.yml/badge.svg)](https://github.com/macfanpro/macfanpro/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/macfanpro/macfanpro?sort=date)](https://github.com/macfanpro/macfanpro/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

面向 Apple Silicon Mac 的免费开源风扇控制工具，提供菜单栏应用、命令行和独立后台服务。

MacFanPro是基于 [ThermalForge](https://github.com/ProducerGuy/ThermalForge) 的独立衍生发行，由 hongyukeji 维护，使用自己的版本、安装名称和更新渠道。上游版权与 MIT 许可完整保留，详见 [来源说明](NOTICE.md)。

## 版本规则

版本号采用 **官方版本号 + 第四段修订号**。当前 `0.2.3.15` 基于官方 `0.2.3`，后续修订为 `0.2.3.16`、`0.2.3.17`。只有实际合入新的官方版本后，才更新前三段，例如基于官方 `0.2.4` 的首个修订为 `0.2.4.1`。

应用和 CLI 按每段数字从左到右比较版本，例如 `0.2.3.10 > 0.2.3.9`。

## 功能

- 根据 CPU/GPU 温度自动控制风扇，保留上游 Smart 与内置温控模式。
- 保留已在 M4 Max 上验证的慢速风扇接管、后台通信及自动控制恢复修复。
- 英语、简体中文、繁体中文界面；支持跟随系统和立即切换，繁体由简体按字形转换。
- 原生菜单栏界面，统一分区和控件间距。
- 独立的 `macfanpro` 命令、应用标识、后台服务、日志和配置目录。

需要 macOS 14 或更高版本。源码构建需要 Xcode 16 或更高版本。实机验证以 M4 Max 为主，其他 Apple Silicon 型号需要各自实测。

## 界面预览

本机运行截图（简体中文）：

<img src="docs/images/menu-bar-zh-CN.png" alt="MacFanPro 菜单，退出按钮上方带有分隔线" width="320">

## Homebrew 安装

```bash
brew tap macfanpro/tap
brew install macfanpro
sudo macfanpro install
open /Applications/MacFanPro.app
```

也可以用完整名称首次安装：`brew install macfanpro/tap/macfanpro`。Homebrew 管理下载和构建，`sudo macfanpro install` 将后台程序复制到 root 所有的路径、注册服务并安装菜单栏应用。应用与普通控制命令之后无需 sudo。需要开机启动时，在应用中开启“登录时启动”。

## 更新和卸载

```bash
brew update
brew upgrade macfanpro
macfanpro auto --stop-app
sudo "$(brew --prefix macfanpro)/bin/macfanpro" install
open /Applications/MacFanPro.app
```

同步前先退出菜单栏应用并恢复自动控制，再使用刚升级的 Homebrew 程序更新 root 后台副本和 `/Applications` 中的应用，最后重新打开。应用内更新提示也只跟踪本仓库发行版。

```bash
sudo macfanpro uninstall
brew uninstall macfanpro
```

普通卸载保留用户数据。只有明确需要删除 MacFanPro 的模式、校准和日志时，才使用 `sudo macfanpro uninstall --purge-data`。

## 命令行

```bash
macfanpro status
macfanpro max
macfanpro set 3000
macfanpro auto
macfanpro --help
```

`auto` 恢复 Apple 自动控制；如需同时退出菜单栏应用，使用 `macfanpro auto --stop-app`。应用仍运行时，选择的自动模式可以再次接管风扇。GUI 语言设置不改变命令、协议或数值含义。

## 日志保留

运行日志按天记录在 `~/Library/Logs/MacFanPro/`。每个文件最多 5 MiB，每个日志目录合计最多 50 MiB，最多保留含当天在内的 7 个自然日。应用和 root 后台服务分别使用各自的用户目录，因此两处运行日志合计上限为 100 MiB。启动、写入和运行期间每小时都会清理；磁盘故障时暂停文件日志并稍后重试，日志队列不会无限增长。

`macfanpro log --duration 60s` 将传感器数据采样到默认目录 `~/Library/Application Support/MacFanPro/logs/`。临时采样的 CSV 合计最多 100 MiB，达到上限后停止并保留已有数据。正常结束、Ctrl-C 或 SIGTERM 后保留 24 小时；进程意外结束也会留下可清理标记。清理会跳过仍在写入的采样目录，在应用运行时每小时执行，也会在应用或下一次采样启动时执行。应用未运行时，文件会保留到下次清理。

显式使用 `--output <目录>` 或 `--no-expire` 的采样会永久保留且不受 100 MiB 限制，需要自行管理。旧版未标记过期时间的采样、配置、校准和其他文件不会自动删除。

## 源码与发行包

```bash
git clone https://github.com/macfanpro/macfanpro.git
cd macfanpro
./setup.sh
```

也可在 [Releases](https://github.com/macfanpro/macfanpro/releases/latest) 下载完整应用与 CLI。解压后执行 `sudo ./bin/macfanpro install`，然后打开 `/Applications/MacFanPro.app`。

当前发行包使用 ad-hoc 签名，尚未进行 Apple 公证；Homebrew 安装会在本机从源码构建。[0.2.3.15 验证记录](docs/macfanpro-0.2.3.15-validation.md) 列出了已完成的测试和验证范围。

开发验证：`bash Scripts/test.sh`、`swift build -c release`、`bash Scripts/check-localization-package.sh`。语言资源维护见 [GUI localization](docs/gui-localization.md)。`docs/upstream/` 与早期验收文档保留历史记录，不代表当前发行版或所有机型的测试结论。
