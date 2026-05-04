import { CalendarService } from './CalendarService';
import { LocationService } from './LocationService';
import { WeatherService, WeatherSnapshot } from './WeatherService';
import { BoardStore, ChecklistItem } from '../store/BoardStore';

export interface TodayBoardCardData {
  setupCompleted: boolean;
  title: string;
  routeLabel: string;
  leaveTime: string;
  umbrellaLabel: string;
  scenarioLabel: string;
  statusLabel: string;
  summary: string;
  updatedAt: string;
}

export class TodayBoardSnapshotService {
  static initialize(): void {
    BoardStore.initialize();
    CalendarService.initialize();
    LocationService.initialize();
    WeatherService.initialize();
  }

  static createCardData(): TodayBoardCardData {
    TodayBoardSnapshotService.initialize();
    const board = BoardStore.getSnapshot();
    const weather = WeatherService.getSnapshot();
    const calendar = CalendarService.getSnapshot();
    const checklistItems = board.checklistItems.filter((item: ChecklistItem): boolean => item.selected);

    return {
      setupCompleted: checklistItems.length > 0,
      title: '天气看门板',
      routeLabel: TodayBoardSnapshotService.getWeatherTitle(weather),
      leaveTime: TodayBoardSnapshotService.getPrimaryValue(weather, checklistItems.length),
      umbrellaLabel: TodayBoardSnapshotService.getUmbrellaLabel(weather.signal),
      scenarioLabel: `${checklistItems.length} 项清单`,
      statusLabel: TodayBoardSnapshotService.getStatusLabel(weather.syncState, calendar.syncState, checklistItems.length),
      summary: TodayBoardSnapshotService.getSummary(weather, calendar.syncState, checklistItems.length),
      updatedAt: TodayBoardSnapshotService.getCurrentTime()
    };
  }

  private static getWeatherTitle(weather: WeatherSnapshot): string {
    if (weather.syncState === 'ready') {
      if (weather.signal === 'rain_soon' || weather.signal === 'rainy') {
        return '有降雨提醒';
      }
      if (weather.signal === 'snowy') {
        return '有降雪提醒';
      }
      if (weather.signal === 'sunny' || weather.signal === 'clear') {
        return '晴天';
      }
      if (weather.signal === 'cloudy') {
        return '云天';
      }
      return '天气已接入';
    }
    if (weather.syncState === 'unavailable') {
      return '天气待接入';
    }
    if (weather.syncState === 'empty') {
      return '天气无数据';
    }
    if (weather.syncState === 'missing_location') {
      return '等待定位';
    }
    if (weather.syncState === 'error') {
      return '天气刷新失败';
    }
    return '天气待检查';
  }

  private static getPrimaryValue(weather: WeatherSnapshot, checklistCount: number): string {
    if (weather.syncState === 'ready' && weather.temperature.trim().length > 0) {
      return `${weather.temperature.trim()}°C`;
    }
    if (weather.syncState === 'ready') {
      return '已接入';
    }
    return `清单 ${checklistCount} 项`;
  }

  private static getStatusLabel(weatherState: string, calendarState: string, checklistCount: number): string {
    if (weatherState === 'ready') {
      return '天气可用';
    }
    if (weatherState === 'empty') {
      return '天气无数据';
    }
    if (calendarState === 'ready') {
      return '日历可用';
    }
    return checklistCount > 0 ? '清单可用' : '待配置';
  }

  private static getUmbrellaLabel(signal: string): string {
    if (signal === 'rain_soon' || signal === 'rainy') {
      return '带伞';
    }
    if (signal === 'clear' || signal === 'sunny') {
      return '不用特意带伞';
    }
    if (signal === 'snowy') {
      return '防滑保暖';
    }
    if (signal === 'cloudy') {
      return '按清单出门';
    }
    return '天气未接入';
  }

  private static getSummary(weather: WeatherSnapshot, calendarState: string, checklistCount: number): string {
    if (weather.signal === 'rain_soon' || weather.signal === 'rainy') {
      return '今天有降雨信号，出门前优先确认雨伞。';
    }
    if (weather.signal === 'snowy') {
      return '今天有降雪信号，出门前优先确认鞋子和保暖物品。';
    }
    if (weather.signal === 'sunny' || weather.signal === 'clear') {
      return `今天晴，出门前确认 ${checklistCount} 项清单。`;
    }
    if (weather.syncState === 'unavailable') {
      return '天气能力暂不可用，卡片先展示清单和日历状态。';
    }
    if (weather.syncState === 'empty') {
      return '当前位置暂无天气数据，卡片先展示清单和日历状态。';
    }
    if (calendarState === 'ready') {
      return `今天已有日历信号，出门前确认 ${checklistCount} 项清单。`;
    }
    return `出门前确认 ${checklistCount} 项清单；天气接入后自动补充提醒。`;
  }

  private static getCurrentTime(): string {
    const now = new Date();
    return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
  }
}
