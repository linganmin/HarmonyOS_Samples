/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:TextInput按压态背景色如何修改
*/

// [Start modify_background_color_of_pressed_state]
@Entry
@Component
struct Index {
  @State modifier: MyTextInputModifier = new MyTextInputModifier();

  build() {
    Row() {
      Column() {
        TextInput({ placeholder: 'test' })
          .width('80%')
          .height(100)
          .attributeModifier(this.modifier)
      }
      .width('100%')
    }
    .height('100%')
  }
}

class MyTextInputModifier implements AttributeModifier<TextInputAttribute> {
  applyNormalAttribute(instance: TextInputAttribute): void {
    instance.backgroundColor(Color.Grey);
  }

  applyPressedAttribute(instance: TextInputAttribute): void {
    instance.backgroundColor(Color.Blue);
  }
}

// [End modify_background_color_of_pressed_state]