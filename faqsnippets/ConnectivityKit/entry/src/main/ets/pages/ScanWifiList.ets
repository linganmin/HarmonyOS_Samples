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
* FAQ:如何扫描Wi-Fi列表
 */

// [Start ScanWifiList]
import { wifiManager } from '@kit.ConnectivityKit';

try {
  let scanInfoList = wifiManager.getScanInfoList();
  console.info('scanInfoList:' + JSON.stringify(scanInfoList));
  let len = scanInfoList.length;
  console.log('wifi received scan info: ' + len);
  if (len > 0) {
    for (let i = 0; i < len; ++i) {
      console.info('ssid: ' + scanInfoList[i].ssid);
      console.info('bssid: ' + scanInfoList[i].bssid);
      console.info('capabilities: ' + scanInfoList[i].capabilities);
      console.info('securityType: ' + scanInfoList[i].securityType);
      console.info('rssi: ' + scanInfoList[i].rssi);
      console.info('band: ' + scanInfoList[i].band);
      console.info('frequency: ' + scanInfoList[i].frequency);
      console.info('channelWidth: ' + scanInfoList[i].channelWidth);
      console.info('timestamp: ' + scanInfoList[i].timestamp);
    }
  }
} catch (error) {
  console.error('failed:' + JSON.stringify(error));
}

// [End ScanWifiList]