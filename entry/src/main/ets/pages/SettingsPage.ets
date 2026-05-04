import { AppBottomNav } from '../common/AppBottomNav';
import { AppControlColors, AppControlTone, AppIconTile } from '../common/AppControls';
import { AppIcon, AppIconMapper, AppIconName } from '../common/AppIcon';
import { AppTheme } from '../common/AppTheme';
import { CalendarService } from '../services/CalendarService';
import { LocationService } from '../services/LocationService';
import { WeatherService } from '../services/WeatherService';
import { BoardStore } from '../store/BoardStore';

@Entry
@Component
struct SettingsPage {
  @StorageLink('calendar.permissionState') calendarPermissionState: string = 'unknown';
  @StorageLink('calendar.syncState') calendarSyncState: string = 'idle';
  @StorageLink('calendar.summary') calendarSummary: string = '还没有检查系统日历。';
  @StorageLink('location.permissionState') locationPermissionState: string = 'unknown';
  @StorageLink('location.syncState') locationSyncState: string = 'idle';
  @StorageLink('location.summary') locationSummary: string = '还没有检查定位权限。';
  @StorageLink('weather.syncState') weatherSyncState: string = 'idle';
  @StorageLink('weather.signal') weatherSignal: string = 'unknown';
  @StorageLink('weather.summary') weatherSummary: string = '还没有刷新本地天气。';
  @StorageLink('board.checklistItems') checklistItemsJson: string = '';
  @State toastMessage: string = '';
  private toastToken: number = 0;

  aboutToAppear(): void {
    BoardStore.initialize();
    void this.refreshCalendar(false);
    void this.refreshLocation(false);
    void this.refreshWeather(false);
  }

  private async refreshCalendar(requestPermission: boolean): Promise<void> {
    const hostContext = this.getUIContext().getHostContext();
    if (!hostContext) {
      this.showToast('当前拿不到应用上下文，暂时没法检查日历权限。');
      return;
    }

    await CalendarService.refresh(hostContext, requestPermission);
    if (requestPermission) {
      this.showToast(CalendarService.getSnapshot().summary);
    }
  }

  private async refreshLocation(requestPermission: boolean): Promise<void> {
    const hostContext = this.getUIContext().getHostContext();
    if (!hostContext) {
      this.showToast('当前拿不到应用上下文，暂时没法检查定位权限。');
      return;
    }

    await LocationService.refresh(hostContext, requestPermission);
    if (requestPermission) {
      this.showToast(LocationService.getSnapshot().summary);
    }
  }

  private async refreshWeather(requestLocationPermission: boolean): Promise<void> {
    const hostContext = this.getUIContext().getHostContext();
    if (!hostContext) {
      this.showToast('当前拿不到应用上下文，暂时没法刷新天气。');
      return;
    }

    await WeatherService.refresh(hostContext, requestLocationPermission);
    if (requestLocationPermission) {
      this.showToast(WeatherService.getSnapshot().summary);
    }
  }

  private getCalendarStateText(): string {
    if (this.calendarSyncState === 'ready') {
      return '已接入';
    }
    if (this.calendarPermissionState === 'denied') {
      return '未授权';
    }
    if (this.calendarSyncState === 'empty') {
      return '今天无日程';
    }
    if (this.calendarSyncState === 'error') {
      return '读取失败';
    }
    return '待检查';
  }

  private getLocationStateText(): string {
    if (this.locationSyncState === 'ready') {
      return '已接入';
    }
    if (this.locationPermissionState === 'denied') {
      return '未授权';
    }
    if (this.locationSyncState === 'disabled') {
      return '定位关闭';
    }
    if (this.locationSyncState === 'error') {
      return '读取失败';
    }
    return '待检查';
  }

