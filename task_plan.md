# today-board task plan

> 说明：项目根已经生成真实 HarmonyOS NEXT Stage + ArkTS 脚手架，当前模块名是 `entry`。后续路径一律按当前工程真实结构，不再沿用空目录预估。

## 全局流程图

```mermaid
flowchart LR
  A["1. 工程初始化"] --> B["2. 路由与主题骨架"]
  B --> C["3. 首次配置流"]
  C --> C1["3a. 地址搜索设计"]
  C1 --> D["4. 首页静态实现"]
  D --> E["5. 决策引擎"]
  E --> F["6. 系统能力接入"]
  F --> G["7. 首页联调"]
  G --> H["8. 服务卡片"]
  H --> I["9. 设置与收口"]
  I --> J["10. 验证与整理"]
```

## 当前先做哪一刀

| files | action | verify | done |
| --- | --- | --- | --- |
| `AppScope/*` `entry/*` `hvigor*` `oh-package.json5` | 已用 DevEco Studio 生成 `Empty Ability` 工程，并把标准脚手架并回项目根 | 根目录 `ohpm install --all` 成功；脚手架包含 `AppScope`、`entry`、`hvigor*`、`oh-package.json5` | 是 |
| `entry/src/main/ets/entryability/*` `entry/src/main/ets/pages/*` `entry/src/main/ets/entrybackupability/*` | 已确认真实入口和页面目录：`EntryAbility.ets` + `pages/Index.ets` + `EntryBackupAbility.ets` | DevEco 工程树里能直接看到真实目录结构 | 是 |
| `task_plan.md` `progress.md` `findings.md` | 已把计划从“空目录预估”收敛到“真实 entry 模块结构” | 计划文件中的关键路径和实际工程一致 | 是 |
| `entry/src/main/ets/services/MapSearchService.ets` `entry/src/main/ets/pages/SetupPage.ets` `SettingsPage.ets` `SetupStore.ets` `entry/src/main/ets/config/MapSearchLocalConfig.ets` | 已实现“家/公司地址真实地点搜索选点”：高德 Web 服务 API、本机固定 Key、地址选点持久化 | 已用真实 Key 搜索返回地点；具体家/公司选点等用户选真实地址 | 是 |
| `entry/src/main/ets/common/AppTheme.ets` `entry/src/main/ets/pages/*` `entry/src/main/ets/widget/pages/TodayBoardCard.ets` | 已按 A 方案把主要 UI 重做为通勤票据风：米白纸面、墨绿主票、橙色提醒 | `assembleHap` 成功；HDC 安装启动成功；截图确认首次配置页新版 UI 可见 | 是 |
| `entry/src/main/ets/pages/Index.ets` `entry/src/main/ets/common/AppTheme.ets` | 已按截图改造首页为浅蓝毛玻璃通勤 Dashboard：Hero、交通快捷入口、推荐方案、清单、提醒、常用设置、底部导航 | `assembleHap` 成功；HDC 安装启动成功；首屏/中段/底部截图与布局树已验证 | 是 |
| `entry/src/main/ets/pages/Index.ets` `entry/src/main/ets/common/AppTheme.ets` | 已二次校正首页：天气背景层、透明玻璃层、固定底部导航、路线小地图 | `assembleHap` 成功；HDC 安装启动成功；`/tmp/today-board-frost-home-v3b.png` 和 `/tmp/today-board-frost-lower-v3.png` 已核对 | 是 |
| `entry/src/main/resources/base/media/tb_icon_*.png` `entry/src/main/ets/pages/Index.ets` | 已从 PS 当前打开的原图文件裁出 18 个透明 PNG 图标，并替换首页文字占位图标 | 资源数 18 个；首页引用全部可查；终端构建仍受本机 DevEco SDK 缺组件阻断 | 是 |
| `entry/src/main/resources/base/media/tb_nav_*.png` `tb_feature_*.png` `tb_item_*.png` `tb_weather_*.png` `entry/src/main/ets/components/WeatherAnimatedIcon.ets` `entry/src/main/ets/pages/*` | 已按天气看门板重做图标体系，增加天气动画图标和生活小物件图标，并接入首页、清单、提醒、我的和底部导航 | bootstrap `assembleHap` 成功；HDC 安装启动成功；`/tmp/today-board-icons.jpeg` 已核对 | 是 |
| `entry/src/main/resources/base/media/tb_*.png` `scripts/restore_initial_icons.mjs` | 已按用户要求回滚到最开始的蓝紫小图标风格，并把老 `tb_icon_*` 映射到当前页面仍引用的 `tb_nav_*`、`tb_feature_*`、`tb_item_*`、`tb_weather_*` | bootstrap `assembleHap` 成功；HDC 安装启动成功；`/tmp/today-board-icons-restored.jpeg` 已核对 | 是 |
| `DESIGN.md` `entry/src/main/ets/common/AppTheme.ets` `entry/src/main/ets/pages/*` `entry/src/main/ets/common/AppBottomNav.ets` `entry/src/main/ets/widget/pages/TodayBoardCard.ets` `entry/src/main/resources/base/media/tb_apple_hero.png` | 已按 Apple 发布会风重做：项目设计规则落 `DESIGN.md`，首页改黑底发布会主视觉，清单/提醒/我的改 Apple 系统工具页，服务卡片改黑白结论风 | bootstrap `assembleHap` 成功；HDC 安装启动成功；已点击验证看板/清单/提醒/我的 4 个 Tab | 是 |
| `entry/src/main/ets/common/AppIcon.ets` `entry/src/main/ets/common/AppBottomNav.ets` `entry/src/main/ets/pages/*` `entry/src/main/ets/components/WeatherAnimatedIcon.ets` | 已统一当前 4 个 Tab、天气、清单和状态入口图标为 `SymbolGlyph` 系统线性符号 | 根目录 `assembleHap` 成功；HDC 点击清单/提醒/我的后进程保持运行 | 是 |
| `entry/src/main/ets/services/WeatherService.ets` `entry/src/main/ets/services/WeatherKitProvider.ets` `entry/src/main/ets/services/TodayBoardSnapshotService.ets` | 已接入 HMS WeatherServiceKit：先真实定位，再动态加载适配模块，请求 `CURRENT / MINUTE / ALERTS`，按错误码写真实状态 | 根目录 `assembleHap` 成功；启动入口成功；当前设备缺定位时显示等待定位，不造天气数据 | 是 |
| `AppTheme.ets` `AppControls.ets` `AppBottomNav.ets` `Index.ets` `ChecklistPage.ets` `DiscoverPage.ets` `SettingsPage.ets` `tb_apple_hero.png` | 已按 Apple 无蓝色版统一按钮、图标、文字、图标容器、底栏和主视觉资源为黑白灰；橙色只留给异常/缺权限类状态 | 根目录 `assembleHap` 成功；颜色和旧图标引用扫描无命中；HDC 安装启动并点击 4 个 Tab 后进程保持运行 | 是 |
| `BoardStore.ets` `AppIcon.ets` `Index.ets` `ChecklistPage.ets` `DiscoverPage.ets` `SettingsPage.ets` `TodayBoardSnapshotService.ets` `CalendarService.ets` | 已按“天气开通 + 看板去时间 + 标签式清单”落地：天气开通入口放到我的页，主路径不再保存/展示本机目标时间，清单改为预设/自定义图标标签 | 根目录 `assembleHap` 成功；旧时间、蓝色、旧 PNG 扫描通过；HDC 安装启动成功并抓图核对清单/我的页 | 是 |
| `entry/src/main/resources/base/media/*` `entry/src/main/ets/pages/CommuteOptionsPage.ets` `docs/design/*` `scripts/*` | 已清理旧位图图标体系：删除不再使用的 `tb_icon_*`、`tb_nav_*`、`tb_feature_*`、`tb_item_*`、旧天气小图标、旧图标备份和恢复脚本；遗留通勤页改用 `AppIcon` 系统符号 | 资源引用脚本显示 missing refs 为 none；HAP 包内无旧图标资源；根目录 `assembleHap` 成功 | 是 |
| `entry/src/main/ets/store/BoardStore.ets` `entry/src/main/ets/pages/Index.ets` `entry/src/main/ets/pages/DiscoverPage.ets` `entry/src/main/ets/pages/SettingsPage.ets` `entry/src/main/ets/common/AppIcon.ets` `entry/src/main/ets/components/WeatherAnimatedIcon.ets` `entry/src/main/ets/services/TodayBoardSnapshotService.ets` | 已移除手动天气标签完整链路，并让首页 Scroll 视口避开固定底栏 | `rg "ManualWeather|manualWeather"` 无命中；bootstrap `assembleHap` 成功；HDC 安装启动并截图验证 | 是 |
| `entry/src/main/ets/pages/Index.ets` `ChecklistPage.ets` `DiscoverPage.ets` `SettingsPage.ets` `CommuteOptionsPage.ets` `SetupPage.ets` | 已修复 AppGallery 两项审核问题：隐藏首页时停止天气视频，所有页面滚动到边界时有回弹反馈 | 根目录 `assembleHap` 成功；bootstrap 页面已同步并编译到 `PackageHap`，签名仍被既有 keystore/JDK 问题阻断 | 是 |

