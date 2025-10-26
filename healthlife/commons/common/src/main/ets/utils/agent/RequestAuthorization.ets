/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { notificationManager } from '@kit.NotificationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

const TAG: string = '[RequestAuthorization]';
const DOMAIN_NUMBER: number = 0xFF00;

export class RequestAuthorization {
  /**
   * Request notification permission from user
   * @param { UIContext } uIContext - Context for UI operations and resource access
   * @returns { Promise<boolean> } Promise resolves to true if permission granted, false otherwise
   * @note Requires ohos.permission.NOTIFICATION_CONTROLLER permission in config.json
   */
  static async requestNotification(uIContext: UIContext): Promise<boolean> {
    let isRequestSuccess = false;
    let context = uIContext.getHostContext() as common.UIAbilityContext;
    try {
      let isEnabled = await notificationManager.isNotificationEnabled();
      if (isEnabled) {
        return true;
      }
    } catch (err) {
      hilog.error(DOMAIN_NUMBER, TAG, `isNotificationEnabled fail, code is ${err.code}, message is ${err.message}`);
    }

    try {
      await notificationManager.requestEnableNotification(context);
      isRequestSuccess = true;
      return isRequestSuccess;
    } catch (err) {
      if (1600004 == err.code) {
        hilog.error(DOMAIN_NUMBER, TAG,
          `[ANS] requestEnableNotification refused, code is ${err.code}, message is ${err.message}`);
      } else {
        hilog.error(DOMAIN_NUMBER, TAG,
          `[ANS] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
      }
    }
    return isRequestSuccess;
  }
}