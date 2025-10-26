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

/**
 * FAQ:如何实现字体渐变效果
 */

// [Start font_gradient]
@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Text(this.message)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .shaderStyle({
          direction: GradientDirection.Right,
          colors: [['#ff0631f5', 0.0], ['#ff922626', 1]]
        })
    }
    .width('100%')
    .height('100%')
  }
}

// [End font_gradient]