# MacFanPro 0.2.3.15 验证记录

## 修改范围

- 移除旧产品的安装迁移参数、产品识别和选择分支及其测试，保留既有上游迁移实现。
- 移除 Homebrew 旧包名映射和安装提示中的旧产品介绍。保留当前 MacFanPro 配方的 `version_scheme 1`，确保已安装用户的版本顺序连续。
- README、最新变更记录、来源说明和发行说明统一按 MacFanPro 展示；清理旧版专属文档，保留版权持有人及上游许可。
- 本仓库 Releases 与 Tags 只保留实际以 MacFanPro 构建的版本。删除 4 个旧品牌发行页及附件、19 个非 MacFanPro 标签；Git 提交和上游 PR 保留。
- 温度采集、风扇控制、原生菜单、布局、刷新及日志保留逻辑未改变。

## 本机候选版

环境：M4 Max MacBook Pro，macOS 27.0，外接 LG 显示器 1920×1080 逻辑分辨率、2× 缩放。

- Debug、Release 各 102 项测试通过；各配置 108 次断开连接检查通过。
- 包装资源及缺失语言资源时的拒绝保护通过。发行包校验和与应用严格签名校验通过。
- 移除的参数在解析时返回 unknown option，不会开始安装。当前安装的 CLI、应用二进制均不包含旧产品名称。
- 从 MacFanPro 0.2.3.14 更新至 0.2.3.15，应用、CLI、daemon 版本和安装源文件哈希一致。
- 三种语言分别验证摄氏、华氏和关闭重开，原生窗口均为 260×456 pt，上下内容边距各 10 pt，底部控件间距 6/6/13 pt。
- 菜单打开时观察 20 次真实温度刷新，窗口尺寸和位置稳定。语言跟随系统、摄氏单位、Smart 模式与登录启动设置保留。
- 更新切换后台服务时，旧应用在 21:08:16 UTC 记录 6 条连接中断 ERROR；新应用于 21:08:18 UTC 启动后未发现新增 ERROR 或崩溃报告。后续安装先通过 `macfanpro auto --stop-app` 退出应用，再同步后台和重新打开，分别检查安装过程与运行日志。
- README 图片来自本机实际运行的 0.2.3.15 窗口。

## 验证边界

移除兼容入口没有改变温控算法。本次未对其他机型、全部 macOS 版本、睡眠唤醒或重新登录进行实机验证，也未故意制造安装失败。原生菜单与图像边界的隔离测试不等同于其他显示器的实机验证。

## 公开发行与最终本机安装

- 发行源提交：`19dc8b2c561dc052a69b5e117230e605eb7496ca`，标签 `v0.2.3.15`。
- [源码 CI](https://github.com/macfanpro/macfanpro/actions/runs/35655592029)、[发行 CI](https://github.com/macfanpro/macfanpro/actions/runs/35655594811)、[Homebrew CI](https://github.com/macfanpro/homebrew-tap/actions/runs/35656195251) 均通过。
- 下载 GitHub 发行产物，核对 SHA-256、GitHub asset digest、版本与严格代码签名，在本机安装验证。
- [正式发行](https://github.com/macfanpro/macfanpro/releases/tag/v0.2.3.15) 的公开下载与实测 draft 字节一致。`MacFanPro-0.2.3.15-macos-arm64.tar.gz` 的 SHA-256 为 `040e9437bae1e04a4348dedafacb92215f0c8354500050a3e6509bed86d3aa04`。
- Homebrew 从 0.2.3.14 正常升级到 0.2.3.15，严格 audit 和 `brew test` 通过；应用、CLI、daemon 与 Homebrew 安装源哈希一致，版本均为 0.2.3.15。
- 下载产物及 Homebrew 最终安装均采用先退出应用、同步后台、再打开的步骤。两次完整安装与运行检查均没有新增 ERROR 或崩溃报告。
- 下载产物及 Homebrew 安装各完成三语言、两种单位、关闭重开和 20 次真实温度刷新检查，菜单高度、位置、间距及配置保持正常。
- 最终安装实际点击“退出”，确认释放控制；通过 CLI/daemon 短暂设置两只风扇为 2000 RPM，实测进入目标容差范围，再恢复 Apple 自动控制并重新打开应用。
- 当前跟踪文件、安装后的 CLI 与应用二进制均无旧产品名；已移除的安装参数返回 unknown option。Homebrew 旧名映射不存在。
- Releases 和 Tags 经再次查询，均仅保留 MacFanPro `v0.2.3.14` 和 `v0.2.3.15`。
