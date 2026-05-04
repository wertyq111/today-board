import { common } from '@kit.AbilityKit';
import { AmapWeatherService } from './AmapWeatherService';
import { LocationService } from './LocationService';

export type WeatherSignal = 'unknown' | 'clear' | 'rain_soon' | 'sunny' | 'rainy' | 'snowy' | 'cloudy';
export type WeatherSyncState = 'idle' | 'ready' | 'missing_location' | 'unavailable' | 'empty' | 'error';

export interface WeatherSnapshot {
  syncState: WeatherSyncState;
  signal: WeatherSignal;
  temperature: string;
  apparentTemperature: string;
  condition: string;
  rainHint: string;
  updatedAt: string;
  summary: string;
  source?: string;
  errorCode?: number;
  observedAt?: string;
}

interface WeatherErrorLike {
  code?: number;
  message?: string;
}

export class WeatherService {
  static readonly KEY_SYNC_STATE: string = 'weather.syncState';
  static readonly KEY_SIGNAL: string = 'weather.signal';
  static readonly KEY_TEMPERATURE: string = 'weather.temperature';
  static readonly KEY_APPARENT_TEMPERATURE: string = 'weather.apparentTemperature';
  static readonly KEY_CONDITION: string = 'weather.condition';
  static readonly KEY_RAIN_HINT: string = 'weather.rainHint';
  static readonly KEY_UPDATED_AT: string = 'weather.updatedAt';
  static readonly KEY_SUMMARY: string = 'weather.summary';
  static readonly KEY_SOURCE: string = 'weather.source';
  static readonly KEY_ERROR_CODE: string = 'weather.errorCode';
  static readonly KEY_OBSERVED_AT: string = 'weather.observedAt';

  static initialize(): void {
    AppStorage.setOrCreate(WeatherService.KEY_SYNC_STATE, 'idle');
    AppStorage.setOrCreate(WeatherService.KEY_SIGNAL, 'unknown');
    AppStorage.setOrCreate(WeatherService.KEY_TEMPERATURE, '');
    AppStorage.setOrCreate(WeatherService.KEY_APPARENT_TEMPERATURE, '');
    AppStorage.setOrCreate(WeatherService.KEY_CONDITION, '');
    AppStorage.setOrCreate(WeatherService.KEY_RAIN_HINT, '');
    AppStorage.setOrCreate(WeatherService.KEY_UPDATED_AT, '');
    AppStorage.setOrCreate(WeatherService.KEY_SUMMARY, '还没有刷新本地天气。');
    AppStorage.setOrCreate(WeatherService.KEY_SOURCE, '');
    AppStorage.setOrCreate(WeatherService.KEY_ERROR_CODE, 0);
    AppStorage.setOrCreate(WeatherService.KEY_OBSERVED_AT, '');
  }

  static getSnapshot(): WeatherSnapshot {
    return {
      syncState: WeatherService.getString(WeatherService.KEY_SYNC_STATE) as WeatherSyncState || 'idle',
      signal: WeatherService.getString(WeatherService.KEY_SIGNAL) as WeatherSignal || 'unknown',
      temperature: WeatherService.getString(WeatherService.KEY_TEMPERATURE),
      apparentTemperature: WeatherService.getString(WeatherService.KEY_APPARENT_TEMPERATURE),
      condition: WeatherService.getString(WeatherService.KEY_CONDITION),
      rainHint: WeatherService.getString(WeatherService.KEY_RAIN_HINT),
      updatedAt: WeatherService.getString(WeatherService.KEY_UPDATED_AT),
      summary: WeatherService.getString(WeatherService.KEY_SUMMARY) || '还没有刷新本地天气。',
      source: WeatherService.getString(WeatherService.KEY_SOURCE),
      errorCode: AppStorage.get<number>(WeatherService.KEY_ERROR_CODE) ?? 0,
      observedAt: WeatherService.getString(WeatherService.KEY_OBSERVED_AT)
    };
  }

