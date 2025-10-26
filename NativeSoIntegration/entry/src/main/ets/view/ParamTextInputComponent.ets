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
  @Prop paramName: Resource;
  @Prop inputAlert: Resource;

  build() {
    Column({ space: 12 }) {
      Text(this.paramName)
        .fontSize(16)
        .fontColor(Color.Grey)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .width('100%')
      TextInput({ text: this.param, placeholder: this.inputAlert })
        .type(InputType.Number)
        .width('100%')
        .backgroundColor(Color.White)
        .fontSize(16)
        .fontWeight(FontWeight.Regular)
        .maxLength(5)
        .onWillInsert((info: InsertValue) => !(info.insertOffset === 0 && info.insertValue === '0'))
        .onChange((value) => {
          this.param = value;
        })
        .backgroundColor(Color.White)
        .borderRadius(16)
    }
    .margin({
      bottom: 16
    })
    .padding({
      left: 16,
      right: 16
    })
  }
}