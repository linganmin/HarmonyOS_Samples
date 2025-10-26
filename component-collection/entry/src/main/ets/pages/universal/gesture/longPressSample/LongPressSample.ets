/*
 * Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { IntroductionTitle } from '../../../../common/IntroductionTitle';
import { TitleBar } from '../../../../common/TitleBar';
import ShowToast from '../../../../util/ShowToast';
import { getStringData } from '../../../../data/ResourceDataHandle';

@Extend(Button)
function buttonStyle() {
  .margin(8)
  .fontSize(16)
  .width('100%')
  .margin({ left: 24, right: 24, top: 16, bottom: 8 })
}

@Entry
@Component
struct TapGestureExample {
  @State count: number = 0;

  build() {
    Column() {
      TitleBar({ title: $r('app.string.long_press_gesture') })
      Column() {
        IntroductionTitle({ introduction: $r('app.string.long_press') })
        Row() {
          Column() {
            Text(getStringData($r('app.string.onAction')) + this.count)
              .fontSize(24)
              .margin({ top: 20 })
          }
          .height(150)
          .width(300)
          .padding(20)
          .border({ width: 3 })
          .margin(30)
        }
        .justifyContent(FlexAlign.Center)
        .borderRadius(24)
        .backgroundColor(Color.White)
        .height(200)
        .margin({ left: 12, right: 12 })
        .width('100%')

        Button($r('app.string.long_press_text'))
          .buttonStyle(0)// Long press the text with one finger to trigger this gesture event
          .gesture(
            LongPressGesture({
              fingers: 1,
              duration: 500,
              repeat: true
            })// Since repeat is set to true, the long press action will be triggered continuously when it exists, and the trigger interval is duration (the default value is 500ms)
              .onAction((event: GestureEvent) => {
                if (event.repeat) {
                  this.count++;
                }
              })// Triggered once the long press action ends
              .onActionEnd(() => {
                this.count = 0;
              })
              .onActionCancel(() => {
                ShowToast.shortToast($r('app.string.time_picker_dialog_cancel'));
              })
          )
          .id('long_press')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_shallow_grey'))
  }
}