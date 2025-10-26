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
* FAQ:如何实现直播评论场景中顶部渐变遮罩效果
*/

// [Start gradient_mask_for_live_comment_scene]
@Entry
@Component
struct MaskDemo {
  private arr: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

  @Builder
  createOverlayBuilder() {
    Stack()
      .height('100%')
      .width('100%')
      .linearGradient({
        direction: GradientDirection.Bottom, // Gradient direction
        colors: [['#00FFFFFF', 0.0], ['#FFFFFFFF',
          0.3]] // When the proportion of elements at the end of the array is less than 1, it satisfies the repeated shading effect
      })
      .blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN)// Implement a top gradient mask effect using the DST_IN blending mode.
      .hitTestBehavior(HitTestMode.None)
  }

  build() {
    Column() {
      List({ space: 20, initialIndex: 0 }) {
        ForEach(this.arr, (item: number) => {
          ListItem() {
            Text(item.toString())
              .width('100%')
              .height(100)
              .fontSize(16)
              .textAlign(TextAlign.Center)
              .borderRadius(10)
              .backgroundColor(0xFFFFFF)
          }
          .onClick(() => {
            console.log('is click');
          })
        }, (item: string) => item)
      }
      .width('90%')
      .height('100%')
      .scrollBar(BarState.Off)
      .overlay(this.createOverlayBuilder())
      .blendMode(BlendMode.SRC_OVER, BlendApplyType.OFFSCREEN)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xDCDCDC)
  }
}

// [End gradient_mask_for_live_comment_scene]