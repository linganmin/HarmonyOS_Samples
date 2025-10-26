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
import { CommonConstants } from '../common/constants/CommonConstants';

@Entry
@Component
struct ScrollOption {
  private selectTime: Date = new Date('2024-4-17T18:30:00');
  @State select: number = 2;
  private fruits: string[] = ['apple1', 'orange2', 'peach3', 'grape4', 'banana5'];

  build() {
    Navigation() {
      Column() {
        Button($r('app.string.button_scroll_option1'))
          .width(CommonConstants.ONE_HUNDRED_PERCENT)
          .margin({ bottom: $r('app.float.button_margin') })
          .onClick(() => {
            this.getUIContext().showTimePickerDialog({
              selected: this.selectTime,
              backgroundColor: $r('app.color.start_window_background'),
              onAccept: (value: TimePickerResult) => {
                this.selectTime.setHours(value.hour, value.minute);
              }
            })
          })
        Button($r('app.string.button_scroll_option2'))
          .width(CommonConstants.ONE_HUNDRED_PERCENT)
          .margin({ bottom: $r('app.float.card_padding') })
          .onClick(() => {
            this.getUIContext().showTextPickerDialog({
              range: this.fruits,
              selected: this.select,
              backgroundColor: $r('app.color.start_window_background'),
              onAccept: (value: TextPickerResult) => {
                this.select = value.index as number;
              }
            })
          })
      }
      .justifyContent(FlexAlign.End)
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .height(CommonConstants.ONE_HUNDRED_PERCENT)
      .padding({
        left: $r('app.float.card_padding'),
        right: $r('app.float.card_padding')
      })
    }
    .title($r('app.string.scroll_option'))
    .titleMode(NavigationTitleMode.Mini)
  }
}