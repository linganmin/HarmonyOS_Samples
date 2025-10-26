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
* FAQ:如何监听判断VPN类型网络
*/

// [Start OnNetVpn]
import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
export struct JudeNetType {
  getNetType() {
    connection.getAllNets((error: BusinessError, allNets: connection.NetHandle[]) => {
      if (error) {
        console.error(`Failed to get getAllNets. Code: ${error.code}, message: ${error.message}`);
        return;
      }
      for (let netHandle of allNets) {
        connection.getNetCapabilities(netHandle, (error: BusinessError, data: connection.NetCapabilities) => {
          if (error) {
            console.error(`Failed to get capabilities. Code: ${error.code}, message: ${error.message}`);
            return;
          }
          if (data.bearerTypes[0] == connection.NetBearType.BEARER_VPN) {
            console.info('The VPN network is connected');
          }
        })
      }
    });
  }

  build() {
    Column({ space: 10 }) {
      Button('Obtain the type of network connection').onClick(() => {
        this.getNetType()
      })
    }.alignItems(HorizontalAlign.Center)
    .height('100%')
    .width('100%')
  }
}

// [End OnNetVpn]

