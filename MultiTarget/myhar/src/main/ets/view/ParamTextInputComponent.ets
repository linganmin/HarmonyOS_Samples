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
@Component
export struct ParamTextInputComponent {
  @Link param: string;
  @Prop paramName: Resource | string;
  @Prop inputAlert: Resource | string;
  judge = (str: string) => {
    for (let i = 0; i < str.length; i++) {
      if (str[i] !== '0') {
        return false;
      }
    }
    return true;
  }

  build() {
    Column() {
      Text(this.paramName)
        .fontSize(14)
        .fontColor(Color.Black)
        .fontWeight(500)
        .opacity(0.6)
        .height(20)
      TextInput({ text: this.param, placeholder: this.inputAlert })
        .type(InputType.Number)
        .maxLength(5)
        .height(40)
        .backgroundColor(Color.White)
        .fontSize(16)
        .fontColor(Color.Black)
        .opacity(0.6)
        .fontWeight(FontWeight.Normal)
        .onChange((value) => {
          if (value.length > 0 && this.judge(value)) {
            this.param = '0';
          } else {
            this.param = value.replace(/^0+/, '');
          }
        })
        .backgroundColor(Color.White)
        .borderRadius(24)
        .margin({ top: 8, bottom: 8 })
    }
    .padding({ left: 16, right: 16, top: 12 })
    .alignItems(HorizontalAlign.Start)
  }
}