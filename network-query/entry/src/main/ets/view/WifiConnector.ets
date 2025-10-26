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

import { BusinessError } from '@kit.BasicServicesKit';
import { connection } from '@kit.NetworkKit';
import { wifiManager } from '@kit.ConnectivityKit';
import { Logger } from '../common/Logger';
import { WlanItemView } from '../component/WlanItem';
import { showToast } from '../common/ToastUtil';

const TAG = 'WifiConnectorTag';
const TARGET_WIFI_SSID: string = 'MyWifi';

@Component
export struct WifiConnector {
  private uiContext: UIContext = this.getUIContext();
  @State currentSsid: string = '';
  @State scanInfoList: wifiManager.WifiScanInfo[] = [];
  private recvWifiConnectionChangeFunc = (result: number) => {
    Logger.info(TAG, `wifiConnectionChange wifi connection change result: ${result}`);
    if (result === 1) {
      // WiFi is connected
      showToast(this.uiContext, $r('app.string.wlan_is_connected'));
      this.getScanList();
    } else {
      // WiFi is disconnected
      showToast(this.uiContext, $r('app.string.wlan_is_disconnected'));
      this.currentSsid = '';
      this.scanInfoList = [];
    }
  }
  private recvWifiScanStateChangeFunc = (result: number) => {
    Logger.info(TAG, `Receive Wifi scan state change event: ${result}`);
    this.getScanList();
  }

  // [Start get_wifi_info_step]
  checkNetwork(): void {
    try {
      // Use the synchronization method to obtain the default activated data network handle (default network)
      let netHandle = connection.getDefaultNetSync();
      if (netHandle.netId === 0) {
        // If there is no network connected, the netid of the obtained netHandler is 0
        showToast(this.uiContext, $r('app.string.no_network_tips'));
        return;
      }
      // Obtain the capability information of the network corresponding to the netHandle
      let netCapability = connection.getNetCapabilitiesSync(netHandle);
      let networkCap = netCapability.networkCap || [];
      let bearerTypes: connection.NetBearType[] = netCapability.bearerTypes;
      let isWifi = bearerTypes.includes(connection.NetBearType.BEARER_WIFI);
      if (!isWifi) {
        showToast(this.uiContext, $r('app.string.network_is_not_wifi'));
        return;
      }
      // The network type is WIFI to get network connection information
      let linkedInfo = wifiManager.getLinkedInfoSync();
      let ssid: string = linkedInfo.ssid;
      // [Start judge_wifi_available]
      if (ssid === TARGET_WIFI_SSID) {
        // Connected to the target wifi
        // [StartExclude get_wifi_info_step]
        if (networkCap.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
          showToast(this.uiContext, $r('app.string.connected_to_spec_wifi'));
        } else if (networkCap.includes(connection.NetCap.NET_CAPABILITY_PORTAL)) {
          // Login verification is required for the current network
          showToast(this.uiContext, $r('app.string.network_need_auth'));
        } else {
          showToast(this.uiContext, $r('app.string.result_network_unavailable'));
        }
        // [EndExclude get_wifi_info_step]
      } else {
        showToast(this.uiContext, $r('app.string.not_connected_spec_wifi'));
      }
      // [End judge_wifi_available]
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `checkNetwork err, code: ${error.code}, message: ${error.message}`);
    }
  }
  // [End get_wifi_info_step]

  aboutToAppear(): void {
    try {
      // Register the Wi-Fi connection state change event
      wifiManager.on('wifiConnectionChange', this.recvWifiConnectionChangeFunc);
      // Get scan status 0: Scan failed; 1: The scan is successful.
      wifiManager.on('wifiScanStateChange', this.recvWifiScanStateChangeFunc);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `on wifi change err, errCode: ${error.code}, error mesage: ${error.message}`);
    }

  }

  aboutToDisappear(): void {
    try {
      // Unregister the WLAN connection status change event
      wifiManager.off('wifiConnectionChange', this.recvWifiConnectionChangeFunc);
      // Unregister and stop getting the scan status.
      wifiManager.off('wifiScanStateChange', this.recvWifiScanStateChangeFunc);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `off wifi change err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }

  getLinkedInfo(): void {
    try {
      let linkedInfo = wifiManager.getLinkedInfoSync();
      this.currentSsid = linkedInfo.ssid;
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `getLinkedInfo err, code: ${error.code}, message: ${error.message}`);
    }
  }

  // [Start get_wifi_list_step]
  getScanList(): void {
    try {
      let isWifiActive = wifiManager.isWifiActive();
      if (!isWifiActive) {
        showToast(this.uiContext, $r('app.string.turn_on_wlan_tips'));
        return;
      }
      this.getLinkedInfo();
      let temp = wifiManager.getScanInfoList();
      if (temp.length > 0) {
        // Remove duplicate WiFi data
        this.scanInfoList = this.uniqueBySsid(temp);
        Logger.info(TAG, `getScanList length: ${this.scanInfoList.length}`);
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `getScanList err, code: ${error.code}, message: ${error.message}`);
    }
  }
  // [End get_wifi_list_step]

  uniqueBySsid(arr: wifiManager.WifiScanInfo[]): wifiManager.WifiScanInfo[] {
    const set = new Set<string>();
    return arr.filter((item) => {
      const key = item.ssid;
      if (!set.has(key)) {
        set.add(key);
        return true;
      }
      return false;
    });
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Column() {
          List() {
            ForEach(this.scanInfoList, (item: wifiManager.WifiScanInfo) => {
              if (item.ssid && item.ssid !== '') {
                ListItem() {
                  Column() {
                    WlanItemView({
                      ssid: item.ssid,
                      currentLinkedSsid: this.currentSsid,
                      securityType: item.securityType
                    })
                  }
                }
              }
            }, (item: wifiManager.WifiScanInfo, index: number) => index + item.ssid)
          }
          .borderRadius(20)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .divider({
            strokeWidth: 1,
            color: '#0D000000',
            startMargin: 12,
            endMargin: 12
          })
        }
        .margin({ top: 12 })
        .layoutWeight(1)

        Button($r('app.string.btn_get_scan_wifi'))
          .width('100%')
          .onClick(() => {
            this.getScanList();
          })

        Button($r('app.string.btn_is_connected_target', TARGET_WIFI_SSID))
          .width('100%')
          .onClick(() => {
            this.checkNetwork();
          })
      }
      .height('100%')
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        bottom: 16
      })
    }
    .title($r('app.string.title_connect_specified_network'))
    .backgroundColor($r('sys.color.background_secondary'))
  }
}