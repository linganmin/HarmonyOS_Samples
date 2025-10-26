/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { ApplicationStateChangeCallback, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SuspendTaskInfo } from './SuspendTaskInfo';
import SuspendTaskUtils from '../utils/SuspendTaskUtils';

const TAG: string = '[ShortTermTaskModel]';

export class ShortTermTaskModel {
  public suspendTaskInfo: SuspendTaskInfo = { id: 0, delayTime: 0 };
  private context: common.UIAbilityContext = AppStorage.get("context") as common.UIAbilityContext;

  // [Start subscribeStateChange_start]
  // Apply front - and back-end status monitoring
  subscribeStateChange() {
    let that = this;
    // Gets applicationContext
    let applicationContext = this.context.getApplicationContext();
    let applicationStateChangeCallback: ApplicationStateChangeCallback = {
      onApplicationForeground() {
        hilog.info(0x0000, TAG, 'applicationStateChangeCallback onApplicationForeground');
      },
      onApplicationBackground() {
        hilog.info(0x0000, TAG, 'applicationStateChangeCallback onApplicationBackground');
        // Apply for short-time tasks when the application changes from foreground to background
        that.suspendTaskInfo = SuspendTaskUtils.requestSuspendDelay('Suspend Task');
        hilog.info(0x0000, TAG,
          `requestSuspendDelay, id:${that.suspendTaskInfo.id}, delayTime:${that.suspendTaskInfo.delayTime}`);
      }
    }
    try {
      // Registers the background and pre - application status monitoring through applicationContext
      applicationContext.on('applicationStateChange', applicationStateChangeCallback);
    } catch (paramError) {
      hilog.error(0x0000, TAG,
        `error: ${(paramError as BusinessError).code}, ${(paramError as BusinessError).message}`);
    }
  }
  // [End subscribeStateChange_start]

  offAppStateChange(): void {
    let applicationContext = this.context.getApplicationContext();
    try {
      applicationContext.off('applicationStateChange');
      hilog.info(0x0000, TAG, 'ApplicationStateChange off succeeded.');
    } catch (paramError) {
      hilog.error(0x0000, TAG,
        `error: ${(paramError as BusinessError).code}, ${(paramError as BusinessError).message}`);
    }
  }
}