  static async refresh(hostContext: common.Context, requestLocationPermission: boolean = false): Promise<WeatherSnapshot> {
    const location = await LocationService.refresh(hostContext, requestLocationPermission);
    if (location.syncState !== 'ready') {
      WeatherService.applySnapshot({
        syncState: 'missing_location',
        signal: 'unknown',
        temperature: '',
        apparentTemperature: '',
        condition: '',
        rainHint: '',
        updatedAt: WeatherService.formatCurrentTime(),
        summary: location.summary,
        source: AmapWeatherService.PROVIDER_AMAP,
        observedAt: WeatherService.formatCurrentTime()
      });
      return WeatherService.getSnapshot();
    }

    try {
      const amapSnapshot = await AmapWeatherService.fetchSnapshotByAdcode(location.adcode);
      const snapshot: WeatherSnapshot = {
        syncState: amapSnapshot.syncState as WeatherSyncState,
        signal: amapSnapshot.signal as WeatherSignal,
        temperature: amapSnapshot.temperature,
        apparentTemperature: amapSnapshot.apparentTemperature,
        condition: amapSnapshot.condition,
        rainHint: amapSnapshot.rainHint,
        updatedAt: amapSnapshot.updatedAt,
        summary: amapSnapshot.summary,
        source: amapSnapshot.source,
        observedAt: amapSnapshot.observedAt
      };
      WeatherService.applySnapshot(snapshot);
      return WeatherService.getSnapshot();
    } catch (error) {
      const snapshot = WeatherService.createErrorSnapshot(error);
      WeatherService.applySnapshot(snapshot);
      return WeatherService.getSnapshot();
    }
  }

  private static createErrorSnapshot(error: object): WeatherSnapshot {
    console.error(`Failed to refresh AMap weather: ${JSON.stringify(error)}`);
    const code = WeatherService.getErrorCode(error);
    const message = WeatherService.getErrorMessage(error);
    if (message.includes('暂无天气数据')) {
      return {
        syncState: 'empty',
        signal: 'unknown',
        temperature: '',
        apparentTemperature: '',
        condition: '',
        rainHint: '',
        updatedAt: WeatherService.formatCurrentTime(),
        summary: '当前位置暂无高德天气数据。',
        source: AmapWeatherService.PROVIDER_AMAP,
        errorCode: code,
        observedAt: WeatherService.formatCurrentTime()
      };
    }
    return {
      syncState: 'error',
      signal: 'unknown',
      temperature: '',
      apparentTemperature: '',
      condition: '',
      rainHint: '',
      updatedAt: WeatherService.formatCurrentTime(),
      summary: message.length > 0 ? message : '高德天气刷新失败。',
      source: AmapWeatherService.PROVIDER_AMAP,
      errorCode: code,
      observedAt: WeatherService.formatCurrentTime()
    };
  }

  private static createUnavailableSnapshot(summary: string, errorCode: number = 0): WeatherSnapshot {
    return {
      syncState: 'unavailable',
      signal: 'unknown',
      temperature: '',
      apparentTemperature: '',
      condition: '',
      rainHint: '',
      updatedAt: WeatherService.formatCurrentTime(),
      summary: summary,
      source: AmapWeatherService.PROVIDER_AMAP,
      errorCode: errorCode,
      observedAt: WeatherService.formatCurrentTime()
    };
  }

  private static getErrorCode(error: object): number {
    const errorLike = error as WeatherErrorLike;
    return typeof errorLike.code === 'number' ? errorLike.code : 0;
  }

  private static getErrorMessage(error: object): string {
    const errorLike = error as WeatherErrorLike;
    if (typeof errorLike.message === 'string') {
      return errorLike.message;
    }
    return '';
  }

  private static applySnapshot(snapshot: WeatherSnapshot): void {
    AppStorage.set(WeatherService.KEY_SYNC_STATE, snapshot.syncState);
    AppStorage.set(WeatherService.KEY_SIGNAL, snapshot.signal);
    AppStorage.set(WeatherService.KEY_TEMPERATURE, snapshot.temperature);
    AppStorage.set(WeatherService.KEY_APPARENT_TEMPERATURE, snapshot.apparentTemperature);
    AppStorage.set(WeatherService.KEY_CONDITION, snapshot.condition);
    AppStorage.set(WeatherService.KEY_RAIN_HINT, snapshot.rainHint);
    AppStorage.set(WeatherService.KEY_UPDATED_AT, snapshot.updatedAt);
    AppStorage.set(WeatherService.KEY_SUMMARY, snapshot.summary);
    AppStorage.set(WeatherService.KEY_SOURCE, snapshot.source ?? '');
    AppStorage.set(WeatherService.KEY_ERROR_CODE, snapshot.errorCode ?? 0);
    AppStorage.set(WeatherService.KEY_OBSERVED_AT, snapshot.observedAt ?? '');
  }

  private static getString(key: string): string {
    return AppStorage.get<string>(key) ?? '';
  }

  private static formatCurrentTime(): string {
    const now = new Date();
    return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
  }
}
