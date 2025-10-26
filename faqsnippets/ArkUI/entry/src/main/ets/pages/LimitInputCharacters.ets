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
* FAQ:TextInput如何限制输入字符为某些字符
*/

// [Start limit_input_characters]
@Entry
@Component
struct Index {
  controller: TextInputController = new TextInputController();

  build() {
    Column() {
      TextInput({ placeholder: 'Please input a password', text: '123456', controller: this.controller })
        .type(InputType.Password)
        .placeholderColor(Color.Gray)
        .inputFilter('[0-9]', (val) => { //Only allow the input of characters 0-9, other characters are invalid
          console.error('TextInputExample : ' + val);
          // Invalid input return 0
          return 0;
        })
    }
  }
}
// [End limit_input_characters]