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
* FAQ:Web组件中如何通过手势滑动返回上一个Web页面
*/

// [Start BackPageByGesturesPage]
import { webview } from "@kit.ArkWeb";

@Entry
@Component
struct PageOne {
  pageInfos: NavPathStack = new NavPathStack();
  controller: webview.WebviewController = new webview.WebviewController();

  build() {
    NavDestination() {
      Column() {
        Web({ src: 'https://www.XXX.com/', controller: this.controller }) // It needs to be manually replaced with the actual website
      }
      .width('100%')
      .height('100%')
    }
    .title('pageOne')
    .onBackPressed(() => {
      if (this.controller.accessBackward()) { // Determine whether the web page can be navigated back
        this.controller.backward() // Navigate back to the previous webpage
        return true
      } else {
        const popDestinationInfo = this.pageInfos.pop(); // Pop the top element of the routing stack 
        return true;
      }
    }).onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}
// [End BackPageByGesturesPage]