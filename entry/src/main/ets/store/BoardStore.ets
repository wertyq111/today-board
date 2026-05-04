export type ChecklistIconName =
  'bag' | 'badge' | 'phone' | 'key' | 'headphones' | 'cup' | 'umbrella' |
  'wallet' | 'tissue' | 'mask' | 'battery' | 'medicine';

export interface ChecklistItem {
  id: string;
  label: string;
  icon: ChecklistIconName;
  selected: boolean;
  custom: boolean;
}

export interface BoardSnapshot {
  checklistItems: ChecklistItem[];
  completed: boolean;
}

export class BoardStore {
  static readonly KEY_CHECKLIST_ITEMS: string = 'board.checklistItems';
  static readonly KEY_LEGACY_CHECKLIST_TEXT: string = 'board.checklistText';
  static readonly KEY_COMPLETED: string = 'board.completed';

  static readonly DEFAULT_CHECKLIST_ITEMS: ChecklistItem[] = [
    { id: 'preset-badge', label: '工牌', icon: 'badge', selected: true, custom: false },
    { id: 'preset-phone', label: '手机', icon: 'phone', selected: true, custom: false },
    { id: 'preset-key', label: '钥匙', icon: 'key', selected: true, custom: false },
    { id: 'preset-headphones', label: '耳机', icon: 'headphones', selected: true, custom: false },
    { id: 'preset-cup', label: '水杯', icon: 'cup', selected: true, custom: false },
    { id: 'preset-umbrella', label: '雨伞', icon: 'umbrella', selected: true, custom: false },
    { id: 'preset-wallet', label: '钱包', icon: 'wallet', selected: true, custom: false },
    { id: 'preset-tissue', label: '纸巾', icon: 'tissue', selected: true, custom: false },
    { id: 'preset-mask', label: '口罩', icon: 'mask', selected: true, custom: false },
    { id: 'preset-battery', label: '充电宝', icon: 'battery', selected: true, custom: false }
  ];
  static readonly DEFAULT_CHECKLIST_ITEMS_JSON: string = JSON.stringify(BoardStore.DEFAULT_CHECKLIST_ITEMS);

  static initialize(): void {
    PersistentStorage.persistProps([
      { key: BoardStore.KEY_CHECKLIST_ITEMS, defaultValue: '' },
      { key: BoardStore.KEY_LEGACY_CHECKLIST_TEXT, defaultValue: '' },
      { key: BoardStore.KEY_COMPLETED, defaultValue: true }
    ]);
    BoardStore.ensureChecklistItems();
  }

  static getSnapshot(): BoardSnapshot {
    const checklistItems = BoardStore.getAllChecklistItems();
    return {
      checklistItems,
      completed: checklistItems.some((item: ChecklistItem) => item.selected)
    };
  }

  static getAllChecklistItems(itemsJson?: string): ChecklistItem[] {
    const storedValue = itemsJson ?? BoardStore.getString(BoardStore.KEY_CHECKLIST_ITEMS);
    if (storedValue.trim().length === 0) {
      return BoardStore.cloneDefaultChecklistItems();
    }

    try {
      const parsed = JSON.parse(storedValue) as ChecklistItem[];
      return BoardStore.normalizeChecklistItems(parsed);
    } catch (error) {
      console.error(`Failed to parse checklist items: ${JSON.stringify(error)}`);
      return BoardStore.cloneDefaultChecklistItems();
    }
  }

  static getSelectedChecklistItems(itemsJson?: string): ChecklistItem[] {
    return BoardStore.getAllChecklistItems(itemsJson)
      .filter((item: ChecklistItem): boolean => item.selected);
  }

  static getChecklistItems(itemsJson?: string): string[] {
    return BoardStore.getSelectedChecklistItems(itemsJson)
      .map((item: ChecklistItem): string => item.label);
  }

  static toggleChecklistItem(itemId: string): void {
    const items = BoardStore.getAllChecklistItems()
      .map((item: ChecklistItem): ChecklistItem => {
        if (item.id !== itemId) {
          return item;
        }
        return {
          id: item.id,
          label: item.label,
          icon: item.icon,
          selected: !item.selected,
          custom: item.custom
        };
      });
    BoardStore.saveChecklistItems(items);
  }

  static addCustomChecklistItem(label: string, icon: ChecklistIconName): boolean {
    const normalizedLabel = BoardStore.normalizeChecklistLabel(label);
    if (normalizedLabel.length === 0) {
      return false;
    }

    const items = BoardStore.getAllChecklistItems();
    const alreadyExists = items.some((item: ChecklistItem): boolean => item.label === normalizedLabel);
    if (alreadyExists) {
      return false;
    }

    items.push({
      id: `custom-${Date.now()}`,
      label: normalizedLabel,
      icon: BoardStore.normalizeChecklistIcon(icon),
      selected: true,
      custom: true
    });
    BoardStore.saveChecklistItems(items);
    return true;
  }

