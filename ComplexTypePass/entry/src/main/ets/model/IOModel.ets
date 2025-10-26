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

export interface InputField {
  label: string;
  inputStr: string;
  inputType: InputType;
  maxLength?: number;
  placeholder?: string | ResourceStr;
}

@Component
export struct InputArea {
  @Consume inputArray: Array<InputField>;

  build() {
    Column() {
      ForEach(this.inputArray, (inputField: InputField, i: number) => {
        Row() {
          Text(`${inputField.label}:`)
            .width($r('app.string.25percent'))
            .fontSize($r("app.string.button_text_font_size_big"))
            .fontWeight(FontWeight.Medium)
          TextInput({ placeholder: inputField?.placeholder })
            .width($r('app.string.75percent'))
            .placeholderColor(Color.Gray)
            .textAlign(TextAlign.End)
            .backgroundColor(Color.White)
            .onChange((str) => {
              this.inputArray[i].inputStr = str;
            })
            .type(inputField.inputType)
            .maxLength(inputField?.maxLength)
            .maxLines(1)
        }
        .width('100%')
        .height($r('app.string.input_text_row_height'))

        if (i < this.inputArray.length - 1) {
          Divider()
            .width('100%')
            .strokeWidth(0.5)
            .color($r('app.string.divider_color'))
        }
      }, (_inputField: InputField, i: number) => i.toString())
    }
    .margin({ bottom: $r('app.string.margin_l') })
    .padding({
      left: $r('app.string.margin_m'),
      right: $r('app.string.margin_m'),
    })
    .backgroundColor(Color.White)
    .borderRadius($r('app.string.border_radius'))
  }
}

@Component
export struct OutputArea {
  @Consume printStr: string;

  build() {
    Scroll() {
      Text(this.printStr)
        .fontSize($r("app.string.button_text_font_size_big"))
        .margin({
          left: $r('app.string.margin_l'),
          right: $r('app.string.margin_l'),
          top: $r('app.string.margin_l_half'),
          bottom: $r('app.string.margin_l_half'),
        })
    }
    .constraintSize({
      minHeight: $r('app.string.output_area_min_height'),
      maxHeight: $r('app.string.output_area_max_height'),
    })
    .width($r('app.string.100percent'))
    .backgroundColor($r('app.string.OutputArea_background'))
    .borderRadius($r('app.string.border_radius'))
    .align(Alignment.TopStart)
  }
}