import { ChecklistIconName } from '../store/BoardStore';

export type AppIconName =
  'home' | 'checklist' | 'reminders' | 'profile' |
  'weatherClear' | 'weatherRain' | 'weatherCloud' | 'weatherUnknown' |
  'calendar' | 'location' | 'settings' | 'serviceCard' | 'refresh' |
  ChecklistIconName;

export class AppIconMapper {
  static getSymbol(name: AppIconName): Resource {
    switch (name) {
      case 'home':
        return $r('sys.symbol.house');
      case 'checklist':
        return $r('sys.symbol.list_checkmark');
      case 'reminders':
        return $r('sys.symbol.bell');
      case 'profile':
        return $r('sys.symbol.person_crop_circle_fill');
      case 'weatherClear':
        return $r('sys.symbol.sun');
      case 'weatherRain':
        return $r('sys.symbol.light_rain');
      case 'weatherCloud':
        return $r('sys.symbol.cloud');
      case 'weatherUnknown':
        return $r('sys.symbol.questionmark_cloud_fill');
      case 'calendar':
        return $r('sys.symbol.calendar');
      case 'location':
        return $r('sys.symbol.location_up');
      case 'settings':
        return $r('sys.symbol.slider_horizontal_2_1');
      case 'serviceCard':
        return $r('sys.symbol.square_fill_grid_2x2_badge_adiowaves');
      case 'refresh':
        return $r('sys.symbol.arrow_clockwise');
      case 'badge':
        return $r('sys.symbol.person_badge_checkmark');
      case 'headphones':
        return $r('sys.symbol.headphones');
      case 'phone':
        return $r('sys.symbol.phone');
      case 'cup':
        return $r('sys.symbol.cup');
      case 'umbrella':
        return $r('sys.symbol.umbrella');
      case 'key':
        return $r('sys.symbol.key');
      case 'wallet':
        return $r('sys.symbol.wallet');
      case 'tissue':
        return $r('sys.symbol.rectangle_stack');
      case 'mask':
        return $r('sys.symbol.mask_fill');
      case 'battery':
        return $r('sys.symbol.battery_bolt');
      case 'medicine':
        return $r('sys.symbol.cross_filled_drop');
      case 'bag':
      default:
        return $r('sys.symbol.bag');
    }
  }

  static forChecklistItem(item: string): AppIconName {
    const normalized = item.trim();
    if (normalized.includes('工牌')) {
      return 'badge';
    }
    if (normalized.includes('耳机')) {
      return 'headphones';
    }
    if (normalized.includes('手机')) {
      return 'phone';
    }
    if (normalized.includes('水') || normalized.includes('杯') || normalized.includes('咖啡')) {
      return 'cup';
    }
    if (normalized.includes('伞') || normalized.includes('雨')) {
      return 'umbrella';
    }
    if (normalized.includes('钥匙')) {
      return 'key';
    }
    if (normalized.includes('钱包') || normalized.includes('卡')) {
      return 'wallet';
    }
    if (normalized.includes('纸') || normalized.includes('巾')) {
      return 'tissue';
    }
    if (normalized.includes('口罩')) {
      return 'mask';
    }
    if (normalized.includes('充电')) {
      return 'battery';
    }
    if (normalized.includes('药')) {
      return 'medicine';
    }
    return 'bag';
  }

  static forWeather(syncState: string, signal: string): AppIconName {
    if (syncState === 'ready' && (signal === 'rain_soon' || signal === 'rainy')) {
      return 'weatherRain';
    }
    if (syncState === 'ready' && (signal === 'clear' || signal === 'sunny')) {
      return 'weatherClear';
    }
    if (syncState === 'ready' && (signal === 'cloudy' || signal === 'snowy')) {
      return 'weatherCloud';
    }
    return 'weatherUnknown';
  }
}

@Component
export struct AppIcon {
  @Prop name: AppIconName = 'bag';
  @Prop iconSize: number = 24;
  @Prop color: string = '#1D1D1F';

  build() {
    SymbolGlyph(AppIconMapper.getSymbol(this.name))
      .fontSize(this.iconSize)
      .fontColor([this.color])
      .width(this.iconSize)
      .height(this.iconSize)
  }
}
