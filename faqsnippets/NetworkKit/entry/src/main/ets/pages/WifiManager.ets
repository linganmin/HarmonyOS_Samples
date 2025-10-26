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
* FAQ:多种网络同时连接时如何优先使用wifi网络
*/

// [Start getNetwork]
// WifiManager.ets
import { BusinessError } from '@kit.BasicServicesKit';
import { connection } from '@kit.NetworkKit';

export class WifiManager {
  private static instance?: WifiManager;

  /**
   * Get singleton
   *
   * @returns Singleton object
   */
  public static getInstance(): WifiManager {
    if (!WifiManager.instance) {
      WifiManager.instance = new WifiManager();
    }
    return WifiManager.instance;
  }

  /**
   * Start listening for network changes (Wi-Fi network / Bluetooth network / cellular data)
   */
  public startListenNetChange(): void {
    console.info("registerNetListener");
    let netConnectionWifi = connection.createNetConnection({
      netCapabilities: {
        bearerTypes: [connection.NetBearType.BEARER_WIFI]
      }
    });
    netConnectionWifi.register((error: BusinessError) => {
      if (error) {
        console.error(`register error: ${error.code}`);
      }
    });
    netConnectionWifi.on('netAvailable', () => {
      console.info("netConnectionWifi netAvailable");
      this.bindWifiWhenConnected();
    });
    netConnectionWifi.on('netLost', () => {
      console.info("Wifi netLost");
      this.bindWifiWhenConnected();
    });
    let netConnectionBluetooth = connection.createNetConnection({
      netCapabilities: {
        bearerTypes: [connection.NetBearType.BEARER_BLUETOOTH]
      }
    });
    netConnectionBluetooth.register((error: BusinessError) => {
      if (error) {
        console.error(`register error: ${error.code}`);
      }
    });
    netConnectionBluetooth.on('netAvailable', () => {
      console.info('netConnectionBluetooth netAvailable');
      this.bindWifiWhenConnected();
    });
    netConnectionBluetooth.on('netLost', () => {
      console.info('Bluetooth netLost');
      this.bindWifiWhenConnected();
    });
    let netConnectionCellular = connection.createNetConnection({
      netCapabilities: {
        bearerTypes: [connection.NetBearType.BEARER_CELLULAR]
      }
    });
    netConnectionCellular.register((error: BusinessError) => {
      if (error) {
        console.error(`register error: ${error.message}`);
      }
    });
    netConnectionCellular.on('netAvailable', () => {
      console.info('netConnectionCellular netAvailable');
      this.bindWifiWhenConnected();
    });
    netConnectionCellular.on('netLost', () => {
      console.info('Cellular netLost');
      this.bindWifiWhenConnected();
    });
  }

  /**
   * Connect the App to the Wi-Fi network asynchronously
   */
  private async bindWifiWhenConnected(): Promise<void> {
    await connection.setAppNet(connection.getDefaultNetSync()).then(() => {
      console.info('setAppNet default success')
    });
    connection.getAllNets().then((data: connection.NetHandle[]) => {
      data.forEach(net => {
        connection.getNetCapabilities(net).then((data: connection.NetCapabilities) => {
          if (data.bearerTypes.length > 0 && data.bearerTypes[0] === connection.NetBearType.BEARER_WIFI) {
            connection.setAppNet(net).then(() => {
              console.info('setAppNet wifi success');
              return;
            }).catch((error: Error) => {
              console.error(`setAppNet wifi failed, error = ${error.message}`);
            })
          }
        }).catch((error: Error) => {
          console.error(`getNetCapabilities error = ${error.message}`);
        });
      })
    }).catch((error: Error) => {
      console.error(`getAllNets error = ${error.message}`);
    });
  }
}
// [End getNetwork]