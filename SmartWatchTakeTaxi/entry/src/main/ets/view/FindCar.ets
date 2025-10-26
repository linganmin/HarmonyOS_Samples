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

import { hilog } from "@kit.PerformanceAnalysisKit";
import { common } from "@kit.AbilityKit";
import { WindowManager } from '../common/utils/WindowManager';

const TAG = '[FindCar]';

@Builder
export function FindCarBuilder() {
  FindCar();
}

@Entry
@Component
struct FindCar {
  @State format: string = 'mm:ss';
  @Consume('NavPathStack') pageStack: NavPathStack;
  private textTimerController: TextTimerController = new TextTimerController();
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private isKeepScreenOn: boolean = true;

  build() {
    NavDestination() {
      Column() {
        Column() {
          Text($r('app.string.find_car'))
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .width(129)
            .height('11%')
            .lineHeight(27)
            .margin({
              top: '7%'
            })
            .textAlign(TextAlign.Center)

          Column() {
            Image($r('app.media.location'))
              .width(52)
              .height(52)
              .margin(12)

            TextTimer({ isCountDown: false, controller: this.textTimerController })
              .fontColor(Color.White)
              .format(this.format)
              .onTimer((utc: number, elapsedTime: number) => {
                hilog.info(0x0000, TAG, `TextTimer onTimer utc: ${utc}, elapsedTime: ${elapsedTime}.`);
                if (elapsedTime === 3) {
                  this.pageStack.replacePath({ name: 'WaitingAndSuccess' });
                }
              })
              .height(21)
          }
          .height('90%')
          .justifyContent(FlexAlign.Center)
          .width(181)
        }
        .height('80%')

        Stack({ alignContent: Alignment.Top }) {
          Circle({
            width: 500,
            height: 500
          })
            .fill('#1F71FF')
          Text($r('app.string.cancel_hailing'))
            .fontSize(19)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .margin({
              top: 12
            })
        }
        .onClick(() => {
          this.pageStack.pop();
        })
      }
      .height('100%')
      .width('100%')
      .borderRadius('50%')
      .backgroundImage($r('app.media.taxi_bg'))
      .backgroundColor(Color.Black)
    }
    .hideTitleBar(true)
    .onShown(() => {
      // Timed 3s to jump to the next page and keep the screen on for the duration of the display
      this.textTimerController.start();
      WindowManager.keepWindowScreenOn(this.context, this.isKeepScreenOn);
      let screenTimeoutID = setTimeout(() => {
        this.isKeepScreenOn = false;
        WindowManager.keepWindowScreenOn(this.context, this.isKeepScreenOn);
      }, 3000);
      clearTimeout(screenTimeoutID);
    })
    .onHidden(() => {
      this.textTimerController.pause();
    })
  }
}