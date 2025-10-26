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

import { common } from "@kit.AbilityKit";
import { WindowManager } from '../common/utils/WindowManager';

@Builder
export function WaitingAndSuccessBuilder() {
  WaitingAndSuccess();
}

@Entry
@Component
struct WaitingAndSuccess {
  @State arrivingState: boolean = true;
  @State arrivedState: boolean = true;
  @State timeoutID: number = 1;
  @Consume('NavPathStack') pageStack: NavPathStack;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private isKeepScreenOn: boolean = true;

  build() {
    NavDestination() {
      Column() {
        Column() {
          Text(this.arrivingState ? $r('app.string.driver_coming') : $r('app.string.driver_arrived'))
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
            if (this.arrivingState) {
              Text() {
                Span($r('app.string.distance_desc1'))
                  .fontColor(Color.White)
                  .fontSize(24)
                  .fontWeight(FontWeight.Medium)
                Span($r('app.string.distance_desc2'))
                  .fontColor(Color.Gray)
                  .fontSize(19)
                  .fontWeight(FontWeight.Medium)
                Span($r('app.string.distance_desc3'))
                  .fontColor(Color.Gray)
                  .fontSize(19)
                  .fontWeight(FontWeight.Medium)
                Span($r('app.string.distance_desc4'))
                  .fontColor(Color.White)
                  .fontSize(24)
                  .fontWeight(FontWeight.Medium)
                Span($r('app.string.distance_desc5'))
                  .fontColor(Color.Gray)
                  .fontSize(19)
                  .fontWeight(FontWeight.Medium)
              }
              .height(27)
            } else {
              if (this.arrivedState) {
                Text() {
                  Span($r('app.string.alert_desc1'))
                    .fontColor(Color.Gray)
                    .fontSize(19)
                    .fontWeight(FontWeight.Medium)
                  Span($r('app.string.alert_desc2'))
                    .fontColor(Color.White)
                    .fontSize(24)
                    .fontWeight(FontWeight.Medium)
                  Span($r('app.string.alert_desc3'))
                    .fontColor(Color.White)
                    .fontSize(24)
                    .fontWeight(FontWeight.Medium)
                  Span($r('app.string.alert_desc4'))
                    .fontColor(Color.White)
                    .fontSize(24)
                    .fontWeight(FontWeight.Medium)
                  Span($r('app.string.alert_desc5'))
                    .fontColor(Color.Gray)
                    .fontSize(19)
                    .fontWeight(FontWeight.Medium)
                }
                .height(27)
              } else {
                Text($r('app.string.alert_desc6'))
                  .fontColor(Color.White)
                  .fontSize(19)
                  .fontWeight(FontWeight.Medium)
                  .height(27)
              }
            }

            Text($r('app.string.license_plate'))
              .fontColor(Color.White)
              .fontSize(15)
              .margin('2%')

            Text($r('app.string.car_information'))
              .fontSize(15)
              .fontColor(Color.Gray)
          }
          .justifyContent(FlexAlign.Center)
          .height('80%')
        }
        .height('80%')

        Stack({ alignContent: Alignment.Top }) {
          Circle({
            width: 500,
            height: 500
          })
            .fill('#1F71FF')
          Text($r('app.string.cancel_trip'))
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
      .backgroundColor(Color.Black)
    }
    .hideTitleBar(true)
    .onShown(() => {
      // Timed 3s to change the page status or jump to the next page and keep the screen on for the duration of the display
      WindowManager.keepWindowScreenOn(this.context, this.isKeepScreenOn);
      this.timeoutID = setTimeout(() => {
        this.arrivingState = false;
        this.timeoutID = setTimeout(() => {
          this.arrivedState = false;
          this.timeoutID = setTimeout(() => {
            this.isKeepScreenOn = false;
            WindowManager.keepWindowScreenOn(this.context, this.isKeepScreenOn);
            this.pageStack.replacePath({name: 'OnTheWay'});
          }, 3000);
        }, 3000);
      }, 3000);
    })
    .onHidden(() => {
      // Clear the timer
      clearTimeout(this.timeoutID);
    })
  }
}