import { AppBottomNav } from '../common/AppBottomNav';
import { AppIcon, AppIconName } from '../common/AppIcon';
import { AppRoute } from '../common/AppRoute';
import { AppTheme } from '../common/AppTheme';
import { CalendarService } from '../services/CalendarService';
import { WeatherService } from '../services/WeatherService';
import { BoardStore, ChecklistItem } from '../store/BoardStore';

@Entry
@Component
struct Index {
  @StorageLink('board.checklistItems') checklistItemsJson: string = '';
  @StorageLink('calendar.syncState') calendarSyncState: string = 'idle';
  @StorageLink('calendar.summary') calendarSummary: string = '还没有检查系统日历。';
  @StorageLink('weather.syncState') weatherSyncState: string = 'idle';
  @StorageLink('weather.signal') weatherSignal: string = 'unknown';
  @StorageLink('weather.temperature') weatherTemperature: string = '';
  @StorageLink('weather.condition') weatherCondition: string = '';
  @StorageLink('weather.summary') weatherSummary: string = '还没有刷新本地天气。';
  @State summaryCardActive: boolean = false;
  @State checklistCardActive: boolean = false;
  @State pageVisible: boolean = true;
  private weatherHeroVideoController: VideoController = new VideoController();

  aboutToAppear(): void {
    const hostContext = this.getUIContext().getHostContext();
    BoardStore.initialize(hostContext);
    void this.refreshCalendar(false);
    void this.refreshWeather(false);
  }

  onPageShow(): void {
    this.pageVisible = true;
    if (this.shouldUseWeatherHeroVideo()) {
      this.weatherHeroVideoController.start();
    }
  }

  onPageHide(): void {
    this.pageVisible = false;
    this.weatherHeroVideoController.stop();
  }

  private getPageRouter() {
    return this.getUIContext().getRouter();
  }

  private async refreshCalendar(requestPermission: boolean): Promise<void> {
    const hostContext = this.getUIContext().getHostContext();
    if (!hostContext) {
      console.error('Failed to get host context when refreshing calendar.');
      return;
    }
    await CalendarService.refresh(hostContext, requestPermission);
  }

  private async refreshWeather(requestLocationPermission: boolean): Promise<void> {
    const hostContext = this.getUIContext().getHostContext();
    if (!hostContext) {
      console.error('Failed to get host context when refreshing weather.');
      return;
    }
    await WeatherService.refresh(hostContext, requestLocationPermission);
  }

  private getSelectedChecklistItems(): ChecklistItem[] {
    return BoardStore.getSelectedChecklistItems(this.checklistItemsJson);
  }

  private getWeatherSignal(): string {
    const visualSignal = this.getWeatherVisualSignal();
    if (visualSignal === 'rainy') {
      return 'rain_soon';
    }
    if (visualSignal === 'sunny') {
      return 'clear';
    }
    return visualSignal;
  }

  private getWeatherVisualSignal(): string {
    if (this.weatherSyncState === 'ready') {
      if (this.weatherSignal === 'clear' || this.weatherSignal === 'sunny') {
        return 'sunny';
      }
      if (this.weatherSignal === 'rain_soon' || this.weatherSignal === 'rainy') {
        return 'rainy';
      }
      if (this.weatherSignal === 'snowy') {
        return 'snowy';
      }
      if (this.weatherSignal === 'cloudy') {
        return 'cloudy';
      }
    }
    const summarySignal = this.getWeatherSummarySignal();
    if (summarySignal !== 'unknown') {
      return summarySignal;
    }
    return 'unknown';
  }

  private getWeatherSummarySignal(): string {
    const source = `${this.weatherCondition} ${this.weatherSummary}`;
    if (source.includes('雪')) {
      return 'snowy';
    }
    if (source.includes('雨') || source.includes('阵雨') || source.includes('雷')) {
      return 'rainy';
    }
    if (source.includes('晴')) {
      return 'sunny';
    }
    if (source.includes('阴') || source.includes('云') || source.includes('雾') || source.includes('霾') ||
      source.includes('沙') || source.includes('尘')) {
      return 'cloudy';
    }
    return 'unknown';
  }

