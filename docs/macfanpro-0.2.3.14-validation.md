# MacFanPro 0.2.3.14 验证记录

## 修改范围

- ThermalForgePro 更名为 MacFanPro；CLI、模块、资源、应用、服务、IPC、日志与配置使用新标识。
- 项目转移到 `macfanpro/macfanpro`，Homebrew 源转移到 `macfanpro/homebrew-tap`。历史提交、发行记录和上游 PR #54–#60 保留。
- 增加 `install --migrate-thermalforgepro`，沿用备份、停止旧运行程序、复制用户配置及失败回滚机制；保留官方 ThermalForge 的迁移入口。
- 保留原生 MenuBarExtra、自动高度、温度标签最小宽度与居中、三种语言及“退出”分隔线。
- 核心风扇、SMC、传感器、日志等 17 个既有文件逐一规范化名称后比对，确认没有额外行为改动。

## 本机候选版验证

环境：M4 Max MacBook Pro，macOS 27.0；外接 LG 显示器 1920×1080 逻辑分辨率、2× 缩放。此记录不代表全部 macOS 版本或 Apple Silicon 设备。

- Debug、Release 各 103 项测试（17 个测试套件）通过；各配置的 108 次断开连接子进程检查通过。
- 包装资源与缺少语言资源时的拒绝安装检查通过；发行包 SHA-256 与 app 严格签名校验通过。
- 从实际安装的 ThermalForgePro 0.2.3.13 迁移成功。旧应用和服务停止，新应用、CLI 与 daemon 均报告 0.2.3.14。
- 语言跟随系统、摄氏单位、Smart 模式保留；用户模式与采样日志逐文件比对一致。停用旧登录启动项，再启用新应用登录启动项。
- 英文、简体、繁体分别验证摄氏、华氏与关闭重开。原生面板均为 260×456 pt，上下内容边距各 10 pt，底部控件间距 6/6/13 pt。
- 菜单打开时完成 20 次真实温度刷新观察，面板位置与尺寸稳定；菜单栏两位数与华氏三位数显示通过。
- README 图片来自 `/Applications/MacFanPro.app` 的真实窗口，显示新名称、完整底部及“退出”。

## 验证边界

新迁移选择逻辑覆盖了匹配与错误参数、无旧安装及两个旧控制器同时存在的拒绝分支。没有在真实硬件上故意制造安装失败验证回滚，也没有额外验证睡眠唤醒、其他 macOS 版本与机型。此次未改变温控或菜单行为；这些测试不构成零缺陷保证。

## 公开发行与最终安装

- 发行源提交：`b3bdd62f6994b83238da5d7f2bc088bd8ae540bf`，标签 `v0.2.3.14`。
- [源码 CI](https://github.com/macfanpro/macfanpro/actions/runs/35652903650)、[发行 CI](https://github.com/macfanpro/macfanpro/actions/runs/35652907771)、[Homebrew CI](https://github.com/macfanpro/homebrew-tap/actions/runs/35653198112) 均通过。
- 从 GitHub 下载 draft 产物，核对 `SHA256SUMS` 与 GitHub asset digest，严格验证签名并在本机安装。发行包 CLI/app/daemon 版本一致，三语言、两种单位、关闭重开与连续刷新检查全部通过。
- [正式发行](https://github.com/macfanpro/macfanpro/releases/tag/v0.2.3.14) 的未认证公开下载与实测 draft 字节一致。文件 `MacFanPro-0.2.3.14-macos-arm64.tar.gz` 的 SHA-256：`11054f43b6f33555f0c26a0ca0effa62f562895fed0b8e92090d7b15d663bafa`。
- 本机最终通过 `macfanpro/tap/macfanpro` 源码安装并同步 `/Applications/MacFanPro.app` 和 root daemon。Homebrew 严格 audit 与 `brew test` 通过。最终安装三语言、单位、自动高度、辅助功能、连续刷新等检查再次通过。
- 实际点击“退出”，确认应用退出并释放控制；通过新 CLI/daemon 短暂设置两只风扇为 2000 RPM，读回实际转速达到目标容差内，然后恢复 Apple 自动控制并重新打开应用。Smart 模式、语言、单位和登录启动设置保留。
- 候选、下载产物及 Homebrew 三个验证时段均未发现新增 ERROR 日志或崩溃报告。
- 卸载旧 Homebrew 包与 tap，确认旧 app、CLI、daemon、socket、登录启动注册均不存在；清除 140 个旧数据、缓存、日志、偏好、迁移备份及测试临时路径。历史 Git 提交、版本验收文档与版权记录保留。
- README 最终图片从 Homebrew 安装后的真实运行窗口重新截取。源码目录已移动到 `/Users/Home/Codes/Swift/MacFanPro`，所有关联上游工作树连接已修复。

Homebrew 全量 `brew list --versions` 在枚举本机其他 cask 元数据时出现内部异常；限定本项目的 formula 安装、列举、测试与严格 audit 均通过。本次未修改其他 cask 或全局 Homebrew 实现。
