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
struct BindExample {
  @State priorityTestValue: string = '';
  @State parallelTestValue: string = '';

  build() {
    Column() {
      TitleBar({ title: $r('app.string.bind_gesture_methods') })
      Column() {
        IntroductionTitle({ introduction: $r('app.string.bind_gesture_priorityGesture') })
        Scroll() {
          Column() {
            Text(getStringData($r('app.string.bind_gesture_tapGesture')) + this.priorityTestValue)
              .fontSize(24)
              .gesture(
                TapGesture()
                  .onAction(() => {
                    this.priorityTestValue += getStringData($r('app.string.bind_gesture_text'));
                  }))
              .id('bind_one')
          }
          .width(250)
          .border({ width: 3 })
        }
        .borderRadius(24)
        .backgroundColor(Color.White)
        .height(220)
        .margin({ left: 12, right: 12 })
        .width('100%')

        Button($r('app.string.bind_click'))// When set to priorityGesture, clicking on the text will ignore the TapGesture gesture event of the Text component and give priority to the TapGesture gesture event of the parent component Column
          .priorityGesture(
            TapGesture()
              .onAction((event: GestureEvent) => {
                this.priorityTestValue += getStringData($r('app.string.bind_gesture_column'));
              }), GestureMask.IgnoreInternal)
          .buttonStyle(0)

        IntroductionTitle({ introduction: $r('app.string.bind_gesture_parallelGesture') })
        Scroll() {
          Column() {
            Text(getStringData($r('app.string.bind_gesture_tapGesture')) + this.parallelTestValue)
              .fontSize(24)
          }
          .width(250)
          .border({ width: 3 })
        }
        .borderRadius(24)
        .backgroundColor(Color.White)
        .height(220)
        .margin({ left: 12, right: 12 })
        .width('100%')

        Row() {
          Button($r('app.string.bind_click'))
            .buttonStyle(0)// When set to parallelGesture, clicking on the text will trigger the TapGesture gesture event of both the child component Text and the parent component Column
            .gesture(
              TapGesture()
                .onAction(() => {
                  this.parallelTestValue += getStringData($r('app.string.bind_gesture_text'));
                }))
            .id('bind_two')
        }
        .parallelGesture(
          TapGesture()
            .onAction((event: GestureEvent) => {
              this.parallelTestValue += getStringData($r('app.string.bind_gesture_column'));
            }), GestureMask.Normal)
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.background_shallow_grey'))
  }
}