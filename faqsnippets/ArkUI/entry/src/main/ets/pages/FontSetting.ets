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
* FAQ:如何设置Text的字体，可以不受系统设置里显示字体大小的影响
*/

// [Start custom_font_setting]
@Entry
@Component
struct CustomFontSetting {
  @State message: string = 'hello world';

  build() {
    Column() {
      Text(this.message)
        .fontSize(53) // Default unit is fp, which changes with system display size
      Text(this.message)
        .fontSize(this.getUIContext().px2fp(160) + 'px') // Use pixel units, unaffected by system display size
      Blank()
        .color(0xff0000)
        .height(30)
        .width(226)
        .margin({ bottom: 20 }) // Default unit vp changes with system display size
      Blank()
        .color(0xff0000)
        .height(30 + 'px')
        .width(this.getUIContext().px2vp(672) + 'px') // Use pixel units, unaffected by system display size
    }
  }
}
// [End custom_font_setting]