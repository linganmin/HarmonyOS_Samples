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
* FAQ:如何解决Web与List的嵌套滑动冲突
*/

// [Start resolve_the_nesting_of_web_and_list]
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct SlidingConflictBetweenWebAndList {
  webviewController: webview.WebviewController = new webview.WebviewController();

  build() {
    List() {
      ListItem() {
        Web({
          src: $rawfile('index.html'),
          controller: this.webviewController
        })
          .width('100%')
          .height(220)
      }.hitTestBehavior(HitTestMode.Block)
      ListItem() {
        Web({
          src: $rawfile('index.html'),
          controller: this.webviewController
        })
          .width('100%')
          .height(220)
      }
      ListItem() {
        Text('1')
      }
      .height(220)
      ListItem() {
        Text('2')
      }
      .height(220)
    }
    .backgroundColor(Color.Blue)
    .width('100%')
    .height('100%')
  }
}
// [End resolve_the_nesting_of_web_and_list]