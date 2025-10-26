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
* FAQ:登录信息的cookie应该在什么时机注入？如何确保刚刚打开的web能注入登录信息cookie
*/

// [Start CookieInject]
import { webview } from '@kit.ArkWeb'

webview.once("webInited", () => {
  console.log("setCookie");
  webview.WebCookieManager.configCookie("https://www.example.com", 'a=b,c=d,e=f');
})

@Entry
@Component
struct WebComponent {
  controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Web({ src: 'www.example.com', controller: this.controller })
    }
  }
}
// [End CookieInject]