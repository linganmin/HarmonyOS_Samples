/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SuspendTaskInfo } from '../viewModel/SuspendTaskInfo';

const TAG: string = '[SuspendTaskUtils]';

class SuspendTaskUtils {
  // [Start requestSuspendDelay_start]
  /**
   *
   * @param reason Set the delay task suspension reason
   * @returns
   */
  requestSuspendDelay(reason: string): SuspendTaskInfo {
    let id: number; // Apply for a short-time task ID
    let delayTime: number; // The remaining time of this request short assignment
    try {
      // Request deferred task
      let delayInfo = backgroundTaskManager.requestSuspendDelay(reason, () => {
        // This function is used to call back the application when a short task requested by the application is about to time out.
        hilog.info(0x0000, TAG, `Request suspension delay will time out.`);
        backgroundTaskManager.cancelSuspendDelay(delayInfo.requestId);
      })
      id = delayInfo.requestId;
      delayTime = delayInfo.actualDelayTime;
      let taskInfo = {
        id: id,
        delayTime: delayTime
      } as SuspendTaskInfo;
      return taskInfo;
    } catch (err) {
      let taskInfo = {
        id: 0,
        delayTime: 0
      } as SuspendTaskInfo;
      return taskInfo;
    }
  }
  // [End requestSuspendDelay_start]

  // [Start getRemainingDelayTime_start]
  async getRemainingDelayTime(id: number): Promise<number> {
    let delayTime: number = -1;
    await backgroundTaskManager.getRemainingDelayTime(id).then((res: number) => {
      delayTime = res;
      hilog.info(0x0000, TAG, 'Operation getRemainingDelayTime succeeded. Data: ' + JSON.stringify(res));
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, 'Operation getRemainingDelayTime failed. Cause: ' + err.code);
    });
    return delayTime;
  }
  // [End getRemainingDelayTime_start]

  // [Start cancelSuspendDelay_start]
  cancelSuspendDelay(id: number): boolean {
    try {
      backgroundTaskManager.cancelSuspendDelay(id);
      hilog.info(0x0000, TAG, 'cancelSuspendDelay succeeded.');
    } catch (err) {
      hilog.error(0x0000, TAG, `cancelSuspendDelay failed. Cause: ${JSON.stringify(err)}`);
      return false;
    }
    return true;
  }
  // [End cancelSuspendDelay_start]
}

let suspendTaskUtils = new SuspendTaskUtils();

export default suspendTaskUtils as SuspendTaskUtils;