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
import Logger from './Logger';

// [Start create_rcp_session]
export class HttpProxy {
  session?: rcp.Session;

  constructor(sessionConfiguration?: rcp.SessionConfiguration | undefined) {
    try {
      this.session = rcp.createSession(sessionConfiguration);
    } catch (error) {
      Logger.error(`ErrorCode: ${(error as BusinessError).code}, Message: ${(error as BusinessError).message}`);
    }
  }

  // [StartExclude create_rcp_session]
  // [Start handle_response]
  private handleResponse(res: rcp.Response, resourceHandler: webview.WebResourceHandler,
    options: HttpProxyOptions): void {
    let response = new webview.WebSchemeHandlerResponse();
    response.setStatus(200)
    response.setStatusText('OK')
    response.setMimeType(options.mimeType || 'application/json')
    response.setEncoding('utf-8')
    response.setNetErrorCode(WebNetErrorList.NET_OK)
    response.setHeaderByName('Access-Control-Allow-Origin', options.requestOrigin, true);
    response.setHeaderByName('Access-Control-Allow-Credentials', 'true', true);
    response.setHeaderByName('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE', true);
    response.setHeaderByName('Access-Control-Allow-Headers', 'Content-Type, Authorization', true);
    try {
      resourceHandler.didReceiveResponse(response);
      resourceHandler.didReceiveResponseBody(res.body);
      resourceHandler.didFinish();
    } catch (error) {
      Logger.error(`ErrorCode: ${(error as BusinessError).code}, Message: ${(error as BusinessError).message}`);
    }
  }
  // [End handle_response]

  // [EndExclude create_rcp_session]
  public get(request: string, resourceHandler: webview.WebResourceHandler, options: HttpProxyOptions): void {
    try {
      this.session?.get(request).then((res) => {
        this.handleResponse(res, resourceHandler, options)
      }).catch((error: BusinessError) => {
        Logger.error(`ErrorCode: ${error.code}, Message: ${error.message}`);
      })
    } catch (error) {
      Logger.error(`ErrorCode: ${(error as BusinessError).code}, Message: ${(error as BusinessError).message}`);
    }
  }

  // [StartExclude create_rcp_session]
  public post(request: string, resourceHandler: webview.WebResourceHandler, options: HttpProxyOptions): void {
    try {
      this.session?.post(request).then((res) => {
        this.handleResponse(res, resourceHandler, options)
      }).catch((error: BusinessError) => {
        Logger.error(`ErrorCode: ${error.code}, Message: ${error.message}`);
      })
    } catch (error) {
      Logger.error(`ErrorCode: ${(error as BusinessError).code}, Message: ${(error as BusinessError).message}`);
    }
  }
  // [EndExclude create_rcp_session]
}
// [End create_rcp_session]

@Observed
export
class HttpProxyOptions {
  public mimeType?: string;
  public requestOrigin?: string;
}
