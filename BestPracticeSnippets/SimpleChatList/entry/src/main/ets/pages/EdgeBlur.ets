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


@Component
export struct EdgeBlur {
  private arr: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  // [Start linearGradient]
  @Builder
  overlayBuilder() {
    Stack().height('100%').height('100%')
      .linearGradient({
        direction: GradientDirection.Bottom, // Gradient direction.
        colors: [[0x00000000, 0.0], [0xB3000000, 1.0]]
      })
      .blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN)
  }

  build() {
    NavDestination() {
      List({ space: 20, initialIndex: 0 }) {
        ForEach(this.arr, (item: number) => {
          ListItem() {
            Text('' + item)
              .width('100%')
              .height(100)
              .fontSize(16)
              .textAlign(TextAlign.Center)
              .borderRadius(16)
              .backgroundColor(0xDCDCDC)
          }
          .borderRadius(16)
          .backgroundColor(0xDCDCDC)
        }, (item: string) => item)
      }
      .overlay(this.overlayBuilder())
      // [End linearGradient]
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      // [Start DisableScrolling]
      .onScrollFrameBegin((offset: number, state: ScrollState) => {
        return { offsetRemain: 0 } // If the return value is set to 0, it means that there will be no scrolling.
      })
      // [End DisableScrolling]
      .friction(0.6)
      .contentEndOffset(60)
      .width('90%')
    }
    .width('100%')
    .height('100%')
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}