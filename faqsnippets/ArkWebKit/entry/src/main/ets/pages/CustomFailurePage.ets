/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
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
* FAQ:Web加载失败时默认的白屏页面如何改为自定义的错误页
*/

// [Start CustomFailurePage]
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Stack() {
      Web({ src: 'www.example.com', controller: this.controller })
        .onErrorReceive((event) => {
          // Only handle loading errors of the main framework to avoid duplicate processing of errors in sub-resources
          if (event && event.request.isMainFrame()) {
            try {
              // 加载自定义错误页面
              this.controller.loadUrl($rawfile('custom_failure_page.html'));
            } catch (error) {
              console.error(`ErrorCode: ${(error as BusinessError).code}, Message: ${(error as BusinessError).message}`);
            }
          }
        })
    }
  }
}
// [End CustomFailurePage]