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

import { WebNetErrorList, webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { rcp } from '@kit.RemoteCommunicationKit';
import Constants from '../common/Constants';
import { HttpProxy } from '../common/HttpProxy';
import Logger from '../common/Logger';
import { PageLoadError } from '../common/PageLoadError';
import Header from '../component/Header';

@Component
export struct RemoteRequest {
  @StorageProp('currentBreakpoint') curBp: string = Constants.BREAKPOINTS[1];
  controller: WebviewController = new webview.WebviewController();schemeHandler: webview.WebSchemeHandler = new webview.WebSchemeHandler();
  uiContext: UIContext = this.getUIContext();
  staticDnsRules: rcp.StaticDnsRules = [
    { host: 'www.c.harmonyos', port: 8080, ipAddresses: ['127.0.0.1'] },
  ];
  // Create a proxy request class
  httpProxy: HttpProxy = new HttpProxy({
    requestConfiguration: {
      dns: {
        dnsRules: this.staticDnsRules,
      }
    }
  });

  build() {
    Column() {
      Header({ headerTitle: $r('app.string.scene_name2') })
      Row() {
        // [Start remote_request]
        Web({ src: 'http://www.a.harmonyos:8080/RemoteRequest/dist/index.html', controller: this.controller })
          .onControllerAttached(() => {
            try {
              // Using interceptor to intercept requests
              this.schemeHandler.onRequestStart((request: webview.WebSchemeHandlerRequest, resourceHandler: webview.WebResourceHandler) => {
                Logger.info('[schemeHandler] onRequestStart');
                if (request.getRequestUrl().includes('www.c.harmonyos')) {
                  // Through proxy request server
                  this.httpProxy.get(request.getRequestUrl(), resourceHandler, {
                    mimeType: 'application/json',
                    requestOrigin: 'http://www.a.harmonyos:8080'
                  })
                  return true;
                } else {
                  return false;
                }
              })

              // Bind an interceptor to the HTTP protocol.
              this.controller.setWebSchemeHandler('http', this.schemeHandler);
            } catch (error) {
              Logger.error(`ErrorCode: ${(error as BusinessError).code}, Message: ${(error as BusinessError).message}`);
            }
          })
            // [End remote_request]
          .onErrorReceive((event) => {
            PageLoadError.handleErrorReceive(event, this.controller);
          })
          .javaScriptAccess(true)
          .fileAccess(true)
          .domStorageAccess(true)
          .imageAccess(true)
          .backgroundColor($r('sys.color.background_secondary'))
      }
    }
    .width(Constants.FULL_WIDTH)
    .justifyContent(FlexAlign.Center)
  }
}