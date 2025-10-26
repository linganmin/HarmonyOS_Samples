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
* FAQ:connection如何监听网络事件
*/

// [Start OnConnection]
import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct ListenNetworkEvent {
  listenNetworkEvent() {
    // Create NetConnection object
    let netConnection: connection.NetConnection = connection.createNetConnection();

    // Register subscription events using the register interface first
    netConnection.register((error: BusinessError) => {
      console.info(JSON.stringify(error));
    });

    // Subscribe to network available events. You can only receive this event notification after calling register
    netConnection.on('netAvailable', (data: connection.NetHandle) => {
      console.info('Succeeded to get data: ' + JSON.stringify(data));
    });
  }

  build() {
    Column({ space: 10 }) {
      Button('监听网络事件').onClick(() => {
        this.listenNetworkEvent()
      })
    }
    .alignItems(HorizontalAlign.Center)
    .height('100%')
    .width('100%')
  }
}
// [End OnConnection]

