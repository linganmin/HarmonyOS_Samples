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
* FAQ:如何判断Web滑动到了顶部/底部，并且把滑动事件传递给页面
*/

// [Start GetScroll]
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct Index {
  private scrollerForScroll: Scroller = new Scroller();
  controller: webview.WebviewController = new webview.WebviewController; // Web component controller, used for loading pages and interaction control
  @State scrollDirection: ScrollDirection = ScrollDirection.Vertical;
  title = '2023落下帷幕，一起迎接2024年***********************************************';
  review = '评论';
  context = '一起迎接2024年，***********************************************************************************';
  list = [0, 0, 0, 0];

  build() {
    Flex() {
      Scroll(this.scrollerForScroll) {
        Column({ space: 5 }) {
          Text(this.title)
            .fontSize(40)
            .padding(40)
          List() {
            ForEach(this.list, () => {
              ListItem() {
                Text(this.context).fontSize(16)
              }
            })
          }

          Web({ src: $rawfile('index.html'), controller: this.controller })
            .nestedScroll({
              scrollForward: NestedScrollMode.SELF_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })
            .height('100%')
            .width('100%')
            .layoutMode(WebLayoutMode.FIT_CONTENT)
          Text(this.review)
            .fontSize(30)
          List() {
            ForEach(this.list, () => {
              ListItem() {
                Text(this.context)
                  .fontSize(16)
              }
            })
          }
        }
        .width('95%')
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('120%')
      .scrollable(this.scrollDirection)
    }
    .width('100%')
    .height('100%')

  }
}
// [End GetScroll]