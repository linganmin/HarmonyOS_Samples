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
export function OnTheWayBuilder() {
  OnTheWay();
}

@Entry
@Component
struct OnTheWay {
  @State timeoutID: number = 0;
  @Consume('NavPathStack') pageStack: NavPathStack;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private isKeepScreenOn: boolean = true;

  build() {
    NavDestination() {
        Column() {
          Column() {
            Text($r('app.string.on_the_way'))
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
              Text() {
                Span($r('app.string.on_the_way_distance1'))
                  .fontColor(Color.Gray)
                  .fontWeight(FontWeight.Regular)
                  .fontSize(18)
                Span($r('app.string.on_the_way_distance2'))
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Regular)
                  .fontSize(24)
                Span($r('app.string.on_the_way_distance3'))
                  .fontColor(Color.Gray)
                  .fontWeight(FontWeight.Regular)
                  .fontSize(18)
              }
              .height(32)
              Text() {
                Span($r('app.string.on_the_way_time1'))
                  .fontColor(Color.Gray)
                  .fontWeight(FontWeight.Regular)
                  .fontSize(18)
                Span($r('app.string.on_the_way_time2'))
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Regular)
                  .fontSize(24)
                Span($r('app.string.on_the_way_time3'))
                  .fontColor(Color.Gray)
                  .fontWeight(FontWeight.Regular)
                  .fontSize(18)
              }
              .height(32)
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
            Text($r('app.string.terminate_trip'))
              .fontSize(19)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
              .margin({
                top: 12
              })
          }
          .onClick(() => {
            this.pageStack.replacePath({ name: 'PayTheBill' });
          })
        }
        .height('100%')
        .width('100%')
        .borderRadius('50%')
        .backgroundColor(Color.Black)
        .justifyContent(FlexAlign.Center)
    }
    .hideTitleBar(true)
    .onShown(() => {
      // Timed 3s to jump to the next page and keep the screen on for the duration of the display
      WindowManager.keepWindowScreenOn(this.context, this.isKeepScreenOn);
      this.timeoutID = setTimeout(() => {
        this.isKeepScreenOn = false;
        WindowManager.keepWindowScreenOn(this.context, this.isKeepScreenOn);
        this.pageStack.replacePath({ name: 'PayTheBill' });
      }, 3000);
    })
    .onHidden(() => {
      // Clear the timer
      clearTimeout(this.timeoutID);
    })
  }
}