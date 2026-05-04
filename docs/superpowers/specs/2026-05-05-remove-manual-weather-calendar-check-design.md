# 去掉手动天气标签与日历读取确认设计

## 目标

本次只做两件事：

1. 彻底去掉“手动天气标签”的所有产品路径，让天气只来自真实 `WeatherService` / 高德天气链路。
2. 确认系统日历日程是否能在当前设备上读取到，并给出明确状态。

项目仍保持 local-only HarmonyOS NEXT ArkTS 应用，不引入后端，不造假数据。

## 现状

天气当前有两条来源：

- 真实天气：`WeatherService` 通过定位和高德天气写入 `weather.*` 状态。
- 手动天气：`BoardStore` 保存 `board.manualWeatherTag`，首页、“我的”页、提醒页、服务卡片快照和公共天气图标映射会优先使用这个手动值。

日历当前已有真实读取链路：

- `module.json5` 声明 `ohos.permission.READ_CALENDAR`。
- `CalendarService.refresh()` 检查或申请权限。
- 授权后调用 `calendarManager.getCalendarManager()`，读取今天所有日历的事件实例。
- 只取今天尚未结束、非全天的下一条日程。
- 结果写入 `calendar.permissionState`、`calendar.syncState`、`calendar.summary` 等状态。

## 方案选择

采用彻底删除方案：不再保留任何产品可用的手动天气覆盖能力。

不采用隐藏入口但保留逻辑，因为旧的 `board.manualWeatherTag` 可能继续影响首页，造成“看起来是真实天气，实际被本地旧值覆盖”的问题。

不采用开发开关，因为当前产品目标是早晨看真实天气，不需要把调试能力混入产品路径。

## 天气设计

首页天气显示只从真实天气状态推导：

- `weather.syncState === ready` 时，按 `weather.signal`、`weather.condition`、`weather.summary` 显示对应天气、文案和主视觉动画。
- 缺定位、缺配置、接口失败、无数据时，直接显示真实状态，不补默认天气。
- 旧的 `board.manualWeatherTag` 即使还留在用户本机存储里，也不参与首页判断。

“我的”页删除“手动天气标签”整块：

- 删除“不选择、晴天、多云、小雨、中雨”等按钮。
- 删除手动标签当前值展示。
- 天气状态行继续保留，只负责刷新真实天气。

公共图标映射也不再接收手动天气参数，避免手动天气继续影响列表页、提醒页或服务卡片。

`BoardStore.ets` 中的手动天气类型、常量、存储 key、选项数组、保存函数和查询函数都删除。旧本机存储里的 `board.manualWeatherTag` 不迁移、不读取、不清洗；它只是历史残留，产品代码不再引用它。

## 日历读取确认设计

日历链路先不重写，先做真实验证。

验证路径：

1. 安装启动 App。
2. 进入“我的”页。
3. 点击日历行右侧刷新按钮。
4. 如果系统弹日历权限，选择允许。
5. 回到页面读取状态。

可接受结果只有四类：

| 状态 | 含义 |
| --- | --- |
| 已接入 | 已读取到今天尚未结束、非全天的下一条日程 |
| 今天无日程 | 有权限，但今天没有符合条件的后续日程 |
| 未授权 | 用户未授权或系统拒绝读取 |
| 读取失败 | 调用系统日历接口失败 |

日历验收分两个用例：

| 用例 | 前提 | 预期 |
| --- | --- | --- |
| 有未来非全天日程 | 系统日历里存在今天尚未结束、非全天日程，并允许 App 读取日历 | “我的”页日历状态为“已接入”，摘要包含时间和标题；首页日历状态同步显示“已接入” |
| 无未来非全天日程 | 已授权，但今天没有尚未结束、非全天日程 | “我的”页日历状态为“今天无日程”；首页日历状态显示“无日程” |

如果当前设备没有今天的后续日程，不能说“读不到日历”，只能说“权限链路可用，但今天无符合条件日程”。如果要验证读取到具体标题，需要用户在系统日历里创建一条今天未来时间的非全天日程。

## 受影响文件

预计修改：

- `entry/src/main/ets/store/BoardStore.ets`
- `entry/src/main/ets/pages/Index.ets`
- `entry/src/main/ets/pages/SettingsPage.ets`
- `entry/src/main/ets/pages/DiscoverPage.ets`
- `entry/src/main/ets/common/AppIcon.ets`
- `entry/src/main/ets/services/TodayBoardSnapshotService.ets`
- `entry/src/main/ets/components/WeatherAnimatedIcon.ets`
- `.deveco-bootstrap/TodayBoardBootstrap/entry/src/main/ets/**` 对应文件
- `progress.md`
- `findings.md` 如验证发现问题再记录

不修改：

- `CalendarService.ets`，除非真实验证发现接口或状态判断有 bug。
- 天气 MP4/PNG 资源。
- 后端或远端配置。

## 验收标准

天气：

- “我的”页不再出现“手动天气标签”区域。
- 首页不再读取或显示手动天气文案。
- 全局搜索不再有产品路径使用 `board.manualWeatherTag`。
- 真实天气不可用时，页面显示真实失败/待定位/无数据状态。

日历：

- 构建成功。
- 安装启动成功。
- 点击日历刷新后，页面显示明确状态。
- 如果设备授权且有今天未来非全天日程，首页日历状态应进入“已接入”。
- 如果授权但没有符合条件日程，页面显示“今天无日程”。

## 验证命令

```bash
DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk /Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw assembleHap --no-daemon --no-incremental --info
```

DevEco 当前打开 `.deveco-bootstrap/TodayBoardBootstrap` 时，根目录和 bootstrap 都要构建，并用 bootstrap HAP 安装到设备验收。

## 已知限制

当前项目不是 git 仓库，设计文档不能提交 commit，只能保存到项目文件。
