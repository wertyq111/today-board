# Apple 系统风图标统一 + HMS 天气接入执行记录

## 目标

把当前 4 个 Tab 和服务卡片的图标统一为 Apple/Harmony 系统线性符号风，并把天气刷新改成真实 HMS WeatherServiceKit 数据链路。

## 已落地

- 新增 `entry/src/main/ets/common/AppIcon.ets`，统一封装 `SymbolGlyph($r('sys.symbol.*'))`。
- 底部导航、首页轻量信息区、清单项、提醒页、我的页和 `WeatherAnimatedIcon` 已改用 `AppIcon`。
- 当前 4 个 Tab 不再直接散用 `tb_nav_*`、`tb_item_*`、`tb_weather_*`。
- 新增 `entry/src/main/ets/services/WeatherKitProvider.ets`，把 `@kit.WeatherServiceKit` 静态导入隔离在适配模块。
- `WeatherService.refresh()` 先调用 `LocationService.refresh()` 获取真实定位，再动态加载 HMS 天气适配模块。
- HMS 请求范围为 `CURRENT / MINUTE / ALERTS`，成功才写入 `ready`。
- 定位未就绪写 `missing_location`；HMS 能力缺失写 `unavailable`；无网格数据写 `empty`；其他错误写 `error`。
- `WeatherSnapshot` 只新增可选字段 `source / errorCode / observedAt`，不破坏现有页面读取方式。

## 验证

- 根目录执行 `DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk /Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw assembleHap --no-daemon --no-incremental --info` 成功。
- 沙箱内 HDC 仍会报 `Connect server failed`，沙箱外 `hdc list targets` 识别到 `127.0.0.1:5555`。
- 已安装 `entry/build/default/outputs/default/entry-default-unsigned.hap`。
- `aa start -a EntryAbility -b com.palmpet.myapplication` 成功，`pidof com.palmpet.myapplication` 返回进程 `7834`。
- 已通过 HDC 坐标点击清单、提醒、我的 3 个 Tab，切换后进程仍保持运行。
- 已抓取 `/private/tmp/today-board-hms-start.jpeg` 和 `/private/tmp/today-board-hms-profile.jpeg` 核对页面风格和系统符号图标。

## Review 结论

- 当前天气链路不写假温度、不写假雨情，缺定位时保持“等待定位”。
- WeatherServiceKit 导入只在适配模块内出现，入口不会因主路径静态导入直接加载 HMS 天气 HSP。
- 2x2 服务卡片仍需桌面真实添加卡片后做小尺寸溢出检查。
