# Apple 发布会风改版执行记录

## 目标

把天气看门板从蓝天毛玻璃改成“首页 Apple 发布会海报感，其他页面 Apple 系统工具感”。

## 设计规则

- 根目录 `awesome-design-md` 只作为来源索引；本项目规则落在 `DESIGN.md`。
- 首页使用黑底、超大标题、短结论、Apple Blue 操作色和生成主视觉。
- 清单、提醒、我的使用 `#f5f5f7` 背景、白色列表块、低阴影、清楚状态文案。
- 数据保持 local-only：不新增后端、不新增 mock、不伪造天气或日历。
- 底部导航固定在底部，黑色紧凑样式，避免继续扩大卡通感。

## 已落地

- `entry/src/main/ets/common/AppTheme.ets` 收敛 Apple 色板、字号、圆角、阴影。
- `entry/src/main/ets/pages/Index.ets` 改为黑底发布会首屏和轻量信息区。
- `entry/src/main/ets/pages/ChecklistPage.ets`、`DiscoverPage.ets`、`SettingsPage.ets` 改为系统工具页。
- `entry/src/main/ets/common/AppBottomNav.ets` 改为紧凑黑色固定底栏。
- `entry/src/main/ets/widget/pages/TodayBoardCard.ets` 改为黑白主结论服务卡片。
- `entry/src/main/resources/base/media/tb_apple_hero.png` 新增发布会主视觉资源。

## 验证

- DevEco bootstrap `assembleHap --no-daemon --no-incremental --info` 成功。
- HDC 安装、启动成功。
- 已点击验证看板、清单、提醒、我的 4 个 Tab 可达。
- 首页截图检查后修正了摘要区与底栏重叠、底栏透出文字的问题。

## 剩余风险

- 2x2 服务卡片已构建通过，但本轮未在桌面真实添加卡片验证。
- Weather Service Kit 在当前设备仍不可用，页面继续暴露真实不可用状态。
