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
* FAQ:如何获取网络类型：Wi-Fi，3G，4G，5G等
 */

// [Start GetNetCapabilities]
import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { radio } from '@kit.TelephonyKit';

@Entry
@Component
struct Index {
  build() {
    Column() {
      Button('获取网络类型')
        .type(ButtonType.Normal)
        .width(200)
        .height(200)
        .onClick(() => {
          connection.getDefaultNet().then((netHandle: connection.NetHandle) => {
            if (netHandle.netId == 0) {
              // When there is currently no connected network, the obtained netHandler's netid is 0, which belongs to an abnormal scenario.
              // Here, some processing mechanisms can be added according to the actual situation.
              return;
            }
            // Obtain the capability information of the network corresponding to netHandle
            connection.getNetCapabilities(netHandle, (error: BusinessError, data: connection.NetCapabilities) => {
              if (error) {
                console.error(`Failed to get net capabilities. Code:${error.code}, message:${error.message}`);
                return;
              }
              console.info("Succeeded to get data: " + JSON.stringify(data));
              if (data.bearerTypes[0] == 1) {
                // console.info("Wi Fi network");
              } else if (data.bearerTypes[0] == 0) {
                // console.info("Cellular Network");
                let slotId: number = 0; // Slot ID, -0: Slot 1, -1: Slot 2
                radio.getSignalInformation(slotId, (err: BusinessError, data: Array<radio.SignalInformation>) => {
                  if (err) {
                    console.error(`getSignalInformation failed, callback: err->${JSON.stringify(err)}`);
                    return;
                  }
                  console.info(`getSignalInformation success, callback: data->${JSON.stringify(data)}`);
                  // Return an array of SignalInformation objects, where the returned signalType represents the network type NetworkType
                });
              }
            })
          }).catch((error: BusinessError) => {
            console.error('error: ' + JSON.stringify(error));
          });
        })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
// [End GetNetCapabilities]