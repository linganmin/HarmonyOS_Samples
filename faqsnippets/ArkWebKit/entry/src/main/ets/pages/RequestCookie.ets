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
* FAQ:通过网络请求而来的 Cookie 如何同步配置到web中
*/

// [Start RequestCookie]
import { webview } from '@kit.ArkWeb'
@Entry
@Component
struct WebComponent {
  controller: webview.WebviewController = new webview.WebviewController();
  headers : Array<webview.WebHeader> = [{ headerKey : "msg",headerValue : 'hello'}];
  build() {
    Column() {
      Button('configCookieSync')
        .onClick(() => {
          try {
            webview.WebCookieManager.configCookieSync('https://www.example.com', 'a=b;c=d;e=f');
          } catch (error) {
            console.error(`ErrorCode: ${error.code},  Message: ${error.message}`);
          }
        })
      Button('fetchCookieSync')
        .onClick(() => {
          try {
            let value = webview.WebCookieManager.fetchCookieSync('https://www.example.com');
            console.log("fetchCookieSync cookie = " + value);
          } catch (error) {
            console.error(`ErrorCode: ${error.code},  Message: ${error.message}`);
          }
        })
      Column() {
        Web({ src: 'www.example.com', controller: this.controller })
          .width('100%')
          .height('100%')
      }
      .layoutWeight(1)
    }
  }
}
// [End RequestCookie]