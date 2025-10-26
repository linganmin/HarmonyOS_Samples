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

import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { pushCommon, RemoteNotificationExtensionAbility } from '@kit.PushKit';
import Logger from '../utils/Logger';
import { ExtraData } from './Model';
import { BusinessError } from '@kit.BasicServicesKit';

export default class RemoteNotificationExtAbility extends RemoteNotificationExtensionAbility {
  async onReceiveMessage(
    remoteNotificationInfo: pushCommon.RemoteNotificationInfo
  ): Promise<pushCommon.RemoteNotificationContent> {
    try {
      Logger.info('RemoteNotificationExtAbility onReceiveMessage');
      // get extraData passed by REST API
      const extraData: ExtraData = JSON.parse(JSON.parse(remoteNotificationInfo.data)?.data);
      const resourceMgr = (this.context as common.ExtensionContext).resourceManager;
      const content = await resourceMgr.getMediaContent($r('app.media.overlay').id);
      const overlayIcon = await image.createImageSource(content.buffer).createPixelMap();

      // Return the replaced message content.
      return {
        // Title of an extended notification
        title: await resourceMgr.getStringByName('express_title'),
        // Content of an extended notification
        text: (await resourceMgr.getStringByName('express_message')).replace('%s', extraData.time)
          .replace('%s', extraData.amount),
        // Overlay icon of an extended notification
        overlayIcon,
        // Badge number increment (but not the actual badge number displayed)
        badgeNumber: 1,
        // Data configured for the action to be triggered upon message tapping
        wantAgent: {
          abilityName: 'ClickActionAbility',
          parameters: {
            testKey: 'RemoteNotification',
          },
        },
      };
    } catch (e) {
      const err: BusinessError = e;
      Logger.error('RemoteNotificationExtAbility error: %{public}d %{public}s', err.code, err.message);
      return {};
    }
  }
}
