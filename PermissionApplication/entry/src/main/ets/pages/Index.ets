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

import { i18n, intl } from '@kit.LocalizationKit';
import { abilityAccessCtrl, bundleManager, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State isShowPermissions: boolean = false;
  @State latitude: number = 0;
  @State longitude: number = 0;
  @State currentLocation: string = '';
  @State permissionsMessage: string | Resource = $r('app.string.obtain_location_permission');
  @State locationServiceMessage: string | Resource = $r('app.string.obtain_location_permission');
  @State isShowLocation: boolean = false;
  @Watch('locale') @StorageLink('language') systemLanguages: string = i18n.System.getAppPreferredLanguage();
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  locale(): void {
    this.getLocation();
  }

  build() {
    Column({ space: 10 }) {
      Column() {
        Row() {
          Text($r('app.string.current_location_text'))
            .fontSize(20)
            .fontWeight(FontWeight.Bolder)
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .padding({
          left: 12,
          right: 16
        })
        .margin({
          top: 16,
          bottom: 16
        })

        Row() {
          Text(this.currentLocation)
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16
        })
      }

      Column() {
        if (this.isShowPermissions) {
          Text() {
            Span(this.permissionsMessage)
              .fontColor('#99000000')
            Span($r('app.string.open_permission'))
              .fontColor('#0A59F7')
              .onClick(() => {
                this.checkPermissionGrant();
              })
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16
          })
          .margin({
            bottom: 16
          })
        }
        if (this.isShowLocation) {
          Text() {
            Span(this.locationServiceMessage)
              .fontColor('#99000000')
            Span($r('app.string.open_location_services_text'))
              .fontColor('#0A59F7')
              .onClick(() => {
                this.isLocationToggle();
              })
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16
          })
          .margin({
            bottom: 16
          })
        }

        Button($r('app.string.get_current_location'))
          .onClick(() => {
            this.currentLocation = '';
            this.checkPermissionGrant();
          })
          .backgroundColor('#0A59F7')
          .width(288)
          .margin({
            bottom: 16
          })
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height('100%')
  }

  // [Start open_permissions_setting]
  // The permission setting dialog box is displayed.
  private openPermissionsSetting(): void {
    let atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionOnSetting(this.context, ['ohos.permission.APPROXIMATELY_LOCATION',
      'ohos.permission.LOCATION']).then((data: Array<abilityAccessCtrl.GrantStatus>) => {
      if (data[0] === -1 && data[1] === -1) {
        this.isShowPermissions = true;
        this.permissionsMessage = $r('app.string.obtain_location_permission');
        return;
      } else if (data[0] === 0 && data[1] === -1) {
        this.isShowPermissions = true;
        this.permissionsMessage = $r('app.string.obtain_precise_positioning');
      } else {
        this.isShowPermissions = false;
      }
      this.isLocationToggle();
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'Index', 'data:' + JSON.stringify(err));
    });
  }
  // [End open_permissions_setting]

  // [Start check_permission_grant]
  // Verify if the application has been granted permission.
  checkPermissionGrant(): void {
    let hasPermission = false;
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, 'Index',
        `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    try {
      let atManager = abilityAccessCtrl.createAtManager();
      let approximatelyLocation = atManager.checkAccessTokenSync(tokenId, 'ohos.permission.APPROXIMATELY_LOCATION');
      let location = atManager.checkAccessTokenSync(tokenId, 'ohos.permission.LOCATION');
      hasPermission = approximatelyLocation === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED &&
        location === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, 'Index', `Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }
    if (hasPermission) {
      this.isLocationToggle();
    } else {
      this.requestPermissions();
    }
  }
  // [End check_permission_grant]

  // [Start request_permissions]
  // Requests location permissions from the user.
  requestPermissions(): void {
    let atManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(this.context, ['ohos.permission.APPROXIMATELY_LOCATION',
        'ohos.permission.LOCATION']).then((data) => {
        if (data.authResults[0] === -1 || data.authResults[1] === -1) {
          if (data.dialogShownResults && (data.dialogShownResults[0] || data.dialogShownResults[1])) {
            this.isShowPermissions = true;
            if(data.authResults[0] === -1){
              this.permissionsMessage = $r('app.string.obtain_location_permission');
            } else {
              this.permissionsMessage = $r('app.string.obtain_precise_positioning')
            }
          } else {
            this.openPermissionsSetting();
            return;
          }
        } else {
          this.isShowPermissions = false;
        }
        if (data.authResults[0] !== 0) {
          return;
        }
        this.isLocationToggle();
      }).catch((err: Error) => {
        hilog.error(0x0000, 'Index', 'requestPermissionsFromUser err:' + JSON.stringify(err));
      });
    } catch (err) {
      hilog.error(0x0000, 'Index', 'requestPermissionsFromUser err:' + JSON.stringify(err));
    }
  }
  // [End request_permissions]

  // [Start is_location_toggle]
  // Obtain current location switch status and pull up the global switch to set the pop-up box.
  isLocationToggle(): void {
    let atManager = abilityAccessCtrl.createAtManager();
    let isLocationEnabled = true;
    try {
      isLocationEnabled = geoLocationManager.isLocationEnabled();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'Index', `isLocationEnabled failed, error code=${err.code}, message=${err.message}`);
    }
    if (!isLocationEnabled) {
      atManager.requestGlobalSwitch(this.context, abilityAccessCtrl.SwitchType.LOCATION).then((data: boolean) => {
        if (data) {
          this.isShowLocation = false;
          this.getLocation();
        } else {
          this.isShowLocation = true;
          this.locationServiceMessage = $r('app.string.open_location_services');
        }
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'Index', 'data:' + JSON.stringify(err));
      });
    } else {
      this.isShowLocation = false;
      this.getLocation();
    }
  }

  getLocation(): void {
    let request: geoLocationManager.SingleLocationRequest = {
      'locatingTimeoutMs': 10000,
      'locatingPriority': geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED
    };
    // Get current location.
    geoLocationManager.getCurrentLocation(request).then((location) => {
      this.latitude = location.latitude;
      this.longitude = location.longitude;
      let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest = {
        'locale': this.systemLanguages.toString().includes('zh') ? 'zh' : 'en',
        'latitude': this.latitude,
        'longitude': this.longitude,
        'maxItems': 1
      };
      // Call the inverse geocoding service to convert coordinates into geographic descriptions.
      geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest).then((data) => {
        if (data[0].placeName) {
          this.currentLocation = data[0].placeName;
        }
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'Index', 'GetAddressesFromLocation err:' + JSON.stringify(err));
      });
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'Index', 'Promise getCurrentLocation err:' + JSON.stringify(err));
    })
  }
  // [End is_location_toggle]
}