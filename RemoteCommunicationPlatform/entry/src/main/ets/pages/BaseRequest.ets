/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { BusinessError } from '@kit.BasicServicesKit';
import { rcp } from '@kit.RemoteCommunicationKit';
import { url } from '@kit.ArkTS';
import Logger from '../common/Logger';
import { CommonConstants } from '../common/CommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

interface UserInfo {
  userName: string;
}

@Builder
export function BaseRequestBuilder() {
  BaseRequest()
}

@Component
export struct BaseRequest {
  @State patchHeaders: string = '';
  @State baseAddress: url.URL | string | undefined = '';
  @StorageLink('PatchHeaders') storageLinkPatchHeaders: string = '';
  @StorageLink('BaseAddress') storageLinkBaseAddress: string = '';

  patchRequest() {
    // [Start session_fetch]
    // Define the headers
    let headers: rcp.RequestHeaders = {
      'accept': 'application/json'
    };
    // Define the content to be modified
    let modifiedContent: UserInfo = {
      'userName': 'xxxxxx'
    };
    const securityConfig: rcp.SecurityConfiguration = {
      tlsOptions: {
        tlsVersion: 'TlsV1.3'
      }
    };
    // Create the communication session object session
    try {
      const session = rcp.createSession({ requestConfiguration: { security: securityConfig } });
      // Define the request object rep
      let req = new rcp.Request('http://example.com/fetch', 'PATCH', headers, modifiedContent);
      // Initiate a request
      session.fetch(req).then((response) => {
        Logger.info(`Request succeeded, message is ${JSON.stringify(response)}`);
      }).catch((err: BusinessError) => {
        Logger.error(`err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
      });
      // [End session_fetch]
      this.patchHeaders = JSON.stringify(req, null, 2);
      AppStorage.setOrCreate('PatchHeaders', this.patchHeaders);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'BaseRequest', `createSession failed. code=${err.code}, message=${err.message}`);
    }
  }

  setBaseAddress() {
    // [Start session_config]
    // Define the sessionConfig object
    const sessionConfig: rcp.SessionConfiguration = {
      baseAddress: 'http://api.example.com',
      headers: {
        'authorization': 'Bearer YOUR_ACCESS_TOKEN',
        'content-type': 'application/json'
      },
      requestConfiguration:{
        security:{
          tlsOptions: {
            tlsVersion: 'TlsV1.3'
          }
        }
      }
    };
    // Create the communication session object session and input sessionConfig
    try {
      const session = rcp.createSession(sessionConfig);
      let req = new rcp.Request('http://example.com', 'GET');
      session.fetch(req).then((response) => {
        Logger.info(`Request succeeded, message is ${JSON.stringify(response)}`);
      }).catch((err: BusinessError) => {
        Logger.error(`err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
      });
      this.baseAddress = sessionConfig.baseAddress;
      AppStorage.setOrCreate('BaseAddress', this.baseAddress);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'BaseRequest', `createSession failed. code=${err.code}, message=${err.message}`);
    }
    // [End session_config]
  }

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.patch_request_param'))
          .margin({ bottom: $r('app.float.text_margin_bottom') })
          .textAlign(TextAlign.Start)
          .width(CommonConstants.FULL_PERCENT)
        TextArea({ text: this.storageLinkPatchHeaders })
          .margin({ bottom: $r('app.float.textArea_margin_bottom') })
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.TEXTAREA_HEIGHT)
          .focusable(false)
        Button($r('app.string.patch_request'))
          .onClick(() => {
            if (!this.storageLinkPatchHeaders) {
              this.patchRequest();
            }
          })
          .margin({ bottom: $r('app.float.button_margin_bottom') })
          .width(CommonConstants.FULL_PERCENT)
        Text($r('app.string.set_baseAddress_success'))
          .margin({ bottom: $r('app.float.text_margin_bottom') })
          .textAlign(TextAlign.Start)
          .width(CommonConstants.FULL_PERCENT)
        TextArea({ text: this.storageLinkBaseAddress })
          .margin({ bottom: $r('app.float.textArea_margin_bottom') })
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.TEXTAREA_HEIGHT)
          .focusable(false)
        Button($r('app.string.set_baseAddress'))
          .onClick(() => {
            if (!this.storageLinkBaseAddress) {
              this.setBaseAddress();
            }
          })
          .width(CommonConstants.FULL_PERCENT)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.End)
      .padding($r('app.float.padding'))
    }
  }
}