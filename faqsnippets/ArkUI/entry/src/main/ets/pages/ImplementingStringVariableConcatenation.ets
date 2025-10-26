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
* FAQ:ArkUI组件的字符串中如何实现字符串变量拼接
*/

@Component
struct implement {
  build() {
    // [Start implementing_string_variable_concatenation_one]
    Text($r('app.string.EntryAbility_desc', 'Hello'))
    // [End implementing_string_variable_concatenation_one]
  }
}

// [Start implementing_string_variable_concatenation_Four]
@Entry
@Component
struct Page1 {
  @State num1: number = 100;

  build() {
    Row() {
      Column() {
        Text($r('app.string.module_desc', this.num1))
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End implementing_string_variable_concatenation_Four]