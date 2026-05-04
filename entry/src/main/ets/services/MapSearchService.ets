import { http } from '@kit.NetworkKit';
import { MAP_SEARCH_API_KEY, MAP_SEARCH_CITY } from '../config/MapSearchConfig';
import { AddressSelection } from '../store/SetupStore';

export interface MapSearchResult {
  provider: string;
  placeId: string;
  name: string;
  address: string;
  latitude: number;
  longitude: number;
}

interface AMapPoi {
  id?: string;
  name?: string;
  address?: string | string[];
  location?: string;
}

interface AMapTextSearchResponse {
  status?: string;
  info?: string;
  infocode?: string;
  pois?: AMapPoi[];
}

export class MapSearchService {
  static readonly PROVIDER_AMAP: string = 'amap';
  static readonly KEY_PROVIDER: string = 'mapSearch.provider';
  static readonly KEY_API_KEY: string = 'mapSearch.apiKey';
  static readonly KEY_CITY: string = 'mapSearch.city';
  static readonly DEFAULT_PROVIDER: string = MapSearchService.PROVIDER_AMAP;
  static readonly DEFAULT_API_KEY: string = MAP_SEARCH_API_KEY.trim();
  static readonly DEFAULT_CITY: string = MAP_SEARCH_CITY.trim();

  static initialize(): void {
    PersistentStorage.persistProps([
      { key: MapSearchService.KEY_PROVIDER, defaultValue: MapSearchService.DEFAULT_PROVIDER },
      { key: MapSearchService.KEY_API_KEY, defaultValue: MapSearchService.DEFAULT_API_KEY },
      { key: MapSearchService.KEY_CITY, defaultValue: MapSearchService.DEFAULT_CITY }
    ]);
    MapSearchService.applyLocalConfig();
  }

  static saveConfig(apiKey: string, city: string): void {
    AppStorage.set(MapSearchService.KEY_PROVIDER, MapSearchService.DEFAULT_PROVIDER);
    AppStorage.set(MapSearchService.KEY_API_KEY, apiKey.trim());
    AppStorage.set(MapSearchService.KEY_CITY, city.trim());
  }

  static isConfigured(): boolean {
    return MapSearchService.getApiKey().length > 0;
  }

  static getCity(): string {
    return MapSearchService.getString(MapSearchService.KEY_CITY).trim();
  }

  static getMaskedKey(): string {
    const apiKey = MapSearchService.getApiKey();
    if (apiKey.length === 0) {
      return '未配置';
    }
    if (apiKey.length <= 8) {
      return '已配置';
    }
    return `${apiKey.slice(0, 4)}...${apiKey.slice(-4)}`;
  }

  static async search(keyword: string): Promise<MapSearchResult[]> {
    const normalizedKeyword = keyword.trim();
    if (normalizedKeyword.length < 2) {
      throw new Error('请输入至少 2 个字再搜索。');
    }

    const apiKey = MapSearchService.getApiKey();
    if (apiKey.length === 0) {
      throw new Error('地图搜索未配置，请先在设置页填入高德 Web 服务 Key。');
    }

    return MapSearchService.searchAmap(normalizedKeyword, apiKey, MapSearchService.getCity());
  }

  static toAddressSelection(result: MapSearchResult): AddressSelection {
    if (!Number.isFinite(result.latitude) || !Number.isFinite(result.longitude)) {
      throw new Error('地图结果缺少有效经纬度，不能保存。');
    }

    return {
      source: 'place_search',
      provider: result.provider,
      placeId: result.placeId,
      name: result.name,
      address: result.address,
      latitude: result.latitude,
      longitude: result.longitude,
      selectedAt: Date.now()
    };
  }

  private static async searchAmap(keyword: string, apiKey: string, city: string): Promise<MapSearchResult[]> {
    const queryParts: string[] = [
      `key=${encodeURIComponent(apiKey)}`,
      `keywords=${encodeURIComponent(keyword)}`,
      'offset=10',
      'page=1',
      'extensions=base',
      'output=JSON'
    ];
    if (city.trim().length > 0) {
      queryParts.push(`city=${encodeURIComponent(city.trim())}`);
      queryParts.push('citylimit=false');
    }

    const requestUrl = `https://restapi.amap.com/v3/place/text?${queryParts.join('&')}`;
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
        throw new Error(`地图搜索请求失败：HTTP ${response.responseCode}`);
      }

      const payload = JSON.parse(`${response.result}`) as AMapTextSearchResponse;
      if (payload.status !== '1') {
        throw new Error(`地图搜索失败：${payload.info ?? '未知错误'}${payload.infocode ? `(${payload.infocode})` : ''}`);
      }

      return MapSearchService.parseAmapPois(payload.pois ?? []);
    } finally {
      httpRequest.destroy();
    }
  }

  private static parseAmapPois(pois: AMapPoi[]): MapSearchResult[] {
    return pois
      .map((poi: AMapPoi): MapSearchResult | undefined => MapSearchService.parseAmapPoi(poi))
      .filter((item: MapSearchResult | undefined): boolean => item !== undefined) as MapSearchResult[];
  }

  private static parseAmapPoi(poi: AMapPoi): MapSearchResult | undefined {
    const name = MapSearchService.readText(poi.name);
    const address = MapSearchService.readText(poi.address);
    const placeId = MapSearchService.readText(poi.id);
    const location = MapSearchService.readText(poi.location);
    const coordinates = location.split(',');
    if (name.length === 0 || address.length === 0 || placeId.length === 0 || coordinates.length !== 2) {
      return undefined;
    }

    const longitude = Number(coordinates[0]);
    const latitude = Number(coordinates[1]);
    if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
      return undefined;
    }

    return {
      provider: MapSearchService.PROVIDER_AMAP,
      placeId,
      name,
      address,
      latitude,
      longitude
    };
  }

  private static readText(value: string | string[] | undefined): string {
    if (Array.isArray(value)) {
      return value.join('').trim();
    }
    return value?.trim() ?? '';
  }

  private static getApiKey(): string {
    return MapSearchService.getString(MapSearchService.KEY_API_KEY).trim();
  }

  private static applyLocalConfig(): void {
    if (MapSearchService.DEFAULT_API_KEY.length === 0) {
      return;
    }
    AppStorage.set(MapSearchService.KEY_PROVIDER, MapSearchService.DEFAULT_PROVIDER);
    AppStorage.set(MapSearchService.KEY_API_KEY, MapSearchService.DEFAULT_API_KEY);
    if (MapSearchService.DEFAULT_CITY.length > 0 || MapSearchService.getCity().length === 0) {
      AppStorage.set(MapSearchService.KEY_CITY, MapSearchService.DEFAULT_CITY);
    }
  }

  private static getString(key: string): string {
    return AppStorage.get<string>(key) ?? '';
  }
}
