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

import { wifiManager } from '@kit.ConnectivityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function WiFiQueryBuilder() {
  WiFiQuery()
}

@Component
export struct WiFiQuery {
  @State text: ResourceStr = '';
  @State textArea: string = '';

  // [Start get_wifi_status]
  getWifiStatus() {
    try {
      let isWifiActive = wifiManager.isWifiActive();
      hilog.info(0x0000, 'Sample', 'isWifiActive: %{public}s', isWifiActive);
      // [StartExclude get_wifi_status]
      this.textArea = 'isWifiActive:' + isWifiActive;
      // [EndExclude get_wifi_status]
    } catch (error) {
      hilog.error(0x0000, 'Sample', 'failed: err->: %{public}s', JSON.stringify(error));
    }
  }
  // [End get_wifi_status]

  // [Start get_wifi_is_connected]
  getWifiIsConnected() {
    try {
      let ret = wifiManager.isConnected();
      hilog.info(0x0000, 'Sample', 'isConnected: %{public}s', ret);
      // [StartExclude get_wifi_is_connected]
      this.textArea = 'isConnected:' + ret;
      // [EndExclude get_wifi_is_connected]
    } catch (error) {
      hilog.error(0x0000, 'Sample', 'failed: err->: %{public}s', JSON.stringify(error));
    }
  }
  // [End get_wifi_is_connected]

  // [Start get_scan_info_list]
  getScanInfoList() {
    try {
      let scanInfoList = wifiManager.getScanInfoList();
      hilog.info(0x0000, 'Sample', 'scanInfoList: %{public}s', JSON.stringify(scanInfoList));
      // [StartExclude get_scan_info_list]
      this.textArea = 'scanInfoList:' + JSON.stringify(scanInfoList);
      // [EndExclude get_scan_info_list]
    } catch (error) {
      hilog.error(0x0000, 'Sample', 'failed: err->: %{public}s', JSON.stringify(error));
    }
  }
  // [End get_scan_info_list]

  // [Start get_signal_level]
  getSignalLevel() {
    try {
      let rssi = 0;
      let band = 0;
      let level = wifiManager.getSignalLevel(rssi, band);
      hilog.info(0x0000, 'Sample', 'level: %{public}s', JSON.stringify(level));
      // [StartExclude get_signal_level]
      this.textArea = 'level:' + JSON.stringify(level);
      // [EndExclude get_signal_level]
    } catch (error) {
      hilog.error(0x0000, 'Sample', 'failed: err->: %{public}s', JSON.stringify(error));
    }
  }
  // [End get_signal_level]

  // [Start add_candidate_config]
  addCandidateConfig() {
    try {
      let config: wifiManager.WifiDeviceConfig = {
        ssid: '****',
        preSharedKey: '****',
        securityType: 0
      };
      wifiManager.addCandidateConfig(config).then(result => {
        hilog.info(0x0000, 'Sample', 'result: %{public}s', JSON.stringify(result));
      }).catch((err: number) => {
        hilog.error(0x0000, 'Sample', 'failed: err->: %{public}s', JSON.stringify(err));
      });
      // [StartExclude add_candidate_config]
      this.textArea = JSON.stringify(config);
      // [EndExclude add_candidate_config]
    } catch (error) {
      hilog.error(0x0000, 'Sample', 'failed: err->: %{public}s', JSON.stringify(error));
    }
  }
  // [End add_candidate_config]

  @Builder
  NavDestinationTitle() {
    Column() {
      Text($r('app.string.wifi_query'))
        .fontSize(20)
        .lineHeight(40)
        .fontWeight(700)
        .width('100%')
        .padding({ left: 12 })
    }
    .width('100%')
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Text(this.text)
            .margin({ bottom: 12 })
            .textAlign(TextAlign.Start)
            .width('100%')
            .height(20)
          TextArea({ text: this.textArea })
            .width('100%')
            .height('45%')
            .focusable(false)
        }

        Column({ space: 12 }) {
          Button($r('app.string.Check_wlan_is_enabled'))
            .onClick(() => {
              this.text = $r('app.string.wlan_is_enabled');
              this.getWifiStatus();
            })
            .width('100%')
            .backgroundColor('#0A59F7')
          Button($r('app.string.Check_wlan_is_Connected'))
            .onClick(() => {
              this.text = $r('app.string.wlan_is_Connected');
              this.getWifiIsConnected();
            })
            .width('100%')
            .backgroundColor('#0A59F7')
          Button($r('app.string.get_list_of_scanned_hotspots'))
            .onClick(() => {
              this.text = $r('app.string.list_of_scanned_hotspots');
              this.getScanInfoList();
            })
            .width('100%')
            .backgroundColor('#0A59F7')
          Button($r('app.string.get_wifi_signal_strength'))
            .onClick(() => {
              this.text = $r('app.string.wifi_signal_strength');
              this.getSignalLevel();
            })
            .width('100%')
            .backgroundColor('#0A59F7')
          Button($r('app.string.add_candidate_network_configuration'))
            .onClick(() => {
              this.text = $r('app.string.candidate_network_configuration');
              this.addCandidateConfig();
            })
            .width('100%')
            .backgroundColor('#0A59F7')
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(16)
    }
    .title(this.NavDestinationTitle())
  }
}