import {
  SETUP_SEED_ENABLED,
  SETUP_SEED_HOME_ADDRESS,
  SETUP_SEED_HOME_NAME,
  SETUP_SEED_OFFICE_ADDRESS,
  SETUP_SEED_OFFICE_NAME,
  SETUP_SEED_WORK_START_TIME
} from '../config/SetupSeedConfig';

export interface CommuteOption {
  id: string;
  label: string;
  durationMinutes: number;
  costYuan: number;
  note: string;
}

export type AddressSource = 'manual' | 'place_search';

export interface AddressSelection {
  source: AddressSource;
  provider?: string;
  placeId?: string;
  name: string;
  address: string;
  latitude?: number;
  longitude?: number;
  selectedAt: number;
}

export interface SetupPayload {
  homeAddress: string;
  officeAddress: string;
  homeAddressSelection?: AddressSelection;
  officeAddressSelection?: AddressSelection;
  workStartTime: string;
  checklistText: string;
  commuteOptions: CommuteOption[];
}

export interface SetupSnapshot {
  homeAddress: string;
  officeAddress: string;
  homeAddressSelection?: AddressSelection;
  officeAddressSelection?: AddressSelection;
  workStartTime: string;
  checklistText: string;
  commuteOptions: CommuteOption[];
  setupCompleted: boolean;
}

export class SetupStore {
  static readonly KEY_HOME_ADDRESS: string = 'setup.homeAddress';
  static readonly KEY_OFFICE_ADDRESS: string = 'setup.officeAddress';
  static readonly KEY_HOME_ADDRESS_SELECTION_JSON: string = 'setup.homeAddressSelectionJson';
  static readonly KEY_OFFICE_ADDRESS_SELECTION_JSON: string = 'setup.officeAddressSelectionJson';
  static readonly KEY_WORK_START_TIME: string = 'setup.workStartTime';
  static readonly KEY_CHECKLIST_TEXT: string = 'setup.checklistText';
  static readonly KEY_COMMUTE_OPTIONS_JSON: string = 'setup.commuteOptionsJson';
  static readonly KEY_SETUP_COMPLETED: string = 'setup.completed';

  static readonly DEFAULT_WORK_START_TIME: string = '09:00';
  static readonly DEFAULT_CHECKLIST_TEXT: string = '工牌,耳机,水杯,雨伞';
  static readonly DEFAULT_COMMUTE_OPTIONS: CommuteOption[] = [
    { id: 'subway', label: '地铁优先', durationMinutes: 45, costYuan: 6, note: '稳定、低成本，适合常规工作日。' },
    { id: 'taxi', label: '打车直达', durationMinutes: 28, costYuan: 38, note: '时间不够或临近降雨时更有价值。' },
    { id: 'bus_walk', label: '公交 + 步行', durationMinutes: 52, costYuan: 4, note: '晴天可选，但暴雨和高温场景要降权。' }
  ];
  static readonly DEFAULT_COMMUTE_OPTIONS_JSON: string = JSON.stringify(SetupStore.DEFAULT_COMMUTE_OPTIONS);

  static initialize(): void {
    PersistentStorage.persistProps([
      { key: SetupStore.KEY_HOME_ADDRESS, defaultValue: '' },
      { key: SetupStore.KEY_OFFICE_ADDRESS, defaultValue: '' },
      { key: SetupStore.KEY_HOME_ADDRESS_SELECTION_JSON, defaultValue: '' },
      { key: SetupStore.KEY_OFFICE_ADDRESS_SELECTION_JSON, defaultValue: '' },
      { key: SetupStore.KEY_WORK_START_TIME, defaultValue: SetupStore.DEFAULT_WORK_START_TIME },
      { key: SetupStore.KEY_CHECKLIST_TEXT, defaultValue: SetupStore.DEFAULT_CHECKLIST_TEXT },
      { key: SetupStore.KEY_COMMUTE_OPTIONS_JSON, defaultValue: SetupStore.DEFAULT_COMMUTE_OPTIONS_JSON },
      { key: SetupStore.KEY_SETUP_COMPLETED, defaultValue: false }
    ]);
    SetupStore.applyLocalSeedIfNeeded();
  }

