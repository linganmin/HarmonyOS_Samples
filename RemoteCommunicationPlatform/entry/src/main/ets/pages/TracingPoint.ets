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
import Logger from '../common/Logger';
import { CommonConstants } from '../common/CommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function TracingPointBuilder() {
  TracingPoint()
}

@Component
export struct TracingPoint {
  @State detailInfo: string = '';
  @StorageLink('TracingPoint') storageLinkTracingPoint: string = '';

  setTracingPoint() {
    // [Start custom_http_events_handler]
    // Define a custom response handler
    const customHttpEventsHandler: rcp.HttpEventsHandler = {
      onDataReceive: (incomingData: ArrayBuffer) => {
        // Custom logic for handling incoming data
        Logger.info('Received data:', JSON.stringify(incomingData));
        return incomingData.byteLength;
      },
      onHeaderReceive: (headers: rcp.RequestHeaders) => {
        // Custom logic for handling response headers
        Logger.info('Received headers:', JSON.stringify(headers));
      },
      onDataEnd: () => {
        // Custom logic for handling data transfer completion
        Logger.info('Data transfer complete');
      }
    };

    // Configure tracing settings
    const tracingConfig: rcp.TracingConfiguration = {
      verbose: true,
      infoToCollect: {
        incomingHeader: true, // Event of collecting the input header information
        outgoingHeader: true, // Collect Outgoing Header Information Event
        incomingData: true, // Collect Incoming Data Information Event
        outgoingData: true // Collect Outgoing Data Information Event
      },
      collectTimeInfo: true,
      httpEventsHandler: customHttpEventsHandler
    };
    const securityConfig: rcp.SecurityConfiguration = {
      tlsOptions: {
        tlsVersion: 'TlsV1.3'
      }
    };
    // Use the configuration in the session creation
    try {
      const session = rcp.createSession({ requestConfiguration: { tracing: tracingConfig, security: securityConfig } });
      session.get('http://developer.huawei.com').then((response) => {
        Logger.info(`Request succeeded, message is ${JSON.stringify(response)}`);
      }).catch((err: BusinessError) => {
        Logger.error(`err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
      });
      // [End custom_http_events_handler]
      this.detailInfo = JSON.stringify(tracingConfig, null, 2);
      AppStorage.setOrCreate('TracingPoint', this.detailInfo);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TracingPoint', `createSession failed. code=${err.code}, message=${err.message}`);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Text($r('app.string.information'))
            .margin({ bottom: $r('app.float.text_margin_bottom') })
            .textAlign(TextAlign.Start)
            .width(CommonConstants.FULL_PERCENT)
          TextArea({ text: this.storageLinkTracingPoint })
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.TEXTAREA_HEIGHT)
            .focusable(false)
        }

        Column() {
          Button($r('app.string.configuration_information'))
            .onClick(() => {
              if (!this.storageLinkTracingPoint) {
                this.setTracingPoint();
              }
            })
            .width(CommonConstants.FULL_PERCENT)
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding($r('app.float.padding'))
    }
  }
}