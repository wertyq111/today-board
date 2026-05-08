# today-board progress

| 日期 | 状态 | 说明 |
| --- | --- | --- |
| 2026-04-23 | 已完成 | 完成产品方向收敛：生活信息类、练手型、上班通勤人群、晨报 + 混合通勤决策 |
| 2026-04-23 | 已完成 | 完成设计确认：首页结构 A、视觉方向 A、服务卡片结构 A |
| 2026-04-23 | 已完成 | 完成设计文档落盘：`docs/superpowers/specs/2026-04-23-today-board-design.md` |
| 2026-04-23 | 已完成 | 找回会话 `019db937-956c-7562-af22-777ade8ae10e`，确认上一轮已经收敛完产品、设计和实现总计划 |
| 2026-04-23 | 已完成 | 核对本机环境：`/Applications/DevEco-Studio.app` 已安装，但终端里还没有可直接调用的 `ohpm`、`hdc`、`hvigorw` |
| 2026-04-23 | 已完成 | 用 Computer Use 驱动 DevEco Studio，生成 `Empty Ability` 脚手架，真实结构确认是 `AppScope + entry` |
| 2026-04-23 | 已完成 | 已把脚手架并回项目根，根目录 `ohpm install --all` 成功 |
| 2026-04-23 | 已完成 | DevEco 临时工程首轮 sync 红字后，重试成功；`Ohpm Install` 和 `Build Init` 都显示 successful |
| 2026-04-23 | 已完成 | 已落 `common/AppRoute.ets`、`common/AppTheme.ets` 和 5 个页面骨架，首页不再是默认 `Hello World` |
| 2026-04-23 | 已完成 | 已注册 `SetupPage`、`CommuteOptionsPage`、`ChecklistPage`、`SettingsPage`，并补齐应用文案和基础主题资源 |
| 2026-04-23 | 已完成 | DevEco 验证工程同步后，`Problems` 面板对首页显示 `No problems in Index.ets` |
| 2026-04-23 | 已完成 | 已实现 `SetupStore` 本地持久化，首次配置会保存家、公司、上班时间、默认清单和 3 个通勤方案 |
| 2026-04-23 | 已完成 | 首页静态内容已改为读取本地配置；首次进入未配置时会自动跳转到 `SetupPage` |
| 2026-04-23 | 已完成 | DevEco 验证工程中 `Index.ets` 和 `SetupPage.ets` 的 `Problems` 面板都已经清空 |
| 2026-04-23 | 已完成 | 已新增 `CommuteDecisionEngine`，首页现在会按当前时间、默认上班时间和本地通勤配置输出透明规则结论 |
| 2026-04-23 | 已完成 | 已把页面里的全局 `router` 调用替换成 `UIContext.Router` 写法，`SetupPage.ets` 的最新 LSP 校验日志已清空 |
| 2026-04-23 | 已完成 | 已新增 `CalendarService`，能检查日历权限、请求授权，并读取今天第一条有效日程 |
| 2026-04-23 | 已完成 | 首页目标时间已切到“系统日历首条日程优先，默认上班时间兜回显”；设置页已补日历授权入口 |
| 2026-04-24 | 已完成 | 已新增 `LocationService`，能检查定位权限、请求授权，并读取当前位置经纬度 |
| 2026-04-24 | 已调整 | `WeatherService` 已移除 HMS `WeatherServiceKit` 静态导入；当前设备缺运行组件时直接显示天气不可用，不造天气数据 |
| 2026-04-24 | 已完成 | 设置页已补定位和天气刷新入口；天气缺运行组件、缺定位、刷新失败都会直接显示，不补假数据 |
| 2026-04-24 | 已完成 | 已新增 `TodayBoardSnapshotService`，把首页同一套通勤结论收成服务卡片可用数据 |
| 2026-04-24 | 已完成 | 已注册 `TodayBoardFormAbility` 和 `form_config.json`，新增 2x2 桌面服务卡片页面 `TodayBoardCard.ets` |
| 2026-04-24 | 已完成 | DevEco `Run entry` 已通过：build、install、launch 成功，设备进程保持运行，未再出现本应用 `cppcrash` |
| 2026-04-24 | 待验证 | 服务卡片代码已接入，仍差 DevEco/真机创建卡片、定时刷新和点击打开主应用验证 |
| 2026-04-24 | 已完成 | 用户确认地址能力走“真实地点搜索 + 本地 Key 不提交”方向 |
| 2026-04-24 | 已完成 | 已落地图地址搜索设计文档：`docs/superpowers/specs/2026-04-24-map-search-design.md` |
| 2026-04-24 | 已完成 | 已按用户要求创建 `lessons.md`，记录本项目后续必须遵守的踩坑经验 |
| 2026-04-24 | 已完成 | 已实现高德 Web 服务地点搜索：设置页配置本机 Key，配置页可搜索并选中家/公司地址 |
| 2026-04-24 | 已完成 | 已给 `module.json5` 补 `ohos.permission.INTERNET`，地图搜索请求才有网络权限 |
| 2026-04-24 | 已验证 | DevEco bootstrap `assembleHap` 成功，HDC 安装并启动 `com.palmpet.myapplication` 成功，进程号 `27370` |
| 2026-04-24 | 已完成 | 已按用户提供的高德 Web 服务 Key 做本机固定配置，真实 Key 放在已忽略的本机 ArkTS 配置文件里 |
| 2026-04-24 | 已验证 | 重新构建安装后，首次配置页“搜索地图地点”已启用；用“人民广场”真实查询返回 2 个地点，未保存为家/公司 |
| 2026-04-24 | 已确认 | 用户选择 UI 改版方向 A：清爽通勤看板 / 通勤票据风 |
| 2026-04-24 | 已完成 | 已落 UI 改版设计文档：`docs/superpowers/specs/2026-04-24-ticket-ui-redesign.md` |
| 2026-04-24 | 已完成 | 已把主题、首页、首次配置页、设置页、清单页、通勤方案页和 2x2 服务卡片统一为米白纸面、墨绿票据、橙色提醒的通勤票据风 |
| 2026-04-24 | 已验证 | bootstrap `assembleHap` 成功，HDC 安装并启动成功，设备进程号 `12087`；已抓取 `/tmp/today-board-screen.png` 验证首次配置页新版 UI 可见 |
| 2026-04-24 | 已完成 | 已按截图把首页单独重做为浅蓝毛玻璃通勤 Dashboard，保留配置页、设置页、清单页、通勤方案页原有入口 |
| 2026-04-24 | 已验证 | bootstrap `assembleHap` 成功，HDC 安装并启动 `com.palmpet.myapplication` 成功；已抓取 `/tmp/today-board-frost-home.png`、`/tmp/today-board-frost-lower.png`、`/tmp/today-board-frost-bottom.png` |
| 2026-04-24 | 已验证 | 布局树确认首页包含推荐方案、出发时间、费用、出门清单、常用设置和底部导航；未写入测试地址，天气不可用时显示状态文案而不是假温度 |
| 2026-04-24 | 已完成 | 已从 PS 当前打开的 `/Users/zhouxufeng/Downloads/ChatGPT Image 2026年4月24日 11_16_58.png` 裁出 18 个透明 PNG 图标，放入 `entry/src/main/resources/base/media/` |
| 2026-04-24 | 已完成 | 首页交通入口、路线预览、出门清单、常用设置、底部导航已从文字占位图标换成 `tb_icon_*` 资源 |
| 2026-04-24 | 已完成 | 已按用户指出的问题二次校正首页：补天气背景层、玻璃透明层、城市/车辆视觉、路线小地图，底部导航改为固定覆盖在视口底部 |
| 2026-04-24 | 已验证 | bootstrap `assembleHap` 成功，HDC 安装并启动成功；已抓取 `/tmp/today-board-frost-home-v3b.png`、`/tmp/today-board-frost-lower-v3.png` 验证首页和滚动后状态 |
| 2026-04-24 | 已验证 | 布局树确认底部导航固定在屏幕底部，滚动内容里仍包含通勤方案、出门清单、常用设置；未写入测试地址，天气仍不显示假温度 |
| 2026-04-27 | 已完成 | 已按底部导航先出 4 页重设计稿：`docs/design/bottom-tabs-redesign.html` 和 `docs/design/bottom-tabs-redesign.png`；用户确认只需放大底部导航和首页图标 |
| 2026-04-27 | 已完成 | 已落 ArkTS：底部导航图标放大并抽成共享组件，首页快捷入口/清单图标放大，补齐 `DiscoverPage`，`SettingsPage` 接入固定底部导航 |
| 2026-04-27 | 已验证 | bootstrap `assembleHap` 成功，产物为 `.deveco-bootstrap/TodayBoardBootstrap/entry/build/default/outputs/default/entry-default-unsigned.hap`；当前 `hdc list targets` 为空，未能安装截图 |
| 2026-04-27 | 已完成 | 底部导航改为直接使用 `tb_icon_board/itinerary/discover/profile` 的完整按钮 PNG，尺寸放大到 `62x62`，导航栏高度同步加到 `98` |
| 2026-04-27 | 已验证 | 清理 `default@CompileArkTS` 脏缓存后，bootstrap `assembleHap` 重新构建成功 |
| 2026-04-27 | 已验证 | HDC 重新连接到 `127.0.0.1:5555` 后，安装启动成功，并抓取 `/tmp/today-board-bottom-buttons.png` 验证底部按钮图标已明显放大 |
| 2026-04-27 | 已完成 | 首页交通入口改为固定图标槽、标题槽、副文案槽，图标和文字中轴对齐 |
| 2026-04-27 | 已完成 | “我的”页改为首页同款天空背景、浅蓝毛玻璃卡片、大号按钮图标和固定底部导航 |
| 2026-04-27 | 已验证 | bootstrap `assembleHap` 成功，HDC 安装启动成功；已抓取 `/tmp/today-board-icon-align-home.png` 和 `/tmp/today-board-icon-align-profile.png` 核对效果 |
| 2026-04-28 | 已完成 | 修正首页交通入口、出门清单和底部导航的图标文字对齐：统一改为固定图标槽、固定文字槽和固定 `lineHeight` |
| 2026-04-28 | 已验证 | bootstrap `assembleHap` 成功，HDC 安装启动成功；已抓取 `/tmp/today-board-align-v2-home.png` 核对红框区域 |
| 2026-04-28 | 已完成 | 无后端天气看门板第一批落地：底部 Tab 改为看板/清单/提醒/我的，首页主语义切到天气、清单、日历，清单页接入固定底栏，我的页撤掉地图配置入口 |
| 2026-04-28 | 已验证 | bootstrap `assembleHap --no-daemon --no-incremental --info` 成功；HDC 当前返回 `Connect server failed`，未能安装截图 |
| 2026-04-28 | 已完成 | 第二阶段清理：入口不再初始化地图搜索，服务卡片改为天气/清单结论，天气不可用文案去掉通勤表达，旧 Setup/Commute 页面从 `main_pages.json` 注册表摘除 |
| 2026-04-28 | 已验证 | 第二阶段再次同步到 bootstrap 并执行 `assembleHap --no-daemon --no-incremental --info` 成功；HDC 重启后仍返回 `Connect server failed`，未能安装截图 |
| 2026-04-28 | 已完成 | 第三阶段清理：新增 `BoardStore` 承接本机看板设置、清单、手动天气标签，首页/清单/提醒/我的/服务卡片主路径不再读取旧 `SetupStore` |
| 2026-04-28 | 已验证 | 第三阶段同步到 bootstrap 并执行 `assembleHap --no-daemon --no-incremental --info` 成功；沙箱内 HDC 返回 `Connect server failed`，沙箱外通过 DevEco 设备链路抓取 `/tmp/today_board_current.jpeg` 成功 |
| 2026-04-28 | 已验证 | 用户确认后已覆盖安装最新 HAP 并启动成功；已抓取 `/tmp/today_board_stage3.jpeg`、`/tmp/today_board_checklist_stage3.jpeg`、`/tmp/today_board_reminders_stage3b.jpeg`、`/tmp/today_board_profile_stage3.jpeg` 验收 4 个底部 Tab |
| 2026-04-28 | 已完成 | 重新生成精制图标体系：新增 `tb_nav_*`、`tb_feature_*`、`tb_item_*`、`tb_weather_*`，并重绘旧 `tb_icon_*` 兼容资源 |
| 2026-04-28 | 已完成 | 新增 `WeatherAnimatedIcon`，首页、提醒页、我的页的天气入口改走天气动画图标；清单页和首页清单项改用生活小物件图标 |
| 2026-04-28 | 已验证 | DevEco bootstrap `assembleHap --no-daemon --no-incremental --info` 成功；沙箱外 HDC 安装启动成功，已抓取 `/tmp/today-board-icons.jpeg` 验证首页新图标可见 |
| 2026-04-28 | 已回滚 | 按用户要求还原回最开始的蓝紫小图标风格；从早期 `tb_icon_*` 构建资源恢复，并映射到当前新增资源名 |
| 2026-04-28 | 已验证 | 还原后 DevEco bootstrap `assembleHap --no-daemon --no-incremental --info` 成功；HDC 安装启动成功，已抓取 `/tmp/today-board-icons-restored.jpeg` |
| 2026-04-28 | 已完成 | 已新增项目根 `DESIGN.md`，把 `awesome-design-md` Apple 方向改写成本项目 ArkUI 规则：黑底发布会首页、浅灰系统工具页、蓝色只做状态和操作 |
| 2026-04-28 | 已完成 | 已新增 `tb_apple_hero.png` 主视觉；首页改为黑底 Apple 发布会首屏，保留真实天气/日历/清单状态，不新增 mock |
| 2026-04-28 | 已完成 | 清单、提醒、我的已改成 Apple 系统工具页；底部导航改为紧凑黑色固定栏；2x2 服务卡片改成黑白主结论风 |
| 2026-04-28 | 已验证 | Apple 改版同步到 DevEco bootstrap 后 `assembleHap --no-daemon --no-incremental --info` 成功；HDC 安装、启动成功 |
| 2026-04-28 | 已验证 | 已通过 HDC 点击验证看板、清单、提醒、我的 4 个 Tab 可达；首页截图检查后修正了摘要区与底栏重叠、底栏透出文字的问题 |
| 2026-04-28 | 已完成 | 新增 `AppIcon` 系统符号组件，当前 4 个 Tab、天气状态、清单项、提醒页、我的页已统一为 Apple/Harmony 线性图标风 |
| 2026-04-28 | 已完成 | 天气刷新改为 `WeatherService -> LocationService -> WeatherKitProvider`：先取真实定位，再动态加载 HMS WeatherServiceKit 请求 `CURRENT / MINUTE / ALERTS` |
| 2026-04-28 | 已验证 | 根目录 `assembleHap --no-daemon --no-incremental --info` 成功；HDC 安装启动成功，点击清单/提醒/我的后应用进程保持运行 |
| 2026-04-29 | 已完成 | 按用户要求实现 Apple 无蓝色版：按钮、图标、文字、图标容器、底部导航和首页链接统一改为黑白灰；首页主视觉 PNG 同步去色 |
| 2026-04-29 | 已完成 | 新增 `AppControls.ets`，沉淀 `AppActionButton`、`AppIconTile`、`AppGroupedListRow`；清单、提醒、我的改用浅灰系统页和中性控件 |
| 2026-04-29 | 已修复 | 天气刷新前新增 `canIUse('SystemCapability.Weather.Core')` 门禁，当前设备缺 WeatherServiceKit HSP 时不再加载天气 Provider，入口不再崩溃 |
| 2026-04-29 | 已验证 | 根目录 `assembleHap --no-daemon --no-incremental --info` 成功；`rg "#0071E3|#E8F2FF|APPLE_BLUE|APPLE_BLUE_SOFT"` 无命中；HDC 安装启动成功，点击看板/清单/提醒/我的后进程保持运行 |
| 2026-04-29 | 已完成 | 天气开通入口收敛到“我的”页：按真实链路走定位权限、定位开关、`SystemCapability.Weather.Core`、`WeatherServiceKit`；当前设备缺组件时显示“待开通/组件不可用” |
| 2026-04-29 | 已完成 | 今日看板主路径移除本机目标时间：`BoardStore` 不再保存 `board.targetTime`，首页/我的页不再展示 `09:00` 或默认上班时间文案 |
| 2026-04-29 | 已完成 | 清单改为结构化标签：预设 10 个通勤物品，支持图标标签选中/取消，自定义物品通过固定图标池手动选择并写入本机 |
| 2026-04-29 | 已验证 | 根目录 `assembleHap --no-daemon --no-incremental --info` 成功；旧时间、蓝色常量、旧 PNG 图标扫描通过；HDC 安装启动成功，清单/我的截图已核对，进程号 `24371` |
| 2026-04-29 | 已完成 | 按 A 方案切到 APP 直连高德天气：新增 `AmapWeatherService`，用定位反查 adcode 后请求实时天气，天气信号扩展为晴/雨/雪/云四类 |
| 2026-04-29 | 已完成 | 首页按已确认预览落地天气动效：晴天右上光柱、雨天慢速雨线和摘要卡顶部水花、雪天慢速雪花和浅积雪、云天全屏树叶和云层明暗 |
| 2026-04-29 | 已完成 | “我的”页删除本机清单卡片和底部三个大按钮，日历/定位/天气状态右侧改为行内刷新图标 |
| 2026-04-29 | 已验证 | 根目录 `assembleHap --no-daemon --no-incremental --info` 成功；`hdc list targets` 当前返回 `Connect server failed`，本轮未能安装截图 |
| 2026-04-29 | 已修复 | 根据 Gemini 参考页重做首页实机天气氛围：修正 ArkUI ARGB 透明色、收紧首屏卡片、补玻璃卡 hover 流光，并让天气卡直接读取真实天气状态 |
| 2026-04-29 | 已验证 | DevEco bootstrap `assembleHap --no-daemon --no-incremental --info` 成功；HDC 安装启动成功，最终截图 `today-board-home-device-v8.jpeg` 显示天气卡为“晴”，无黄色硬块 |
| 2026-04-29 | 已完成 | 首页顶部空黑区压缩，主视觉上方大标题、说明文案和文字按钮已移除，只保留品牌行、天气画面和状态卡 |
| 2026-04-29 | 已验证 | 根目录与 DevEco bootstrap `assembleHap --no-daemon --no-incremental --info` 均成功；本轮 HDC 安装截图被系统审批限额拦截，需在 DevEco 点 Run 做最终肉眼确认 |
| 2026-04-29 | 已完成 | 再次压缩首页顶部留白：品牌行上移、主视觉上移约 60px、hero 高度从 364 缩到 304，天气层高度同步收紧 |
| 2026-04-29 | 已验证 | 根目录与 DevEco bootstrap `assembleHap --no-daemon --no-incremental --info` 均成功 |
| 2026-04-29 | 已修复 | 首页品牌行不在顶部的问题：`heroScene` 外层 `Stack` 改为 `Alignment.TopStart`，品牌行固定到 hero 顶部 |
| 2026-04-29 | 已完成 | 出门清单首页卡片改为两排展示，最多显示 8 个清单项，卡片高度同步从 148 提到 228 |
| 2026-04-29 | 已验证 | 根目录与 DevEco bootstrap 构建成功；HDC 安装启动成功，最终截图 `today-board-home-device-v10.jpeg` 已确认品牌行贴顶、清单两排可见 |
| 2026-04-29 | 已完成 | 生成并接入 17 张天气主视觉：晴、小雨、中雨、大雨、雷阵雨、雷暴雨、雨夹雪、雾霾、阴、多云、小雪、中雪、大雪、暴雪、40 度以上大晴、沙尘、大雾 |
| 2026-04-29 | 已完成 | 首页 `heroScene` 改为按高德天气文字选择对应主视觉，天气展示区域改大并使用 `ImageFit.Cover` 展示 |
| 2026-04-29 | 已验证 | DevEco bootstrap 构建成功；当前 `hdc list targets` 为空，未能自动安装截图 |
| 2026-04-30 | 已完成 | 按中文天气图对照表覆盖 APP 天气主视觉资源：`/Volumes/AgentAPFS/image/*.png` 已写入 `entry/src/main/resources/base/media/tb_weather_hero_*.png` |
| 2026-04-30 | 已验证 | 17 张图片源文件与 APP 资源 SHA256 全部一致；根目录与 DevEco bootstrap `assembleHap` 均成功 |
| 2026-04-30 | 已完成 | 已清理旧位图图标体系：应用资源从 96 个收窄到 22 个，只保留启动图标、`tb_apple_hero` 和当前天气主视觉；同步删除旧图标备份、预览和恢复脚本 |
| 2026-04-30 | 已验证 | 资源引用检查 missing refs 为 none；HAP 包内无旧图标资源；根目录 `assembleHap --no-daemon --no-incremental --info` 成功 |
| 2026-05-04 | 已调整 | 首页天气 MP4 恢复 `ImageFit.Cover`，并把同名天气 PNG 批量裁成对应 MP4 的真实尺寸，避免预览图和动画比例不一致 |
| 2026-05-04 | 已验证 | 根目录与 DevEco bootstrap `assembleHap` 均成功；已安装启动并抓取 `/tmp/today-board-cover-cropped-cloudy.jpeg` 核对多云画面 |
| 2026-05-04 | 已完成 | 已用用户提供的 `晴.mp4`、`小雨.mp4`、`中雨.mp4`、`雷阵雨.mp4` 替换同名天气动画，并用新视频缩略图同步对应 PNG 预览图 |
| 2026-05-04 | 已验证 | 4 个新 MP4 均为 `720x1280`；根目录与 DevEco bootstrap `assembleHap` 均成功；已安装启动并截图核对晴、小雨、中雨、雷阵雨 |
| 2026-05-05 | 已完成 | 已移除手动天气标签完整链路：`BoardStore` 不再持久化 `board.manualWeatherTag`，首页、提醒页、我的页、服务卡片和天气图标都只读取真实天气状态 |
| 2026-05-05 | 已修复 | 首页固定底部导航不再遮挡第二张“出门清单”卡片；首页 `Scroll` 视口避开底栏，滚动后卡片可完整露出 |
| 2026-05-05 | 已验证 | DevEco bootstrap `assembleHap` 成功，HDC 安装启动成功；已抓取 `artifacts/today_board_home_after_navfix.jpeg`、`artifacts/today_board_home_after_scroll.jpeg`、`artifacts/today_board_profile_calendar_refresh.jpeg` |
| 2026-05-05 | 已完成 | 已填写 AppGallery Connect 基础信息文档：`docs/release/appgallery-basic-info.md`；本地包名改为 `com.zhouxufeng.todayboard`，应用名统一为“天气看门板” |
| 2026-05-05 | 已验证 | 根目录和 DevEco bootstrap `assembleHap` 均成功；当前仍未配置 Release 签名，所以构建日志会提示跳过签名 |
| 2026-05-05 | 已完成 | 已按用户反馈把应用图标收敛为单一圆角天气看板：`docs/release/app-icon-source.svg`，主体只保留太阳、云朵和今日提示线 |
| 2026-05-05 | 已完成 | 已统一包内应用图标资源：`AppScope` 与 `entry` 的 `background.png` 使用新 1024 图，`foreground.png` 为空透明层，`startIcon.png` 与上传 1024 图哈希一致 |
| 2026-05-05 | 已完成 | 已导出 AppGallery 可上传图标：`docs/release/app-icon-1024.png` 和 `docs/release/app-icon-216.png`，均为正方形 PNG 且小于 3 MB |
| 2026-05-05 | 已验证 | 单一看板图标接入后，尺寸/大小/透明层/哈希校验通过；根目录 `assembleHap --no-daemon --no-incremental --info` 构建成功 |
| 2026-05-06 | 已完成 | 已确认应用图标配置接入包内资源；`AppScope`、`entry` 和启动图标继续复用同一张单一看板图标 |
| 2026-05-06 | 已完成 | 已把天气“云天”文案统一改为“多云”，并把卡片里的“日历信号”改成“日历” |
| 2026-05-06 | 已完成 | 提醒页已移除桌面卡片入口，只保留天气、清单、日历三条规则 |
| 2026-05-06 | 已完成 | 首页、清单、提醒、我的和底部导航已增加 520vp 展开屏最大宽度，适配二折叠、三折叠的大屏展开态 |
| 2026-05-06 | 已验证 | 根目录 `assembleHap --no-daemon --no-incremental --info` 成功；DevEco 直连 `Huawei_TripleFold` 安装启动成功；已抓取 `artifacts/today-board-app-trifold-520.jpeg` 和 `artifacts/today-board-reminder-trifold-520.jpeg` 核对展开屏居中、提醒页无桌面卡片 |
| 2026-05-06 | 已修复 | 高德 Key 缺失根因是天气服务读了空的 `MapSearchConfig.ets`；已改为通过可提交配置桥接到本机忽略 Key 文件，真实 Key 不进入源码 |
| 2026-05-06 | 已验证 | 高德天气接口用本机 Key 返回 `status=1/info=OK`；根目录 `assembleHap` 成功；DevEco bootstrap 已编译到 `PackageHap`，最后仅因本机 keystore/JDK 算法问题停在签名 |
| 2026-05-07 | 已修复 | 根据 AppGallery 功耗/UX 测试报告处理两项问题：首页天气视频在 `onPageHide` 停止，所有页面 `Scroll` 显式开启 `EdgeEffect.Spring` 回弹 |
| 2026-05-07 | 已验证 | 根目录 `assembleHap` 成功；DevEco bootstrap 已同步页面代码并编译到 `PackageHap`，最后仍停在既有 keystore/JDK `HmacPBESHA256` 签名问题 |
