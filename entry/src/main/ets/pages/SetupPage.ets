import { AppRoute } from '../common/AppRoute';
import { AppTheme } from '../common/AppTheme';
import { MapSearchResult, MapSearchService } from '../services/MapSearchService';
import { AddressSelection, CommuteOption, SetupStore } from '../store/SetupStore';

@Entry
@Component
struct SetupPage {
  @State homeAddress: string = '';
  @State officeAddress: string = '';
  @State homeAddressSelectionJson: string = '';
  @State officeAddressSelectionJson: string = '';
  @State workStartTime: string = SetupStore.DEFAULT_WORK_START_TIME;
  @State checklistText: string = SetupStore.DEFAULT_CHECKLIST_TEXT;
  @State subwayDuration: string = '45';
  @State subwayCost: string = '6';
  @State taxiDuration: string = '28';
  @State taxiCost: string = '38';
  @State busDuration: string = '52';
  @State busCost: string = '4';
  @State validationMessage: string = '';
  @State saveMessage: string = '';
  @State forceSetupFlow: boolean = false;
  @State addressSearchVisible: boolean = false;
  @State addressSearchTarget: string = 'home';
  @State addressSearchKeyword: string = '';
  @State addressSearchMessage: string = '';
  @State addressSearchResults: MapSearchResult[] = [];
  @StorageLink('mapSearch.apiKey') mapSearchApiKey: string = '';
  @StorageLink('mapSearch.city') mapSearchCity: string = '';

  aboutToAppear(): void {
    MapSearchService.initialize();
    const snapshot = SetupStore.getSnapshot();
    const subway = snapshot.commuteOptions.find((item: CommuteOption) => item.id === 'subway');
    const taxi = snapshot.commuteOptions.find((item: CommuteOption) => item.id === 'taxi');
    const busWalk = snapshot.commuteOptions.find((item: CommuteOption) => item.id === 'bus_walk');

    this.homeAddress = snapshot.homeAddress;
    this.officeAddress = snapshot.officeAddress;
    this.homeAddressSelectionJson = this.stringifyAddressSelection(snapshot.homeAddressSelection);
    this.officeAddressSelectionJson = this.stringifyAddressSelection(snapshot.officeAddressSelection);
    this.workStartTime = snapshot.workStartTime;
    this.checklistText = snapshot.checklistText;
    this.subwayDuration = `${subway?.durationMinutes ?? 45}`;
    this.subwayCost = `${subway?.costYuan ?? 6}`;
    this.taxiDuration = `${taxi?.durationMinutes ?? 28}`;
    this.taxiCost = `${taxi?.costYuan ?? 38}`;
    this.busDuration = `${busWalk?.durationMinutes ?? 52}`;
    this.busCost = `${busWalk?.costYuan ?? 4}`;
    this.forceSetupFlow = !snapshot.setupCompleted;
  }

  private getPageRouter() {
    return this.getUIContext().getRouter();
  }

  private canSubmit(): boolean {
    const fieldsReady = this.homeAddress.trim().length > 0 && this.officeAddress.trim().length > 0 &&
      this.workStartTime.trim().match(/^\d{1,2}:\d{2}$/) !== null;
    const checklistReady = SetupStore.normalizeChecklistText(this.checklistText).length > 0;
    const optionNumbers = [
      Number(this.subwayDuration),
      Number(this.subwayCost),
      Number(this.taxiDuration),
      Number(this.taxiCost),
      Number(this.busDuration),
      Number(this.busCost)
    ];

    return fieldsReady && checklistReady && optionNumbers.every((value: number) => Number.isFinite(value) && value > 0);
  }

  private buildPayload(): CommuteOption[] {
    return [
      {
        id: 'subway',
        label: '地铁优先',
        durationMinutes: Number(this.subwayDuration),
        costYuan: Number(this.subwayCost),
        note: '稳定、低成本，适合常规工作日。'
      },
      {
        id: 'taxi',
        label: '打车直达',
        durationMinutes: Number(this.taxiDuration),
        costYuan: Number(this.taxiCost),
        note: '时间不够或临近降雨时更有价值。'
      },
      {
        id: 'bus_walk',
        label: '公交 + 步行',
        durationMinutes: Number(this.busDuration),
        costYuan: Number(this.busCost),
        note: '晴天可选，但暴雨和高温场景要降权。'
      }
    ];
  }

