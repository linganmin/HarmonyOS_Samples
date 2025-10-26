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
* FAQ:TextInput在聚焦时如何使光标回到起点
*/

// [Start return_the_cursor_to_the_start_point]
@Entry
@Component
struct TextInputDemo {
  controller: TextInputController = new TextInputController();

  build() {
    Column() {
      TextInput({ controller: this.controller })
        .onEditChange((isEditing: boolean) => {
          if (isEditing) {
            setTimeout(() => {
              // The cursor will reset to the beginning of the text after 100ms
              this.controller.caretPosition(0);
            }, 100)
          }
        })
    }
  }
}
// [End return_the_cursor_to_the_start_point]