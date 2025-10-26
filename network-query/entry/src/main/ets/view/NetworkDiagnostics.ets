/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { connection } from '@kit.NetworkKit';
import { netQuality } from '@kit.NetworkBoostKit';
import { radio } from '@kit.TelephonyKit';
import { wifiManager } from '@kit.ConnectivityKit';
import { Logger } from '../common/Logger';
import { NetInfoItem } from '../component/NetInfoItem';
import { NetworkUtil } from '../common/NetworkUtil';

const TAG = 'NetworkDiagnosticsTag';

// test download url
const TEST_DOWNLOAD_URL = '';

@Component
export struct NetworkDiagnostics {
  @State networkType: string = '';
  @State proxyInfo: string = '';
  @State routeInfo: string = '';
  @State ipAddress: string = '';
  @State gateway: string = '';
  @State dnsServers: string = '';
  @State wifiSignal: string = '';
  @State wifiMac: string = '';
  @State operatorName: string = '';
  @State cellularType: string = '';
  @State isRoaming: string = '';
  @State cellularSignal: string = '';
  @State isRadioOn: boolean = false;
  @State currentNetType: string = '';
  @State checkResult: ResourceStr = '';
  private isNetAvailable: boolean = false;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private cachePath = this.context.cacheDir + '/temp_download.tmp';
  private timeoutId: number = -1;
  private totalSpeed: number = 0;
  private totalRttMs: number = 0;
  private totalWifiRssi: number = 0;
  private totalCellularRssi: number = 0;
  private rttMsTimes: number = 0;
  private hasNetwork: boolean = true;

  aboutToAppear(): void {
    this.onQosChange();
    this.queryNetworkInfo();
  }

  // [Start query_network_info_step]
  queryNetworkInfo() {
    this.checkNetAvailable();
    if (!this.hasNetwork) {
      this.clearContent();
      return;
    }
    this.getConnectionInfo();
    this.getWifiInfo();
    this.getCellularInfo();

    if (this.timeoutId === -1 && TEST_DOWNLOAD_URL !== '') {
      this.checkResult = $r('app.string.result_is_checking');
      // Start download file
      NetworkUtil.downloadFile(this.context, TEST_DOWNLOAD_URL, this.cachePath);
      this.timeoutId = setTimeout(() => {
        // Remove download task after 10 seconds
        NetworkUtil.removeTask();
        this.timeoutId = -1;
      }, 10000)
    }
  }
  // [End query_network_info_step]

