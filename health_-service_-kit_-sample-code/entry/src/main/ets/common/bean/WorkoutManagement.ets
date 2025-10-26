/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { healthService } from '@kit.HealthServiceKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class WorkoutManagement {
  public static async readActivityReport(): Promise<string> {
    try {
      let activityReport: healthService.workout.ActivityReport = await healthService.workout.readActivityReport();
      hilog.info(0x0000, 'testTag', 'Succeeded in reading ActivityReport');
      let result = 'Succeeded in reading ActivityReport\n';
      Object.keys(activityReport).forEach(key => {
        result += `the ${key} is ${activityReport[key]}` + '\n';
        hilog.info(0x0000, 'testTag', `the ${key} is ${activityReport[key]}`);
      });
      return result;
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to read ActivityReport. Code: ${err.code}, message: ${err.message}`);
      return `Failed to read ActivityReport. Code: ${err.code}, message: ${err.message}`;
    }
  }
}