  private getWeatherStateText(): string {
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
      return '已接入';
    }
    if (this.weatherSyncState === 'missing_location') {
      return '待定位';
    }
    if (this.weatherSyncState === 'unavailable') {
      return '待开通';
    }
    if (this.weatherSyncState === 'empty') {
      return '无数据';
    }
    if (this.weatherSyncState === 'error') {
      return '刷新失败';
    }
    return '待检查';
  }

  private getChecklistCount(): number {
    return BoardStore.getSelectedChecklistItems(this.checklistItemsJson).length;
  }

  private getCalendarTone(): AppControlTone {
    return this.calendarPermissionState === 'denied' || this.calendarSyncState === 'error' ? 'warning' :
      this.calendarSyncState === 'ready' ? 'normal' : 'muted';
  }

  private getLocationTone(): AppControlTone {
    return this.locationPermissionState === 'denied' || this.locationSyncState === 'disabled' ||
      this.locationSyncState === 'error' ? 'warning' : this.locationSyncState === 'ready' ? 'normal' : 'muted';
  }

  private getWeatherTone(): AppControlTone {
    return this.weatherSyncState === 'unavailable' || this.weatherSyncState === 'missing_location' ||
      this.weatherSyncState === 'error' ? 'warning' : this.weatherSyncState === 'ready' ? 'normal' : 'muted';
  }

  private showToast(message: string): void {
    const normalizedMessage = message.trim();
    if (normalizedMessage.length === 0) {
      return;
    }
    const nextToken = this.toastToken + 1;
    this.toastToken = nextToken;
    this.toastMessage = normalizedMessage;
    setTimeout(() => {
      if (this.toastToken === nextToken) {
        this.toastMessage = '';
      }
    }, 2200);
  }

  @Builder
  pageHeader() {
    Column({ space: 8 }) {
      Text('我的')
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.APPLE_TEXT)

      Text('权限、天气来源和出门规则。')
        .fontSize(15)
        .fontColor(AppTheme.APPLE_SECONDARY_TEXT)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 20, right: 20, top: 26, bottom: 8 })
  }

  @Builder
  statusGroup() {
    Column({ space: 0 }) {
      this.statusRow('日历', this.getCalendarStateText(), this.calendarSummary, this.getCalendarTone(), 'calendar',
        true, () => {
          void this.refreshCalendar(true);
        })
      Divider().strokeWidth(1).color(AppTheme.APPLE_LINE).margin({ left: 18 })
      this.statusRow('定位', this.getLocationStateText(), this.locationSummary, this.getLocationTone(), 'location',
        true, () => {
          void this.refreshLocation(true);
        })
      Divider().strokeWidth(1).color(AppTheme.APPLE_LINE).margin({ left: 18 })
      this.statusRow('天气', this.getWeatherStateText(), this.weatherSummary, this.getWeatherTone(),
        AppIconMapper.forWeather(this.weatherSyncState, this.weatherSignal), true, () => {
          void this.refreshWeather(true);
        })
      Divider().strokeWidth(1).color(AppTheme.APPLE_LINE).margin({ left: 18 })
      this.statusRow('清单', `${this.getChecklistCount()} 项`, '已选出门物品。', 'normal', 'checklist', false, () => {})
    }
    .width('100%')
    .backgroundColor(AppTheme.APPLE_SURFACE)
    .borderRadius(AppTheme.CARD_RADIUS)
    .clip(true)
  }

  @Builder
  statusRow(title: string, value: string, detail: string, tone: AppControlTone, iconName: AppIconName,
    canRefresh: boolean, refreshHandler: () => void) {
    Row({ space: 12 }) {
      AppIconTile({ name: iconName, iconSize: 19, tileSize: 32, tone: tone })

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

      Row({ space: 8 }) {
        Text(value)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppControlColors.text(tone))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (canRefresh) {
          Stack({ alignContent: Alignment.Center }) {
            AppIcon({ name: 'refresh', iconSize: 14, color: AppControlColors.text(tone) })
          }
          .width(28)
          .height(28)
          .backgroundColor(AppTheme.APPLE_ACTION_MUTED)
          .borderRadius(14)
          .onClick(() => {
            refreshHandler();
          })
        }
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 15, bottom: 15 })
  }

  @Builder
  toastBanner() {
    Text(this.toastMessage)
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor('#FFFFFF')
      .textAlign(TextAlign.Center)
      .lineHeight(18)
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .backgroundColor('#E61D1D1F')
      .borderRadius(18)
      .shadow({ radius: 18, color: '#30000000', offsetX: 0, offsetY: 8 })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column({ space: 14 }) {
          this.pageHeader()
          this.statusGroup()
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 102 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .backgroundColor(AppTheme.APPLE_BACKGROUND)

      AppBottomNav({ activeTab: 'profile' })

      if (this.toastMessage.length > 0) {
        Row() {
          this.toastBanner()
        }
        .width('100%')
        .padding({ left: 28, right: 28 })
        .position({ x: 0, y: 44 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.APPLE_BACKGROUND)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
