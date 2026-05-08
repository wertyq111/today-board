# today-board findings

| 日期 | 类型 | 内容 | 处理 |
| --- | --- | --- | --- |
| 2026-04-23 | 环境 | 项目目录当前不是 git 仓库 | 如需提交或建 PR，先初始化仓库或接入现有仓库 |
| 2026-04-23 | 环境 | 项目根已经有真实 HarmonyOS 脚手架，真实模块名是 `entry` | 后续实现直接围绕 `entry/src/main/ets/*` 展开 |
| 2026-04-23 | 环境 | 本机已安装 `/Applications/DevEco-Studio.app`；虽然终端里没有全局 `ohpm`、`hdc`、`hvigorw`，但可直接调用 DevEco 内置 `ohpm` | 依赖安装先走 DevEco 内置工具链 |
| 2026-04-23 | 环境 | DevEco 临时工程首轮 sync 一度报错，但重试后 `Ohpm Install` 和 `Build Init` 都成功 | 当前不用继续怀疑 `ohpm` 源入口本身，后面重点放回应用实现 |
| 2026-04-23 | 环境 | 终端直跑 `hvigorw assembleHap` 仍报 `SDK component missing` | 现阶段先用 DevEco IDE 做本地验证；如果后面要接 CLI/CI，再单独修本机 SDK 映射 |
| 2026-04-24 | 环境 | 根目录没有 `./hvigorw`；改用 DevEco 自带 `hvigorw` 后，显式设置 `DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk/default` 仍报 `SDK component missing` | 当前构建仍卡本机 SDK 完整性，不是天气代码的运行结果 |
| 2026-04-24 | 环境 | 服务卡片接入后再次运行 DevEco 自带 `hvigorw assembleHap`，仍停在 `SDK component missing` | 需要先在 DevEco SDK 管理器补齐 SDK 组件，才能做终端构建和桌面卡片真机验证 |
| 2026-04-23 | 现状 | 首次配置流和首页静态联动已经写完，DevEco 验证工程里 `Index.ets` 和 `SetupPage.ets` 没有当前文件问题 | 下一步主要看设备侧运行和交互手感，而不是继续补骨架 |
| 2026-04-23 | 现状 | 第一版通勤决策引擎已经接到首页，当前不会伪造天气和日历，只会明确暴露“信息不完整” | 下一步优先接真实系统信号，而不是继续堆静态文案 |
| 2026-04-23 | 现状 | 系统日历已经接进首页和设置页；今天第一条有效日程会优先替换默认上班时间 | 定位和天气还没接，所以首页仍可能显示“信息不完整” |
| 2026-04-24 | 现状 | 定位已经接进设置页；天气刷新入口保留，但当前设备缺少 HMS Weather Service HSP，天气不参与首页决策 | 后续只有确认目标设备具备 Weather HSP 或产品决定接第三方天气源时，才重新接真实天气 |
| 2026-04-24 | 约束 | `@kit.WeatherServiceKit` 在当前设备运行时会加载 `/data/storage/el1/bundle/com.huawei.hms.weather/WeatherService/WeatherService/ets/modules.abc`，缺 HSP 会导致 `LoadJSPandaFile` 后 SIGABRT | 已移除静态导入，当前直接显示天气服务不可用，不走第三方天气接口，也不捏造天气 |
| 2026-04-24 | 验证 | DevEco `Run entry` 重新执行后显示 `Build task`、`bm install`、`aa start` 全部成功，`pidof com.palmpet.myapplication` 能拿到进程号 | entry 启动报错已解除；旧 FaultLog 里仍会显示修复前的历史 cppcrash，可忽略 |
| 2026-04-23 | 环境 | 本轮 Computer Use 没拿到 DevEco 窗口控制；改用 DevEco LSP 日志核对校验结果 | `SetupPage.ets` 最新日志里 `tsCheck / etsLint / ArkTSLint` 都已清空 |
| 2026-04-23 | 验证 | 本轮日历相关文件主要做了本地自检和 SDK 声明对照；DevEco 当前焦点没切到新文件，所以还没有拿到 `CalendarService.ets` 的单文件日志校验 | 下一步最好接模拟器或真机点一遍日历授权和首页刷新 |
| 2026-04-24 | 已确认 | 天气接口定为 HMS `@kit.WeatherServiceKit`；当前只请求 `CURRENT / HOURLY / MINUTE / ALERTS` | 不引入远端后端，不引入第三方天气 key |
| 2026-04-24 | 已确认 | 服务卡片配置已补 `FormExtensionAbility`、`$profile:form_config`、ArkTS 卡片完整 `.ets` 路径和 2x2 规格 | 卡片创建、刷新、点击打开主应用还必须等 DevEco/设备侧验证 |
| 2026-04-24 | 已确认 | 家和公司地址需要支持真实地点搜索选中；方向定为 Web/API 地点搜索服务 + 本地 Key 不提交 | 已实现高德 Web 服务搜索；未配置真实服务时不造地点数据 |
| 2026-04-24 | 约束 | 当前 `.gitignore` 已忽略 `local.properties` 和 `project-*.json` | 地图搜索 Key 只能放本地忽略文件，不能进入源码、资源或项目说明 JSON |
| 2026-04-24 | 已实现 | 地图搜索第一版改用高德 Web 服务 API：`https://restapi.amap.com/v3/place/text`，只解析真实返回的 `pois`、`address`、`location` | 未配置 Key 时不发请求；结果缺地址或经纬度时不允许保存为地图选点 |
| 2026-04-24 | 约束 | 地图 Key 可通过设置页写入本机应用存储，也可通过已忽略的 `MapSearchLocalConfig.ets` 固定默认值；真实 Key 不写文档、不写 tracked 源码、不写项目 JSON | 如果后续接入仓库，不能把真实 Key 固化进 tracked 文件 |
| 2026-04-24 | 已确认 | 本机固定地图 Key 已落到 `.gitignore` 覆盖的 ArkTS 配置文件 | 后续构建会自动把地图搜索置为已配置；进度文件不记录明文 Key |
| 2026-04-24 | 验证 | 本机固定 Key 生效后，首次配置页地图搜索按钮已启用，真实 POI 搜索能返回地点 | 当前只验证查询返回；家/公司具体选点留给用户选真实地址 |
| 2026-04-24 | 现状 | 旧 UI 主要问题是页面像功能卡片堆叠，没有统一视觉隐喻 | 已改成通勤票据风：深绿主票面、米白纸面、橙色行动提醒 |
| 2026-04-24 | 验证 | UI 改版后 `assembleHap`、HDC 安装、`aa start` 都成功，进程保持运行 | 已用截图确认首次配置页新版 UI 可见；未写入测试地址，避免污染用户真实配置 |
| 2026-04-24 | 现状 | 首页需要单独改成毛玻璃通勤 Dashboard，不扩散到全应用 | 已只改 `Index.ets` 和首页主题常量，其他页面与地图 Key 配置不动 |
| 2026-04-24 | 约束 | 当前天气没有真实温度字段，设备还会返回 Weather Service Kit 不可用 | 首页显示“天气待开通/天气待接入”等状态，不显示假 `24°C` |
| 2026-04-24 | 验证 | 毛玻璃首页初版在大字号真机环境下出现快捷入口和常用设置文字截断 | 已把快捷入口改短标签、通勤方案改纵向信息流、常用设置改 2x2，并重新截图验证 |
| 2026-04-24 | 现状 | PS 当前打开的图标原图在 `/Users/zhouxufeng/Downloads/ChatGPT Image 2026年4月24日 11_16_58.png`，尺寸 1254×1254 | 已按原图坐标裁出 18 个透明 PNG，不使用截图压缩件 |
| 2026-04-24 | 验证 | `entry/src/main/resources/base/media/` 下已有 18 个 `tb_icon_*.png`，首页引用全部能查到 | 终端构建仍被本机 DevEco SDK 缺组件拦住，需 DevEco SDK 补齐后再真机复验 |
| 2026-04-24 | 现状 | 毛玻璃首页初版不像参考图，根因是卡片仍接近不透明、背景缺天气层、底部导航仍在滚动内容里 | 已改成 `Stack` 三层结构：背景铺满、内容滚动、底部导航固定 |
| 2026-04-24 | 约束 | ArkUI `Blank` 不能直接放在 `Stack` 内，自定义 `@Builder` 调用后也不能继续链 `.position()` | 已改用 `Text('')` 承载装饰形状，并把定位封进专用 builder |
| 2026-04-24 | 验证 | 8 位色值按 Web RGBA 写会在 ArkUI 下变成 ARGB，导致蓝色背景变黄绿色 | 已统一修正透明色写法，重新截图确认天气背景回到蓝天云层 |
| 2026-04-24 | 环境 | `DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk/default` 会触发 SDK component 错误，未设置又可能触发 SDK path 错误 | 已确认临时设置为 `/Applications/DevEco-Studio.app/Contents/sdk` 后 `assembleHap` 成功 |
| 2026-04-27 | 验证 | 本轮 `assembleHap` 已成功，但 `hdc list targets` 返回 `[Empty]` | 当前没有可安装截图的设备；等设备重新连上后直接安装同一个 HAP 复验 |
| 2026-04-23 | 风险 | 定位、系统日历、服务卡片都涉及权限和真机验证 | 先把静态 UI 跑通，再逐个接系统能力 |
| 2026-04-23 | 约束 | 第一版不做后端、不做远端、不做复杂路线引擎 | 所有实现都以端上本地规则为准 |
| 2026-04-24 | 约束 | 当前项目已创建 `lessons.md` | 后续新任务开始前先读该文件 |
| 2026-04-28 | 已实现 | `awesome-design-md/design-md/apple/README.md` 本地只有外链索引，项目需要自己的可执行规则 | 已新增 `DESIGN.md`，以后 ArkUI 改版直接按本项目规则执行 |
| 2026-04-28 | 验证 | Apple 首页首轮截图发现底部导航压住摘要/清单区域，透明底栏会透出后方文字 | 已压缩 hero 高度、收紧底栏尺寸、移除底栏模糊并提高黑色透明度 |
| 2026-04-28 | 约束 | Weather Service Kit 当前设备仍不可用，不能为了 Apple 风格显示假温度或假天气 | 首页、提醒、我的和服务卡片继续显示真实状态或不可用状态 |
| 2026-04-28 | 待验证 | 服务卡片已随 Apple 黑白风构建通过，但本轮只验证了主应用 4 个 Tab | 后续仍需在桌面真实添加 2x2 卡片，检查小尺寸内容是否溢出 |
| 2026-04-28 | 已实现 | 当前 4 个 Tab 的图标已从 bitmap 资源切到 `AppIcon` + `SymbolGlyph` | 后续页面不要继续散用 `tb_nav_*`、`tb_item_*`、`tb_weather_*` 扩大卡通图标体系 |
| 2026-04-28 | 已实现 | HMS 天气接入已隔离到 `WeatherKitProvider.ets`，主刷新链路只动态加载适配模块 | 设备缺 WeatherServiceKit 运行能力时，界面显示真实不可用状态，不让入口崩溃 |
| 2026-04-28 | 验证 | `SymbolGlyph` 可用的系统符号名以 SDK `sysResource` 为准，`person_crop_circle` 不存在，实际用 `person_crop_circle_fill` | 新增符号前先查 SDK 资源名，避免靠视觉命名猜 |
| 2026-04-29 | 已实现 | Apple 无蓝色版不能只改 ArkUI 色值，首页主视觉 PNG 的蓝色高光也会破坏风格一致性 | 已把 `tb_apple_hero.png` 转成灰阶，最终首页截图无蓝色高光 |
| 2026-04-29 | 已修复 | 当前设备缺 `/data/storage/el1/bundle/com.huawei.hms.weather/WeatherService/WeatherService/ets/modules.abc` 时，加载含 `@kit.WeatherServiceKit` 顶层导入的 Provider 会触发 fatal | `WeatherService.refresh()` 先检查 `SystemCapability.Weather.Core`，缺能力时写入 `unavailable`，不再 import Provider |
| 2026-04-29 | 验证 | 最终包安装启动后，点击看板、清单、提醒、我的 4 个 Tab 都成功，进程号保持为 `24095` | 本轮设备验收通过；天气仍按真实不可用状态显示，不造假数据 |
| 2026-04-29 | 已实现 | 旧 `board.checklistText` 不能继续作为主路径清单模型 | `BoardStore` 新增结构化 `ChecklistItem`，只保留旧文本字段用于首次迁移 |
| 2026-04-29 | 已修复 | 去掉 `board.targetTime` 后，`CalendarService` 空/失败状态仍残留“默认上班时间”文案 | 日历状态文案改为真实状态：无日程、无权限、读取失败，不再提示默认时间 |
| 2026-04-29 | 验证 | 当前设备缺 Weather Service Kit 运行组件 | 天气状态真实显示“待开通/组件不可用”；HDC 安装启动后进程保持为 `24371` |
| 2026-04-29 | 已实现 | 天气源已从 Weather Service Kit 改为高德 Web 服务 | Key 只放在已忽略的 `WeatherLocalConfig.ets`，生产代码不写假天气；无定位、无 Key、无返回都会显示真实失败状态 |
| 2026-04-29 | 验证 | 首页天气动效使用 ArkUI 原生形状和状态动画，不引入 WebView 或 mock 预览数据 | `assembleHap` 已通过，设备侧截图仍需 HDC 恢复后补验 |
| 2026-04-29 | 已修复 | 首页实机和预览页不一致，主因是 ArkUI 8 位色值按 ARGB 解释，旧晴天光柱被画成不透明色块 | 已改为低透明 ARGB 渐变，并用实机截图验证没有黄色硬块 |
| 2026-04-29 | 已修复 | 首页天气卡一度显示“待接入”，但摘要已经有高德真实天气 | 原因是动态值通过普通 Builder 参数传入后未按预期刷新；已改为卡片组件内部直接读取 `@StorageLink` 状态 |
| 2026-04-29 | 已修复 | 首页首屏顶部黑色空区过大，主视觉区域文字太抢画面 | 已上移主视觉、缩短 hero 高度，并移除大标题/说明/文字按钮 |
| 2026-04-30 | 已清理 | `tb_icon_*`、`tb_nav_*`、`tb_feature_*`、`tb_item_*` 和旧天气小图标已经不是当前主路径资源 | 已从应用资源、旧图标预览、旧图标备份和恢复脚本中清理；后续图标继续走 `AppIcon` + `SymbolGlyph` |
| 2026-05-04 | 已调整 | 天气视频是 720×1280/1080×1920，但同名预览 PNG 原来多为 1024×1536，比例不一致会让切换到动画时像被放大 | 已恢复 `ImageFit.Cover`，并把同名 PNG 裁剪/重采样到对应 MP4 的真实尺寸 |
| 2026-05-05 | 已确认 | 当前设备日历读取链路可用，刷新后进入 `empty` 状态并显示“今天无日程 / 今天没有后续日程”，不是 `denied` 或 `error` | 要验证具体日程标题，需要先在系统日历里放一条今天未来的非全天日程 |
| 2026-05-05 | 已修复 | 首页第二张卡片被底部固定导航压住，单独增加内容底部空白不能解决首屏覆盖 | 已让首页 `Scroll` 本身给底栏留出底部视口空间，并用滚动截图确认卡片完整露出 |
| 2026-05-05 | 已修复 | `AppScope` 与 `entry` 的 `foreground.png` 哈希不一致，且 `startIcon.png` 仍是 144 x 144 | 已用新绘制母版统一为包内同源图标，并导出 1024/216 两个正方形 PNG 上传文件 |
| 2026-05-07 | 审核 | AppGallery 功耗测试指出“前台不可见动效”时，截图停在“我的”页，但真正耗资源的是路由栈后面的首页天气 `Video` | 已给首页加 `VideoController`，页面隐藏时停止播放，页面显示时才恢复 |
| 2026-05-07 | 审核 | AppGallery UX 测试指出页面 `Scroll` 到顶/到底缺少反馈；ArkUI `Scroll` 默认边界效果是 `None` | 已给首页、清单、提醒、我的、旧通勤页和首次配置页加 `EdgeEffect.Spring` |
