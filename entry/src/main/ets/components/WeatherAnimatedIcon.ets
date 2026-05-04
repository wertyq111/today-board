import { AppIcon, AppIconMapper } from '../common/AppIcon';
import { AppTheme } from '../common/AppTheme';

@Component
export struct WeatherAnimatedIcon {
  syncState: string = 'idle';
  signal: string = 'unknown';
  iconSize: number = 56;
  iconColor: string = AppTheme.APPLE_ICON;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      AppIcon({
        name: AppIconMapper.forWeather(this.syncState, this.signal),
        iconSize: this.iconSize,
        color: this.iconColor
      })
    }
    .width(this.iconSize)
    .height(this.iconSize)
  }
}
