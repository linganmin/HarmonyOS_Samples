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
* FAQ:如何实现点击输入框时会拉起软键盘，点击Button时软键盘关闭
*/

// [Start click_button_software_keyboard_to_close]
import { inputMethod } from '@kit.IMEKit';

@Entry
@Component
struct ClickBlankHideKeyboard {
  build() {
    Column({ space: 12 }) {
      TextInput({ placeholder: 'Please enter your account' })
        .height(40)
      TextInput({ placeholder: 'Please input a password' })
        .height(40)
      Button('log on').width('100%')
        .onClick(() => {
          // Exit text editing mode
          try {
            this.inputRef.blur(); 
            // Close the current input session and hide the soft keyboard.
            inputMethod.getController().stopInputSession();
          } catch (err) {
            console.error('Failed to hide keyboard: ' + err);
          }
        })
    }
  }
}
// [End click_button_software_keyboard_to_close]