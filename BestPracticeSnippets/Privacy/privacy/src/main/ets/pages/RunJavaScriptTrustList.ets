/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

/**
 * 最佳实践：应用安全编码实践
 * 场景十五：避免加载不可信的JavaScript脚本—加载前进行白名单校验
 */

// [Start check_the_trust_list]
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct WebComponent {
  controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Web({ src: $rawfile('index.html'), controller: this.controller })
        .javaScriptAccess(true)
        .onPageEnd(e => {
          let whiteMethods = ['test()', 'test1()'];
          let jsMethod: string = 'alert(`xss`)'; // Externally controllable fields
          // Check the trustlist
          if (whiteMethods.indexOf(jsMethod) === -1) {
            hilog.error(0x0000, 'privacy', 'input method not in whiteList');
            return;
          }
          this.controller.runJavaScript(jsMethod)
            .then((result) => {
              hilog.info(0x0000, 'privacy', 'result: ' + result);
            })
            .catch((error: BusinessError) => {
              hilog.error(0x0000, 'privacy', `ErrorCode: ${error.code},  Message: ${error.message}`);
            })
          if (e) {
            hilog.info(0x0000, 'privacy', 'url: ', e.url);
          }
        })
    }
  }
}
// [End check_the_trust_list]