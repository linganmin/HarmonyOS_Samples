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

import libConversion from 'libconversion.so';
import Logger from '../common/utils/Logger';
import CommonConstants from '../common/constants/CommonContants';

@Component
export struct ArrayType {
  @State arrStr: string = ''; // Used to display arrays.
  @State result: string = ''; // Displays results in reverse order.
  @State textContent: string = ''; // Enter the text content of the box.
  private index: number = 0; // Array subscripts.
  private arr: number[] = []; // Arrays that need to be passed.
  private controller: TextInputController = new TextInputController();

  build() {
    Column() {
      Row() {
        Text($r('app.string.ArrayType_description'))
          .fontSize($r('app.float.message_font_size'))
          .fontWeight(CommonConstants.FONT_WEIGHT)
          .align(Alignment.Center)
      }
      .width(CommonConstants.FULL_PARENT)
      .padding({
        left: $r('app.float.level2_padding_left'),
        right: $r('app.float.level2_padding_right'),
        top: $r('app.float.level3_padding_top')
      })
      .alignItems(VerticalAlign.Bottom)
      .justifyContent(FlexAlign.Start)

      Column() {
        Row() {
          Text($r('app.string.ArrayType_array'))
            .height($r('app.float.tips_result_message_height'))
            .fontColor($r('app.color.tips_result_color'))
            .fontSize($r('app.float.tips_result_font_size'))
        }
        .height($r('app.float.tips_result_height1'))
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Bottom)
        .width(CommonConstants.FULL_PARENT)
        .padding({
          bottom: $r('app.float.level2_padding_bottom'),
          right: $r('app.float.level2_padding_right')
        })

        Row() {
          Text(this.arrStr)
            .fontSize($r('app.float.result_font_size1'))
            .width(CommonConstants.FULL_PARENT)
            .height(CommonConstants.FULL_PARENT)
            .textOverflow({ overflow: TextOverflow.MARQUEE })
        }
        .height($r('app.float.tips_result_height1'))
        .width(CommonConstants.FULL_PARENT)
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Bottom)
        .padding({
          bottom: $r('app.float.level2_padding_bottom'),
          right: $r('app.float.level2_padding_right')
        })

        Row() {
          Text($r('app.string.ArrayType_reverse'))
            .height($r('app.float.tips_result_message_height'))
            .fontColor($r('app.color.tips_result_color'))
            .fontSize($r('app.float.tips_result_font_size'))
        }
        .height($r('app.float.tips_result_height1'))
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Bottom)
        .width(CommonConstants.FULL_PARENT)
        .padding({
          bottom: $r('app.float.level2_padding_bottom'),
          right: $r('app.float.level2_padding_right')
        })

        Row() {
          Text(this.result)
            .fontSize($r('app.float.result_font_size1'))
            .width(CommonConstants.FULL_PARENT)
            .height(CommonConstants.FULL_PARENT)
            .textOverflow({ overflow: TextOverflow.MARQUEE })
        }
        .height($r('app.float.tips_result_height1'))
        .width(CommonConstants.FULL_PARENT)
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Bottom)
        .padding({
          bottom: $r('app.float.level2_padding_bottom'),
          right: $r('app.float.level2_padding_right')
        })

        Row() {
          Text($r('app.string.ArrayType_input1'))
            .fontSize($r('app.float.input_font_size'))
            .height($r('app.float.tips_result_message_height'))
          TextInput({ text: this.textContent, controller: this.controller })
            .type(InputType.Number)
            .height(CommonConstants.FULL_PARENT)
            .margin({ left: $r('app.float.margin_left1') })
            .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
            .maxLength(CommonConstants.INPUT_MAX_LENGTH)
            .onChange(value => {
              this.textContent = value;
            })
        }
        .height($r('app.float.tips_result_height1'))
        .width(CommonConstants.FULL_PARENT)
        .justifyContent(FlexAlign.Start)
        .margin({ top: $r('app.float.margin_top3') })
        .padding({
          left: $r('app.float.level3_padding_left'),
          right: $r('app.float.level3_padding_right')
        })
      }
      .margin($r('app.float.level3_padding_left'))
      .borderRadius($r('app.float.function_area_border_radius'))
      .height($r('app.float.function_area_height1'))
      .backgroundColor(Color.White)

      Blank()

      Column({ space: CommonConstants.SPACE }) {
        Button($r('app.string.ArrayType_confirm'))
          .width(CommonConstants.FULL_PARENT)
          .fontSize($r('app.float.message_font_size'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.button_color'))
          .onClick(() => {
            Logger.info('Confirm the entry');
            if (this.textContent != '') {
              this.arr[this.index] = Number.parseInt(this.textContent);
              this.arrStr += ' ' + this.textContent;
              this.index++;
              this.textContent = '';
              this.result = '';
            }
          })

        Button($r('app.string.ArrayType_conversion'))
          .width(CommonConstants.FULL_PARENT)
          .fontSize($r('app.float.message_font_size'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.button_color'))
          .onClick(() => {
            // Call the native arrReverse method.
            this.result = '';
            let resultTemp = libConversion.arrReverse(this.arr);
            for (let i of resultTemp) {
              this.result += ' ' + i.toString(CommonConstants.DECIMAL_FORMAT);
            }
          })

        Button($r('app.string.ArrayType_reset'))
          .width(CommonConstants.FULL_PARENT)
          .fontSize($r('app.float.message_font_size'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.button_color'))
          .onClick(() => {
            Logger.info('clear all of arr[].');
            this.arrStr = '';
            this.arr = [];
            this.result = '';
            this.index = 0;
            this.textContent = '';
          })
      }
      .padding({
        left: $r('app.float.padding_left'),
        right: $r('app.float.padding_left')
      })
      .margin({ bottom: $r('app.float.margin_bottom') })
    }
    .width(CommonConstants.FULL_PARENT)
    .height(CommonConstants.FULL_PARENT)
    .backgroundColor($r('app.color.back_ground_color'))
  }
}