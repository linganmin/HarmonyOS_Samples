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

import { rcp } from '@kit.RemoteCommunicationKit';
import { url } from '@kit.ArkTS';
import { fileIo as fs } from '@kit.CoreFileKit';
import { CommonConstants } from '../common/CommonConstants';
import { ResponseCachingInterceptor, ResponseHeaderRemoveInterceptor, ResponseCache } from '../utils/Interceptors';
import Logger from '../common/Logger';

@Builder
export function RequestAndResponseBuilder() {
  RequestAndResponse()
}

// [Start create_session]
const cache = new ResponseCache();
const sessionConfig: rcp.SessionConfiguration = {
  interceptors: [
    new ResponseCachingInterceptor(cache),
    new ResponseHeaderRemoveInterceptor()
  ],
  requestConfiguration: {
    security: {
      tlsOptions: {
        tlsVersion: 'TlsV1.3'
      }
    }
  }
};

const session = rcp.createSession(sessionConfig);
// [End create_session]

@Component
export struct RequestAndResponse {
  @State requestAndResponse: string = '';
  @State isImageDownloaded: boolean = false;
  @State requestUrl: url.URL | string = '';
  @State url: string = '';
  @StorageLink('ReplacedInfo') storageLink: string = '';
  private readonly pathToImage: string = this.getUIContext().getHostContext()!.filesDir + '/panda.jpg';
  private simulateSlowNetwork: boolean = false;

  private async getImage() {
    this.isImageDownloaded = false;
    const request = new rcp.Request(`http://www.example.com/Panda.jpg`, 'GET');
    this.requestUrl = request.url;

    request.destination = {
      kind: 'file',
      file: this.pathToImage
    };

    try {
      const response = await session.fetch(request);
      const isFileCreated = fs.accessSync(this.pathToImage);
      if (response.statusCode === 200 && isFileCreated) {
        this.isImageDownloaded = true;
      }
    } catch (err) {
      Logger.error(`err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
    }

    if (this.simulateSlowNetwork) {
      this.url = this.storageLink;
    } else {
      this.url = String(this.requestUrl);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            Text($r('app.string.enable_request_caching'))
            Toggle({ type: ToggleType.Switch, isOn: this.simulateSlowNetwork })
              .onChange((isOn) => {
                this.simulateSlowNetwork = isOn;
              })
          }
          .margin({ bottom: $r('app.float.simulate_margin_bottom') })
          .backgroundColor($r('app.color.start_window_background'))
          .borderRadius($r('app.float.simulate_borderRadius'))
          .padding({ left: $r('app.float.simulate_padding_left'), right: $r('app.float.simulate_padding_right') })
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.SIMULATE_TEXT_HEIGHT)
          .justifyContent(FlexAlign.SpaceBetween)

          Text($r('app.string.image_url'))
            .margin({ bottom: $r('app.float.simulate_margin_bottom') })
            .width(CommonConstants.FULL_PERCENT)
          TextArea({ text: this.url })
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.TEXTAREA_HEIGHT)
            .textAlign(TextAlign.Start)
            .focusable(false)
        }

        Button($r('app.string.get_image'))
          .width(CommonConstants.FULL_PERCENT)
          .onClick(() => {
            this.getImage();
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding($r('app.float.padding'))
    }
    .backgroundColor($r('app.color.gray_background'))
  }
}