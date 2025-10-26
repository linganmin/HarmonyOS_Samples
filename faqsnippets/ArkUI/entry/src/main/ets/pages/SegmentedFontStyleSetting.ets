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
* FAQ:文本组件是否支持分段设置字体样式
*/

// [Start segmented_font_style_setting]
@Entry
@Component
struct TestDemoPage {
  @State message: string = "Hello World";

  build() {
    Row() {
      Column() {
        Text() {
          // Using the Span subcomponent to implement segmented style settings
          Span('test text: ')
            .fontSize(20)
            .fontWeight(FontWeight.Bolder)
            .fontColor(Color.Black)
          Span(this.message)
            .fontSize(15)
            .fontColor(Color.Red)
        }
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End segmented_font_style_setting]