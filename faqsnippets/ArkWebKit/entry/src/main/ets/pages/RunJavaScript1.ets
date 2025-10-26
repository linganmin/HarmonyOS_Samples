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
* FAQ:Web加载的H5页面跳转后，如何避免原有页面注册的资源被清空
*/

// [Start RunJavaScript1]
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct Index {
  controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Column({ space: 20 }) {
      Button('调用注册资源')
        .onClick(e => {
          try {
            this.controller.runJavaScript(
              'test()',
              (error, result) => {
                if (error) {
                  console.error(`run JavaScript error, ErrorCode: ${error.code},  Message: ${error.message}`);
                  return;
                }
                if (result) {
                  console.info(`The test() return value is: ${result}`);
                }
              });
          } catch (error) {
            console.error(`ErrorCode: ${error.code},  Message: ${error.message}`);
          }
        })
      Button('调用注册资源')
        .onClick(e => {
          try {
            this.controller.runJavaScript(
              'bodyOnLoadLocalStorage()',
              (error, result) => {
                if (error) {
                  console.error(`run JavaScript error, ErrorCode: ${error.code},  Message: ${error.message}`);
                  return;
                }
                if (result) {
                  console.info(`The bodyOnLoadLocalStorage() return value is: ${result}`);
                }
              });
          } catch (error) {
            console.error(`ErrorCode: ${error.code},  Message: ${error.message}`);
          }
        })
      Web({ src: $rawfile('index.html'), controller: this.controller })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .backgroundColor(Color.Grey)
        .width('100%')
        .height('100%')
    }
  }
}
// [End RunJavaScript1]