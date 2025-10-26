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

import { buffer } from '@kit.ArkTS';
import { PromptAction } from '@kit.ArkUI';
import { WebNetErrorList, webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import Constants from '../common/Constants';
import Logger from '../common/Logger';
import { PageLoadError } from '../common/PageLoadError';
import Header from '../component/Header';

// Obtaining the File Type
function getContentType(ext: string) {
  if (ext.includes('.html')) {
    return 'text/html';
  } else if (ext.includes('.js')) {
    return 'text/javascript';
  } else if (ext.includes('.css')) {
    return 'text/css';
  } else if (ext.includes('.json')) {
    return 'application/json';
  } else if (ext.includes('.png')) {
    return 'image/png';
  } else if (ext.includes('.jpeg')) {
    return 'image/jpeg';
  } else if (ext.includes('.svg')) {
    return 'image/svg+xml';
  } else {
    return 'application/octet-stream';
  }
}

@Component
export struct CustomProtocol {
  @StorageProp('currentBreakpoint') curBp: string = Constants.BREAKPOINTS[1];
  controller: WebviewController = new webview.WebviewController();
  schemeHandler: webview.WebSchemeHandler = new webview.WebSchemeHandler();
  uiContext: UIContext = this.getUIContext();
  promptAction: PromptAction = this.uiContext.getPromptAction();
  @State toastId: number = 0;

  build() {
    Column() {
      Header({ headerTitle: $r('app.string.scene_name4') })
      Row() {
        Web({ src: 'app://index.html', controller: this.controller })
          .onControllerAttached(() => {
            try {
              // [Start bind_interceptor]
              this.schemeHandler.onRequestStart((request: webview.WebSchemeHandlerRequest,
                resourceHandler: webview.WebResourceHandler) => {

                // [StartExclude bind_interceptor]
                // Determine whether it is a pop-up request
                // [Start open_dialog]
                if (request.getRequestUrl().includes('openDialog')) {
                  this.promptAction.showToast({
                    message: $r('app.string.CustomProtocol_toast'),
                    duration: 3000,
                  })
                  return true;
                }
                // [End open_dialog]
                // Read Local Files
                // [Start read_local_file]
                let pathArray = request.getRequestUrl().split('app://');
                let filePath = this.uiContext.getHostContext()!.resourceDir + '/CustomProtocol/dist/' +
                pathArray[pathArray.length-1];
                let file = fs.readTextSync(filePath);

                let response = new webview.WebSchemeHandlerResponse();
                response.setNetErrorCode(WebNetErrorList.NET_OK);
                response.setStatus(200);
                response.setStatusText('OK');
                response.setMimeType(getContentType(filePath));
                response.setEncoding('utf-8');

                // Convert to buffer type
                let buf = buffer.from(file)
                try {
                  if (buf.length === 0) {
                    resourceHandler.didFail(WebNetErrorList.ERR_FAILED);
                  } else {
                    resourceHandler.didReceiveResponse(response);
                    resourceHandler.didReceiveResponseBody(buf.buffer);
                    resourceHandler.didFinish();
                  }
                } catch (error) {
                  Logger.error(`[schemeHandler] ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
                }
                // [End read_local_file]
                // [EndExclude bind_interceptor]
                return true;
              })

              // Bind an interceptor to the app protocol
              this.controller.setWebSchemeHandler('app', this.schemeHandler);
              // [End bind_interceptor]
            } catch (error) {
              Logger.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
            }
          })
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