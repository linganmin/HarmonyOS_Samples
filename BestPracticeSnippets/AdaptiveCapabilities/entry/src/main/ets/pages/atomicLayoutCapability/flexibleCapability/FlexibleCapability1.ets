/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// [Start FlexibleCapability1]
@Entry
@Component
struct FlexibleCapability1 {
  @State sliderWidth: number = 1000;

  // Bottom slider - adjust container size by dragging the slider.
  @Builder
  slider() {
    Slider({ value: this.sliderWidth, min: 300, max: 1000 })
      .blockColor(Color.White)
      .width('60%')
      .onChange((value: number) => {
        this.sliderWidth = value;
      })
      .position({ x: '20%', y: '80%' })
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        // Distribute all extra space to the image using flexGrow and allocate all insufficient space to the side margins using flexShrink.
        Row()
          .width(150)
          .height(400)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .flexGrow(0)
          .flexShrink(1)
        Image($r('app.media.illustrator'))
          .width(300)
          .height(400)
          .objectFit(ImageFit.Contain)
          .backgroundColor('#66F1CCB8')
          .flexGrow(1)
          .flexShrink(0)
        Row()
          .width(150)
          .height(400)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .flexGrow(0)
          .flexShrink(1)
      }
      .width(this.sliderWidth)

      this.slider()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}

// [End FlexibleCapability1]