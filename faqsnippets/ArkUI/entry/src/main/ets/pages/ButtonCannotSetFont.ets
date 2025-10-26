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
* FAQ:Button组件无法设置字体最大、最小值
*/

// [Start button_cannot_set_font]
@Entry
@Component
struct FontSizeButtonExample {
  @State text: string = 'hello';
  @State widthShortSize: number = 300;


  build() {
    Row() {
      Button(this.text)
        .width(this.widthShortSize)
        .height(100)
        //// Set the font size range to 20-40vp，Automatically adjust during actual rendering.
        .labelStyle({
          overflow: TextOverflow.Clip,
          maxLines: 1,
          minFontSize: 20,
          maxFontSize: 40,
          font: {
            size: 30,
            weight: FontWeight.Bolder,
            family: 'cursive',
            style: FontStyle.Italic
          }
        })
    }
  }
}
// [End button_cannot_set_font]