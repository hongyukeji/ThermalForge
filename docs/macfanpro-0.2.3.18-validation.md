# MacFanPro 0.2.3.18 验证记录

## 修改范围

- 菜单：语言选择移出上游页脚，与新增的“版本”一行组成独立区块，上下各一条分隔线，位于“退出”正上方；版本号来自 `MacFanProVersion.current`。“°F / °C”与“登录时启动”保持上游位置。
- 文案：英文与简体中文新增 “Version / 版本”；繁体由 `Scripts/update-traditional.swift` 生成，同时把 3 条既有 MacFanPro 文案恢复为排序后的位置（译文不变）。
- 温控算法、传感器读取、日志与风扇控制未改变。

## 本机候选版

环境：M4 Max MacBook Pro（Mac16,5），macOS 27.0。

- 用真实菜单代码离屏渲染英文、简体中文、繁体中文面板，包括正常、CLI 保持与更新提示、版本不一致与安全覆盖、后台无响应四种场景；新区块位置与分隔线正确，面板宽度 260 pt，高度随内容自适应。
- Debug、Release 各 116 项测试通过；各配置 108 次断连检查通过；语言资源打包检查通过。

## 公开发行

- 发行源提交：`bf6b35d`，标签 `v0.2.3.18`。[源码 CI](https://github.com/macfanpro/macfanpro/actions/runs/35975396388)、[发行 CI](https://github.com/macfanpro/macfanpro/actions/runs/35975397222) 通过。
- 下载草稿附件，`SHA256SUMS` 校验通过，与 GitHub asset digest 一致：`MacFanPro-0.2.3.18-macos-arm64.tar.gz` 为 `4c4f2d731f77e35036ab8e2cf0695ee0000d645281c3d8bb4a8668a0c113e866`。CLI 与应用版本为 0.2.3.18，严格代码签名校验通过。
- 以先退出应用、同步后台、再打开的步骤安装下载产物；已安装的后台服务 CLI 与应用二进制与发行包逐字节一致，后台服务运行中。

