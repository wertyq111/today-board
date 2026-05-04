import { AppIcon, AppIconName } from './AppIcon';
import { AppTheme } from './AppTheme';

export type AppActionButtonTone = 'primary' | 'secondary';
export type AppControlTone = 'normal' | 'muted' | 'warning';

export class AppControlColors {
  static text(tone: AppControlTone): string {
    if (tone === 'warning') {
      return AppTheme.APPLE_ORANGE;
    }
    if (tone === 'muted') {
      return AppTheme.APPLE_SECONDARY_TEXT;
    }
    return AppTheme.APPLE_TEXT;
  }

  static icon(tone: AppControlTone): string {
    if (tone === 'warning') {
      return AppTheme.APPLE_ORANGE;
    }
    if (tone === 'muted') {
      return AppTheme.APPLE_ICON_MUTED;
    }
    return AppTheme.APPLE_ICON;
  }

  static tile(tone: AppControlTone): string {
    if (tone === 'warning') {
      return '#FFF4E3';
    }
    return AppTheme.APPLE_ICON_TILE;
  }
}

@Component
export struct AppIconTile {
  name: AppIconName = 'bag';
  tone: AppControlTone = 'normal';
  tileSize: number = 34;
  iconSize: number = 20;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      AppIcon({
        name: this.name,
        iconSize: this.iconSize,
        color: AppControlColors.icon(this.tone)
      })
    }
    .width(this.tileSize)
    .height(this.tileSize)
    .backgroundColor(AppControlColors.tile(this.tone))
    .borderRadius(Math.floor(this.tileSize / 3.4))
  }
}

@Component
export struct AppActionButton {
  label: string = '';
  tone: AppActionButtonTone = 'primary';
  buttonHeight: number = 46;
  onTap: () => void = () => {};

  private getBackgroundColor(): string {
    return this.tone === 'primary' ? AppTheme.APPLE_ACTION : AppTheme.APPLE_ACTION_MUTED;
  }

  private getTextColor(): string {
    return this.tone === 'primary' ? AppTheme.APPLE_ACTION_TEXT : AppTheme.APPLE_ACTION_MUTED_TEXT;
  }

  build() {
    Button(this.label)
      .width('100%')
      .height(this.buttonHeight)
      .fontSize(15)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.getTextColor())
      .backgroundColor(this.getBackgroundColor())
      .borderRadius(Math.floor(this.buttonHeight / 2))
      .onClick(() => {
        this.onTap();
      })
  }
}

@Component
export struct AppGroupedListRow {
  title: string = '';
  value: string = '';
  detail: string = '';
  iconName: AppIconName = 'bag';
  iconTone: AppControlTone = 'normal';
  valueTone: AppControlTone = 'normal';
  onTap: () => void = () => {};

  build() {
    Row({ space: 12 }) {
      AppIconTile({ name: this.iconName, iconSize: 19, tileSize: 32, tone: this.iconTone })

      Column({ space: 5 }) {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.APPLE_TEXT)

        Text(this.detail)
          .fontSize(12)
          .fontColor(AppTheme.APPLE_SECONDARY_TEXT)
          .lineHeight(18)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.value.length > 0) {
        Text(this.value)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppControlColors.text(this.valueTone))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 16, bottom: 16 })
    .onClick(() => {
      this.onTap();
    })
  }
}
