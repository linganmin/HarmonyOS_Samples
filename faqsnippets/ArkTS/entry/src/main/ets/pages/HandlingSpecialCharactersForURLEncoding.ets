/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
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
* FAQ:如何在URL编码时处理特殊字符
 */

// [Start HandlingSpecialCharactersForURLEncoding]
@Entry
@Component
export struct HandlingSpecialCharactersForURLEncoding {
  @State message: string = 'encode';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            const originalString = '123+456';
            const encoded = encodeURIComponent(originalString);
            console.info(encoded); // output: '123%2B456'.
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}

// [End HandlingSpecialCharactersForURLEncoding]