import { CommuteOption } from '../store/SetupStore';

export type WeatherSignal = 'unknown' | 'clear' | 'rain_soon';

export interface CommuteDecisionInput {
  currentTime: string;
  targetArrivalTime: string;
  commuteOptions: CommuteOption[];
  checklistItems: string[];
  weatherSignal: WeatherSignal;
  hasCalendarData: boolean;
}

export interface CommuteDecisionResult {
  status: 'ready' | 'incomplete';
  scenarioLabel: string;
  recommendedOption: CommuteOption;
  leaveTime: string;
  reasons: string[];
  riskHint: string;
  reminder: string;
  summary: string;
  pendingSignals: string[];
}

interface CommuteOptionProfile {
  stabilityScore: number;
  outdoorExposureScore: number;
}

interface EvaluatedOption {
  option: CommuteOption;
  profile: CommuteOptionProfile;
  leaveTime: string;
  minutesUntilRecommendedLeave: number;
  minutesUntilHardDeadline: number;
}

export class CommuteDecisionEngine {
  static readonly LEAVE_BUFFER_MINUTES: number = 20;

  static decide(input: CommuteDecisionInput): CommuteDecisionResult {
    if (input.commuteOptions.length === 0) {
      throw new Error('CommuteDecisionEngine requires at least one commute option.');
    }

    const currentMinutes = CommuteDecisionEngine.parseClock(input.currentTime);
    const targetMinutes = CommuteDecisionEngine.parseClock(input.targetArrivalTime);
    const evaluatedOptions = input.commuteOptions.map((option: CommuteOption) =>
      CommuteDecisionEngine.evaluateOption(option, currentMinutes, targetMinutes));
    const fastestOption = CommuteDecisionEngine.pickFastest(evaluatedOptions);
    const cheapestOption = CommuteDecisionEngine.pickCheapest(evaluatedOptions);
    const mostStableOption = CommuteDecisionEngine.pickMostStable(evaluatedOptions);
    const lowestExposureOption = CommuteDecisionEngine.pickLowestOutdoorExposure(evaluatedOptions);
    const pendingSignals = CommuteDecisionEngine.buildPendingSignals(input);

    let scenarioLabel = '稳妥优先';
    let recommended = mostStableOption;
    let reasons: string[] = [
      '当前没有触发抢时间、避雨或省钱条件，先按更稳的固定方案处理。',
      `${mostStableOption.option.label} 的建议出发时间是 ${mostStableOption.leaveTime}。`
    ];
    let riskHint = '如果你比建议时间再晚很多，首页就应该切到更快方案。';

    if (fastestOption.minutesUntilHardDeadline < 0) {
      scenarioLabel = '已经晚了';
      recommended = fastestOption;
      reasons = [
        `按 ${input.targetArrivalTime} 到达来算，${fastestOption.option.label} 的硬截止时间也已经被压过了。`,
        `现在只剩最短耗时方案还能尽量少迟到。`
      ];
      riskHint = '别再停留，缓冲时间已经全部吃掉了。';
    } else if (fastestOption.minutesUntilRecommendedLeave <= 15) {
      scenarioLabel = '抢时间';
      recommended = fastestOption;
      reasons = [
        `离 ${fastestOption.option.label} 的建议出发时间只剩 ${Math.max(fastestOption.minutesUntilRecommendedLeave, 0)} 分钟。`,
        `先按最短耗时 ${fastestOption.option.durationMinutes} 分钟的方案抢时间。`
      ];
      riskHint = '再拖几分钟，连最快方案的缓冲时间都会被吃掉。';
    } else if (input.weatherSignal === 'rain_soon') {
      scenarioLabel = '避雨优先';
      recommended = lowestExposureOption;
      reasons = [
        '临近降雨时，先减少室外暴露，再看耗时和费用。',
        `${lowestExposureOption.option.label} 的室外暴露更少，建议 ${lowestExposureOption.leaveTime} 前出门。`
      ];
      riskHint = '如果雨势提前，尽量避免带长步行段的方案。';
    } else if (input.weatherSignal === 'clear' && fastestOption.minutesUntilRecommendedLeave >= 55) {
      scenarioLabel = '省钱优先';
      recommended = cheapestOption;
      reasons = [
        `离最早建议出发点还有 ${fastestOption.minutesUntilRecommendedLeave} 分钟，时间比较宽。`,
        `今天可以用更低成本的 ${cheapestOption.option.label}。`
      ];
      riskHint = '如果临时出门时间往后拖，就要重新切回更稳或更快的方案。';
    }

    return {
      status: pendingSignals.length > 0 ? 'incomplete' : 'ready',
      scenarioLabel,
      recommendedOption: recommended.option,
      leaveTime: recommended.leaveTime,
      reasons,
      riskHint,
      reminder: CommuteDecisionEngine.buildReminder(recommended.option, input.checklistItems, input.weatherSignal),
      summary: `推荐 ${recommended.option.label}，建议 ${recommended.leaveTime} 前出门，路上约 ${recommended.option.durationMinutes} 分钟，费用约 ${recommended.option.costYuan} 元。`,
      pendingSignals
    };
  }