| 阶段 | files | action | verify | done |
| --- | --- | --- | --- | --- |
| 1. 工程初始化 | `AppScope/*` `entry/*` `hvigor*` `oh-package.json5` | 脚手架已生成并并回项目根，下一步只差用根目录工程补一次 IDE 打开和设备侧验证 | `ohpm install` 已通；后续还要补模拟器或真机启动首页空壳 | 否 |
| 2. 路由与主题骨架 | `entry/src/main/ets/entryability/*` `entry/src/main/ets/pages/*` `entry/src/main/ets/common/*` | 首页、首次配置页、设置页、通勤方案页、清单页和公共主题常量都已统一为通勤票据风，当前只差逐页点击验证 | 页面可切换；主题色、字号、间距统一 | 否 |
| 3. 首次配置流 | `entry/src/main/ets/pages/Setup*.ets` `entry/src/main/ets/store/*` `entry/src/main/ets/services/MapSearchService.ets` | 已完成家、公司、上班时间、通勤方案、默认清单的录入和本地持久化；家/公司已支持高德真实地点搜索选中 | 首次配置完成后能落盘，再次打开不丢失；地图搜索不造数据；真实 Key 已本机固定并点测通过 | 否 |
| 4. 首页静态实现 | `entry/src/main/ets/pages/Index.ets` `entry/src/main/ets/common/AppTheme.ets` | 首页已改成读取本地配置和真实系统信号的毛玻璃通勤 Dashboard；缺地址、缺天气、缺日历都直接显示状态 | 首屏/中段/底部截图和布局树已验证，不展示伪造天气或测试地址 | 是 |
| 5. 决策引擎 | `entry/src/main/ets/domain/CommuteDecisionEngine.ets` `entry/src/main/ets/pages/Index.ets` | 已完成第一版透明规则：当前按当前时间、默认上班时间和本地通勤配置计算推荐方案、出门时间、风险提示和随身提醒 | 代码已接到首页；后续还要补设备侧点击验证和真实天气/日历输入 | 否 |
| 6. 系统能力接入 | `entry/src/main/ets/services/LocationService.ets` `CalendarService.ets` `WeatherService.ets` `WeatherKitProvider.ets` | 已接入系统日历、定位权限和 HMS WeatherServiceKit 动态适配；天气只在真实定位和 HMS 返回成功后进入 `ready` | 日历、定位、天气的缺权限、无数据、读取失败都会暴露，不偷偷补假值；根目录 `assembleHap` 已成功 | 是 |
| 7. 首页联调 | `entry/src/main/ets/pages/Index.ets` `entry/src/main/ets/store/*` | 首页已经接上“系统日历首条日程优先”和天气 `unknown` 状态；当前不把不可用天气纳入决策 | DevEco `Run entry` 已能启动并保持进程；后续重点验证配置流点击和日历授权 | 否 |
| 8. 服务卡片 | `entry/src/main/ets/formextension/*` `entry/src/main/ets/widget/*` `entry/src/main/resources/*` | 已实现单结论 2x2 桌面卡片，并同步成通勤票据风；创建和定时刷新时复用首页同一套决策数据 | 资源配置已本地自检；还差 DevEco/真机创建卡片、刷新、点击打开主应用 | 否 |
| 9. 设置与收口 | `entry/src/main/ets/pages/Settings*.ets` `entry/src/main/ets/utils/*` | “我的”页已改成权限、天气、日历、本机规则的设置列表；仍沿用本机真实状态，不新增后端 | 设置页已通过 HDC 点击进入和截图核对 | 是 |
| 10. 验证与整理 | `findings.md` `progress.md` `docs/*` | Apple 改版已补设计规范、执行记录和问题记录；旧未注册页面不在本轮扩大重构 | 首页、清单、提醒、我的 4 个主 Tab 已跑通；服务卡片完成构建，仍需桌面添加卡片实测 | 否 |
