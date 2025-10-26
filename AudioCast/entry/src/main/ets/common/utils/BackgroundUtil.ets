/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { wantAgent, common } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'BackgroundUtil';

export class BackgroundUtil {
  /**
   * Start background task.
   *
   * @param context
   */
  public static startContinuousTask(context?: common.UIAbilityContext): void {
    if (!context) {
      hilog.error(0x0000, TAG, 'startContinuousTask failed', `context undefined`);
      return;
    }
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: context.abilityInfo.bundleName,
          abilityName: context.abilityInfo.name
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: Object) => {
      try {
        backgroundTaskManager.startBackgroundRunning(context,
          backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj).then(() => {
          hilog.info(0x0000, TAG, 'startBackgroundRunning succeeded');
        }).catch((error: BusinessError) => {
          hilog.error(0x0000, TAG, `startBackgroundRunning failed Cause: code ${error.code}`);
        });
      } catch (error) {
        hilog.error(0x0000, TAG, `startBackgroundRunning failed.message ${(error as BusinessError).message}`);
      }
    }).catch((error: BusinessError) => {
      hilog.error(0x0000, TAG, `getWantAgent failed Cause: code ${error.code}`);
    });
  }

  /**
   * Stop background task.
   *
   * @param context
   */
  public static stopContinuousTask(context: common.UIAbilityContext): void {
    try {
      backgroundTaskManager.stopBackgroundRunning(context).then(() => {
        hilog.info(0x0000, TAG, 'stopBackgroundRunning succeeded');
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, TAG, `stopBackgroundRunning failed Cause: code ${error.code}`);
      });
    } catch (error) {
      hilog.error(0x0000, TAG, `stopBackgroundRunning failed. message ${(error as BusinessError).message}`);
    }
  }
}