  static getSnapshot(): SetupSnapshot {
    return {
      homeAddress: SetupStore.getString(SetupStore.KEY_HOME_ADDRESS),
      officeAddress: SetupStore.getString(SetupStore.KEY_OFFICE_ADDRESS),
      homeAddressSelection: SetupStore.getAddressSelection(SetupStore.KEY_HOME_ADDRESS_SELECTION_JSON),
      officeAddressSelection: SetupStore.getAddressSelection(SetupStore.KEY_OFFICE_ADDRESS_SELECTION_JSON),
      workStartTime: SetupStore.getString(SetupStore.KEY_WORK_START_TIME) || SetupStore.DEFAULT_WORK_START_TIME,
      checklistText: SetupStore.getString(SetupStore.KEY_CHECKLIST_TEXT) || SetupStore.DEFAULT_CHECKLIST_TEXT,
      commuteOptions: SetupStore.getCommuteOptions(),
      setupCompleted: SetupStore.isSetupCompleted()
    };
  }

  static saveSetup(payload: SetupPayload): void {
    AppStorage.set(SetupStore.KEY_HOME_ADDRESS, payload.homeAddress.trim());
    AppStorage.set(SetupStore.KEY_OFFICE_ADDRESS, payload.officeAddress.trim());
    AppStorage.set(SetupStore.KEY_HOME_ADDRESS_SELECTION_JSON, JSON.stringify(payload.homeAddressSelection ??
      SetupStore.createManualAddressSelection(payload.homeAddress)));
    AppStorage.set(SetupStore.KEY_OFFICE_ADDRESS_SELECTION_JSON, JSON.stringify(payload.officeAddressSelection ??
      SetupStore.createManualAddressSelection(payload.officeAddress)));
    AppStorage.set(SetupStore.KEY_WORK_START_TIME, payload.workStartTime.trim());
    AppStorage.set(SetupStore.KEY_CHECKLIST_TEXT, SetupStore.normalizeChecklistText(payload.checklistText));
    AppStorage.set(SetupStore.KEY_COMMUTE_OPTIONS_JSON, JSON.stringify(payload.commuteOptions));
    AppStorage.set(SetupStore.KEY_SETUP_COMPLETED, true);
  }

  static isSetupCompleted(): boolean {
    const homeAddress = SetupStore.getString(SetupStore.KEY_HOME_ADDRESS).trim();
    const officeAddress = SetupStore.getString(SetupStore.KEY_OFFICE_ADDRESS).trim();
    const workStartTime = SetupStore.getString(SetupStore.KEY_WORK_START_TIME).trim();
    const checklistItems = SetupStore.getChecklistItems();
    const commuteOptions = SetupStore.getCommuteOptions();
    const completedFlag = AppStorage.get<boolean>(SetupStore.KEY_SETUP_COMPLETED) ?? false;

    return completedFlag && homeAddress.length > 0 && officeAddress.length > 0 && workStartTime.length > 0 &&
      checklistItems.length > 0 && commuteOptions.length >= 2;
  }

  static getCommuteOptions(): CommuteOption[] {
    const storedValue = SetupStore.getString(SetupStore.KEY_COMMUTE_OPTIONS_JSON) || SetupStore.DEFAULT_COMMUTE_OPTIONS_JSON;
    try {
      const parsed = JSON.parse(storedValue) as CommuteOption[];
      if (Array.isArray(parsed) && parsed.length > 0) {
        return parsed.map((item: CommuteOption): CommuteOption => ({
          id: item.id,
          label: item.label,
          durationMinutes: Number(item.durationMinutes),
          costYuan: Number(item.costYuan),
          note: item.note
        }));
      }
    } catch (error) {
      console.error(`Failed to parse commute options: ${JSON.stringify(error)}`);
    }
    return JSON.parse(SetupStore.DEFAULT_COMMUTE_OPTIONS_JSON) as CommuteOption[];
  }