  private getWeatherSummaryCondition(): string {
    const condition = this.weatherCondition.trim();
    if (condition.length > 0) {
      return condition;
    }

    const summary = this.weatherSummary.trim();
    const degreeIndex = summary.indexOf('°C');
    if (degreeIndex <= 0) {
      return '';
    }
    const beforeTemperature = summary.substring(0, degreeIndex).trim();
    const parts = beforeTemperature.split(' ');
    if (parts.length >= 2) {
      return parts[parts.length - 2];
    }
    return '';
  }

  private getWeatherHeroSourceText(): string {
    const condition = this.getWeatherSummaryCondition();
    return `${condition} ${this.weatherCondition} ${this.weatherSummary}`;
  }

  private getWeatherHeroKey(): string {
    const source = this.getWeatherHeroSourceText();
    const temperature = Number.parseFloat(this.weatherTemperature.trim());

    if (source.includes('雷暴')) {
      return 'severe_thunderstorm';
    }
    if (source.includes('雷阵雨') || source.includes('雷雨')) {
      return 'thunder_shower';
    }
    if (source.includes('暴雪')) {
      return 'blizzard';
    }
    if (source.includes('大雪')) {
      return 'heavy_snow';
    }
    if (source.includes('中雪')) {
      return 'moderate_snow';
    }
    if (source.includes('小雪')) {
      return 'light_snow';
    }
    if (source.includes('雨夹雪')) {
      return 'sleet';
    }
    if (source.includes('大雨') || source.includes('暴雨')) {
      return 'heavy_rain';
    }
    if (source.includes('中雨')) {
      return 'moderate_rain';
    }
    if (source.includes('小雨') || source.includes('雨')) {
      return 'light_rain';
    }
    if (source.includes('沙尘') || source.includes('扬沙') || source.includes('浮尘')) {
      return 'dust_storm';
    }
    if (source.includes('大雾') || source.includes('浓雾') || source.includes('强浓雾')) {
      return 'dense_fog';
    }
    if (source.includes('雾') || source.includes('霾')) {
      return 'haze';
    }
    if (source.includes('阴')) {
      return 'overcast';
    }
    if (source.includes('多云') || source.includes('云')) {
      return 'cloudy';
    }
    if (source.includes('晴')) {
      if (!Number.isNaN(temperature) && temperature >= 40) {
        return 'extreme_hot_sunny';
      }
      return 'sunny';
    }
    return 'apple';
  }

  private getWeatherHeroImage(): Resource {
    switch (this.getWeatherHeroKey()) {
      case 'sunny':
        return $r('app.media.tb_weather_hero_sunny');
      case 'cloudy':
        return $r('app.media.tb_weather_hero_cloudy');
      case 'overcast':
        return $r('app.media.tb_weather_hero_overcast');
      case 'light_rain':
        return $r('app.media.tb_weather_hero_light_rain');
      case 'moderate_rain':
        return $r('app.media.tb_weather_hero_moderate_rain');
      case 'heavy_rain':
        return $r('app.media.tb_weather_hero_heavy_rain');
      case 'thunder_shower':
        return $r('app.media.tb_weather_hero_thunder_shower');
      case 'severe_thunderstorm':
        return $r('app.media.tb_weather_hero_severe_thunderstorm');
      case 'light_snow':
        return $r('app.media.tb_weather_hero_light_snow');
      case 'moderate_snow':
        return $r('app.media.tb_weather_hero_moderate_snow');
      case 'heavy_snow':
        return $r('app.media.tb_weather_hero_heavy_snow');
      case 'blizzard':
        return $r('app.media.tb_weather_hero_blizzard');
      case 'sleet':
        return $r('app.media.tb_weather_hero_sleet');
      case 'haze':
        return $r('app.media.tb_weather_hero_haze');
      case 'dense_fog':
        return $r('app.media.tb_weather_hero_dense_fog');
      case 'dust_storm':
        return $r('app.media.tb_weather_hero_dust_storm');
      case 'extreme_hot_sunny':
        return $r('app.media.tb_weather_hero_extreme_hot_sunny');
      default:
        return $r('app.media.tb_apple_hero');
    }
  }

