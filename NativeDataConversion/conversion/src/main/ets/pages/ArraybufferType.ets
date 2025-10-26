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

import libCalculator from 'libconversion.so';
import CommonConstants from '../common/constants/CommonContants';

@Component
export struct ArraybufferType {
  @State result: string = '';
  @State num1: number = 0;
  @State num2: number = 0;
  private arrBuf: ArrayBuffer = new ArrayBuffer(CommonConstants.BUFFER_SIZE);
  private controller1: TextInputController = new TextInputController();
  private controller2: TextInputController = new TextInputController();

  build() {
    Column() {
      Row() {
        Text($r('app.string.ArraybufferType_description'))
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
          Text($r('app.string.result'))
            .height($r('app.float.tips_result_message_height'))
            .fontColor($r('app.color.tips_result_color'))
            .fontSize($r('app.float.tips_result_font_size'))
        }
        .height($r('app.float.tips_result_height'))
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Bottom)
        .width(CommonConstants.FULL_PARENT)
        .padding({
          bottom: $r('app.float.level2_padding_bottom'),
          right: $r('app.float.level2_padding_right')
        })

        Row() {
          Text(this.result)
            .textAlign(TextAlign.End)
            .fontSize($r('app.float.result_font_size'))
            .width(CommonConstants.FULL_PARENT)
            .height(CommonConstants.FULL_PARENT)
            .textOverflow({ overflow: TextOverflow.Clip })
        }
        .height($r('app.float.tips_result_height'))
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Bottom)
        .width(CommonConstants.FULL_PARENT)
        .padding({
          bottom: $r('app.float.level2_padding_bottom'),
          right: $r('app.float.level2_padding_right')
        })

        Row() {
          Text($r('app.string.ArraybufferType_input1'))
            .fontSize($r('app.float.input_font_size'))
            .height($r('app.float.tips_result_message_height'))
          TextInput({ controller: this.controller1 })
            .type(InputType.Number)
            .height(CommonConstants.FULL_PARENT)
            .margin({ left: $r('app.float.margin_left1') })
            .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
            .maxLength(CommonConstants.INPUT_MAX_LENGTH1)
            .onChange(value => {
              this.num1 = Number.parseInt(value);
            })
        }
        .height($r('app.float.input_height'))
        .margin({ top: $r('app.float.margin_top2') })
        .padding({
          left: $r('app.float.level3_padding_left'),
          right: $r('app.float.level3_padding_right')
        })
        .width(CommonConstants.FULL_PARENT)
        .justifyContent(FlexAlign.Start)

        Row() {
          Text($r('app.string.ArraybufferType_input2'))
            .fontSize($r('app.float.input_font_size'))
            .height($r('app.float.tips_result_message_height'))
          TextInput({ controller: this.controller2 })
            .type(InputType.Number)
            .height(CommonConstants.FULL_PARENT)
            .margin({ left: $r('app.float.margin_left1') })
            .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
            .maxLength(CommonConstants.INPUT_MAX_LENGTH1)
            .onChange(value => {
              this.num2 = Number.parseInt(value);
            })
        }
        .height($r('app.float.input_height'))
        .margin({ top: $r('app.float.margin_top3') })
        .padding({
          left: $r('app.float.level3_padding_left'),
          right: $r('app.float.level3_padding_right')
        })
        .width(CommonConstants.FULL_PARENT)
        .justifyContent(FlexAlign.Start)
      }
      .margin($r('app.float.level3_padding_left'))
      .borderRadius($r('app.float.function_area_border_radius'))
      .height($r('app.float.function_area_height'))
      .backgroundColor(Color.White)

      Blank()

      Row() {
        Button($r('app.string.ArraybufferType_conversion'))
          .fontSize($r('app.float.message_font_size'))
          .fontWeight(CommonConstants.FONT_WEIGHT)
          .width(CommonConstants.FULL_PARENT)
          .backgroundColor($r('app.color.button_color'))
          .onClick(() => {
            let temp = new Int32Array(this.arrBuf);
            temp[0] = this.num1;
            temp[1] = this.num2;
            // Call the ArrayBuf method on the native side.
            let arraybuffer: ArrayBuffer = libCalculator.arrayBuf(this.arrBuf);
            let view = new Int32Array(arraybuffer);
            this.result = view.toString();
          })
      }
      .width(CommonConstants.FULL_PARENT)
      .padding({
        left: $r('app.float.padding_left'),
        right:$r('app.float.padding_left')
      })
      .margin({ bottom: $r('app.float.margin_bottom') })
      .justifyContent(FlexAlign.Center)
    }
    .width(CommonConstants.FULL_PARENT)
    .height(CommonConstants.FULL_PARENT)
    .backgroundColor($r('app.color.back_ground_color'))
  }
}