  // [Start get_network_type_available_step]
  checkNetAvailable(): void {
    try {
      let netHandle = connection.getDefaultNetSync();
      if (netHandle.netId === 0) {
        // If there is no network connected, the netid of the obtained netHandler is 0
        this.hasNetwork = false;
        this.checkResult = $r('app.string.result_network_not_connect');
        return;
      }
      this.hasNetwork = true;
      let netCapability = connection.getNetCapabilitiesSync(netHandle);
      let bearerTypes: connection.NetBearType[] = netCapability.bearerTypes;
      let netCaps: connection.NetCap[] = netCapability.networkCap || [];
      this.networkType = NetworkUtil.getNetworkTypeStr(bearerTypes[0]);
      this.isNetAvailable = netCaps.includes(connection.NetCap.NET_CAPABILITY_VALIDATED);
      if (this.isNetAvailable) {
        this.checkResult = $r('app.string.result_network_available');
      } else {
        this.checkResult = $r('app.string.result_network_unavailable');
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `getNetworkType err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }

  // [End get_network_type_available_step]

  clearContent() {
    this.networkType = '';
    this.proxyInfo = '';
    this.routeInfo = '';
    this.ipAddress = '';
    this.gateway = '';
    this.dnsServers = '';
    this.wifiSignal = '';
    this.wifiMac = '';
    this.operatorName = '';
    this.cellularType = '';
    this.isRoaming = '';
    this.cellularSignal = '';
    this.isRadioOn = false;
    this.currentNetType = '';
    this.checkResult = $r('app.string.result_network_not_connect');
  }

  // [Start on_qos_change_step]
  onQosChange(): void {
    try {
      netQuality.on('netQosChange', (list: netQuality.NetworkQos[]) => {
        if (list.length > 0) {
          list.forEach(async (qos) => {
            // [StartExclude on_qos_change_step]
            Logger.info(TAG, `linkDownBandwidth： ${qos.linkDownBandwidth / 8 / 1024 / 1024}MB/s`);
            Logger.info(TAG, `rttMs： ${qos.rttMs}`);
            Logger.info(TAG, `linkDownRate： ${qos.linkDownRate / 8 / 1024 / 1024}MB/s`);
            // [EndExclude on_qos_change_step]
            if (this.timeoutId !== -1 && TEST_DOWNLOAD_URL !== '') {
              let wifiRssi = NetworkUtil.getWifiSignalRssi();
              let cellularRssi = await NetworkUtil.getCellularSignalRssi();
              this.totalSpeed += qos.linkDownRate;
              this.totalRttMs += qos.rttMs;
              this.totalWifiRssi += wifiRssi;
              this.totalCellularRssi += cellularRssi;
              this.rttMsTimes += 1;
            }
            if ((this.timeoutId === -1) && (this.rttMsTimes !== 0) && (TEST_DOWNLOAD_URL !== '')) {
              // Average download speed
              let avgSpeed = this.totalSpeed / 8 / 1024 / 1024 / 10;
              // Average latency
              let avgRttMs = this.totalRttMs / this.rttMsTimes;
              // Average wifi signal strength
              let avgWifiRssi = this.totalWifiRssi / this.rttMsTimes;
              // Average cellular signal strength
              let avgCellularRssi = this.totalCellularRssi / this.rttMsTimes;
              // [StartExclude on_qos_change_step]
              Logger.info(TAG, `avg speed： ${avgSpeed}`);
              Logger.info(TAG, `avg rttms： ${avgRttMs}`);
              Logger.info(TAG, `avg wifi rssi： ${avgWifiRssi}`);
              Logger.info(TAG, `avg cellular rssi： ${avgCellularRssi}`);
              this.rttMsTimes = 0
              this.totalSpeed = 0;
              this.totalRttMs = 0;
              this.totalWifiRssi = 0;
              this.totalCellularRssi = 0;
              // [EndExclude on_qos_change_step]
              if (avgSpeed < 1 || avgRttMs > 100) {
                this.checkResult = $r('app.string.network_bad_tips');
                return;
              }
              // The network is considered poor when the WiFi signal strength is below -70dBm
              // or the cellular network signal strength is below -100dBm
              if ((this.networkType === 'wifi' && avgWifiRssi < -70) ||
                (this.networkType === 'cellular' && avgCellularRssi < -100)) {
                this.checkResult = $r('app.string.network_bad_tips');
              } else {
                this.checkResult = $r('app.string.result_network_normal');
              }
            }
          });
        }
      });
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `on netQosChange err, code: ${error.code}, message: ${error.message}`);
    }
  }

  // [End on_qos_change_step]

  // [Start get_connection_info_step]
  getConnectionInfo(): void {
    try {
      let netHandle = connection.getDefaultNetSync();
      let properties = connection.getConnectionPropertiesSync(netHandle);
      // route info
      let routes = properties.routes || [];
      // ip address info
      let addresses = properties.linkAddresses || [];
      // dns service info
      let dnses = properties.dnses || [];
      // [StartExclude get_connection_info_step]
      this.routeInfo = JSON.stringify(routes);
      this.ipAddress = JSON.stringify(addresses);
      this.dnsServers = JSON.stringify(dnses);
      // [EndExclude get_connection_info_step]
      // get proxy info
      connection.getDefaultHttpProxy().then((data: connection.HttpProxy) => {
        Logger.info(TAG, `getDefaultHttpProxy success, data: ${JSON.stringify(data)}`);
        this.proxyInfo = JSON.stringify(data);
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `getDefaultHttpProxy err, code: ${error.code}, mesage: ${error.message}`);
      });
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `getConnectionInfo err, code: ${error.code}, message: ${error.message}`);
    }
  }

  // [End get_connection_info_step]

  // [Start get_wifi_info_step]
  getWifiInfo(): void {
    try {
      let linkInfo = wifiManager.getLinkedInfoSync();
      this.wifiSignal = `${linkInfo.rssi}dBm`;
      this.wifiMac = linkInfo.macAddress;
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `getWifiRssi err, code: ${error.code}, message: ${error.message}`);
    }
  }

  // [End get_wifi_info_step]

  // [Start get_cellular_info]
  async getCellularInfo(): Promise<void> {
    try {
      let primarySlotId = await radio.getPrimarySlotId();
      // Get the carrier name
      this.operatorName = radio.getOperatorNameSync(primarySlotId);
      // Whether the radio on the cellular main card is turned on
      this.isRadioOn = await radio.isRadioOn(primarySlotId);
      let networkState = await radio.getNetworkState(primarySlotId);
      // Determine whether the cellular network is roaming
      this.isRoaming = networkState.isRoaming + '';
      let signalInfos: radio.SignalInformation[] = radio.getSignalInformationSync(primarySlotId);
      if (signalInfos.length > 0) {
        let signalInfo = signalInfos[0];
        // Get cellular network signal strength
        this.cellularSignal = signalInfo.dBm + 'dBm';
        // Get the cellular network standard
        this.cellularType = NetworkUtil.getCellularTypeStr(signalInfo.signalType);
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `getCellularInfo err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }

  // [End get_cellular_info]

  aboutToDisappear(): void {
    try {
      netQuality.off('netQosChange');
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `on netQosChange err, code: ${error.code}, message: ${error.message}`);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 12 }) {
            NetInfoItem({ title: $r('app.string.title_check_result'), content: this.checkResult });
            NetInfoItem({ title: $r('app.string.title_network_type'), content: this.networkType });
            NetInfoItem({ title: $r('app.string.title_proxy_info'), content: this.proxyInfo });
            NetInfoItem({ title: $r('app.string.title_router_info'), content: this.routeInfo });
            NetInfoItem({ title: $r('app.string.title_ip_address_info'), content: this.ipAddress });
            NetInfoItem({ title: $r('app.string.title_dns_server'), content: this.dnsServers });
            NetInfoItem({ title: $r('app.string.title_wifi_signal'), content: this.wifiSignal });
            NetInfoItem({ title: $r('app.string.title_wifi_mac_address'), content: this.wifiMac });
            NetInfoItem({ title: $r('app.string.title_cellular_type'), content: this.cellularType });
            NetInfoItem({ title: $r('app.string.title_is_radio_on'), content: this.isRadioOn + '' });
            NetInfoItem({ title: $r('app.string.title_operator_name'), content: this.operatorName });
            NetInfoItem({ title: $r('app.string.title_is_roaming'), content: this.isRoaming });
            NetInfoItem({ title: $r('app.string.title_cellular_signal_rssi'), content: this.cellularSignal });
          }
        }
        .layoutWeight(1)
        .margin({ bottom: 16 })
        .padding({
          left: 16,
          right: 16
        })

        Button($r('app.string.re_query_network_info'))
          .width('calc(100% - 32vp)')
          .margin({
            left: 16,
            right: 16
          })
          .onClick(() => {
            this.queryNetworkInfo();
          })
      }
      .height('100%')
      .width('100%')
      .padding({
        top: 16,
        bottom: 16
      })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title($r('app.string.title_network_troubleshooting'))
  }
}