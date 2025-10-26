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

import { UIAbility, Want } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { PromptAction, window } from '@kit.ArkUI';
import { pushService } from '@kit.PushKit';
import Logger from '../utils/Logger';
import { ExtraData } from './Model';
import { BusinessError } from '@kit.BasicServicesKit';
import { VoipCallService } from '../service/VoipCallService';

export default class MainAbility extends UIAbility {
  private localStorage = new LocalStorage();
  private promptAction: PromptAction = new PromptAction();

  onCreate(want: Want): void {
    Logger.info('MainAbility onCreate');
    this.localStorage.setOrCreate('want', want);
    this.receiveMessage();
  }

  onNewWant(want: Want): void {
    Logger.info('MainAbility onNewWant');
    this.localStorage.setOrCreate('want', want);
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    Logger.info('MainAbility onWindowStageCreate');
    try {
      await windowStage.loadContent('pages/MainPage', this.localStorage).then(()=>{
        this.promptAction = windowStage.getMainWindowSync()?.getUIContext()?.getPromptAction();
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to load the content. Cause code: ${err.code}, message: ${err.message}`);
      });
    } catch (e) {
      Logger.error(`Failed to load the content. Cause code: ${e.code}, message: ${e.message}`);
    }
    await this.requestEnableNotification();
  }

  /**
   * Request permission to send notification
   */
  private async requestEnableNotification(): Promise<void> {
    try {
      await notificationManager.requestEnableNotification(this.context);
      Logger.info('Succeeded in requesting enable notification');
    } catch (e) {
      const err: BusinessError = e;
      Logger.error('Failed to request enable notification: %{public}d %{public}s', err.code, err.message);
    }
  }

  /**
   * Receives scenario-specific messages from Push Kit
   */
  private receiveMessage(): void {
    try {
      pushService.receiveMessage('IM', this, (payload) => {
        try { // recommend to add try-catch block to capture exceptions
          Logger.info(`receiveMessage, type: ${payload.type}`);
          // get extraData passed by REST API
          const extraData: ExtraData = JSON.parse(JSON.parse(payload.data).data);

          // TODO: modify it based on your service scenario
          this.promptAction.showToast({
            message: $r('app.string.express_message', extraData.time, extraData.amount),
            duration: 5000,
          });
        } catch (e) {
          const err: BusinessError = e;
          Logger.error('Failed to process message: %{public}d %{public}s', err.code, err.message);
        }
      });
    } catch (e) {
      const err: BusinessError = e;
      Logger.error('Failed to receive message: %{public}d %{public}s', err.code, err.message);
    }

    try {
      pushService.receiveMessage('BACKGROUND', this, (payload) => {
        try { // recommend to add try-catch block to capture exceptions
          Logger.info(`receiveMessage, type: ${payload.type}`);
          // get extraData passed by REST API
          const extraData: string = JSON.parse(payload?.data)?.data;
          Logger.info('receive background message, extraData: %{public}s', extraData);
        } catch (e) {
          let errRes: BusinessError = e as BusinessError;
          Logger.error('Failed to process background message: %{public}d %{public}s', errRes.code, errRes.message);
        }
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      Logger.error('Failed to get background message: %{public}d %{public}s', e.code, e.message);
    }

    try {
      pushService.receiveMessage('VoIP', this, async (payload) => {
        try { // recommend to add try-catch block to capture exceptions
          Logger.info(`receiveMessage, type: ${payload.type}`);
          if (canIUse('SystemCapability.Telephony.VoipCallManager')) {
            await VoipCallService.processVoIPMainMsg(payload.data, this.context);
          } else {
            Logger.error('processVoIPMainMsg not by this device');
          }
        } catch (e) {
          let errRes: BusinessError = e as BusinessError;
          Logger.error('Failed to process VoIP message: %{public}d %{public}s', errRes.code, errRes.message);
        }
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      Logger.error('Failed to register VOIP: %{public}d %{public}s', e.code, e.message);
    }
  }
}
