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

// [Start adaptive_color]
@Component
export struct AdaptiveColorMode {
  @Consume('navPathStack') navPathStack: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
          Text('Background Material Blur').fontColor('#FFFFFF')
        }
        .height('50%')
        .width('70%')
        // just set the parameter adaptiveColor
        .backgroundEffect({
          radius: 20,
          saturation: 1.0,
          brightness: 1.0,
          adaptiveColor: AdaptiveColor.AVERAGE
        })
        .position({ x: '15%', y: '30%' })
      }
      .height('100%')
      .width('100%')
      .backgroundImage($r('app.media.test'))
      .backgroundImageSize(ImageSize.Cover)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
  }
}
// [End adaptive_color]