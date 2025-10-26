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
* FAQ:rcp模块发起请求时如何设置超时时间
 */

// [Start RcpConfig]
import { rcp } from '@kit.RemoteCommunicationKit';

const sessionConfig: rcp.SessionConfiguration = {
  // Used to specify the configuration of HTTP requests associated with the session
  requestConfiguration: {
    transfer: {
      // Timeout parameter setting
      timeout: {
        // The connection has timed out. The default value is 60,000
        connectMs: 5000,
        // Transmission timeout, with the default value being 60,000
        transferMs: 10000,
      },
    }
  }
};
const session = rcp.createSession(sessionConfig);

@Entry
@Component
export struct SetTimeout {
  build() {
    Row() {
      Column() {
        Button($r('app.string.timeout_parameter_setting'))
          .onClick(() => {
            if (session) {
              console.log('Created session successful!')
              console.log('Connection timeout parameter settings:',
                sessionConfig.requestConfiguration?.transfer?.timeout?.connectMs);
              console.log('Transmission timeout parameters settings:',
                sessionConfig.requestConfiguration?.transfer?.timeout?.transferMs);
            } else {
              console.log('Created session failure!');
            }
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}


// [End RcpConfig]