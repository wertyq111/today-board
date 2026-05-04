import { AppBottomNav } from '../common/AppBottomNav';
import { AppActionButton } from '../common/AppControls';
import { AppIcon } from '../common/AppIcon';
import { AppTheme } from '../common/AppTheme';
import { BoardStore, ChecklistIconName, ChecklistItem } from '../store/BoardStore';

@Entry
@Component
struct ChecklistPage {
  @StorageLink('board.checklistItems') checklistItemsJson: string = '';
  @State customExpanded: boolean = false;
  @State customLabel: string = '';
  @State customIcon: ChecklistIconName = 'bag';
  @State actionMessage: string = '';

  aboutToAppear(): void {
    BoardStore.initialize();
  }

  private getAllChecklistItems(): ChecklistItem[] {
    return BoardStore.getAllChecklistItems(this.checklistItemsJson);
  }

  private getSelectedChecklistItems(): ChecklistItem[] {
    return BoardStore.getSelectedChecklistItems(this.checklistItemsJson);
  }

  private getChecklistRows(): ChecklistItem[][] {
    const items = this.getAllChecklistItems();
    const rows: ChecklistItem[][] = [];
    for (let index = 0; index < items.length; index += 2) {
      rows.push(items.slice(index, index + 2));
    }
    return rows;
  }

  private getIconRows(): ChecklistItem[][] {
    const items = BoardStore.getIconOptions();
    const rows: ChecklistItem[][] = [];
    for (let index = 0; index < items.length; index += 4) {
      rows.push(items.slice(index, index + 4));
    }
    return rows;
  }

  private toggleItem(item: ChecklistItem): void {
    BoardStore.toggleChecklistItem(item.id);
    this.actionMessage = item.selected ? `${item.label} 已从今日清单移除。` : `${item.label} 已加入今日清单。`;
  }

  private addCustomItem(): void {
    const added = BoardStore.addCustomChecklistItem(this.customLabel, this.customIcon);
    if (!added) {
      this.actionMessage = '物品名称为空或已经存在。';
      return;
    }
    this.actionMessage = `${this.customLabel.trim()} 已加入今日清单。`;
    this.customLabel = '';
    this.customIcon = 'bag';
    this.customExpanded = false;
  }

