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

import { BusinessError } from '@kit.BasicServicesKit';
import { serviceNotification } from '@kit.PushKit';
import Logger from '../utils/Logger';
import { PromptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

@Component
export struct SubscribePage {
  // TODO: please replace them with your template IDs on the AppGallery Connect page, the maximum number of IDs is 3
  private templateIds: string[] = ['****', '****', '****'];
  promptAction: PromptAction = this.getUIContext().getPromptAction();

  @Builder
  TitleBuilder() {
    Row() {
      Text($r('app.string.subscribe_title'))
    }
    .width('100%')
    .height('100%')
  }

  build() {
    NavDestination() {
      Button($r('app.string.subscribe_btn'))
        .onClick(() => this.subscribeServiceNotification())
    }
    .title(this.TitleBuilder)
  }

  private async subscribeServiceNotification(): Promise<void> {
    try {
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const rsp:serviceNotification.RequestResult = await serviceNotification.requestSubscribeNotification(
        context,
        this.templateIds,
        serviceNotification.SubscribeNotificationType.SUBSCRIBE_WITH_HUAWEI_ID
      );
      this.handleEntityResult(rsp.entityResult);
    } catch (e) {
      const err: BusinessError = e;
      switch (err.code) {
        case 1000900011:
          Logger.error('Please check the network');
          this.promptAction.showDialog({
            title: $r('app.string.subscribe_failed'),
            message: $r('app.string.network_error'),
            buttons: [{
              text: $r('app.string.sure'),
              color: '#000000'
            }]
          }).catch(() => {
            // TODO: Implement error handling.
          });
          break;
        case 1000900022:
          Logger.error('Please enable the device service notification switch before subscribing');
          this.promptAction.showDialog({
            title: $r('app.string.subscribe_failed'),
            message: $r('app.string.enable_device_switch'),
            buttons: [{
              text: $r('app.string.sure'),
              color: '#000000'
            }]
          }).catch(() => {
            // TODO: Implement error handling.
          });
          break;
        case 1000900030:
          Logger.error('Please login with Huawei ID before subscribing service notification');
          this.promptAction.showDialog({
            title: $r('app.string.subscribe_failed'),
            message: $r('app.string.login'),
            buttons: [{
              text: $r('app.string.sure'),
              color: '#000000'
            }],
          }).catch(() => {
            // TODO: Implement error handling.
          });
          break;
        default:
          Logger.error('Failed to request serviceNotification: %{public}d %{public}s', err.code,
            err.message);
          this.promptAction.showToast({
            message: $r('app.string.subscribe_failed'),
          });
          break;
      }
    }
  }

  private handleEntityResult(entityResult: serviceNotification.EntityResult[]): void {
    Logger.info('Subscribe result: %{public}s', JSON.stringify(entityResult));
    if (entityResult.every((result) => result.resultCode === serviceNotification.ResultCode.ACCEPTED)) {
      Logger.info('Succeeded in subscribing all templates');
      try {
        this.promptAction.showToast({
          message: $r("app.string.subscribe_succeeded"),
        });
      } catch (error) {
        // TODO: Implement error handling.
      }
    } else if (entityResult.some((result) => result.resultCode === serviceNotification.ResultCode.ACCEPTED)) {
      Logger.info('Succeeded in subscribing some templates');
      try {
        this.promptAction.showToast({
          message: $r("app.string.subscribe_partial_succeeded"),
        });
      } catch (error) {
        // TODO: Implement error handling.
      }
    } else {
      Logger.info('Failed to subscribe templates');
      try {
        this.promptAction.showToast({
          message: $r("app.string.subscribe_failed"),
        });
      } catch (error) {
        // TODO: Implement error handling.
      }
    }
  }
}