import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import geoLocationManager from '@ohos.geoLocationManager';
import { AmapWeatherService, AmapResolvedLocation } from './AmapWeatherService';

export type LocationPermissionState = 'unknown' | 'granted' | 'denied';
export type LocationSyncState = 'idle' | 'ready' | 'denied' | 'disabled' | 'error';

export interface LocationSnapshot {
  permissionState: LocationPermissionState;
  syncState: LocationSyncState;
  latitude: number;
  longitude: number;
  accuracy: number;
  adcode: string;
  province: string;
  city: string;
  district: string;
  address: string;
  summary: string;
}

export class LocationService {
  static readonly KEY_PERMISSION_STATE: string = 'location.permissionState';
  static readonly KEY_SYNC_STATE: string = 'location.syncState';
  static readonly KEY_LATITUDE: string = 'location.latitude';
  static readonly KEY_LONGITUDE: string = 'location.longitude';
  static readonly KEY_ACCURACY: string = 'location.accuracy';
  static readonly KEY_ADCODE: string = 'location.adcode';
  static readonly KEY_PROVINCE: string = 'location.province';
  static readonly KEY_CITY: string = 'location.city';
  static readonly KEY_DISTRICT: string = 'location.district';
  static readonly KEY_ADDRESS: string = 'location.address';
  static readonly KEY_SUMMARY: string = 'location.summary';
  static readonly ACCURATE_LOCATION_PERMISSION: 'ohos.permission.LOCATION' = 'ohos.permission.LOCATION';
  static readonly APPROXIMATE_LOCATION_PERMISSION: 'ohos.permission.APPROXIMATELY_LOCATION' =
    'ohos.permission.APPROXIMATELY_LOCATION';

  static initialize(): void {
    AppStorage.setOrCreate(LocationService.KEY_PERMISSION_STATE, 'unknown');
    AppStorage.setOrCreate(LocationService.KEY_SYNC_STATE, 'idle');
    AppStorage.setOrCreate(LocationService.KEY_LATITUDE, 0);
    AppStorage.setOrCreate(LocationService.KEY_LONGITUDE, 0);
    AppStorage.setOrCreate(LocationService.KEY_ACCURACY, 0);
    AppStorage.setOrCreate(LocationService.KEY_ADCODE, '');
    AppStorage.setOrCreate(LocationService.KEY_PROVINCE, '');
    AppStorage.setOrCreate(LocationService.KEY_CITY, '');
    AppStorage.setOrCreate(LocationService.KEY_DISTRICT, '');
    AppStorage.setOrCreate(LocationService.KEY_ADDRESS, '');
    AppStorage.setOrCreate(LocationService.KEY_SUMMARY, '还没有检查定位权限。');
  }

  static getSnapshot(): LocationSnapshot {
    return {
      permissionState: LocationService.getString(LocationService.KEY_PERMISSION_STATE) as LocationPermissionState || 'unknown',
      syncState: LocationService.getString(LocationService.KEY_SYNC_STATE) as LocationSyncState || 'idle',
      latitude: LocationService.getNumber(LocationService.KEY_LATITUDE),
      longitude: LocationService.getNumber(LocationService.KEY_LONGITUDE),
      accuracy: LocationService.getNumber(LocationService.KEY_ACCURACY),
      adcode: LocationService.getString(LocationService.KEY_ADCODE),
      province: LocationService.getString(LocationService.KEY_PROVINCE),
      city: LocationService.getString(LocationService.KEY_CITY),
      district: LocationService.getString(LocationService.KEY_DISTRICT),
      address: LocationService.getString(LocationService.KEY_ADDRESS),
      summary: LocationService.getString(LocationService.KEY_SUMMARY) || '还没有检查定位权限。'
    };
  }