  private stringifyAddressSelection(selection?: AddressSelection): string {
    return selection ? JSON.stringify(selection) : '';
  }

  private parseAddressSelection(selectionJson: string): AddressSelection | undefined {
    if (selectionJson.trim().length === 0) {
      return undefined;
    }

    try {
      const selection = JSON.parse(selectionJson) as AddressSelection;
      if (selection.source === 'manual' && selection.address.trim().length > 0) {
        return selection;
      }
      if (selection.source === 'place_search' && selection.address.trim().length > 0 &&
        Number.isFinite(selection.latitude) && Number.isFinite(selection.longitude)) {
        return selection;
      }
    } catch (error) {
      console.error(`Failed to parse address selection on setup page: ${JSON.stringify(error)}`);
    }
    return undefined;
  }

  private getAddressSelectionForSave(address: string, selectionJson: string): AddressSelection {
    const selection = this.parseAddressSelection(selectionJson);
    if (selection) {
      return selection;
    }
    return SetupStore.createManualAddressSelection(address);
  }

  private isMapSearchConfigured(): boolean {
    return this.mapSearchApiKey.trim().length > 0;
  }

  private getAddressSourceText(selectionJson: string): string {
    const selection = this.parseAddressSelection(selectionJson);
    if (selection?.source === 'place_search') {
      return '地图选点';
    }
    return '手动输入';
  }

  private getAddressSelectionSummary(selectionJson: string): string {
    const selection = this.parseAddressSelection(selectionJson);
    if (selection?.source !== 'place_search') {
      return '';
    }
    return `已选：${selection.name}，${selection.address}`;
  }

  private openAddressSearch(target: string): void {
    this.addressSearchTarget = target;
    this.addressSearchKeyword = target === 'home' ? this.homeAddress : this.officeAddress;
    this.addressSearchVisible = true;
    this.addressSearchResults = [];
    this.addressSearchMessage = this.isMapSearchConfigured() ? '输入地点关键词后搜索。' : '地图搜索未配置，请先去设置页填入高德 Web 服务 Key。';
  }

  private closeAddressSearch(): void {
    this.addressSearchVisible = false;
    this.addressSearchResults = [];
    this.addressSearchMessage = '';
  }

  private async searchAddress(): Promise<void> {
    this.addressSearchMessage = '正在搜索真实地图地点...';
    this.addressSearchResults = [];

    try {
      const results = await MapSearchService.search(this.addressSearchKeyword);
      this.addressSearchResults = results;
      this.addressSearchMessage = results.length > 0 ? `找到 ${results.length} 个地点。` : '没有找到地点，请换个关键词。';
    } catch (error) {
      this.addressSearchMessage = error instanceof Error ? error.message : '地图搜索失败。';
    }
  }

  private selectAddressResult(result: MapSearchResult): void {
    try {
      const selection = MapSearchService.toAddressSelection(result);
      const displayAddress = `${result.name} ${result.address}`;
      if (this.addressSearchTarget === 'home') {
        this.homeAddress = displayAddress;
        this.homeAddressSelectionJson = JSON.stringify(selection);
      } else {
        this.officeAddress = displayAddress;
        this.officeAddressSelectionJson = JSON.stringify(selection);
      }
      this.closeAddressSearch();
    } catch (error) {
      this.addressSearchMessage = error instanceof Error ? error.message : '这个地点缺少有效坐标，不能保存。';
    }
  }

  private async submitSetup(): Promise<void> {
    this.validationMessage = '';
    this.saveMessage = '';

    if (!this.canSubmit()) {
      this.validationMessage = '请把家、公司、上班时间、清单和 3 个通勤方案都补完整。';
      return;
    }

    SetupStore.saveSetup({
      homeAddress: this.homeAddress,
      officeAddress: this.officeAddress,
      homeAddressSelection: this.getAddressSelectionForSave(this.homeAddress, this.homeAddressSelectionJson),
      officeAddressSelection: this.getAddressSelectionForSave(this.officeAddress, this.officeAddressSelectionJson),
      workStartTime: this.workStartTime,
      checklistText: this.checklistText,
      commuteOptions: this.buildPayload()
    });

    this.saveMessage = '已保存到本地。';

    try {
      if (this.forceSetupFlow) {
        await this.getPageRouter().replaceUrl({ url: AppRoute.INDEX });
        return;
      }
      this.getPageRouter().back();
    } catch (error) {
      console.error(`Failed to finish setup flow: ${JSON.stringify(error)}`);
    }
  }

