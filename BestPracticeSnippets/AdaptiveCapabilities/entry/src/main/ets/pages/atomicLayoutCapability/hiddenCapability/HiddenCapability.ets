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

// [Start HiddenCapability]
@Entry
@Component
struct HiddenCapability {
  @State rate: number = 0.8;

  @Builder
  slider() {
    Slider({ value: this.rate * 100, min: 10, max: 80 })
      .blockColor(Color.White)
      .width('60%')
      .height(50)
      .onChange((value: number) => {
        this.rate = value / 100;
      })
      .position({ x: '20%', y: '80%' })
  }

  build() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.favorite'))
            .width(48)
            .height(48)
            .objectFit(ImageFit.Contain)
        }
        // Layout priority.
        .displayPriority(1)
        .padding({ left: 12, right: 12 })

        Row() {
          Image($r('app.media.down'))
            .width(48)
            .height(48)
            .objectFit(ImageFit.Contain)
        }
        // Layout priority.
        .displayPriority(2)
        .padding({ left: 12, right: 12 })

        Row() {
          Image($r('app.media.pause'))
            .width(48)
            .height(48)
            .objectFit(ImageFit.Contain)
        }
        // Layout priority.
        .displayPriority(3)
        .padding({ left: 12, right: 12 })

        Row() {
          Image($r('app.media.next'))
            .width(48)
            .height(48)
            .objectFit(ImageFit.Contain)
        }
        // Layout priority.
        .displayPriority(2)
        .padding({ left: 12, right: 12 })

        Row() {
          Image($r('app.media.list'))
            .width(48)
            .height(48)
            .objectFit(ImageFit.Contain)
        }
        // Layout priority.
        .displayPriority(1)
        .padding({ left: 12, right: 12 })
      }
      .width(this.rate * 100 + '%')
      .height(96)
      .borderRadius(16)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .justifyContent(FlexAlign.Center)

      this.slider()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}

// [End HiddenCapability]