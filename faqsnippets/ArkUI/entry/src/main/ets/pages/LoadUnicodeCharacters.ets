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
* FAQ:Text 组件如何加载Unicode字符
*/

const StrToUnicode = ()=>{
  // [Start str_to_Unicode]
  let chineseStr: string = "中文";
  const encodedStr = Array.from(chineseStr).map(char =>`\\u${char.codePointAt(0)!.toString(16).padStart(4, '0')}`).join("");
  // [End str_to_Unicode]
}

const UnicodeToStr = ()=>{
  // [Start Unicode_to_str]
  let unicodeStr: string = "\\u4e2d\\u6587";
  const decodedStr = unicodeStr.replace(/\\u([\dA-Fa-f]{4})/g,(_,p1:string) => String.fromCodePoint(parseInt(p1, 16)));
  // [End Unicode_to_str]
}


// [Start load_unicode_characters]
@Entry
@Component
struct TextView {
  build() {
    Column() {
      Text("\u{1F468}\u200D\u{1F469}\u200D\u{1F467}\u200D\u{1F466}")
        .width(100)
        .height(100)
        .fontSize(50)
    }
  }
}
// [End load_unicode_characters]