  private static evaluateOption(option: CommuteOption, currentMinutes: number, targetMinutes: number): EvaluatedOption {
    const recommendedLeaveMinutes = targetMinutes - option.durationMinutes - CommuteDecisionEngine.LEAVE_BUFFER_MINUTES;
    const hardDeadlineMinutes = targetMinutes - option.durationMinutes;

    return {
      option,
      profile: CommuteDecisionEngine.getOptionProfile(option.id),
      leaveTime: CommuteDecisionEngine.formatClock(recommendedLeaveMinutes),
      minutesUntilRecommendedLeave: recommendedLeaveMinutes - currentMinutes,
      minutesUntilHardDeadline: hardDeadlineMinutes - currentMinutes
    };
  }

  private static pickFastest(options: EvaluatedOption[]): EvaluatedOption {
    return [...options].sort((left: EvaluatedOption, right: EvaluatedOption) => {
      if (left.option.durationMinutes !== right.option.durationMinutes) {
        return left.option.durationMinutes - right.option.durationMinutes;
      }
      return left.option.costYuan - right.option.costYuan;
    })[0];
  }

  private static pickCheapest(options: EvaluatedOption[]): EvaluatedOption {
    return [...options].sort((left: EvaluatedOption, right: EvaluatedOption) => {
      if (left.option.costYuan !== right.option.costYuan) {
        return left.option.costYuan - right.option.costYuan;
      }
      return left.option.durationMinutes - right.option.durationMinutes;
    })[0];
  }

  private static pickMostStable(options: EvaluatedOption[]): EvaluatedOption {
    return [...options].sort((left: EvaluatedOption, right: EvaluatedOption) => {
      if (left.profile.stabilityScore !== right.profile.stabilityScore) {
        return right.profile.stabilityScore - left.profile.stabilityScore;
      }
      if (left.option.durationMinutes !== right.option.durationMinutes) {
        return left.option.durationMinutes - right.option.durationMinutes;
      }
      return left.option.costYuan - right.option.costYuan;
    })[0];
  }

  private static pickLowestOutdoorExposure(options: EvaluatedOption[]): EvaluatedOption {
    return [...options].sort((left: EvaluatedOption, right: EvaluatedOption) => {
      if (left.profile.outdoorExposureScore !== right.profile.outdoorExposureScore) {
        return left.profile.outdoorExposureScore - right.profile.outdoorExposureScore;
      }
      if (left.option.durationMinutes !== right.option.durationMinutes) {
        return left.option.durationMinutes - right.option.durationMinutes;
      }
      return right.profile.stabilityScore - left.profile.stabilityScore;
    })[0];
  }

  private static buildPendingSignals(input: CommuteDecisionInput): string[] {
    const pendingSignals: string[] = [];

    if (input.weatherSignal === 'unknown') {
      pendingSignals.push('天气还没接入，当前结论没把降雨和体感算进去。');
    }
    if (!input.hasCalendarData) {
      pendingSignals.push(`当前先按默认上班时间 ${input.targetArrivalTime} 计算，还没读取系统日历。`);
    }

    return pendingSignals;
  }

  private static buildReminder(option: CommuteOption, checklistItems: string[], weatherSignal: WeatherSignal): string {
    const normalizedItems = checklistItems
      .map((item: string) => item.trim())
      .filter((item: string) => item.length > 0);
    const briefChecklist = normalizedItems.slice(0, 2).join('、');

    if (weatherSignal === 'rain_soon' && normalizedItems.some((item: string) => item.includes('伞'))) {
      return '先把雨伞拿上，再出门。';
    }
    if (option.id === 'bus_walk' && normalizedItems.some((item: string) => item.includes('水杯'))) {
      return '步行段更长，水杯别忘了。';
    }
    if (option.id === 'taxi') {
      return briefChecklist.length > 0 ? `时间紧，先确认 ${briefChecklist}，然后直接下楼。` : '时间紧，确认随身物品后直接下楼。';
    }
    return briefChecklist.length > 0 ? `先确认 ${briefChecklist}。` : '先确认随身物品。';
  }

  private static getOptionProfile(optionId: string): CommuteOptionProfile {
    switch (optionId) {
      case 'subway':
        return { stabilityScore: 5, outdoorExposureScore: 1 };
      case 'taxi':
        return { stabilityScore: 4, outdoorExposureScore: 0 };
      case 'bus_walk':
        return { stabilityScore: 2, outdoorExposureScore: 4 };
      default:
        throw new Error(`Unknown commute option id: ${optionId}`);
    }
  }

  private static parseClock(value: string): number {
    const match = value.trim().match(/^(\d{1,2}):(\d{2})$/);
    if (!match) {
      throw new Error(`Invalid clock value: ${value}`);
    }

    const hour = Number(match[1]);
    const minute = Number(match[2]);
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw new Error(`Clock value out of range: ${value}`);
    }

    return hour * 60 + minute;
  }

  private static formatClock(totalMinutes: number): string {
    let normalizedMinutes = totalMinutes % (24 * 60);
    if (normalizedMinutes < 0) {
      normalizedMinutes += 24 * 60;
    }

    const hour = Math.floor(normalizedMinutes / 60);
    const minute = normalizedMinutes % 60;
    return `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
  }
}
