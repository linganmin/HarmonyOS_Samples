/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { notificationManager } from '@kit.NotificationKit';
import { WantAgent } from '@ohos.wantAgent'

interface NotificationRequestUtilResultType {
  slotType: notificationManager.SlotType,
  id: number,
  content: notificationManager.NotificationContent
}

class NotificationRequestUtil {
  /**
   * init basic NotificationRequest
   * @param notificationContent
   * @return return the created NotificationRequest
   */
  initBasicNotificationRequest(notificationContent: notificationManager.NotificationContent) {
    let result: NotificationRequestUtilResultType = {
      slotType: notificationManager.SlotType.CONTENT_INFORMATION,
      id: 1, // Notification ID, default is 1.
      content: notificationContent
    }
    return result;
  }

  /**
   * init NotificationRequest width buttons
   * @param notificationContent
   * @param notificationActionButtons
   * @return return the created NotificationRequest
   */
  initButtonNotificationRequest(notificationContent: notificationManager.NotificationContent,
    notificationActionButtons: notificationManager.NotificationActionButton[]): notificationManager.NotificationRequest {
    let actionButtons = notificationActionButtons
    if (notificationActionButtons.length > 2) {
      actionButtons = notificationActionButtons.splice(0, 2)
    }
    return {
      notificationSlotType: notificationManager.SlotType.CONTENT_INFORMATION,
      id: 1,
      content: notificationContent,
      actionButtons: actionButtons
    };
  }

  /**
   * init wantAgent NotificationRequest
   * @param notificationContent
   * @param notificationWantAgent
   * @return return the created NotificationRequest
   */

  initWantAgentNotificationRequest(notificationContent: notificationManager.NotificationContent,
    notificationWantAgent: WantAgent): notificationManager.NotificationRequest {
    return {
      notificationSlotType: notificationManager.SlotType.CONTENT_INFORMATION,
      id: 1,
      content: notificationContent,
      wantAgent: notificationWantAgent
    };
  }
}

export let notificationRequestUtil = new NotificationRequestUtil();