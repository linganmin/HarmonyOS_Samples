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

import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import Constants from '../common/Constants';
import Logger from '../common/Logger';
import { PageLoadError } from '../common/PageLoadError';
import Header from '../component/Header';

@Component
export struct CookiesSettings {
  @StorageProp('currentBreakpoint') curBp: string = Constants.BREAKPOINTS[1];
  @State webError: boolean = false;
  controller: WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Header({ headerTitle: $r('app.string.scene_name3') })
      Row() {
        Web({ src: 'http://www.a.harmonyos:8080/CookiesSettingsA/dist/index.html', controller: this.controller })
          .onErrorReceive((event) => {
            PageLoadError.handleErrorReceive(event, this.controller);
          })
          .javaScriptAccess(true)
          .fileAccess(true)
          .domStorageAccess(true)
          .imageAccess(true)
          .backgroundColor($r('sys.color.background_secondary'))
      }
      .layoutWeight(1)

      Column() {
        Button($r('app.string.CookiesSettings_button'))
          .width(Constants.FULL_WIDTH)
          .height(48)
          .onClick(() => {
            try {
              // Obtain the cookie for domain A and set it for domain B.
              // [Start put_accept_cookie]
              webview.WebCookieManager.putAcceptCookieEnabled(true);
              webview.WebCookieManager.putAcceptThirdPartyCookieEnabled(true)
              let value = webview.WebCookieManager.fetchCookieSync('http://www.a.harmonyos');
              webview.WebCookieManager.configCookieSync('http://www.b.harmonyos',
                value + '; PATH=/; Max-Age=900000; HttpOnly; SameSite=Lax');
              // [End put_accept_cookie]
              this.controller.loadUrl('http://www.b.harmonyos:8080/CookiesSettingsB/dist/index.html');
            } catch (error) {
              Logger.error(`ErrorCode: ${(error as BusinessError).code}, Message: ${(error as BusinessError).message}`);
            }
          })
      }
      .visibility(this.webError ? Visibility.Hidden : Visibility.Visible)
      .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8'), bottom: $r('sys.float.padding_level12') })
    }
    .width(Constants.FULL_WIDTH)
    .justifyContent(FlexAlign.Center)
  }
}
