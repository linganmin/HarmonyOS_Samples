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
* FAQ:如何解决Text组件文本为中文、数字、英文混合时显示省略号截断异常的问题
*/

// [Start resolve_text_truncation_exception]
@Entry
@Component
struct TextEllipsisDemo {
  @State text: string = '2 years · VIP membership for 3 months · 8GB · 230mm · Product color';

  build() {
    RelativeContainer() {
      Text(this.text)
        .width(200)// Set maximum number of rows
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })// Long text display ellipsis
        .ellipsisMode(EllipsisMode.END)// Set the line breaking rule WordBreak.BREAK_ALL and implement truncation on a letter by letter basis
        .wordBreak(WordBreak.BREAK_ALL)// API11+ required, for letter-level truncation
        .textAlign(TextAlign.JUSTIFY)
        .backgroundColor(Color.Green)
        .fontSize(16)
    }
    .height('100%')
    .width('100%')
  }
}

// [End resolve_text_truncation_exception]