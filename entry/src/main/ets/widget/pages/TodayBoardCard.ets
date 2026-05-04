const CARD_BLACK: string = '#000000';
const CARD_SURFACE: string = '#F5F5F7';
const CARD_WHITE: string = '#FFFFFF';
const CARD_TEXT: string = '#1D1D1F';
const CARD_MUTED: string = '#6E6E73';
const CARD_ORANGE: string = '#FF9F0A';
let cardStorage = new LocalStorage();

@Entry(cardStorage)
@Component
struct TodayBoardCard {
  @LocalStorageProp('setupCompleted') setupCompleted: boolean = false;
  @LocalStorageProp('title') title: string = '天气看门板';
  @LocalStorageProp('routeLabel') routeLabel: string = '打开应用';
  @LocalStorageProp('leaveTime') leaveTime: string = '清单 4 项';
  @LocalStorageProp('umbrellaLabel') umbrellaLabel: string = '天气未接入';
  @LocalStorageProp('scenarioLabel') scenarioLabel: string = '出门清单';
  @LocalStorageProp('statusLabel') statusLabel: string = '点击进入';
  @LocalStorageProp('summary') summary: string = '出门前确认清单；天气接入后自动补充提醒。';
  @LocalStorageProp('updatedAt') updatedAt: string = '--:--';

  private openApp(): void {
    postCardAction(this, {
      action: 'router',
      abilityName: 'EntryAbility',
      params: {
        source: 'todayBoardCard'
      }
    });
  }

  private getStatusColor(): string {
    return this.setupCompleted ? CARD_TEXT : CARD_ORANGE;
  }

  build() {
    Column({ space: 9 }) {
      Row() {
        Text('天气看门板')
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor(CARD_TEXT)

        Blank()

        Text(this.updatedAt)
          .fontSize(10)
          .fontColor(CARD_MUTED)
      }
      .width('100%')

      Column({ space: 5 }) {
        Text(this.leaveTime)
          .fontSize(31)
          .fontWeight(FontWeight.Bold)
          .fontColor(CARD_WHITE)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.routeLabel)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#A1A1A6')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 14, right: 14, top: 13, bottom: 13 })
      .borderRadius(22)
      .backgroundColor(CARD_BLACK)

      Text(this.summary)
        .fontSize(11)
        .fontColor(CARD_MUTED)
        .lineHeight(16)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      Row({ space: 7 }) {
        this.infoChip(this.scenarioLabel, CARD_TEXT)
        this.infoChip(this.umbrellaLabel, this.umbrellaLabel === '带伞' ? CARD_ORANGE : CARD_MUTED)
      }
      .width('100%')

      Row() {
        Text(this.statusLabel)
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getStatusColor())
          .backgroundColor(CARD_WHITE)
          .borderRadius(11)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })

        Blank()

        Text('打开')
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor(CARD_TEXT)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(13)
    .borderRadius(28)
    .backgroundColor(CARD_SURFACE)
    .onClick(() => {
      this.openApp();
    })
  }

  @Builder
  infoChip(label: string, color: string) {
    Text(label)
      .fontSize(10)
      .fontWeight(FontWeight.Medium)
      .fontColor(color)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .backgroundColor(CARD_WHITE)
      .borderRadius(12)
      .padding({ left: 8, right: 8, top: 5, bottom: 5 })
      .layoutWeight(1)
  }
}