  static async refresh(hostContext: common.Context, requestPermission: boolean = false): Promise<LocationSnapshot> {
    const atManager = abilityAccessCtrl.createAtManager();
    const tokenId = hostContext.applicationInfo.accessTokenId;
    let accuratePermissionGranted = atManager.checkAccessTokenSync(tokenId, LocationService.ACCURATE_LOCATION_PERMISSION) ===
      abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    let approximatePermissionGranted = atManager.checkAccessTokenSync(tokenId,
      LocationService.APPROXIMATE_LOCATION_PERMISSION) ===
      abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;

    if ((!accuratePermissionGranted || !approximatePermissionGranted) && requestPermission) {
      const permissionResult = await atManager.requestPermissionsFromUser(hostContext, [
        LocationService.ACCURATE_LOCATION_PERMISSION,
        LocationService.APPROXIMATE_LOCATION_PERMISSION
      ]);
      accuratePermissionGranted = permissionResult.authResults[0] === 0;
      approximatePermissionGranted = permissionResult.authResults[1] === 0;
    }

    if (!accuratePermissionGranted || !approximatePermissionGranted) {
      LocationService.applySnapshot({
        permissionState: 'denied',
        syncState: 'denied',
        latitude: 0,
        longitude: 0,
        accuracy: 0,
        adcode: '',
        province: '',
        city: '',
        district: '',
        address: '',
        summary: '需要开启精确定位权限，当前没法刷新本地天气。'
      });
      return LocationService.getSnapshot();
    }

    try {
      if (!geoLocationManager.isLocationEnabled()) {
        LocationService.applySnapshot({
          permissionState: 'granted',
          syncState: 'disabled',
          latitude: 0,
          longitude: 0,
          accuracy: 0,
          adcode: '',
          province: '',
          city: '',
          district: '',
          address: '',
          summary: '系统定位开关没有打开，当前没法刷新本地天气。'
        });
        return LocationService.getSnapshot();
      }

      const location = await geoLocationManager.getCurrentLocation({
        priority: geoLocationManager.LocationRequestPriority.ACCURACY,
        scenario: geoLocationManager.LocationRequestScenario.DAILY_LIFE_SERVICE
      });
      const resolvedLocation = await AmapWeatherService.resolveLocation(location.latitude, location.longitude);

      LocationService.applySnapshot({
        permissionState: 'granted',
        syncState: 'ready',
        latitude: location.latitude,
        longitude: location.longitude,
        accuracy: location.accuracy,
        adcode: resolvedLocation.adcode,
        province: resolvedLocation.province,
        city: resolvedLocation.city,
        district: resolvedLocation.district,
        address: resolvedLocation.address,
        summary: LocationService.buildSummary(resolvedLocation, location.accuracy)
      });
      return LocationService.getSnapshot();
    } catch (error) {
      console.error(`Failed to refresh location: ${JSON.stringify(error)}`);
      const message = LocationService.getErrorMessage(error);
      LocationService.applySnapshot({
        permissionState: 'granted',
        syncState: 'error',
        latitude: 0,
        longitude: 0,
        accuracy: 0,
        adcode: '',
        province: '',
        city: '',
        district: '',
        address: '',
        summary: message.length > 0 ? message : '定位读取失败，当前没法刷新本地天气。'
      });
      return LocationService.getSnapshot();
    }
  }

  private static applySnapshot(snapshot: LocationSnapshot): void {
    AppStorage.set(LocationService.KEY_PERMISSION_STATE, snapshot.permissionState);
    AppStorage.set(LocationService.KEY_SYNC_STATE, snapshot.syncState);
    AppStorage.set(LocationService.KEY_LATITUDE, snapshot.latitude);
    AppStorage.set(LocationService.KEY_LONGITUDE, snapshot.longitude);
    AppStorage.set(LocationService.KEY_ACCURACY, snapshot.accuracy);
    AppStorage.set(LocationService.KEY_ADCODE, snapshot.adcode);
    AppStorage.set(LocationService.KEY_PROVINCE, snapshot.province);
    AppStorage.set(LocationService.KEY_CITY, snapshot.city);
    AppStorage.set(LocationService.KEY_DISTRICT, snapshot.district);
    AppStorage.set(LocationService.KEY_ADDRESS, snapshot.address);
    AppStorage.set(LocationService.KEY_SUMMARY, snapshot.summary);
  }

  private static buildSummary(resolvedLocation: AmapResolvedLocation, accuracy: number): string {
    const placeText = LocationService.getPlaceText(resolvedLocation);
    const accuracyText = Math.round(accuracy);
    return `${placeText}，精度约 ${accuracyText} 米。`;
  }

  private static getPlaceText(resolvedLocation: AmapResolvedLocation): string {
    if (resolvedLocation.address.length > 0) {
      return resolvedLocation.address;
    }
    const cityText = resolvedLocation.city.length > 0 ? resolvedLocation.city : resolvedLocation.province;
    if (cityText.length > 0 && resolvedLocation.district.length > 0) {
      return `${cityText}${resolvedLocation.district}`;
    }
    if (cityText.length > 0) {
      return cityText;
    }
    if (resolvedLocation.district.length > 0) {
      return resolvedLocation.district;
    }
    return '已拿到当前位置';
  }

  private static getErrorMessage(error: object): string {
    const errorLike = error as Error;
    if (typeof errorLike.message === 'string') {
      return errorLike.message;
    }
    return '';
  }

  private static getString(key: string): string {
    return AppStorage.get<string>(key) ?? '';
  }

  private static getNumber(key: string): number {
    return AppStorage.get<number>(key) ?? 0;
  }
}
