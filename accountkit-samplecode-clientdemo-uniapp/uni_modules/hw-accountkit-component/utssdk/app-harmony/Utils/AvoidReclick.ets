/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';

const domainId: number = 0x0000;
const logTag: string = 'AvoidReclick';

export class AvoidReclick {
  static lastClickTime: number = 0; // Record the time of the last repeated tap.

  public static avoidRepeatClick(callback: VoidCallback, interval: number = 400) {
    const currentTime = Date.now();
    if (Math.abs(currentTime - AvoidReclick.lastClickTime) > interval) {
      AvoidReclick.lastClickTime = currentTime;
      hilog.info(domainId, logTag, 'Effective click');
      callback();
    } else {
      hilog.info(domainId, logTag, 'Invalid click');
    }
  }
}

