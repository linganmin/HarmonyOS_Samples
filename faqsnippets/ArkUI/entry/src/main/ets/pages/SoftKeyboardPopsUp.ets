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
* FAQ:如何实现软键盘弹出后，整体布局不变
*/

// [Start soft_keyboard_pops_up]
// xxx.ets
@Entry
@Component
struct TextInputExample {
  scroller: Scroller = new Scroller();
  @State text: string = '';

  build() {
    Scroll(this.scroller) {
      Column({ space: 20 }) {
        TextInput({ placeholder: 'Please enter the content.' })
          .expandSafeArea([SafeAreaType.KEYBOARD])
          .type(InputType.Password)
          .margin({ top: 200 })
        TextInput({ placeholder: 'Please enter the content.' })
          .expandSafeArea([SafeAreaType.KEYBOARD])
          .margin({ top: 200 })
        Text(`UserName：${this.text}`)
          .expandSafeArea([SafeAreaType.KEYBOARD])
          .width('80%')
          .margin({ top: 200 })
        TextInput({ placeholder: 'Please enter a user name.', text: this.text })
          .expandSafeArea([SafeAreaType.KEYBOARD])
          .margin({ top: 200 })
          .onChange((value: string) => {
            this.text = value;
          })
      }
      .width('100%')
    }
    .scrollBar(BarState.Off)
  }
}
// [End soft_keyboard_pops_up]