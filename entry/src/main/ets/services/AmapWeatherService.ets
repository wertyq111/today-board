import { http } from '@kit.NetworkKit';
import { MAP_SEARCH_API_KEY } from '../config/MapSearchConfig';

type AmapWeatherSignal = 'unknown' | 'clear' | 'rain_soon' | 'sunny' | 'rainy' | 'snowy' | 'cloudy';

interface AmapWeatherSnapshot {
  syncState: 'ready' | 'unavailable';
  signal: AmapWeatherSignal;
  temperature: string;
  apparentTemperature: string;
  condition: string;
  rainHint: string;
  updatedAt: string;
  summary: string;
  source: string;
  observedAt: string;
}

export interface AmapResolvedLocation {
  adcode: string;
  province: string;
  city: string;
  district: string;
  address: string;
}

interface AMapAddressComponent {
  adcode?: string | string[];
  province?: string | string[];
  city?: string | string[];
  district?: string | string[];
}

interface AMapRegeocode {
  formatted_address?: string;
  addressComponent?: AMapAddressComponent;
}

interface AMapRegeoResponse {
  status?: string;
  info?: string;
  infocode?: string;
  regeocode?: AMapRegeocode;
}

interface AMapLiveWeather {
  city?: string;
  adcode?: string;
  weather?: string;
  temperature?: string;
  winddirection?: string;
  windpower?: string;
  humidity?: string;
  reporttime?: string;
}

interface AMapWeatherResponse {
  status?: string;
  info?: string;
  infocode?: string;
  lives?: AMapLiveWeather[];
}

export class AmapWeatherService {
  static readonly PROVIDER_AMAP: string = 'amap';
  private static readonly API_KEY: string = MAP_SEARCH_API_KEY.trim();

  static isConfigured(): boolean {
    return AmapWeatherService.API_KEY.length > 0;
  }

  static async fetchSnapshot(latitude: number, longitude: number): Promise<AmapWeatherSnapshot> {
    if (!AmapWeatherService.isConfigured()) {
      return AmapWeatherService.createUnavailableSnapshot('高德天气 Key 未配置，当前没法刷新真实天气。');
    }

    const resolvedLocation = await AmapWeatherService.resolveLocation(latitude, longitude);
    return AmapWeatherService.fetchSnapshotByAdcode(resolvedLocation.adcode);
  }

  static async fetchSnapshotByAdcode(adcode: string): Promise<AmapWeatherSnapshot> {
    if (!AmapWeatherService.isConfigured()) {
      return AmapWeatherService.createUnavailableSnapshot('高德天气 Key 未配置，当前没法刷新真实天气。');
    }

    const normalizedAdcode = adcode.trim();
    if (normalizedAdcode.length === 0) {
      throw new Error('高德天气刷新失败：定位缺少城市编码。');
    }

    const liveWeather = await AmapWeatherService.fetchLiveWeather(normalizedAdcode);
    const condition = AmapWeatherService.readText(liveWeather.weather);
    const temperature = AmapWeatherService.readText(liveWeather.temperature);
    const signal = AmapWeatherService.mapConditionToSignal(condition);
    const city = AmapWeatherService.readText(liveWeather.city);
    const reporttime = AmapWeatherService.readText(liveWeather.reporttime);
    const windDirection = AmapWeatherService.readText(liveWeather.winddirection);
    const windPower = AmapWeatherService.readText(liveWeather.windpower);
    const humidity = AmapWeatherService.readText(liveWeather.humidity);

    return {
      syncState: 'ready',
      signal,
      temperature,
      apparentTemperature: '',
      condition,
      rainHint: signal === 'rainy' ? '当前天气有降雨信号。' : '',
      updatedAt: AmapWeatherService.formatCurrentTime(),
      summary: AmapWeatherService.buildSummary(city, condition, temperature, windDirection, windPower, humidity),
      source: AmapWeatherService.PROVIDER_AMAP,
      observedAt: reporttime.length > 0 ? reporttime : AmapWeatherService.formatCurrentTime()
    };
  }

