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
 * 场景二十四：避免注册返回含有全局认证凭据的JavaScriptProxy-修改方法二
 */

// [Start url_list_check]
// Index.ets
import { url } from '@kit.ArkTS';
import { webview } from '@kit.ArkWeb';
import { hilog } from '@kit.PerformanceAnalysisKit';

// Check Function
function checkUrl(surl: string): boolean {
  let tmpUrl = url.URL.parseURL(surl);
  hilog.info(0x0000, 'privacy', 'res.scheme:' + tmpUrl.protocol); // scheme
  hilog.info(0x0000, 'privacy', 'res.host:' + tmpUrl.host); // host
  hilog.info(0x0000, 'privacy', 'res.port:' + tmpUrl.port); // port
  hilog.info(0x0000, 'privacy', 'res.path:' + tmpUrl.pathname); // path
  hilog.info(0x0000, 'privacy', 'res.ssp:' + tmpUrl.hostname); // ssp
  // After obtaining the values of the scheme, host, port, and path parameters, perform security verification based on the service requirements
  // The part is omitted here. The verification is performed based on the service requirements
  if ('校验成功') {
    return true;
  }
  return false;
}

@Entry
@Component
struct Index {
  controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Row() {
        Button('registerJavaScriptProxy').onClick(() => {
          this.controller.registerJavaScriptProxy(
            {
              getServiceToken: () => {
                return 'DLFJSLDFJALGJLDFJSDDFISLDF323LSDJFLS212DLSFJOEV';
              }
            },
            'objName',
            ['getServiceToken']
          );
          this.controller.refresh();
        })
      }

      Web({ src: $rawfile('H5CallETS.html'), controller: this.controller })
        .javaScriptAccess(true)
        .javaScriptProxy({
          object: {
            getServiceToken: () => {
              return 'DLFJSLDFJALGJLDFJSDDFISLDF323LSDJFLS212DLSFJOEV';
            }
          },
          name: 'objName',
          methodList: ['getServiceToken'],
          controller: this.controller
        })
        .onLoadIntercept((event) => {
          hilog.info(0x0000, 'privacy', 'wzz:onLoadIntercept:' + event.data.toString());
          let tempUrl = event.data.toString();
          return checkUrl(tempUrl); // Returns true to block the load, otherwise allow the load
        })
    }
  }
}
// [End url_list_check]