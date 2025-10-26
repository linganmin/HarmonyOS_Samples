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
* FAQ:多个Cookie如何进行批量设置
*/

// [Start MultiCookieConfig]
import { webview } from '@kit.ArkWeb';

webview.once("webInited", () => {
  console.info("webInited setCookie");
  webview.WebCookieManager.configCookie("https://www.example.com", 'a=b');
  webview.WebCookieManager.configCookie("https://www.example.com", 'c=d');
  webview.WebCookieManager.configCookie("https://www.example.com", 'e=f');
})

@Entry
@Component
struct LoginCookieConfig {
  controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Button('fetchCookieSync')
        .onClick(() => {
          try {
            let value = webview.WebCookieManager.fetchCookieSync('https://www.example.com');
            console.log(`fetchCookieSync cookie value is: ${value}`);
          } catch (error) {
            console.error(`fetchCookieSync failed,error is: ${JSON.stringify(error)}`);
          }
        })
      Web({ src: 'www.example.com', controller: this.controller })
    }
  }
}
// [End MultiCookieConfig]