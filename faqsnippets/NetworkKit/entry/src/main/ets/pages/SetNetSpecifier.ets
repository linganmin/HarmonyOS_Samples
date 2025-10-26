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
* FAQ:如何解决网络连接状态变化的公共事件返回内容为"NetType":1的问题
*/

// [Start SetNetSpecifier]
import { connection } from '@kit.NetworkKit';
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';

function  listen_network() {
  let netSpecifier: connection.NetSpecifier = {
    netCapabilities: {
      //Assuming the current default network is WiFi, a cellular network connection needs to be created, and the network type can be specified as cellular network
      bearerTypes: [connection.NetBearType.BEARER_CELLULAR, connection.NetBearType.BEARER_WIFI],
    },
  };
  let conn = connection.createNetConnection(netSpecifier);

  conn.register((err: BusinessError, data: void) => {
    console.warn('register Network ' + JSON.stringify(err))
  });

  // Subscription event, network available
  conn.on('netAvailable', ((data: connection.NetHandle) => {
    console.warn('Network available, netId is ' + data.netId);
  }));

  // Subscription event, network available
  conn.on('netCapabilitiesChange', ((data: connection.NetCapabilityInfo) => {
    console.warn('Network netCapabilitiesChange bearerTypes ' + data.netCap.bearerTypes);
    console.warn('Network netCapabilitiesChange networkCap ' + data.netCap.networkCap);
  }));

  // Subscription event, network unavailable
  conn.on('netUnavailable', ((data: void) => {
    console.warn('The network is unavailable, data is ' + JSON.stringify(data));
  }));

  // Subscription event, network disconnection
  conn.on('netLost', ((data: connection.NetHandle) => {
    console.warn('Network lost, netId is ' + data.netId);
  }));
}

// After monitoring an event, it is necessary to obtain the network status through a network interface
function sub_network() {
  console.warn('into sub_network')
  // Public event monitoring code:
  let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    // Subscription message exception public event
    events: ['usual.event.CONNECTIVITY_CHANGE']
  }

  // Create subscriber callback
  commonEventManager.createSubscriber(subscribeInfo, (err: BusinessError, subscriber: commonEventManager.CommonEventSubscriber) => {
    if (err) {
      console.warn(`Failed to create netWorkSubscribeInfo. Code is ${err.code}, message is ${err.message}`);
      return;
    }
    if (subscribeInfo && subscribeInfo != null) {
      // Subscribe to public event callbacks
      commonEventManager.subscribe(subscriber, (err: BusinessError, data: commonEventManager.CommonEventData) => {
        if (err) {
          console.warn(`Failed to netWorkSubscribe common event. Code is ${err.code}, message is ${err.message}`);
          return;
        }
        console.warn('NET_CONNECTIVITY_CHANGE：' + JSON.stringify(data.parameters));

        setTimeout(async () => {
          connection.getDefaultNet((error, data) => {
            console.log(JSON.stringify(error))
            console.log(JSON.stringify(data))
          }) }, 500);
        // The log printed here is{'NetType':1,'moduleName':''}
      })
    }
  })
}

@Entry
@Component
struct NetWork {
  build() {
    Row() {
      Column() {
        Button('Monitor the network').onClick(() => {
          listen_network()
        })
        Button('Obtain the network status').onClick(() => {
          sub_network()
        })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End SetNetSpecifier]

