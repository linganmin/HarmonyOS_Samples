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

import { ArcButton, ArcButtonOptions, ArcButtonPosition, ArcButtonStyleMode } from '@kit.ArkUI';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { sensor } from '@kit.SensorServiceKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'SensorsView';

@Builder
export function SensorsViewBuilder() {
  SensorsPageView()
}

// [Start reqPermissionsFromUser]
const permissions: Array<Permissions> = ['ohos.permission.READ_HEALTH_DATA'];
// [StartExclude reqPermissionsFromUser]

@Component
export struct SensorsPageView {
  @State heartRate: number = 0;
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.Watch_sensor'))
          .fontColor(Color.White)
          .font({
            size: 19,
            weight: 700
          })
          .margin({
            top: 20
          })
        Row() {
          Text(this.heartRate.toString())
            .font({
              size: 30,
              weight: 700
            })
          Text('bpm')
            .fontSize(18)
        }
        .alignItems(VerticalAlign.Bottom)

        // [Start sensor]
        ArcButton({
          options: new ArcButtonOptions({
            label: $r('app.string.Heart_rate_monitoring'),
            position: ArcButtonPosition.BOTTOM_EDGE,
            styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
            onClick: () => {
              const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
              reqPermissionsFromUser(permissions, context);
              try {
                sensor.on(sensor.SensorId.HEART_RATE, (data: sensor.HeartRateResponse) => {
                  this.heartRate = data.heartRate;
                }, { interval: 100000000 });
              } catch (error) {
                let e: BusinessError = error as BusinessError;
                hilog.error(0x0000, TAG, `Failed to invoke on. Code: ${e.code}, message: ${e.message}`);
              }
            }
          })
        })
        // [End sensor]
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideToolBar(true)
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }

  aboutToDisappear(): void {
    try {
      sensor.off(sensor.SensorId.HEART_RATE);
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      hilog.error(0x0000, TAG, `Failed to invoke off. Code: ${e.code}, message: ${e.message}`);
    }
  }
}

// [EndExclude reqPermissionsFromUser]
function reqPermissionsFromUser(permissions: Array<Permissions>, context: common.UIAbilityContext): void {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  atManager.requestPermissionsFromUser(context, permissions).then(() => {
    hilog.info(0x0000, TAG, 'Success to request permissions from user.');
  }).catch((err: BusinessError) => {
    hilog.error(0x0000, TAG, `Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
  })
}
// [End reqPermissionsFromUser]