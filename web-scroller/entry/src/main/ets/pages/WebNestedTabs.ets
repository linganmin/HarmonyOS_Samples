/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { webview } from '@kit.ArkWeb';

@Component
export struct WebNestedTabs {
  @State currentIndex: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  private controller: webview.WebviewController = new webview.WebviewController();
  private tabController: TabsController = new TabsController();

  @Builder
  tabBuilder(text: Resource, targetIndex: number) {
    Row() {
      Text(text)
        .fontColor(targetIndex === this.currentIndex ? Color.White : Color.Black)
        .fontSize(14)
        .fontWeight(500)
        .lineHeight(20)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(158)
    .height(40)
    .borderRadius(20)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(targetIndex === this.currentIndex ? '#0A59F7' : '#E5E7E9')
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabController.changeIndex(targetIndex);
    })
    .margin({
      left: 6,
      right: 6,
      top: 8,
      bottom: 8
    })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Web({
            src: "https://www.huawei.com/cn",
            controller: this.controller
          })
            .height(400)
            .width('100%')
          Column() {

            Tabs({ barPosition: BarPosition.Start, controller: this.tabController }) {
              TabContent() {
                Web({
                  src: 'https://developer.huawei.com/consumer/cn/',
                  controller: this.controller
                })
                  .nestedScroll({
                    scrollForward: NestedScrollMode.PARENT_FIRST,
                    scrollBackward: NestedScrollMode.SELF_FIRST
                  })
                  .height('100%')
              }
              .tabBar(this.tabBuilder($r('app.string.announcement1'), 0))

              TabContent() {
                Web({
                  src: 'https://developer.huawei.com/consumer/cn/',
                  controller: this.controller
                })
                  .nestedScroll({
                    scrollForward: NestedScrollMode.PARENT_FIRST,
                    scrollBackward: NestedScrollMode.SELF_FIRST
                  })
                  .height('100%')
              }
              .tabBar(this.tabBuilder($r('app.string.announcement2'), 1))
            }
            .vertical(false)
            .scrollable(true)
            .barMode(BarMode.Scrollable)
            .barHeight(56)
            .height('100%')
            .barBackgroundColor('#F1F3F5')
            .scrollable(false)
          }
          .height('100%')
        }
      }
    }
    .padding({ top: this.topRectHeight })
    .title('WebNestedTabs')
  }
}