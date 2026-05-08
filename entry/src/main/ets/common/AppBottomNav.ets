import { AppRoute } from './AppRoute';
import { AppTheme } from './AppTheme';
import { AppIcon, AppIconName } from './AppIcon';

export type AppBottomNavTab = 'home' | 'checklist' | 'reminders' | 'profile';

@Component
export struct AppBottomNav {
  activeTab: AppBottomNavTab = 'home';

  private getPageRouter() {
    return this.getUIContext().getRouter();
  }

  @Builder
  navItem(label: string, iconName: AppIconName, tab: AppBottomNavTab, route: string) {
    Column({ space: 3 }) {
      AppIcon({
        name: iconName,
        iconSize: 21,
        color: this.activeTab === tab ? AppTheme.APPLE_NAV_ACTIVE : AppTheme.APPLE_NAV_INACTIVE
      })
        .opacity(this.activeTab === tab ? 1 : 0.58)

      Text(label)
        .width('100%')
        .height(16)
        .fontSize(10)
        .fontWeight(this.activeTab === tab ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.activeTab === tab ? AppTheme.APPLE_NAV_ACTIVE : AppTheme.APPLE_NAV_INACTIVE)
        .textAlign(TextAlign.Center)
        .lineHeight(16)
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(44)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(async () => {
      if (this.activeTab !== tab) {
        await this.getPageRouter().replaceUrl({ url: route });
      }
    })
  }

  build() {
    Row() {
      this.navItem('看板', 'home', 'home', AppRoute.INDEX)
      this.navItem('清单', 'checklist', 'checklist', AppRoute.CHECKLIST)
      this.navItem('提醒', 'reminders', 'reminders', AppRoute.DISCOVER)
      this.navItem('我的', 'profile', 'profile', AppRoute.SETTINGS)
    }
    .width('90%')
    .constraintSize({ maxWidth: AppTheme.NAV_MAX_WIDTH })
    .height(58)
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
    .backgroundColor(AppTheme.APPLE_NAV_BG)
    .border({ width: 1, color: AppTheme.APPLE_NAV_BORDER })
    .borderRadius(24)
    .shadow({ radius: 14, color: '#66000000', offsetX: 0, offsetY: 8 })
    .margin({ bottom: 10 })
  }
}
