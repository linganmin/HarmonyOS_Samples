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
export struct LocalResource {
  @StorageProp('currentBreakpoint') curBp: string = Constants.BREAKPOINTS[1];
  controller: WebviewController = new webview.WebviewController();
  uiContext: UIContext = this.getUIContext();

  build() {
    Column() {
      Header({ headerTitle: $r('app.string.scene_name1') })
      Row() {
        // [Start local_resource]
        Web({ src: 'resource://resfile/LocalResource/dist/index.html', controller: this.controller })
          .onControllerAttached(() => {
            try {
              // Set the list of paths that allow cross-origin access
              this.controller.setPathAllowingUniversalAccess([
                this.uiContext.getHostContext()!.resourceDir + '/LocalResource',
              ])
            } catch (error) {
              Logger.error(`ErrorCode: ${(error as BusinessError).code}, Message: ${(error as BusinessError).message}`);
            }
          })
          // [End local_resource]
          .onErrorReceive((event) => {
            PageLoadError.handleErrorReceive(event, this.controller)
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