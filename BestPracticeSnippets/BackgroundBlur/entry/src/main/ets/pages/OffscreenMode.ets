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

// [Start OffscreenMode]
@Component
export struct OffscreenMode {
  @Consume('navPathStack') navPathStack: NavPathStack;

  build() {
    NavDestination() {
      Stack() {
        Stack() {
          Image($r('app.media.map')).width('100%').height('100%').borderRadius(15)
          Flex({ direction: FlexDirection.ColumnReverse }) {
          }
          .height(80)
          .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THIN, { scale: 0.3 })
          .flexShrink(0)
          .width('100%')
          .padding(0)
          .borderRadius({
            topLeft: 0,
            topRight: 0,
            bottomLeft: 15,
            bottomRight: 15
          })
          .position({ x: 0, y: 220 })
        }.margin({ left: '16', right: '16' })
        .height(300)
        .borderRadius(15)
        // blend mode is set to offscreen mode
        .blendMode(BlendMode.SRC_OVER, BlendApplyType.OFFSCREEN)
      }
      .width('100%')
      .height('100%')
      .backgroundImage($r('app.media.img'))
      .backgroundImageSize(ImageSize.Cover)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
  }
}
// [End OffscreenMode]