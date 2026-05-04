import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import calendarManager from '@ohos.calendarManager';

export type CalendarPermissionState = 'unknown' | 'granted' | 'denied';
export type CalendarSyncState = 'idle' | 'ready' | 'empty' | 'denied' | 'error';

export interface CalendarSnapshot {
  permissionState: CalendarPermissionState;
  syncState: CalendarSyncState;
  targetTime: string;
  eventTitle: string;
  eventLocation: string;
  summary: string;
}

interface DayRange {
  start: number;
  end: number;
}

export class CalendarService {
  static readonly KEY_PERMISSION_STATE: string = 'calendar.permissionState';
  static readonly KEY_SYNC_STATE: string = 'calendar.syncState';
  static readonly KEY_TARGET_TIME: string = 'calendar.targetTime';
  static readonly KEY_EVENT_TITLE: string = 'calendar.eventTitle';
  static readonly KEY_EVENT_LOCATION: string = 'calendar.eventLocation';
  static readonly KEY_SUMMARY: string = 'calendar.summary';
  static readonly READ_PERMISSION: 'ohos.permission.READ_CALENDAR' = 'ohos.permission.READ_CALENDAR';

  static initialize(): void {
    AppStorage.setOrCreate(CalendarService.KEY_PERMISSION_STATE, 'unknown');
    AppStorage.setOrCreate(CalendarService.KEY_SYNC_STATE, 'idle');
    AppStorage.setOrCreate(CalendarService.KEY_TARGET_TIME, '');
    AppStorage.setOrCreate(CalendarService.KEY_EVENT_TITLE, '');
    AppStorage.setOrCreate(CalendarService.KEY_EVENT_LOCATION, '');
    AppStorage.setOrCreate(CalendarService.KEY_SUMMARY, '还没有检查系统日历。');
  }

  static getSnapshot(): CalendarSnapshot {
    return {
      permissionState: CalendarService.getString(CalendarService.KEY_PERMISSION_STATE) as CalendarPermissionState || 'unknown',
      syncState: CalendarService.getString(CalendarService.KEY_SYNC_STATE) as CalendarSyncState || 'idle',
      targetTime: CalendarService.getString(CalendarService.KEY_TARGET_TIME),
      eventTitle: CalendarService.getString(CalendarService.KEY_EVENT_TITLE),
      eventLocation: CalendarService.getString(CalendarService.KEY_EVENT_LOCATION),
      summary: CalendarService.getString(CalendarService.KEY_SUMMARY) || '还没有检查系统日历。'
    };
  }

  static async refresh(hostContext: common.Context, requestPermission: boolean = false): Promise<CalendarSnapshot> {
    const atManager = abilityAccessCtrl.createAtManager();
    const tokenId = hostContext.applicationInfo.accessTokenId;
    let permissionGranted = atManager.checkAccessTokenSync(tokenId, CalendarService.READ_PERMISSION) ===
      abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;

    if (!permissionGranted && requestPermission) {
      const permissionResult = await atManager.requestPermissionsFromUser(hostContext, [CalendarService.READ_PERMISSION]);
      permissionGranted = permissionResult.authResults.some((result: number) => result === 0);
    }

    if (!permissionGranted) {
      CalendarService.applySnapshot({
        permissionState: 'denied',
        syncState: 'denied',
        targetTime: '',
        eventTitle: '',
        eventLocation: '',
        summary: '没有日历权限，当前没法读取真实日历。'
      });
      return CalendarService.getSnapshot();
    }

    try {
      const manager = calendarManager.getCalendarManager(hostContext);
      const calendars = await manager.getAllCalendars();
      const dayRange = CalendarService.getTodayRange();
      const currentTimestamp = Date.now();
      const allEventGroups = await Promise.all(calendars.map((calendar: calendarManager.Calendar) =>
        calendar.queryEventInstances(dayRange.start, dayRange.end)));
      const allEvents: calendarManager.Event[] = [];
      allEventGroups.forEach((group: calendarManager.Event[]) => {
        group.forEach((event: calendarManager.Event) => {
          allEvents.push(event);
        });
      });

      const nextEvent = allEvents
        .filter((event: calendarManager.Event) => !event.isAllDay)
        .filter((event: calendarManager.Event) => CalendarService.getEventEndTime(event) > currentTimestamp)
        .sort((left: calendarManager.Event, right: calendarManager.Event) =>
          CalendarService.getEventStartTime(left) - CalendarService.getEventStartTime(right))[0];

      if (!nextEvent) {
        CalendarService.applySnapshot({
          permissionState: 'granted',
          syncState: 'empty',
          targetTime: '',
          eventTitle: '',
          eventLocation: '',
          summary: '今天没有后续日程。'
        });
        return CalendarService.getSnapshot();
      }

      const eventTitle = nextEvent.title?.trim() || '未命名日程';
      const eventLocation = CalendarService.getEventLocation(nextEvent);
      const targetTime = CalendarService.formatClock(CalendarService.getEventStartTime(nextEvent));
      const locationSuffix = eventLocation.length > 0 ? ` · ${eventLocation}` : '';

      CalendarService.applySnapshot({
        permissionState: 'granted',
        syncState: 'ready',
        targetTime,
        eventTitle,
        eventLocation,
        summary: `今天第一条有效日程是 ${targetTime} 的「${eventTitle}」${locationSuffix}`.trim()
      });
      return CalendarService.getSnapshot();
    } catch (error) {
      console.error(`Failed to refresh calendar: ${JSON.stringify(error)}`);
      CalendarService.applySnapshot({
        permissionState: 'granted',
        syncState: 'error',
        targetTime: '',
        eventTitle: '',
        eventLocation: '',
        summary: '系统日历读取失败。'
      });
      return CalendarService.getSnapshot();
    }
  }

  private static applySnapshot(snapshot: CalendarSnapshot): void {
    AppStorage.set(CalendarService.KEY_PERMISSION_STATE, snapshot.permissionState);
    AppStorage.set(CalendarService.KEY_SYNC_STATE, snapshot.syncState);
    AppStorage.set(CalendarService.KEY_TARGET_TIME, snapshot.targetTime);
    AppStorage.set(CalendarService.KEY_EVENT_TITLE, snapshot.eventTitle);
    AppStorage.set(CalendarService.KEY_EVENT_LOCATION, snapshot.eventLocation);
    AppStorage.set(CalendarService.KEY_SUMMARY, snapshot.summary);
  }

  private static getTodayRange(): DayRange {
    const now = new Date();
    const start = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
    const end = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59, 999);
    const range: DayRange = {
      start: start.getTime(),
      end: end.getTime()
    };

    return range;
  }

  private static getEventStartTime(event: calendarManager.Event): number {
    return event.instanceStartTime ?? event.startTime;
  }

  private static getEventEndTime(event: calendarManager.Event): number {
    return event.instanceEndTime ?? event.endTime;
  }

  private static getEventLocation(event: calendarManager.Event): string {
    const location = event.location;
    if (!location) {
      return '';
    }
    return location.location?.trim() || '';
  }

  private static formatClock(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  private static getString(key: string): string {
    return AppStorage.get<string>(key) ?? '';
  }
}