  static getIconOptions(): ChecklistItem[] {
    return [
      { id: 'icon-badge', label: '工牌', icon: 'badge', selected: false, custom: false },
      { id: 'icon-phone', label: '手机', icon: 'phone', selected: false, custom: false },
      { id: 'icon-key', label: '钥匙', icon: 'key', selected: false, custom: false },
      { id: 'icon-headphones', label: '耳机', icon: 'headphones', selected: false, custom: false },
      { id: 'icon-cup', label: '水杯', icon: 'cup', selected: false, custom: false },
      { id: 'icon-umbrella', label: '雨伞', icon: 'umbrella', selected: false, custom: false },
      { id: 'icon-wallet', label: '钱包', icon: 'wallet', selected: false, custom: false },
      { id: 'icon-tissue', label: '纸巾', icon: 'tissue', selected: false, custom: false },
      { id: 'icon-mask', label: '口罩', icon: 'mask', selected: false, custom: false },
      { id: 'icon-battery', label: '充电宝', icon: 'battery', selected: false, custom: false },
      { id: 'icon-medicine', label: '药品', icon: 'medicine', selected: false, custom: false },
      { id: 'icon-bag', label: '其他', icon: 'bag', selected: false, custom: false }
    ];
  }

  private static ensureChecklistItems(): void {
    if (BoardStore.getString(BoardStore.KEY_CHECKLIST_ITEMS).trim().length > 0) {
      return;
    }

    const legacyText = BoardStore.getString(BoardStore.KEY_LEGACY_CHECKLIST_TEXT);
    const migratedItems = legacyText.trim().length > 0 ?
      BoardStore.createChecklistItemsFromText(legacyText) : BoardStore.cloneDefaultChecklistItems();
    BoardStore.saveChecklistItems(migratedItems);
  }

  private static saveChecklistItems(items: ChecklistItem[]): void {
    const normalizedItems = BoardStore.normalizeChecklistItems(items);
    AppStorage.set(BoardStore.KEY_CHECKLIST_ITEMS, JSON.stringify(normalizedItems));
    AppStorage.set(BoardStore.KEY_COMPLETED, normalizedItems.some((item: ChecklistItem): boolean => item.selected));
  }

  private static createChecklistItemsFromText(text: string): ChecklistItem[] {
    const legacyLabels = BoardStore.normalizeChecklistText(text)
      .split(',')
      .filter((label: string): boolean => label.length > 0);
    if (legacyLabels.length === 0) {
      return BoardStore.cloneDefaultChecklistItems();
    }

    const items = BoardStore.cloneDefaultChecklistItems()
      .map((item: ChecklistItem): ChecklistItem => {
        return {
          id: item.id,
          label: item.label,
          icon: item.icon,
          selected: legacyLabels.includes(item.label),
          custom: item.custom
        };
      });

    legacyLabels.forEach((label: string) => {
      const exists = items.some((item: ChecklistItem): boolean => item.label === label);
      if (!exists) {
        items.push({
          id: `legacy-${label}`,
          label: label,
          icon: BoardStore.inferChecklistIcon(label),
          selected: true,
          custom: true
        });
      }
    });
    return items;
  }

  private static cloneDefaultChecklistItems(): ChecklistItem[] {
    return JSON.parse(BoardStore.DEFAULT_CHECKLIST_ITEMS_JSON) as ChecklistItem[];
  }

  private static normalizeChecklistItems(items: ChecklistItem[]): ChecklistItem[] {
    const normalizedItems: ChecklistItem[] = [];
    items.forEach((item: ChecklistItem) => {
      const label = BoardStore.normalizeChecklistLabel(item.label);
      if (label.length === 0) {
        return;
      }
      const duplicate = normalizedItems.some((storedItem: ChecklistItem): boolean => storedItem.label === label);
      if (duplicate) {
        return;
      }
      normalizedItems.push({
        id: item.id.trim().length > 0 ? item.id.trim() : `item-${normalizedItems.length}`,
        label: label,
        icon: BoardStore.normalizeChecklistIcon(item.icon),
        selected: item.selected,
        custom: item.custom
      });
    });

    return normalizedItems.length > 0 ? normalizedItems : BoardStore.cloneDefaultChecklistItems();
  }

  private static normalizeChecklistText(text: string): string {
    return text
      .replace(/，/g, ',')
      .replace(/\n/g, ',')
      .split(',')
      .map((item: string) => BoardStore.normalizeChecklistLabel(item))
      .filter((item: string) => item.length > 0)
      .join(',');
  }

  private static normalizeChecklistLabel(label: string): string {
    return label.trim().replace(/,/g, '').replace(/，/g, '').slice(0, 12);
  }

  private static normalizeChecklistIcon(icon: string): ChecklistIconName {
    if (icon === 'badge' || icon === 'phone' || icon === 'key' || icon === 'headphones' || icon === 'cup' ||
      icon === 'umbrella' || icon === 'wallet' || icon === 'tissue' || icon === 'mask' || icon === 'battery' ||
      icon === 'medicine') {
      return icon;
    }
    return 'bag';
  }

  private static inferChecklistIcon(label: string): ChecklistIconName {
    if (label.includes('工牌')) {
      return 'badge';
    }
    if (label.includes('手机')) {
      return 'phone';
    }
    if (label.includes('钥匙')) {
      return 'key';
    }
    if (label.includes('耳机')) {
      return 'headphones';
    }
    if (label.includes('水') || label.includes('杯') || label.includes('咖啡')) {
      return 'cup';
    }
    if (label.includes('伞') || label.includes('雨')) {
      return 'umbrella';
    }
    if (label.includes('钱包') || label.includes('卡')) {
      return 'wallet';
    }
    if (label.includes('纸') || label.includes('巾')) {
      return 'tissue';
    }
    if (label.includes('口罩')) {
      return 'mask';
    }
    if (label.includes('充电')) {
      return 'battery';
    }
    if (label.includes('药')) {
      return 'medicine';
    }
    return 'bag';
  }

  private static getString(key: string): string {
    return AppStorage.get<string>(key) ?? '';
  }
}
