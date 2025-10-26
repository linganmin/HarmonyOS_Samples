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
* FAQ:如何主动清除控件的焦点？
*/

// [Start proactively_clear_the_focus_of_the_control]
@Entry
@Component
struct ClearComponentFocus {
  // Whether textInput is focus
  @State textFocusable: boolean = true;
  @State text: string = 'Gain focus';

  build() {
    Column() {
      TextInput({ text: this.text })
        .focusable(this.textFocusable)
        .onFocus(() => {
          this.text = 'Gain focus';
        })
        .onBlur(() => {
          this.text = 'Lost Focus';
        })
      Button('Button1')
        .width(160)
        .height(70)
        .margin({ top: 20 })
        .onClick(() => {
          this.textFocusable = !this.textFocusable;
        })
    }
    .width('100%')
    .height('100%')
  }
}
// [End proactively_clear_the_focus_of_the_control]