  private shouldUseWeatherHeroVideo(): boolean {
    return this.getWeatherHeroKey() !== 'apple';
  }

  private getWeatherHeadline(): string {
    if (this.weatherSyncState === 'ready') {
      const visualSignal = this.getWeatherVisualSignal();
      if (visualSignal === 'rainy') {
        return '有降雨';
      }
      if (visualSignal === 'snowy') {
        return '有降雪';
      }
      if (visualSignal === 'sunny') {
        return '晴天';
      }
      if (visualSignal === 'cloudy') {
        return '多云';
      }
      return '天气已接入';
    }
    if (this.weatherSyncState === 'unavailable') {
      return '天气待开通';
    }
    if (this.weatherSyncState === 'empty') {
      return '暂无天气数据';
    }
    if (this.weatherSyncState === 'missing_location') {
      return '等待定位';
    }
    if (this.weatherSyncState === 'error') {
      return '天气刷新失败';
    }
    const visualSignal = this.getWeatherVisualSignal();
    if (visualSignal === 'rainy') {
      return '有降雨';
    }
    if (visualSignal === 'snowy') {
      return '有降雪';
    }
    if (visualSignal === 'sunny') {
      return '晴天';
    }
    if (visualSignal === 'cloudy') {
      return '多云';
    }
    return '天气待接入';
  }

  private getWeatherCaption(): string {
    return this.weatherSummary.trim().length > 0 ? this.weatherSummary : '没有真实天气数据时不显示假温度。';
  }

  private getWeatherDisplayValue(): string {
    const summaryCondition = this.getWeatherSummaryCondition();
    if (summaryCondition.length > 0) {
      return summaryCondition;
    }
    if (this.weatherTemperature.trim().length > 0) {
      return `${this.weatherTemperature.trim()}°C`;
    }
    if (this.weatherSyncState === 'ready') {
      return this.getWeatherHeadline();
    }
    if (this.weatherSyncState === 'unavailable') {
      return '待开通';
    }
    if (this.weatherSyncState === 'missing_location') {
      return '待定位';
    }
    if (this.weatherSyncState === 'error') {
      return '失败';
    }
    if (this.weatherSyncState === 'empty') {
      return '无数据';
    }
    const visualSignal = this.getWeatherVisualSignal();
    if (visualSignal === 'sunny') {
      return '晴';
    }
    if (visualSignal === 'rainy') {
      return '雨';
    }
    if (visualSignal === 'snowy') {
      return '雪';
    }
    if (visualSignal === 'cloudy') {
      return '多云';
    }
    return '待接入';
  }

  private getCalendarDisplayText(): string {
    if (this.calendarSyncState === 'ready') {
      return '已接入';
    }
    if (this.calendarSyncState === 'empty') {
      return '无日程';
    }
    if (this.calendarSyncState === 'error') {
      return '读取失败';
    }
    return '待检查';
  }

  private getChecklistIcon(item: ChecklistItem): AppIconName {
    return item.icon;
  }

  @Builder
  weatherHeroVideo(source: Resource) {
    Video({
      src: source,
      previewUri: this.getWeatherHeroImage(),
      controller: this.weatherHeroVideoController
    })
      .width('100%')
      .height(420)
      .objectFit(ImageFit.Cover)
      .autoPlay(this.pageVisible)
      .muted(true)
      .loop(true)
      .controls(false)
      .opacity(0.98)
      .position({ x: 0, y: 0 })
  }

