import { AppBottomNav } from '../common/AppBottomNav';
import { AppIcon, AppIconName } from '../common/AppIcon';
import { AppRoute } from '../common/AppRoute';
import { AppTheme } from '../common/AppTheme';
import { CommuteDecisionEngine, CommuteDecisionResult, WeatherSignal } from '../domain/CommuteDecisionEngine';
import { CommuteOption, SetupStore } from '../store/SetupStore';

@Entry
@Component
struct CommuteOptionsPage {
  @StorageLink('setup.homeAddress') homeAddress: string = '';
  @StorageLink('setup.officeAddress') officeAddress: string = '';
  @StorageLink('setup.workStartTime') workStartTime: string = SetupStore.DEFAULT_WORK_START_TIME;
  @StorageLink('setup.checklistText') checklistText: string = SetupStore.DEFAULT_CHECKLIST_TEXT;
  @StorageLink('setup.commuteOptionsJson') commuteOptionsJson: string = SetupStore.DEFAULT_COMMUTE_OPTIONS_JSON;
  @StorageLink('setup.completed') setupCompleted: boolean = false;
  @StorageLink('calendar.syncState') calendarSyncState: string = 'idle';
  @StorageLink('calendar.targetTime') calendarTargetTime: string = '';
  @StorageLink('weather.signal') weatherSignal: string = 'unknown';

  private getPageRouter() {
    return this.getUIContext().getRouter();
  }

  private getCommuteOptions(): CommuteOption[] {
    try {
      const parsed = JSON.parse(this.commuteOptionsJson) as CommuteOption[];
      if (Array.isArray(parsed) && parsed.length > 0) {
        return parsed;
      }
    } catch (error) {
      console.error(`Failed to parse commute options: ${JSON.stringify(error)}`);
    }
    return SetupStore.getCommuteOptions();
  }

  private getChecklistItems(): string[] {
    return SetupStore.normalizeChecklistText(this.checklistText)
      .split(',')
      .map((item: string) => item.trim())
      .filter((item: string) => item.length > 0);
  }

  private getCurrentTime(): string {
    const now = new Date();
    return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
  }

  private getTargetArrivalTime(): string {
    return this.calendarSyncState === 'ready' && this.calendarTargetTime.length > 0 ? this.calendarTargetTime :
      this.workStartTime;
  }

  private getWeatherSignal(): WeatherSignal {
    return this.weatherSignal === 'clear' || this.weatherSignal === 'rain_soon' ? this.weatherSignal : 'unknown';
  }

  private getDecisionResult(): CommuteDecisionResult {
    return CommuteDecisionEngine.decide({
      currentTime: this.getCurrentTime(),
      targetArrivalTime: this.getTargetArrivalTime(),
      commuteOptions: this.getCommuteOptions(),
      checklistItems: this.getChecklistItems(),
      weatherSignal: this.getWeatherSignal(),
      hasCalendarData: this.calendarSyncState === 'ready'
    });
  }

  private hasRouteConfig(): boolean {
    return this.setupCompleted && this.homeAddress.trim().length > 0 && this.officeAddress.trim().length > 0;
  }

  private getFastestOption(): CommuteOption {
    return [...this.getCommuteOptions()].sort((left: CommuteOption, right: CommuteOption) =>
      left.durationMinutes - right.durationMinutes)[0];
  }

  private getCheapestOption(): CommuteOption {
    return [...this.getCommuteOptions()].sort((left: CommuteOption, right: CommuteOption) =>
      left.costYuan - right.costYuan)[0];
  }

  private getDisplayedRecommendationLabel(): string {
    return this.hasRouteConfig() ? this.getDecisionResult().recommendedOption.label : '待配置';
  }

  private getDisplayedLeaveTime(): string {
    return this.hasRouteConfig() ? this.getDecisionResult().leaveTime : '--';
  }

  private getDisplayedDuration(): string {
    return this.hasRouteConfig() ? `${this.getDecisionResult().recommendedOption.durationMinutes}` : '--';
  }

  private getDisplayedCost(): string {
    return this.hasRouteConfig() ? `${this.getDecisionResult().recommendedOption.costYuan}` : '--';
  }

  private getStatusText(): string {
    if (!this.hasRouteConfig()) {
      return '先配置家和公司地址，行程页才显示真实通勤判断。';
    }
    return this.getDecisionResult().summary;
  }

  @Builder
  cloudBlob(widthValue: number, heightValue: number, xValue: Length, yValue: Length, color: string, blurRadius: number) {
    Text('')
      .width(widthValue)
      .height(heightValue)
      .backgroundColor(color)
      .borderRadius(heightValue / 2)
      .blur(blurRadius)
      .position({ x: xValue, y: yValue })
  }

