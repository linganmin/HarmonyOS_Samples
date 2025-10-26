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
* FAQ:Web组件对H5页面、常用框架VUE、React的页面支持情况，包括本地和网络端的页面
*/

// [Start SupportVue1]
// xxx.ets
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebComponent {
  webviewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Button('loadUrl').onClick(() => {
        try { // When the button is clicked, it redirects to www.example1.com via loadUrl
          this.webviewController.loadUrl('www.example1.com');
        } catch (error) {
          console.error(`ErrorCode: ${error.code},  Message: ${error.message}`);
        }
      })
      // When the component is created, load www.example.com 
      Web({ src: 'www.example.com', controller: this.webviewController })
    }
  }
}
// [End SupportVue1]