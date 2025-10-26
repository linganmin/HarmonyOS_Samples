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
* FAQ:如何加载和使用自定义字体
*/

// [Start loading_and_using_custom_fonts]
// xxx.ets
import { Font } from '@kit.ArkUI';

@Entry
@Component
struct FontExample {
  @State message: string = 'Hello World';

  aboutToAppear() {
    // Register in black font
    let font: Font = this.getUIContext().getFont()
    font.registerFont({
      familyName: 'Condensed_Black', // Registered font name
      familySrc: '/font/Sans_Condensed_Black.ttf' // The font folder is at the same level as the pages directory
    })

    // Register in black oblique font
    font.registerFont({
      familyName: 'Condensed_Black_Italic', // Registered font name
      familySrc: '/font/Sans_Condensed_Black_Italic.ttf' // The font folder is at the same level as the pages directory
    })
  }

  build() {
    Column() {
      Text(this.message)
        .align(Alignment.Center)
        .fontSize(50)
        .fontFamily('Condensed_Black') // Use black font
      Text(this.message)
        .align(Alignment.Center)
        .fontSize(50)
        .fontFamily('Condensed_Black_Italic') // Use black oblique font
      Text(this.message)
        .align(Alignment.Center)
        .fontSize(50)
    }
    .width('100%')
    .margin({ top: 30 })
  }
}
// [End loading_and_using_custom_fonts]