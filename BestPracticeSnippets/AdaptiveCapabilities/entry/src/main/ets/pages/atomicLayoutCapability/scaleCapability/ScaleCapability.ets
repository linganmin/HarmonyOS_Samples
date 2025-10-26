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

// [Start ScaleCapability]
@Entry
@Component
struct ScaleCapability {
  @State sliderWidth: number = 400;
  @State sliderHeight: number = 400;

  // Bottom slider - adjust container size through slider drag interaction.
  @Builder
  slider() {
    Slider({
      value: this.sliderWidth,
      min: 100,
      max: 400,
      style: SliderStyle.OutSet
    })
      .blockColor(Color.White)
      .width('60%')
      .height(50)
      .onChange((value: number) => {
        this.sliderWidth = value;
      })
      .position({ x: '20%', y: '80%' })
    Slider({
      value: this.sliderHeight,
      min: 100,
      max: 400,
      style: SliderStyle.OutSet
    })
      .blockColor(Color.White)
      .width('60%')
      .height(50)
      .onChange((value: number) => {
        this.sliderHeight = value;
      })
      .position({ x: '20%', y: '87%' })
  }

  build() {
    Column() {
      Column() {
        Column() {
          Image($r('app.media.illustrator'))
            .width('100%')
            .height('100%')
        }
        // Maintain fixed aspect ratio.
        .aspectRatio(1)
        // Decorative border (purely for visual demonstration purposes).
        .border({ width: 2, color: '#66F1CCB8' })
      }
      .backgroundColor($r('sys.color.comp_background_primary'))
      .height(this.sliderHeight)
      .width(this.sliderWidth)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      this.slider()
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
// [End ScaleCapability]