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
* FAQ:自定义键盘和系统键盘如何切换
*/

// [Start switching_between_custom_and_system_keyboard]
@Component
export struct CustomSystemKeyboardToggle {
  controller: TextInputController = new TextInputController();
  @State inputValue: string = '';
  @State show: boolean = false;

  // Customize keyboard components
  @Builder
  customKeyboardBuilder() {
    Column() {
      Button('x')
        .onClick(() => {
          // Turn off custom keyboard
          this.controller.stopEditing();
          this.show = !this.show;
        })
      Grid() {
        ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, '*', 0, '#'], (item: number | string) => {
          GridItem() {
            Button(item + '')
              .width(110)
              .onClick(() => {
                this.inputValue += item;
              })
          }
        })
      }
      .maxCount(3)
      .columnsGap(10)
      .rowsGap(10)
      .padding(5)
    }
    .backgroundColor(Color.Gray)
  }

  build() {
    Column() {
      TextInput({ controller: this.controller, text: this.inputValue })// Bind custom keyboard
        .customKeyboard(this.show ? this.customKeyboardBuilder() : undefined)
        .margin(10)
        .height(48)
      Button('switch')
        .onClick(() => {
          this.show = !this.show;
        })
    }
  }
}
// [End switching_between_custom_and_system_keyboard]