  @Builder
  pageHeader() {
    Column({ space: 8 }) {
      Text('清单')
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.APPLE_TEXT)

      Text(`${this.getSelectedChecklistItems().length} 项已选，物品都只保存在本机。`)
        .fontSize(15)
        .fontColor(AppTheme.APPLE_SECONDARY_TEXT)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 20, right: 20, top: 26, bottom: 8 })
  }

  @Builder
  tagGroup() {
    Column({ space: 10 }) {
      Row() {
        Text('日常通勤')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.APPLE_SECONDARY_TEXT)

        Blank()

        Text(`${this.getAllChecklistItems().length} 个标签`)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.APPLE_SECONDARY_TEXT)
      }
      .width('100%')

      ForEach(this.getChecklistRows(), (row: ChecklistItem[]) => {
        Row({ space: 10 }) {
          this.itemTag(row[0])
          if (row.length > 1) {
            this.itemTag(row[1])
          } else {
            Blank().layoutWeight(1)
          }
        }
        .width('100%')
      })
    }
    .width('100%')
    .padding(18)
    .backgroundColor(AppTheme.APPLE_SURFACE)
    .borderRadius(AppTheme.CARD_RADIUS)
  }

  @Builder
  itemTag(item: ChecklistItem) {
    Column({ space: 8 }) {
      Row() {
        AppIcon({
          name: item.icon,
          iconSize: 22,
          color: item.selected ? AppTheme.APPLE_ACTION_TEXT : AppTheme.APPLE_TEXT
        })

        Blank()

        Text(item.selected ? '已选' : '待选')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(item.selected ? AppTheme.APPLE_ACTION_TEXT : AppTheme.APPLE_SECONDARY_TEXT)
      }
      .width('100%')

      Text(item.label)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(item.selected ? AppTheme.APPLE_ACTION_TEXT : AppTheme.APPLE_TEXT)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      Text(item.custom ? '自定义' : '预设')
        .fontSize(11)
        .fontColor(item.selected ? '#D1D1D6' : AppTheme.APPLE_SECONDARY_TEXT)
        .width('100%')
    }
    .layoutWeight(1)
    .height(92)
    .padding(12)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(item.selected ? AppTheme.APPLE_ACTION : AppTheme.APPLE_ACTION_MUTED)
    .borderRadius(18)
    .onClick(() => {
      this.toggleItem(item);
    })
  }

  @Builder
  selectedSummary() {
    Column({ space: 10 }) {
      Text('今日已选')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.APPLE_SECONDARY_TEXT)

      Text(this.getSelectedChecklistItems().map((item: ChecklistItem): string => item.label).join('、'))
        .fontSize(15)
        .fontColor(AppTheme.APPLE_TEXT)
        .lineHeight(22)
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(18)
    .backgroundColor(AppTheme.APPLE_SURFACE)
    .borderRadius(AppTheme.CARD_RADIUS)
  }

  @Builder
  customGroup() {
    Column({ space: 12 }) {
      Row() {
        Text('自定义物品')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.APPLE_SECONDARY_TEXT)

        Blank()

        Text(this.customExpanded ? '收起' : '添加')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.APPLE_TEXT)
          .onClick(() => {
            this.customExpanded = !this.customExpanded;
          })
      }
      .width('100%')

      if (this.customExpanded) {
        TextInput({ placeholder: '物品名称，例如 外套', text: this.customLabel })
          .height(46)
          .fontSize(15)
          .fontColor(AppTheme.APPLE_TEXT)
          .placeholderColor(AppTheme.APPLE_TERTIARY_TEXT)
          .backgroundColor(AppTheme.APPLE_BACKGROUND)
          .borderRadius(14)
          .padding({ left: 14, right: 14 })
          .onChange((text: string) => {
            this.customLabel = text;
          })

        Column({ space: 8 }) {
          ForEach(this.getIconRows(), (row: ChecklistItem[]) => {
            Row({ space: 8 }) {
              ForEach(row, (item: ChecklistItem) => {
                this.iconOption(item)
              })
              if (row.length < 4) {
                ForEach([0, 1, 2, 3].slice(row.length), () => {
                  Blank().layoutWeight(1)
                })
              }
            }
            .width('100%')
          })
        }
        .width('100%')

        AppActionButton({
          label: '保存自定义物品',
          tone: 'primary',
          onTap: () => {
            this.addCustomItem();
          }
        })
      } else {
        Text('添加后会成为可点选标签，并保存在本机。')
          .fontSize(13)
          .fontColor(AppTheme.APPLE_SECONDARY_TEXT)
          .lineHeight(19)
          .width('100%')
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(18)
    .backgroundColor(AppTheme.APPLE_SURFACE)
    .borderRadius(AppTheme.CARD_RADIUS)
  }

  @Builder
  iconOption(item: ChecklistItem) {
    Column({ space: 5 }) {
      AppIcon({
        name: item.icon,
        iconSize: 19,
        color: this.customIcon === item.icon ? AppTheme.APPLE_ACTION_TEXT : AppTheme.APPLE_TEXT
      })

      Text(item.label)
        .fontSize(9)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.customIcon === item.icon ? AppTheme.APPLE_ACTION_TEXT : AppTheme.APPLE_SECONDARY_TEXT)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .height(58)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.customIcon === item.icon ? AppTheme.APPLE_ACTION : AppTheme.APPLE_ACTION_MUTED)
    .borderRadius(16)
    .onClick(() => {
      this.customIcon = item.icon;
    })
  }

  @Builder
  messageLine() {
    if (this.actionMessage.length > 0) {
      Text(this.actionMessage)
        .fontSize(12)
        .fontColor(AppTheme.APPLE_SECONDARY_TEXT)
        .width('100%')
        .padding({ left: 6, right: 6 })
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column({ space: 14 }) {
          this.pageHeader()
          this.tagGroup()
          this.selectedSummary()
          this.customGroup()
          this.messageLine()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 34, bottom: 102 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .backgroundColor(AppTheme.APPLE_BACKGROUND)

      AppBottomNav({ activeTab: 'checklist' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.APPLE_BACKGROUND)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