  @Builder
  pageHeader() {
    Column({ space: 12 }) {
      Row() {
        if (!this.forceSetupFlow) {
          Button('返回')
            .fontSize(AppTheme.CAPTION_SIZE)
            .fontColor(AppTheme.ACCENT_COLOR)
            .backgroundColor(AppTheme.ACCENT_SOFT_COLOR)
            .borderRadius(AppTheme.CHIP_RADIUS)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .onClick(() => {
              this.getPageRouter().back();
            })
        }

        Blank()

        Text(this.forceSetupFlow ? '首次配置' : '编辑通勤票')
          .fontSize(AppTheme.CAPTION_SIZE)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.SECONDARY_TEXT_COLOR)
      }
      .width('100%')

      Text('把通勤票填完整')
        .fontSize(AppTheme.TITLE_SIZE)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.PRIMARY_TEXT_COLOR)

      Text('只保留会影响出门判断的字段：地点、时间、方案、清单。')
        .fontSize(AppTheme.BODY_SIZE)
        .fontColor(AppTheme.SECONDARY_TEXT_COLOR)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  @Builder
  stepHeader(step: string, title: string, description: string) {
    Row({ space: 12 }) {
      Text(step)
        .fontSize(AppTheme.CAPTION_SIZE)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.HERO_TEXT_COLOR)
        .backgroundColor(AppTheme.HERO_BACKGROUND)
        .borderRadius(AppTheme.CHIP_RADIUS)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })

      Column({ space: 4 }) {
        Text(title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.PRIMARY_TEXT_COLOR)
        Text(description)
          .fontSize(AppTheme.CAPTION_SIZE)
          .fontColor(AppTheme.SECONDARY_TEXT_COLOR)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
  }

  @Builder
  textField(label: string, placeholder: string, value: string, onChange: (value: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(AppTheme.CAPTION_SIZE)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.SECONDARY_TEXT_COLOR)

      TextInput({ placeholder, text: value })
        .fontSize(AppTheme.BODY_SIZE)
        .fontColor(AppTheme.PRIMARY_TEXT_COLOR)
        .placeholderColor(AppTheme.SECONDARY_TEXT_COLOR)
        .backgroundColor(AppTheme.SURFACE_BACKGROUND)
        .borderRadius(AppTheme.CARD_RADIUS)
        .border({ width: 1, color: AppTheme.BORDER_COLOR })
        .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        .onChange((text: string) => {
          onChange(text);
        })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  @Builder
  addressField(label: string, placeholder: string, value: string, selectionJson: string,
    onChange: (value: string) => void, onSearch: () => void) {
    Column({ space: 10 }) {
      Row() {
        Text(label)
          .fontSize(AppTheme.CAPTION_SIZE)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.SECONDARY_TEXT_COLOR)

        Blank()

        Text(this.getAddressSourceText(selectionJson))
          .fontSize(AppTheme.CAPTION_SIZE)
          .fontColor(AppTheme.ACCENT_COLOR)
      }
      .width('100%')

      TextInput({ placeholder, text: value })
        .fontSize(AppTheme.BODY_SIZE)
        .fontColor(AppTheme.PRIMARY_TEXT_COLOR)
        .placeholderColor(AppTheme.SECONDARY_TEXT_COLOR)
        .backgroundColor(AppTheme.SURFACE_BACKGROUND)
        .borderRadius(AppTheme.CARD_RADIUS)
        .border({ width: 1, color: AppTheme.BORDER_COLOR })
        .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        .onChange((text: string) => {
          onChange(text);
        })

      if (this.getAddressSelectionSummary(selectionJson).length > 0) {
        Text(this.getAddressSelectionSummary(selectionJson))
          .fontSize(AppTheme.CAPTION_SIZE)
          .fontColor(AppTheme.SUCCESS_COLOR)
          .width('100%')
      }

      Button(this.isMapSearchConfigured() ? '搜索地图地点' : '地图搜索未配置')
        .width('100%')
        .fontSize(AppTheme.BODY_SIZE)
        .fontColor(this.isMapSearchConfigured() ? AppTheme.HERO_TEXT_COLOR : AppTheme.SECONDARY_TEXT_COLOR)
        .backgroundColor(this.isMapSearchConfigured() ? AppTheme.HERO_BACKGROUND : AppTheme.SURFACE_MUTED_BACKGROUND)
        .borderRadius(AppTheme.CARD_RADIUS)
        .padding({ top: 13, bottom: 13 })
        .enabled(this.isMapSearchConfigured())
        .onClick(() => {
          onSearch();
        })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(18)
    .borderRadius(AppTheme.CARD_RADIUS)
    .backgroundColor(AppTheme.SURFACE_MUTED_BACKGROUND)
  }

  @Builder
  addressSearchPanel() {
    if (this.addressSearchVisible) {
      Column({ space: 12 }) {
        Row() {
          Text(this.addressSearchTarget === 'home' ? '搜索家的地点' : '搜索公司的地点')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.PRIMARY_TEXT_COLOR)

          Blank()

          Button('关闭')
            .fontSize(AppTheme.CAPTION_SIZE)
            .fontColor(AppTheme.ACCENT_COLOR)
            .backgroundColor(AppTheme.ACCENT_SOFT_COLOR)
            .borderRadius(AppTheme.CHIP_RADIUS)
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .onClick(() => {
              this.closeAddressSearch();
            })
        }
        .width('100%')

        TextInput({ placeholder: '例如：世纪大道、漕河泾、公司大厦', text: this.addressSearchKeyword })
          .fontSize(AppTheme.BODY_SIZE)
          .fontColor(AppTheme.PRIMARY_TEXT_COLOR)
          .placeholderColor(AppTheme.SECONDARY_TEXT_COLOR)
          .backgroundColor(AppTheme.SURFACE_BACKGROUND)
          .borderRadius(AppTheme.CARD_RADIUS)
          .padding({ left: 16, right: 16, top: 14, bottom: 14 })
          .onChange((text: string) => {
            this.addressSearchKeyword = text;
          })

        Button('搜索')
          .width('100%')
          .fontSize(AppTheme.BODY_SIZE)
          .fontColor(AppTheme.HERO_TEXT_COLOR)
          .backgroundColor(AppTheme.ACCENT_COLOR)
          .borderRadius(AppTheme.CARD_RADIUS)
          .padding({ top: 13, bottom: 13 })
          .enabled(this.addressSearchKeyword.trim().length >= 2 && this.isMapSearchConfigured())
          .onClick(() => {
            void this.searchAddress();
          })

        Text(this.addressSearchMessage)
          .fontSize(AppTheme.CAPTION_SIZE)
          .fontColor(AppTheme.SECONDARY_TEXT_COLOR)
          .width('100%')

        ForEach(this.addressSearchResults, (result: MapSearchResult) => {
          this.addressSearchResultRow(result)
        })
      }
      .width('100%')
      .padding(20)
      .borderRadius(AppTheme.CARD_RADIUS)
      .backgroundColor(AppTheme.SURFACE_BACKGROUND)
      .border({ width: 1, color: AppTheme.BORDER_COLOR })
    }
  }

  @Builder
  addressSearchResultRow(result: MapSearchResult) {
    Column({ space: 8 }) {
      Text(result.name)
        .fontSize(AppTheme.BODY_SIZE)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.PRIMARY_TEXT_COLOR)
        .width('100%')

      Text(result.address)
        .fontSize(AppTheme.CAPTION_SIZE)
        .fontColor(AppTheme.SECONDARY_TEXT_COLOR)
        .width('100%')

      Text(`${result.longitude.toFixed(6)}, ${result.latitude.toFixed(6)}`)
        .fontSize(AppTheme.MINI_SIZE)
        .fontColor(AppTheme.ACCENT_COLOR)
        .width('100%')
    }
    .width('100%')
    .padding(14)
    .borderRadius(AppTheme.CHIP_RADIUS)
    .backgroundColor(AppTheme.SURFACE_MUTED_BACKGROUND)
    .onClick(() => {
      this.selectAddressResult(result);
    })
  }

  @Builder
  commuteCard(title: string, description: string, durationValue: string, costValue: string,
    onDurationChange: (value: string) => void, onCostChange: (value: string) => void) {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text(title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.PRIMARY_TEXT_COLOR)
          Text(description)
            .fontSize(AppTheme.CAPTION_SIZE)
            .fontColor(AppTheme.SECONDARY_TEXT_COLOR)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Row({ space: 12 }) {
        this.numberField('分钟', '45', durationValue, onDurationChange)
        this.numberField('费用', '6', costValue, onCostChange)
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(AppTheme.CARD_RADIUS)
    .backgroundColor(AppTheme.SURFACE_BACKGROUND)
    .border({ width: 1, color: AppTheme.BORDER_COLOR })
  }

  @Builder
  numberField(label: string, placeholder: string, value: string, onChange: (value: string) => void) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(AppTheme.CAPTION_SIZE)
        .fontColor(AppTheme.SECONDARY_TEXT_COLOR)

      TextInput({ placeholder, text: value })
        .fontSize(AppTheme.BODY_SIZE)
        .fontColor(AppTheme.PRIMARY_TEXT_COLOR)
        .backgroundColor(AppTheme.SURFACE_MUTED_BACKGROUND)
        .borderRadius(AppTheme.CHIP_RADIUS)
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .onChange((text: string) => {
          onChange(text);
        })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  saveArea() {
    if (this.validationMessage.length > 0) {
      Text(this.validationMessage)
        .fontSize(AppTheme.CAPTION_SIZE)
        .fontColor(AppTheme.WARNING_COLOR)
        .width('100%')
    }

    if (this.saveMessage.length > 0) {
      Text(this.saveMessage)
        .fontSize(AppTheme.CAPTION_SIZE)
        .fontColor(AppTheme.SUCCESS_COLOR)
        .width('100%')
    }

    Button(this.forceSetupFlow ? '生成我的通勤票' : '保存这张通勤票')
      .width('100%')
      .fontSize(17)
      .fontWeight(FontWeight.Bold)
      .fontColor(AppTheme.HERO_TEXT_COLOR)
      .backgroundColor(AppTheme.HERO_BACKGROUND)
      .borderRadius(AppTheme.HERO_RADIUS)
      .padding({ top: 16, bottom: 16 })
      .onClick(() => {
        void this.submitSetup();
      })
  }

  build() {
    Scroll() {
      Column({ space: AppTheme.SECTION_GAP }) {
        this.pageHeader()

        this.stepHeader('01', '固定地点', '可以手动输入，也可以从高德真实地点里选。')
        this.addressField('家', '例如：浦东新区世纪大道 100 号', this.homeAddress, this.homeAddressSelectionJson,
          (value: string) => {
            this.homeAddress = value;
            this.homeAddressSelectionJson = '';
          }, () => {
            this.openAddressSearch('home');
          })
        this.addressField('公司', '例如：徐汇区漕河泾开发区', this.officeAddress, this.officeAddressSelectionJson,
          (value: string) => {
            this.officeAddress = value;
            this.officeAddressSelectionJson = '';
          }, () => {
            this.openAddressSearch('office');
          })
        this.addressSearchPanel()

        this.stepHeader('02', '时间和随身物品', '首页会用这里算出门时间和提醒。')
        this.textField('默认上班时间', '例如：09:00', this.workStartTime, (value: string) => {
          this.workStartTime = value;
        })
        TextArea({ text: this.checklistText, placeholder: '工牌,耳机,水杯,雨伞' })
          .fontSize(AppTheme.BODY_SIZE)
          .fontColor(AppTheme.PRIMARY_TEXT_COLOR)
          .placeholderColor(AppTheme.SECONDARY_TEXT_COLOR)
          .backgroundColor(AppTheme.SURFACE_BACKGROUND)
          .borderRadius(AppTheme.CARD_RADIUS)
          .border({ width: 1, color: AppTheme.BORDER_COLOR })
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          .height(132)
          .onChange((text: string) => {
            this.checklistText = text;
          })

        this.stepHeader('03', '通勤方案', '只填真实耗时和费用，规则不做假路线。')
        this.commuteCard('地铁优先', '稳定、低成本，适合常规工作日。', this.subwayDuration, this.subwayCost,
          (value: string) => { this.subwayDuration = value; },
          (value: string) => { this.subwayCost = value; })
        this.commuteCard('打车直达', '时间不够或临近降雨时更有价值。', this.taxiDuration, this.taxiCost,
          (value: string) => { this.taxiDuration = value; },
          (value: string) => { this.taxiCost = value; })
        this.commuteCard('公交 + 步行', '晴天可选，但暴雨和高温场景要降权。', this.busDuration, this.busCost,
          (value: string) => { this.busDuration = value; },
          (value: string) => { this.busCost = value; })

        this.saveArea()
      }
      .width('100%')
      .padding(AppTheme.PAGE_PADDING)
    }
    .scrollBar(BarState.Off)
    .backgroundColor(AppTheme.PAGE_BACKGROUND)
  }
}
