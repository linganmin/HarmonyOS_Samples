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

// [Start request_permission_step]
import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
// [End request_permission_step]
import { BusinessError } from '@kit.BasicServicesKit';
// [Start get_mac_step]
import { geoLocationManager } from '@kit.LocationKit';
// [End get_mac_step]
// [Start check_wifi_connected_step]
import { wifiManager } from '@kit.ConnectivityKit';
// [End check_wifi_connected_step]
import { Logger } from '../common/Logger';
import { showToast } from '../common/ToastUtil';

const TAG = 'WlanLocationTag';

@Component
export struct WlanLocation {
  @State macAddress: string = '';

  // [Start request_permission_step]
  async requestPermissions(): Promise<number> {

    return new Promise((resolve, reject) => {
      try {
        const permissions: Permissions[] = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];
        const accessManager = abilityAccessCtrl.createAtManager();
        const bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION;
        const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleFlags);
        const grantStatus = accessManager.checkAccessTokenSync(bundleInfo.appInfo.accessTokenId, permissions[0]);
        if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
          resolve(0);
          return;
        }
        accessManager.requestPermissionsFromUser(this.getUIContext().getHostContext(), permissions).then((data) => {
          Logger.info(TAG, `request permissions result: ${JSON.stringify(data)}`);
          let grantStatus: number[] = data.authResults;
          if (grantStatus.length > 0 && grantStatus[0] === 0) {
            Logger.info(TAG, 'request permissions granted');
            resolve(0);
          } else {
            Logger.info('request permissions denied');
            showToast(this.getUIContext(), $r('app.string.no_location_permission_tips'));
            resolve(-1);
          }
        }).catch((error: BusinessError) => {
          Logger.error(TAG, `request permissions exception, Catch error:${JSON.stringify(error)}`);
          reject(error);
        })
      } catch (err) {
        let error = err as BusinessError;
        Logger.error(TAG, `requestPermissions err, errCode: ${error.code}, error mesage: ${error.message}`);
      }
    });
  }
  // [End request_permission_step]

  // [Start check_wifi_connected_step]
  isWiFiConnected(): boolean {
    try {
      if (!wifiManager.isWifiActive()) {
        showToast(this.getUIContext(), $r('app.string.turn_on_wlan_tips'));
        return false;
      }

      if (wifiManager.isConnected()) {
        return true;
      } else {
        showToast(this.getUIContext(), $r('app.string.wifi_not_connect_tips'));
        return false;
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `checkWifiStatus err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
    return false;
  }
  // [End check_wifi_connected_step]

  // [Start get_mac_step]
  getWiFiBssid() {
    if (this.isWiFiConnected()) {
      this.requestPermissions().then(result => {
        if (result === 0) {
          Logger.info(TAG, 'request location permissions success');
          try {
            let bssid: string = geoLocationManager.getCurrentWifiBssidForLocating();
            Logger.info(TAG, `getCurrentWifiBssidForLocating wifi bssid success: ${bssid}`);
            this.macAddress = bssid;
          } catch (error) {
            Logger.error(TAG, `getCurrentWifiBssidForLocatingerror: ${JSON.stringify(error)}`);
          }
        }
      });
    }
  }
  // [End get_mac_step]

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text($r('app.string.mac_address'))
            .fontSize(16)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Regular)
          Text(this.macAddress)
            .fontSize(16)
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignSelf(ItemAlign.Start)
        .backgroundColor($r('sys.color.comp_background_primary'))
        .borderRadius(16)
        .height(56)
        .width('100%')
        .padding({
          left:12,
          right:12
        })

        Blank()

        Button($r('app.string.btn_get_mac'))
          .width('100%')
          .onClick(() => {
            this.getWiFiBssid();
          })
      }
      .height('100%')
      .width('100%')
      .padding(16)
    }
    .title($r('app.string.title_wlan_positioning'))
    .backgroundColor($r('sys.color.background_secondary'))
  }
}