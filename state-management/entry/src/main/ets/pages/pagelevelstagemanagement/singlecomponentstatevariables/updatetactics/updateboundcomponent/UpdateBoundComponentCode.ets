/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { ViewCodeText } from '../../../../../commoncomponents/ViewCodeText';

@Component
export struct UpdateBoundComponentCode {
  // State variables within a component.
  @State titleName: string = 'title';
  // private variables within a component.
  private content: string = 'content';
  // The number of times variables within the component are updated.
  private updateCount: number = 0;

  build() {
    Column({ space: 10 }) {
      // Click to view source code.
      ViewCodeText({webSrc: $rawfile('UpdateBoundComponentCode.ets.html')})

      Column() {
        Text($r('app.string.only_update_state'))
          .fontColor($r('app.color.tips_font_color'))
          .fontSize($r('app.float.tips_font_size'))
          .width('100%')
        Row() {
          Text($r('app.string.only_update_title'))
            .fontColor($r('app.color.button_text_color'))
            .fontSize($r('app.float.button_text_size'))
          Text(`${this.titleName}`) // titleName is a state variable, bound to the Text component.
            .fontColor($r('app.color.button_text_color'))
            .fontSize(20)
        }
        .width('100%')
        .margin(10)

        Text($r('app.string.only_update_private'))
          .fontColor($r('app.color.tips_font_color'))
          .fontSize($r('app.float.tips_font_size'))
          .width('100%')
          .margin({ top: 20 })
        Row() {
          Text($r('app.string.only_update_content'))
            .fontColor($r('app.color.button_text_color'))
            .fontSize($r('app.float.button_text_size'))
          Text(`${this.content}`) // content is private and bound to the Text component.
            .fontColor($r('app.color.button_text_color'))
            .fontSize(20)
        }
        .width('100%')
        .margin(10)
      }
      .width('100%')
      .padding(10)
      .justifyContent(FlexAlign.SpaceAround)
      .backgroundColor($r('app.color.component_background_pink'))

      Column() {
        Button($r('app.string.update_title_content'))
          .onClick(() => {
            // Click to update the variables declared by @State and Private. The update policy is: When the data of @State and Private changes,
            // the component bound by @State variable is updated, while the component bound by Private variable is not updated.
            this.updateCount++;
            this.content = `content ${this.updateCount}`;
            this.titleName = `title ${this.updateCount}`;
          })
          .id('titleAndContentBtn')
          .width('100%')
          .height($r('app.float.button_height'))
          .fontColor($r('app.color.button_text_color'))
          .fontSize($r('app.float.button_text_size'))
          .type(ButtonType.Capsule)
          .backgroundColor($r('app.color.button_background_color'))
        Text($r('app.string.only_update_state_components'))
          .fontColor($r('app.color.tips_font_color'))
          .fontSize($r('app.float.button_text_size'))
          .margin({ top: 30 })
      }.width('100%')
    }
    .padding(10)
    .border({ radius: $r('app.float.component_radius'), color: Color.Grey, width: $r('app.float.border_width') })
  }
}