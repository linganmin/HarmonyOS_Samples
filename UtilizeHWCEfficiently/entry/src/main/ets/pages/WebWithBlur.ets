/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

// [Start WebWithBlur_start]

import { webview } from '@kit.ArkWeb';
// [StartExclude WebWithBlur_start]
@Builder
export function WebWithBlurBuilder() {
  WebWithBlur()
}
// [EndExclude WebWithBlur_start]
@Entry
@Component
struct WebWithBlur {
  @State currentIndex: number = 0; // The index of the currently selected tab page
  private controller: TabsController = new TabsController();
  private webController: webview.WebviewController = new webview.WebviewController();
  // [StartExclude WebWithBlur_start]
  pathStack: NavPathStack = new NavPathStack();
  // [EndExclude WebWithBlur_start]
  @Builder
  tabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    // [StartExclude WebWithBlur_start]
    Column({ space: 4 }) {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size({
          width: 24,
          height: 24
        })
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#0A59F7' : 'rgba(0, 0, 0, 0.6)')
        .fontSize(10)
        .fontWeight(FontWeight.Medium)
    }
    .height('100%')
    .padding({ bottom: 28 })
    .justifyContent(FlexAlign.Center)
    // [EndExclude WebWithBlur_start]
  }

  build() {
    // [StartExclude WebWithBlur_start]
    NavDestination() {
      // [EndExclude WebWithBlur_start]
      Tabs({ barPosition: BarPosition.End, index: 0, controller: this.controller }) {
        TabContent() {
          Web({ src: $rawfile('test.html'), controller: this.webController })
        }
        .tabBar(this.tabBuilder('Tab', 0, $r('app.media.tab_icon_activated'), $r('app.media.tab_icon')))
        // [StartExclude WebWithBlur_start]
        .padding({
          left: 16,
          right: 16,
          top: 10
        })

        TabContent() {
          Web({ src: $rawfile('test.html'), controller: this.webController })
        }
        .tabBar(this.tabBuilder('Tab', 1, $r('app.media.tab_icon_activated'), $r('app.media.tab_icon')))
        .padding({
          left: 16,
          right: 16,
          top: 10
        })
        // [EndExclude WebWithBlur_start]
      }
      .height('100%')
      .width('100%')
      .barOverlap(true) // Set TabBar to be blurred and overlay on top of TabContent
      .barBackgroundColor('rgba(241, 243, 245, 0.3)')
      // [StartExclude WebWithBlur_start]
      .padding({ top: 36 })
      .vertical(false)
      .barMode(BarMode.Fixed)
      .scrollable(true)
      .animationDuration(200)
      .barHeight(80)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    // [EndExclude WebWithBlur_start]
  }
}
// [End WebWithBlur_start]