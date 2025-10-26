/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@Component
export struct Hsp1Page {
  build() {
    NavDestination() {
      Column({ space: 24 }) {
        Column() {
          Text($r('app.string.access_resource_har2'))
            .fontSize(20)
            .fontWeight(700)
            .width('100%')
            .margin({ bottom: 2 })
          // [Start r_start]
          Text($r('app.string.string_in_har2'))
            // [End r_start]
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontSize(16)
            .width('100%')
          // [Start r_start]
          Image($r('app.media.image_in_har2'))
            // [End r_start]
            .width('100%')
            .height(150)
            .objectFit(ImageFit.TOP_START)
            .constraintSize({ maxWidth: 360 })
            .borderRadius(8)
            .margin({ top: 8 })
        }

        Column() {
          Text($r('app.string.access_resource_hsp2'))
            .fontSize(20)
            .fontWeight(700)
            .width('100%')
            .margin({ bottom: 2 })
          // [Start r_hsp2_start]
          Text($r('[hsp2].string.string_in_hsp2'))
            // [End r_hsp2_start]
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontSize(16)
            .width('100%')
          // [Start r_hsp2_start]
          Image($r('[hsp2].media.image_in_hsp2'))
            // [End r_hsp2_start]
            .width('100%')
            .height(150)
            .objectFit(ImageFit.TOP_START)
            .constraintSize({ maxWidth: 360 })
            .borderRadius(8)
            .margin({ top: 8 })
        }
      }
      .padding(16)
    }
    .title('Hsp1Page')
    .backgroundColor('#F1F3F5')
  }
}