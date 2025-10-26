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
* FAQ:使用0x八位颜色设置渐变透明度为什么与#八位资源颜色值不同
*/

// [Start gradient_transparency_varies]
@Entry
@Component
struct ColorGradientExample {
  @State transparent: number | string = '#00333333';
  private bool: boolean = true;

  build() {
    Column({ space: 5 }) {
      Text('linearGradient')
        .fontSize(12)
        .width('90%')
        .fontColor(0xCCCCCC)
      Row()
        .width('90%')
        .height(150)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [[this.transparent, 0.0], [0x80000000, 1.0]]
        })
      Button('Switch color resources')
        .onClick(() => {
          if (this.bool) {
            this.transparent = 0x00333333;
            this.bool = false;
          } else {
            this.transparent = '#00333333';
            this.bool = true;
          }
        })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .padding({ top: 5 })
  }
}
// [End gradient_transparency_varies]