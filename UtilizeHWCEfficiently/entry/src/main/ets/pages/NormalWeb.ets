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

// [Start NormalWeb_start]
import { webview } from '@kit.ArkWeb';
// [StartExclude NormalWeb_start]
@Builder
export function NormalWebBuilder() {
  NormalWeb()
}
// [EndExclude NormalWeb_start]
@Entry
@Component
struct NormalWeb {
  @State currentIndex: number = 0; // The index of the currently selected tab page
  private controller: TabsController = new TabsController();
  private webController: webview.WebviewController = new webview.WebviewController();
  // [StartExclude NormalWeb_start]
  pathStack: NavPathStack = new NavPathStack();
  // [EndExclude NormalWeb_start]
  @Builder
  tabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    // [StartExclude NormalWeb_start]
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
    // [EndExclude NormalWeb_start]
  }

  build() {
    // [StartExclude NormalWeb_start]
    NavDestination() {
      // [EndExclude NormalWeb_start]
      Tabs({ barPosition: BarPosition.End, index: 0, controller: this.controller }) {
        TabContent() {
          Web({ src: $rawfile('test.html'), controller: this.webController })
        }
        .tabBar(this.tabBuilder('Tab', 0, $r('app.media.tab_icon_activated'), $r('app.media.tab_icon')))
        // [StartExclude NormalWeb_start]
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
        // [EndExclude NormalWeb_start]
      }
      .height('100%')
      .width('100%')
      .barOverlap(true) // Set TabBar to overlay on top of TabContent
      .barBackgroundBlurStyle(BlurStyle.NONE) // Set TabBar to be not blurry
      .barBackgroundColor('rgba(241, 243, 245, 1)')
      // [StartExclude NormalWeb_start]
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
    // [EndExclude NormalWeb_start]
  }
}
// [End NormalWeb_start]