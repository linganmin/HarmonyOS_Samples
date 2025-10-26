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

import { common, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';

const TAG = '[BackgroundTaskManager]';

export class BackgroundTaskManager {
  /**
   * Starts a continuous background task with audio playback mode.
   * @param context Optional UIAbility context for the background task.
   */
  public static startContinuousTask(backgroundMode: backgroundTaskManager.BackgroundMode,
    context?: common.UIAbilityContext): void {
    if (!context) {
      return;
    }
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: context.abilityInfo.bundleName,
          abilityName: context.abilityInfo.name
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj) => {
      backgroundTaskManager.startBackgroundRunning(context, backgroundMode, wantAgentObj).then(() => {
        Logger.info(TAG, `startBackgroundRunning succeeded, backgroundMode is ${backgroundMode}.`);
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `startBackgroundRunning failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      });
    })
      .catch(() => {
        Logger.error(TAG, "getWantAgent fail");
      })
    return;
  }

  /**
   * Stops the currently running continuous background task.
   * @param context Optional UIAbility context for the background task.
   */
  public static async stopContinuousTask(context?: common.UIAbilityContext) {
    if (!context) {
      return;
    }
    try {
      await backgroundTaskManager.stopBackgroundRunning(context);
      Logger.info(TAG, `stopBackgroundRunning succeeded.`);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `stopBackgroundRunning failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    return;
  }
}