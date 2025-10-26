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

// [Start EquipartitionCapability]
@Entry
@Component
struct EquipartitionCapability {
  @State rate: number = 0.6;
  private list: number [] = [0, 1, 2, 3];

  // Bottom slider - adjust container dimensions via slider drag interaction.
  @Builder
  slider() {
    Slider({ value: this.rate * 100, min: 30, max: 60 })
      .blockColor(Color.White)
      .width('60%')
      .height(50)
      .onChange((value: number) => {
        this.rate = value / 100;
      })
      .position({ x: '20%', y: '80%' })
  }

  @Builder
  Item() {
    Column() {
      Image($r('app.media.icon'))
        .width(48)
        .height(48)
        .margin(({ top: 8 }))
      Text($r('app.string.show_app_name'))
        .width(64)
        .height(30)
        .lineHeight(15)
        .fontSize(12)
        .textAlign(TextAlign.Center)
        .margin({ top: 8 })
        .padding({ bottom: 15 })
    }
    .width(80)
    .height(102)
  }

  build() {
    Row() {
      Column() {
        // Distribute remaining space evenly along the main axis of the parent container.
        Flex({ justifyContent: FlexAlign.SpaceEvenly }) {
          ForEach(this.list, () => {
            this.Item();
          }, (item: number, index: number) => item.toString() + index)
        }

        // Distribute remaining space evenly along the main axis of the parent container.
        Flex({ justifyContent: FlexAlign.SpaceEvenly }) {
          ForEach(this.list, () => {
            this.Item();
          }, (item: number, index: number) => item.toString() + index)
        }
      }
      .width(this.rate * 100 + '%')
      .height(222)
      .padding({ top: 16 })
      .backgroundColor($r('sys.color.font_on_primary'))
      .borderRadius(16)

      this.slider()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
// [End EquipartitionCapability]