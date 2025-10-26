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
* FAQ:Button组件如何设置渐变背景色
*/

// [Start button_set_gradient_background_color]
@Entry
@Component
struct Index {
  build() {
    Button('test')
      .width(200)
      .height(50)
      .backgroundColor('#00000000')
      .linearGradient({
        angle: 90,
        colors: [[0xff0000, 0.0], [0x0000ff, 0.3], [0xffff00, 1.0]]
      })
  }
}
// [End button_set_gradient_background_color]