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

import { ApplicationStateChangeCallback, common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../common/Logger';
import { ToastUtils } from '../common/ToastUtils';

@Entry
@Component
struct Index {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext
  private applicationContext = this.context.getApplicationContext();

  aboutToAppear(): void {
    let applicationStateChangeCallback: ApplicationStateChangeCallback = {
      onApplicationForeground() {
        Logger.info('applicationStateChangeCallback onApplicationForeground');
      },
      onApplicationBackground() {
        Logger.info('applicationStateChangeCallback onApplicationBackground');
      }
    }

    try {
      this.applicationContext.on('applicationStateChange', applicationStateChangeCallback);
    } catch (err) {
      Logger.error(`Failed to subscribe applicationStateChange. Code is ${err.code}, message is ${err.message}`);
    }
  }

  aboutToDisappear(): void {
    try {
      this.applicationContext.off('applicationStateChange');
    } catch (err) {
      Logger.error(`Failed to unsubscribe applicationStateChange. Code is ${err.code}, message is ${err.message}`);
    }
  }

  build() {
    Column() {
      Text($r('app.string.page_title'))
        .width('100%')
        .fontWeight(700)
        .fontSize(30)
        .textAlign(TextAlign.Start)
        .fontColor($r('sys.color.ohos_id_color_primary'))
        .padding({
          left: 12,
          top: 64,
          right: 20,
          bottom: 8
        })

      Column({ space: 12 }) {

        Button($r('app.string.btn_exit_UIAbility'))
          .width('100%')
          .onClick(() => {
            this.context.terminateSelf().then(() => {
              Logger.info('terminateSelf succeed');
            }).catch((err: BusinessError) => {
              Logger.error(`terminateSelf failed, code is ${err.code}, message is ${err.message}`);
            });
          })

        Button($r('app.string.btn_app_exit'))
          .width('100%')
          .onClick(() => {
            this.applicationContext.killAllProcesses().then(() => {
              Logger.info('killAllProcesses succeed');
            }).catch((err: BusinessError) => {
              Logger.error(`killAllProcesses failed, code is ${err.code}, message is ${err.message}`);
            });
          })

        Button($r('app.string.btn_app_restart'))
          .width('100%')
          .onClick(() => {
            let want: Want = {
              bundleName: this.context.abilityInfo.bundleName,
              abilityName: this.context.abilityInfo.name
            };
            try {
              this.applicationContext.restartApp(want);
            } catch (error) {
              let err = error as BusinessError;
              Logger.error(`restart app failed, code is ${err.code}, message is ${err.message}`);
            }
          })

        Button($r('app.string.btn_to_background'))
          .width('100%')
          .onClick(() => {
            let windowClass = this.context.windowStage.getMainWindowSync();
            windowClass.minimize().then(() => {
              Logger.info('Succeeded in minimize window');
            }).catch((err: BusinessError) => {
              Logger.error(`Failed to minimize window. Code is ${err.code}, message is ${err.message}`);
            })
          })
      }
      .padding(16)
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .backgroundColor('#F1F3F5')
    .justifyContent(FlexAlign.SpaceBetween)
    .height('100%')
    .width('100%')
  }
}