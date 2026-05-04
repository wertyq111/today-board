# 天气看门板

天气看门板是一个 HarmonyOS NEXT 离线优先应用。它把真实天气、本机日历和出门清单放在一个看板里，帮助用户早晨快速确认今天要注意什么、要带什么。

## 功能

- 首页天气看板：展示真实天气、日历状态和出门清单。
- 出门清单：本机保存常用出门物品。
- 提醒页：汇总天气、日历、清单和服务卡片状态。
- 我的页：检查日历、定位、天气和清单状态。
- 服务卡片：提供 2x2 桌面卡片。

## 技术栈

- HarmonyOS NEXT
- Stage 模型
- ArkTS
- ArkUI
- 本机持久化存储

## 本地构建

仓库不会提交真实高德 Key，默认配置为空。需要真实地图 / 天气能力时，在应用设置里配置 Key，或只在本机维护未提交配置。

```bash
DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk \
/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw assembleHap --no-daemon --no-incremental --info
```

构建产物位于：

```text
entry/build/default/outputs/default/
```

## 发布信息

AppGallery Connect 基础信息见：

```text
docs/release/appgallery-basic-info.md
```

当前发布包名：

```text
com.zhouxufeng.todayboard
```

## 本机文件

以下文件不会进入仓库：

- DevEco 临时工程和构建缓存
- 本机配置文件
- 天气 / 地图 Key
- 设备截图和生成物
- `project-config.json` / `project-info.json`
