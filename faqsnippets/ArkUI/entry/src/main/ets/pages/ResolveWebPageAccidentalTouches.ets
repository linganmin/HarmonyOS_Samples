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
* FAQ:如何解决Web页上下滑动时会误触发tab页翻页手势及tab页切换时Web组件还可以上下滚动问题
*/

// [Start resolve_web_page_accidental_touches]
import { webview } from '@kit.ArkWeb';


@Component
@Entry
struct TabWebScroll {
  @State isScrollEnabled: boolean = true; // Control the sliding page for page switching
  private tabsController = new TabsController();
  private currentIndex: number = 0;// Track currently active tab index
  private webviewController: webview.WebviewController = new webview.WebviewController();


  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {
        Web({ src: 'https://developer.huawei.com/consumer/cn/', controller: this.webviewController })
          .nestedScroll({
            // Set nested scrolling
            scrollForward: NestedScrollMode.PARENT_FIRST,
            scrollBackward: NestedScrollMode.SELF_FIRST
          })
      }
      .tabBar(this.tabBuilder('home page', 0))


      TabContent() {
        Column() {
          Text('find')
        }
        .width('100%')
        .height('100%')
      }
      .tabBar(this.tabBuilder('find', 1))


      TabContent() {
        Column() {
          Text('recommend')
        }
        .width('100%')
        .height('100%')
      }
      .tabBar(this.tabBuilder('recommend', 2))


      TabContent() {
        Column() {
          Text('my')
        }
        .width('100%')
        .height('100%')
      }
      .tabBar(this.tabBuilder('my', 3))
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .scrollable(this.isScrollEnabled)
    .onAnimationEnd(() => {
      // Trigger this callback when the animation ends, and set the web component to slide
      this.webviewController?.setScrollable(true);
    })
    .onGestureSwipe(() => {
      // During the sliding process on the page, this callback is triggered frame by frame. When switching between tab pages, the web page cannot slide up or down
      this.webviewController?.setScrollable(false);
    })
  }


  @Builder
  tabBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#1698CE' : '#6B6B6B')
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }
}
// [End resolve_web_page_accidental_touches]