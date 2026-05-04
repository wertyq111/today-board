import { AppBottomNav } from '../common/AppBottomNav';
import { AppControlTone, AppIconTile } from '../common/AppControls';
import { AppIconMapper, AppIconName } from '../common/AppIcon';
import { AppRoute } from '../common/AppRoute';
import { AppTheme } from '../common/AppTheme';
import { BoardStore } from '../store/BoardStore';

@Entry
@Component
struct DiscoverPage {
  @StorageLink('board.checklistItems') checklistItemsJson: string = '';
  @StorageLink('weather.syncState') weatherSyncState: string = 'idle';
  @StorageLink('weather.signal') weatherSignal: string = 'unknown';
  @StorageLink('weather.summary') weatherSummary: string = '还没有刷新本地天气。';
  @StorageLink('calendar.syncState') calendarSyncState: string = 'idle';
  @StorageLink('calendar.summary') calendarSummary: string = '还没有检查系统日历。';

  private getPageRouter() {
    return this.getUIContext().getRouter();
  }

  private getChecklistCount(): number {
    return BoardStore.getSelectedChecklistItems(this.checklistItemsJson).length;
  }

  private getWeatherTitle(): string {
    if (this.weatherSyncState === 'ready') {
      if (this.weatherSignal === 'rain_soon' || this.weatherSignal === 'rainy') {
        return '有降雨';
      }
      if (this.weatherSignal === 'snowy') {
        return '有降雪';
      }
      if (this.weatherSignal === 'sunny' || this.weatherSignal === 'clear') {
        return '晴天';
      }
      if (this.weatherSignal === 'cloudy') {
        return '云天';
      }
      return '天气已接入';
    }
    if (this.weatherSyncState === 'missing_location') {
      return '等待定位';
    }
    if (this.weatherSyncState === 'unavailable') {
      return '天气待开通';
    }
    if (this.weatherSyncState === 'empty') {
      return '暂无天气数据';
    }
    if (this.weatherSyncState === 'error') {
      return '天气刷新失败';
    }
    return '天气待接入';
  }

  private getWeatherDetail(): string {
    return this.weatherSummary.trim().length > 0 ? this.weatherSummary : '没有真实天气结果时，这里只显示待接入状态。';
  }

  private getRuleTone(highlighted: boolean): AppControlTone {
    return highlighted ? 'normal' : 'muted';
  }

  @Builder
  pageHeader() {
    Column({ space: 8 }) {
      Text('提醒')
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.APPLE_TEXT)

      Text('天气、日程和清单规则集中看。')
        .fontSize(15)
        .fontColor(AppTheme.APPLE_SECONDARY_TEXT)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 20, right: 20, top: 26, bottom: 8 })
  }

  @Builder
  primaryRule() {
    Column({ space: 10 }) {
      AppIconTile({
        name: AppIconMapper.forWeather(this.weatherSyncState, this.weatherSignal),
        iconSize: 24,
        tileSize: 42,
        tone: 'normal'
      })

      Text('当前主提醒')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.APPLE_SECONDARY_TEXT)

      Text(this.getWeatherTitle())
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.APPLE_TEXT)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(this.getWeatherDetail())
        .fontSize(14)
        .fontColor(AppTheme.APPLE_SECONDARY_TEXT)
        .lineHeight(21)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(20)
    .backgroundColor(AppTheme.APPLE_SURFACE)
    .borderRadius(AppTheme.CARD_RADIUS)
  }

  @Builder
  ruleGroup() {
    Column({ space: 0 }) {
      this.ruleRow('天气提醒', this.getWeatherTitle(), this.getWeatherDetail(), AppRoute.SETTINGS, true,
        AppIconMapper.forWeather(this.weatherSyncState, this.weatherSignal))
      Divider().strokeWidth(1).color(AppTheme.APPLE_LINE).margin({ left: 18 })
      this.ruleRow('清单规则', `${this.getChecklistCount()} 项必带`, '天气可用后，再按天气状态追加提醒。', AppRoute.CHECKLIST, false, 'checklist')
      Divider().strokeWidth(1).color(AppTheme.APPLE_LINE).margin({ left: 18 })
      this.ruleRow('日历信号', this.calendarSyncState === 'ready' ? '已读取' : '待检查', this.calendarSummary, AppRoute.SETTINGS, false, 'calendar')
      Divider().strokeWidth(1).color(AppTheme.APPLE_LINE).margin({ left: 18 })
      this.ruleRow('服务卡片', '复用首页结论', '桌面 2x2 卡片和首页使用同一套真实状态。', AppRoute.SETTINGS, false, 'serviceCard')
    }
    .width('100%')
    .backgroundColor(AppTheme.APPLE_SURFACE)
    .borderRadius(AppTheme.CARD_RADIUS)
    .clip(true)
  }

  @Builder
  ruleRow(title: string, value: string, detail: string, route: string, highlighted: boolean, iconName: AppIconName) {
    Row({ space: 12 }) {
      AppIconTile({
        name: iconName,
        iconSize: 19,
        tileSize: 32,
        tone: this.getRuleTone(highlighted)
      })

      Column({ space: 5 }) {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.APPLE_TEXT)

        Text(detail)
          .fontSize(12)
          .fontColor(AppTheme.APPLE_SECONDARY_TEXT)
          .lineHeight(18)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(value)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(highlighted ? AppTheme.APPLE_TEXT : AppTheme.APPLE_SECONDARY_TEXT)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 16, bottom: 16 })
    .onClick(async () => {
      await this.getPageRouter().pushUrl({ url: route });
    })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column({ space: 14 }) {
          this.pageHeader()
          this.primaryRule()
          this.ruleGroup()
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 102 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .backgroundColor(AppTheme.APPLE_BACKGROUND)

      AppBottomNav({ activeTab: 'reminders' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.APPLE_BACKGROUND)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