  static async resolveLocation(latitude: number, longitude: number): Promise<AmapResolvedLocation> {
    if (!AmapWeatherService.isConfigured()) {
      throw new Error('高德地图 Key 未配置，当前没法显示具体位置。');
    }

    const location = `${longitude},${latitude}`;
    const requestUrl = `https://restapi.amap.com/v3/geocode/regeo?key=${encodeURIComponent(AmapWeatherService.API_KEY)}&location=${encodeURIComponent(location)}&extensions=base&output=JSON`;
    const payload = await AmapWeatherService.requestJson<AMapRegeoResponse>(requestUrl, '天气定位反查失败');
    if (payload.status !== '1') {
      throw new Error(`天气定位反查失败：${payload.info ?? '未知错误'}${payload.infocode ? `(${payload.infocode})` : ''}`);
    }

    const adcode = AmapWeatherService.readText(payload.regeocode?.addressComponent?.adcode);
    if (adcode.length === 0) {
      throw new Error('天气定位反查失败：高德未返回城市编码。');
    }

    return {
      adcode,
      province: AmapWeatherService.readText(payload.regeocode?.addressComponent?.province),
      city: AmapWeatherService.readText(payload.regeocode?.addressComponent?.city),
      district: AmapWeatherService.readText(payload.regeocode?.addressComponent?.district),
      address: AmapWeatherService.readText(payload.regeocode?.formatted_address)
    };
  }

  private static async fetchLiveWeather(adcode: string): Promise<AMapLiveWeather> {
    const requestUrl = `https://restapi.amap.com/v3/weather/weatherInfo?key=${encodeURIComponent(AmapWeatherService.API_KEY)}&city=${encodeURIComponent(adcode)}&extensions=base&output=JSON`;
    const payload = await AmapWeatherService.requestJson<AMapWeatherResponse>(requestUrl, '高德天气刷新失败');
    if (payload.status !== '1') {
      throw new Error(`高德天气刷新失败：${payload.info ?? '未知错误'}${payload.infocode ? `(${payload.infocode})` : ''}`);
    }

    const lives = payload.lives ?? [];
    if (lives.length === 0) {
      throw new Error('高德天气刷新失败：当前位置暂无天气数据。');
    }
    return lives[0];
  }

  private static async requestJson<T>(requestUrl: string, errorPrefix: string): Promise<T> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(requestUrl, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 8000,
        readTimeout: 8000,
        usingCache: false
      });

      if (response.responseCode < 200 || response.responseCode >= 300) {
        throw new Error(`${errorPrefix}：HTTP ${response.responseCode}`);
      }
      return JSON.parse(`${response.result}`) as T;
    } finally {
      httpRequest.destroy();
    }
  }

  private static mapConditionToSignal(condition: string): AmapWeatherSignal {
    if (condition.includes('雪') || condition.includes('冻雨')) {
      return 'snowy';
    }
    if (condition.includes('雨') || condition.includes('雷')) {
      return 'rainy';
    }
    if (condition.includes('晴') || condition.includes('少云')) {
      return 'sunny';
    }
    if (condition.includes('云') || condition.includes('阴') || condition.includes('雾') ||
      condition.includes('霾') || condition.includes('沙') || condition.includes('尘')) {
      return 'cloudy';
    }
    return 'unknown';
  }

  private static buildSummary(city: string, condition: string, temperature: string, windDirection: string,
    windPower: string, humidity: string): string {
    const cityText = city.length > 0 ? `${city} ` : '';
    const temperatureText = temperature.length > 0 ? `${temperature}°C` : '';
    const windText = windDirection.length > 0 || windPower.length > 0 ? `，${windDirection}${windPower}风` : '';
    const humidityText = humidity.length > 0 ? `，湿度 ${humidity}%` : '';
    return `${cityText}${condition}${temperatureText.length > 0 ? ` ${temperatureText}` : ''}${windText}${humidityText}。`;
  }

  private static createUnavailableSnapshot(summary: string): AmapWeatherSnapshot {
    return {
      syncState: 'unavailable',
      signal: 'unknown',
      temperature: '',
      apparentTemperature: '',
      condition: '',
      rainHint: '',
      updatedAt: AmapWeatherService.formatCurrentTime(),
      summary,
      source: AmapWeatherService.PROVIDER_AMAP,
      observedAt: AmapWeatherService.formatCurrentTime()
    };
  }

  private static readText(value: string | string[] | undefined): string {
    if (Array.isArray(value)) {
      return value.length > 0 ? value[0].trim() : '';
    }
    return value?.trim() ?? '';
  }

  private static formatCurrentTime(): string {
    const now = new Date();
    return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
  }
}
