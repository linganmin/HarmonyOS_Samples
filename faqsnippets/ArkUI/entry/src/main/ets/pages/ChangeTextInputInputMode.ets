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
* FAQ:如何更改TextInput密码输入模式下passwordIcon的大小、颜色、位置
*/

// [Start change_textInput_input_mode]
@Entry
@Component
struct TextInputDemo {
  @State text: string = '';
  @State changeType: InputType = InputType.Password;
  @State isVisible: boolean = false;
  @State isPasswordVisible: boolean = false;
  controller: TextInputController = new TextInputController();

  build() {
    Stack() {
      TextInput({ text: this.text, controller: this.controller })
        .type(this.changeType)
        .placeholderFont({
          size: 16,
          weight: 400
        })
        .showPasswordIcon(false)// You need to disable the native password icon (showPasswordIcon(false)) for it to take effect.
        .width(336)
        .height(56)
        .padding({ right: 50 })
        .onChange((value: string) => {
          this.text = value;
        })
      //Image overlay passwordIcon implementation
      Image($r(this.isVisible ? 'app.media.startIcon' : 'app.media.invisible'))
        .margin({ left: 280 })
        .backgroundColor('#E7E8EA')
        .width(20)
        .height(20)
        .onClick(() => {
          this.isPasswordVisible = !this.isPasswordVisible;
          this.isVisible = !this.isVisible;
          if (this.isPasswordVisible) {
            this.changeType = InputType.Normal;
          } else {
            this.changeType = InputType.Password;
          }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}

// [End change_textInput_input_mode]