  @Builder
  weatherHeroVideoForKey() {
    if (this.getWeatherHeroKey() === 'sunny') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_sunny.mp4'))
    } else if (this.getWeatherHeroKey() === 'cloudy') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_cloudy.mp4'))
    } else if (this.getWeatherHeroKey() === 'overcast') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_overcast.mp4'))
    } else if (this.getWeatherHeroKey() === 'light_rain') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_light_rain.mp4'))
    } else if (this.getWeatherHeroKey() === 'moderate_rain') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_moderate_rain.mp4'))
    } else if (this.getWeatherHeroKey() === 'heavy_rain') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_heavy_rain.mp4'))
    } else if (this.getWeatherHeroKey() === 'thunder_shower') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_thunder_shower.mp4'))
    } else if (this.getWeatherHeroKey() === 'severe_thunderstorm') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_severe_thunderstorm.mp4'))
    } else if (this.getWeatherHeroKey() === 'light_snow') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_light_snow.mp4'))
    } else if (this.getWeatherHeroKey() === 'moderate_snow') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_moderate_snow.mp4'))
    } else if (this.getWeatherHeroKey() === 'heavy_snow') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_heavy_snow.mp4'))
    } else if (this.getWeatherHeroKey() === 'blizzard') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_blizzard.mp4'))
    } else if (this.getWeatherHeroKey() === 'sleet') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_sleet.mp4'))
    } else if (this.getWeatherHeroKey() === 'haze') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_haze.mp4'))
    } else if (this.getWeatherHeroKey() === 'dense_fog') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_dense_fog.mp4'))
    } else if (this.getWeatherHeroKey() === 'dust_storm') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_dust_storm.mp4'))
    } else if (this.getWeatherHeroKey() === 'extreme_hot_sunny') {
      this.weatherHeroVideo($rawfile('tb_weather_hero_extreme_hot_sunny.mp4'))
    } else {
      Image(this.getWeatherHeroImage())
        .width('100%')
        .height(420)
        .objectFit(ImageFit.Cover)
        .opacity(0.98)
        .position({ x: 0, y: 0 })
    }
  }

  @Builder
  heroMedia() {
    if (this.shouldUseWeatherHeroVideo()) {
      this.weatherHeroVideoForKey()
    } else {
      Image(this.getWeatherHeroImage())
        .width('100%')
        .height(420)
        .objectFit(ImageFit.Cover)
        .opacity(0.98)
        .position({ x: 0, y: 0 })
    }
  }

  @Builder
  heroScene() {
    Stack({ alignContent: Alignment.TopStart }) {
      this.heroMedia()

      Text('')
        .width('100%')
        .height(170)
        .linearGradient({
          angle: 180,
          colors: [['#00000000', 0], ['#F0000000', 0.72], [AppTheme.APPLE_BLACK, 1]]
        })
        .position({ x: 0, y: 250 })
    }
    .width('100%')
    .height(420)
    .backgroundColor(AppTheme.APPLE_BLACK)
  }

  @Builder
  weatherMetric() {
    Column({ space: 6 }) {
      Text('天气')
        .fontSize(11)
        .fontColor(AppTheme.APPLE_MUTED_ON_DARK)
        .maxLines(1)

      Text(this.getWeatherDisplayValue())
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.APPLE_TEXT_ON_DARK)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(this.getWeatherHeadline())
        .fontSize(11)
        .fontColor(AppTheme.APPLE_MUTED_ON_DARK)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  checklistMetric() {
    Column({ space: 6 }) {
      Text('清单')
        .fontSize(11)
        .fontColor(AppTheme.APPLE_MUTED_ON_DARK)
        .maxLines(1)

      Text(`${this.getSelectedChecklistItems().length} 项`)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.APPLE_TEXT_ON_DARK)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text('本机保存')
        .fontSize(11)
        .fontColor(AppTheme.APPLE_MUTED_ON_DARK)
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  calendarMetric() {
    Column({ space: 6 }) {
      Text('日历')
        .fontSize(11)
        .fontColor(AppTheme.APPLE_MUTED_ON_DARK)
        .maxLines(1)

      Text(this.getCalendarDisplayText())
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.APPLE_TEXT_ON_DARK)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text('真实状态')
        .fontSize(11)
        .fontColor(AppTheme.APPLE_MUTED_ON_DARK)
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  summaryBand() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column({ space: 18 }) {
        Row() {
          this.weatherMetric()
          Divider().vertical(true).height(54).strokeWidth(1).color(AppTheme.APPLE_DARK_LINE)
          this.checklistMetric()
          Divider().vertical(true).height(54).strokeWidth(1).color(AppTheme.APPLE_DARK_LINE)
          this.calendarMetric()
        }
        .width('100%')

        Text(this.getWeatherCaption())
          .width('100%')
          .fontSize(13)
          .fontColor(AppTheme.APPLE_MUTED_ON_DARK)
          .lineHeight(20)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 18, bottom: 18 })

      this.glassShine(this.summaryCardActive)
    }
    .width('100%')
    .height(150)
    .backgroundColor(AppTheme.APPLE_DARK_PANEL)
    .backgroundBlurStyle(BlurStyle.Thin)
    .border({ width: 1, color: AppTheme.APPLE_DARK_LINE })
    .borderRadius(AppTheme.CARD_RADIUS)
    .clip(true)
    .scale({ x: this.summaryCardActive ? 1.015 : 1, y: this.summaryCardActive ? 1.015 : 1 })
    .animation({ duration: 320, curve: Curve.EaseInOut })
    .onHover((isHover: boolean) => {
      this.summaryCardActive = isHover;
    })
  }

  @Builder
  checklistPreview() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column({ space: 12 }) {
        Row() {
          Text('出门清单')
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.APPLE_TEXT_ON_DARK)

          Blank()

          Text('全部')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppTheme.APPLE_TEXT_ON_DARK)
            .onClick(async () => {
              await this.getPageRouter().pushUrl({ url: AppRoute.CHECKLIST });
            })
        }
        .width('100%')

        Column({ space: 8 }) {
          Row({ space: 8 }) {
            ForEach(this.getSelectedChecklistItems().slice(0, 4), (item: ChecklistItem) => {
              this.checklistPill(item)
            })
          }
          .width('100%')

          Row({ space: 8 }) {
            ForEach(this.getSelectedChecklistItems().slice(4, 8), (item: ChecklistItem) => {
              this.checklistPill(item)
            })
          }
          .width('100%')
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 18, bottom: 18 })

      this.glassShine(this.checklistCardActive)
    }
    .width('100%')
    .height(228)
    .backgroundColor(AppTheme.APPLE_DARK_PANEL)
    .backgroundBlurStyle(BlurStyle.Thin)
    .border({ width: 1, color: AppTheme.APPLE_DARK_LINE })
    .borderRadius(AppTheme.CARD_RADIUS)
    .clip(true)
    .scale({ x: this.checklistCardActive ? 1.015 : 1, y: this.checklistCardActive ? 1.015 : 1 })
    .animation({ duration: 320, curve: Curve.EaseInOut })
    .onHover((isHover: boolean) => {
      this.checklistCardActive = isHover;
    })
  }

  @Builder
  glassShine(isActive: boolean) {
    Text('')
      .width(92)
      .height(210)
      .linearGradient({
        angle: 90,
        colors: [['#00FFFFFF', 0], ['#18FFFFFF', 0.46], ['#00FFFFFF', 1]]
      })
      .rotate({ angle: -28 })
      .position({ x: isActive ? '114%' : '-34%', y: -44 })
      .opacity(isActive ? 1 : 0.26)
      .animation({ duration: 900, curve: Curve.EaseInOut })
      .enabled(false)
  }

  @Builder
  checklistPill(item: ChecklistItem) {
    Column({ space: 6 }) {
      AppIcon({
        name: this.getChecklistIcon(item),
        iconSize: 29,
        color: AppTheme.APPLE_TEXT_ON_DARK
      })
        .opacity(0.9)

      Text(item.label)
        .fontSize(10)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.APPLE_TEXT_ON_DARK)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .height(70)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(AppTheme.APPLE_DARK_PANEL_STRONG)
    .borderRadius(18)
  }

  @Builder
  topWeatherSection() {
    Column({ space: 0 }) {
      this.heroScene()

      Column({ space: 12 }) {
        this.summaryBand()
        this.checklistPreview()
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 128 })
      .backgroundColor(AppTheme.APPLE_BLACK)
    }
    .width('100%')
    .height(942)
    .backgroundColor(AppTheme.APPLE_BLACK)
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Row() {
          Column({ space: 0 }) {
            this.topWeatherSection()
          }
          .width('100%')
          .constraintSize({ maxWidth: AppTheme.PAGE_MAX_WIDTH })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .margin({ bottom: 104 })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .backgroundColor(AppTheme.APPLE_BLACK)

      AppBottomNav({ activeTab: 'home' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.APPLE_BLACK)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