  @Builder
  weatherBackdrop() {
    Stack() {
      Text('')
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [[AppTheme.FROST_PAGE_TOP, 0], [AppTheme.FROST_PAGE_MID, 0.42], [AppTheme.FROST_PAGE_BOTTOM, 1]]
        })

      Text('')
        .width('108%')
        .height(360)
        .linearGradient({
          angle: 180,
          colors: [['#00FFFFFF', 0], ['#46D9F1FF', 0.58], ['#88EEF9FF', 1]]
        })
        .position({ x: '-4%', y: 154 })

      this.cloudBlob(300, 98, '-18%', 34, AppTheme.FROST_CLOUD_WHITE, 16)
      this.cloudBlob(236, 78, '46%', 58, '#7FE9F8FF', 14)
      this.cloudBlob(340, 112, '-26%', 420, '#50E8F4FF', 24)
      this.cloudBlob(190, 72, '65%', 500, '#67BCE6E8', 18)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  glassPanel() {
    Column({ space: 8 }) {
      Row() {
        Column({ space: 4 }) {
          Text('今日通勤行程')
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.FROST_PRIMARY_TEXT)

          Text(`目标到达 ${this.getTargetArrivalTime()} · ${this.hasRouteConfig() ? '本机路线配置' : '路线未完成'}`)
            .fontSize(11)
            .fontColor(AppTheme.FROST_SECONDARY_TEXT)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        AppIcon({
          name: 'calendar',
          iconSize: 52,
          color: AppTheme.FROST_PRIMARY_TEXT
        })
      }
      .width('100%')

      Row() {
        this.heroMetric('推荐', this.getDisplayedRecommendationLabel(), AppTheme.FROST_ACCENT_BLUE)
        Divider().vertical(true).height(38).strokeWidth(1).color(AppTheme.FROST_GLASS_BORDER)
        this.heroMetric('出发', this.getDisplayedLeaveTime(), AppTheme.FROST_GREEN)
        Divider().vertical(true).height(38).strokeWidth(1).color(AppTheme.FROST_GLASS_BORDER)
        this.heroMetric('耗时', this.getDisplayedDuration(), AppTheme.FROST_ORANGE, this.hasRouteConfig() ? '分钟' : '')
      }
      .width('100%')
      .padding(10)
      .backgroundColor(AppTheme.FROST_GLASS_MUTED_BACKGROUND)
      .backgroundBlurStyle(BlurStyle.Thin)
      .border({ width: 1, color: AppTheme.FROST_GLASS_BORDER })
      .borderRadius(22)

      Text(this.getStatusText())
        .width('100%')
        .fontSize(11)
        .fontColor(AppTheme.FROST_PRIMARY_TEXT)
        .lineHeight(17)
        .padding({ left: 4, right: 4 })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(AppTheme.FROST_GLASS_BACKGROUND)
    .backgroundBlurStyle(BlurStyle.Thin)
    .border({ width: 1, color: AppTheme.FROST_GLASS_BORDER })
    .borderRadius(AppTheme.HERO_RADIUS)
    .shadow({ radius: 14, color: AppTheme.FROST_SHADOW, offsetX: 0, offsetY: 6 })
  }

  @Builder
  heroMetric(label: string, value: string, color: string, suffix?: string) {
    Column({ space: 3 }) {
      Text(label)
        .fontSize(AppTheme.MINI_SIZE)
        .fontColor(AppTheme.FROST_SECONDARY_TEXT)
        .maxLines(1)

      Row({ space: 3 }) {
        Text(value)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(suffix ?? '')
          .fontSize(AppTheme.MINI_SIZE)
          .fontColor(AppTheme.FROST_SECONDARY_TEXT)
          .margin({ top: 5 })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  summaryStrip() {
    Row({ space: 8 }) {
      this.summaryPill('方案数', `${this.getCommuteOptions().length}`, 'serviceCard')
      this.summaryPill('最快', this.getFastestOption().label, 'location')
      this.summaryPill('最低费用', `${this.getCheapestOption().costYuan} 元`, 'wallet')
    }
    .width('100%')
  }

  @Builder
  summaryPill(label: string, value: string, iconName: AppIconName) {
    Row({ space: 6 }) {
      AppIcon({
        name: iconName,
        iconSize: 34,
        color: AppTheme.FROST_PRIMARY_TEXT
      })
        .width(46)
        .height(46)

      Column({ space: 1 }) {
        Text(label)
          .fontSize(9)
          .fontColor(AppTheme.FROST_SECONDARY_TEXT)
        Text(value)
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.FROST_PRIMARY_TEXT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1)
    .height(70)
    .padding({ left: 8, right: 8 })
    .backgroundColor(AppTheme.FROST_GLASS_BACKGROUND)
    .backgroundBlurStyle(BlurStyle.Thin)
    .border({ width: 1, color: AppTheme.FROST_GLASS_BORDER })
    .borderRadius(18)
  }

  @Builder
  optionCard(option: CommuteOption) {
    Column({ space: 10 }) {
      Row() {
        Row({ space: 8 }) {
          AppIcon({
            name: this.getOptionIcon(option.id),
            iconSize: 48,
            color: AppTheme.FROST_PRIMARY_TEXT
          })
            .width(72)
            .height(72)

          Column({ space: 3 }) {
            Text(option.label)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppTheme.FROST_PRIMARY_TEXT)

            Text(option.note)
              .fontSize(10)
              .fontColor(AppTheme.FROST_SECONDARY_TEXT)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)

        Text(option.id === this.getDecisionResult().recommendedOption.id && this.hasRouteConfig() ? '推荐' : '方案')
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor(option.id === this.getDecisionResult().recommendedOption.id && this.hasRouteConfig() ?
            AppTheme.FROST_GREEN : AppTheme.FROST_ACCENT_BLUE)
          .borderRadius(AppTheme.CHIP_RADIUS)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      }
      .width('100%')

      Row() {
        this.optionMetric('预计耗时', `${option.durationMinutes}`, '分钟')
        Divider().vertical(true).height(28).strokeWidth(1).color(AppTheme.FROST_GLASS_BORDER)
        this.optionMetric('预计费用', `${option.costYuan}`, '元')
        Divider().vertical(true).height(28).strokeWidth(1).color(AppTheme.FROST_GLASS_BORDER)
        this.optionMetric('建议出发',
          SetupStore.calculateLeaveTime(this.getTargetArrivalTime(), option.durationMinutes,
            CommuteDecisionEngine.LEAVE_BUFFER_MINUTES), '')
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })
      .backgroundColor(AppTheme.FROST_GLASS_MUTED_BACKGROUND)
      .backgroundBlurStyle(BlurStyle.Thin)
      .border({ width: 1, color: AppTheme.FROST_GLASS_BORDER })
      .borderRadius(18)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(AppTheme.FROST_GLASS_BACKGROUND)
    .backgroundBlurStyle(BlurStyle.Thin)
    .border({ width: 1, color: AppTheme.FROST_GLASS_BORDER })
    .borderRadius(AppTheme.CARD_RADIUS)
    .shadow({ radius: 7, color: AppTheme.FROST_SHADOW, offsetX: 0, offsetY: 3 })
  }

  @Builder
  optionMetric(label: string, value: string, suffix: string) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(9)
        .fontColor(AppTheme.FROST_SECONDARY_TEXT)
        .maxLines(1)

      Row({ space: 3 }) {
        Text(value)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.FROST_PRIMARY_TEXT)
          .maxLines(1)

        Text(suffix)
          .fontSize(9)
          .fontColor(AppTheme.FROST_SECONDARY_TEXT)
          .margin({ top: 5 })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  private getOptionIcon(optionId: string): AppIconName {
    if (optionId === 'taxi') {
      return 'location';
    }
    if (optionId === 'subway') {
      return 'serviceCard';
    }
    if (optionId === 'bus_walk') {
      return 'home';
    }
    return 'calendar';
  }

  @Builder
  setupHint() {
    if (!this.hasRouteConfig()) {
      Row({ space: 8 }) {
        Text('!')
          .width(18)
          .height(18)
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .backgroundColor(AppTheme.FROST_ORANGE)
          .borderRadius(9)

        Text('缺少家或公司地址，先完成设置后再计算今日行程。')
          .layoutWeight(1)
          .fontSize(11)
          .fontColor(AppTheme.FROST_PRIMARY_TEXT)

        Text('去配置 >')
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.FROST_ACCENT_BLUE)
      }
      .width('100%')
      .padding(10)
      .backgroundColor('#66FFF8E7')
      .backgroundBlurStyle(BlurStyle.Thin)
      .border({ width: 1, color: AppTheme.FROST_GLASS_BORDER })
      .borderRadius(18)
      .onClick(async () => {
        await this.getPageRouter().pushUrl({ url: AppRoute.SETTINGS });
      })
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      this.weatherBackdrop()

      Scroll() {
        Column({ space: 8 }) {
          this.glassPanel()
          this.summaryStrip()
          this.setupHint()
          ForEach(this.getCommuteOptions(), (option: CommuteOption) => {
            this.optionCard(option)
          })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 12, bottom: 116 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .backgroundColor('#00000000')

      AppBottomNav({ activeTab: 'home' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.FROST_PAGE_BOTTOM)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
