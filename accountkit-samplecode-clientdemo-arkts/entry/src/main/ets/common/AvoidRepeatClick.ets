/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';

const domainId: number = 0x0000;
const logTag: string = 'AvoidRepeatClick';

export class AvoidRepeatClick {
  static lastClickTime: number = 0; // Record the time of the last repeated tap.

  public static avoidRepeatClick(callback: VoidCallback, interval: number = 400) {
    const currentTime = Date.now();
    if (Math.abs(currentTime - AvoidRepeatClick.lastClickTime) > interval) {
      AvoidRepeatClick.lastClickTime = currentTime;
      hilog.info(domainId, logTag, 'Effective click');
      callback();
    } else {
      hilog.info(domainId, logTag, 'Invalid click');
    }
  }
}