  static getChecklistItems(): string[] {
    return SetupStore.normalizeChecklistText(SetupStore.getString(SetupStore.KEY_CHECKLIST_TEXT))
      .split(',')
      .map((item: string) => item.trim())
      .filter((item: string) => item.length > 0);
  }

  static createManualAddressSelection(address: string): AddressSelection {
    const normalizedAddress = address.trim();
    return {
      source: 'manual',
      name: normalizedAddress,
      address: normalizedAddress,
      selectedAt: Date.now()
    };
  }

  static getAddressSelection(key: string): AddressSelection | undefined {
    const storedValue = SetupStore.getString(key);
    if (storedValue.trim().length === 0) {
      return undefined;
    }

    try {
      const parsed = JSON.parse(storedValue) as AddressSelection;
      if (parsed.source === 'manual' && parsed.address.trim().length > 0) {
        return parsed;
      }
      if (parsed.source === 'place_search' && parsed.address.trim().length > 0 &&
        Number.isFinite(parsed.latitude) && Number.isFinite(parsed.longitude)) {
        return parsed;
      }
    } catch (error) {
      console.error(`Failed to parse address selection: ${JSON.stringify(error)}`);
    }
    return undefined;
  }

  static calculateLeaveTime(targetTime: string, durationMinutes: number, bufferMinutes: number = 20): string {
    const match = targetTime.trim().match(/^(\d{1,2}):(\d{2})$/);
    if (!match) {
      return targetTime;
    }
    const hour = Number(match[1]);
    const minute = Number(match[2]);
    let totalMinutes = hour * 60 + minute - durationMinutes - bufferMinutes;
    while (totalMinutes < 0) {
      totalMinutes += 24 * 60;
    }
    const leaveHour = Math.floor(totalMinutes / 60) % 24;
    const leaveMinute = totalMinutes % 60;
    return `${leaveHour.toString().padStart(2, '0')}:${leaveMinute.toString().padStart(2, '0')}`;
  }

  static normalizeChecklistText(text: string): string {
    return text
      .replace(/，/g, ',')
      .replace(/\n/g, ',')
      .split(',')
      .map((item: string) => item.trim())
      .filter((item: string) => item.length > 0)
      .join(',');
  }

  private static getString(key: string): string {
    return AppStorage.get<string>(key) ?? '';
  }

  private static applyLocalSeedIfNeeded(): void {
    if (!SETUP_SEED_ENABLED || SetupStore.isSetupCompleted()) {
      return;
    }
    const homeName = SETUP_SEED_HOME_NAME.trim();
    const homeAddress = SETUP_SEED_HOME_ADDRESS.trim();
    const officeName = SETUP_SEED_OFFICE_NAME.trim();
    const officeAddress = SETUP_SEED_OFFICE_ADDRESS.trim();
    const workStartTime = SETUP_SEED_WORK_START_TIME.trim();
    if (homeName.length === 0 || homeAddress.length === 0 || officeName.length === 0 || officeAddress.length === 0 ||
      workStartTime.length === 0) {
      return;
    }
    const selectedAt = Date.now();
    SetupStore.saveSetup({
      homeAddress: `${homeName} ${homeAddress}`,
      officeAddress: `${officeName} ${officeAddress}`,
      homeAddressSelection: {
        source: 'place_search',
        provider: 'local_seed',
        placeId: 'local-home-seed',
        name: homeName,
        address: homeAddress,
        latitude: 0,
        longitude: 0,
        selectedAt
      },
      officeAddressSelection: {
        source: 'place_search',
        provider: 'local_seed',
        placeId: 'local-office-seed',
        name: officeName,
        address: officeAddress,
        latitude: 0,
        longitude: 0,
        selectedAt
      },
      workStartTime,
      checklistText: SetupStore.DEFAULT_CHECKLIST_TEXT,
      commuteOptions: SetupStore.getCommuteOptions()
    });
  }
}
