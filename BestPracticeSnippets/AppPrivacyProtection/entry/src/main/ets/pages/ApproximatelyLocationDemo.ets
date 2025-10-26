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

import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
import Logger from '../utils/Logger';

@Entry
@Component
struct ApproximatelyLocationDemo {
  @State message: string = '';

  async requestPermissions(): Promise<number> {
    const permissions: Array<Permissions> = ['ohos.permission.APPROXIMATELY_LOCATION'];
    // [Start request_permission]
    const accessManager = abilityAccessCtrl.createAtManager();
    // [End request_permission]
    const bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION;
    const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleFlags);
    let grantStatus: abilityAccessCtrl.GrantStatus | null = null;
    try {
      grantStatus = accessManager.checkAccessTokenSync(bundleInfo.appInfo.accessTokenId, permissions[0]);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(`showToast failed, code=${err.code}, message=${err.message}`);
    }
    return new Promise((resolve, reject) => {
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        // [Start request_permission]
        accessManager.requestPermissionsFromUser(this.getUIContext().getHostContext(),
          ['ohos.permission.APPROXIMATELY_LOCATION'])
          .then((data) => {
            let grantStatus: Array<number> = data.authResults;
            if (grantStatus.length > 0 && grantStatus[0] === 0) {
              // The user is authorized to continue to access the target operation
              Logger.info('request permissions granted');
              // [StartExclude request_permission]
              resolve(0);
              // [EndExclude request_permission]
            } else {
              // The user rejects the authorization
              Logger.info('request permissions denied');
              // [StartExclude request_permission]
              try {
                this.getUIContext().getPromptAction().showToast({
                  message: 'This function requires the location permission. Go to the settings page to authorize the permission'
                });
              } catch (error) {
                let err = error as BusinessError;
                Logger.error(`showToast failed, code=${err.code}, message=${err.message}`);
              }
              resolve(-1);
              // [EndExclude request_permission]
            }
            Logger.info(`request permissions result: ${JSON.stringify(data)}`);
          })
          // [End request_permission]
          .catch((error: BusinessError) => {
            Logger.error(`request permissions exception, Catch error:${JSON.stringify(error)}`);
            reject(error);
          })
      } else {
        resolve(0);
      }
    });
  }

  getLocation() {

    this.requestPermissions().then(data => {
      if (data === 0) {
        // [Start request_permissions]
        let requestInfo: geoLocationManager.LocationRequest = {
          'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
          'scenario': geoLocationManager.LocationRequestScenario.UNSET,
          'timeInterval': 1,
          'distanceInterval': 0,
          'maxAccuracy': 0
        };
        geoLocationManager.getCurrentLocation(requestInfo).then(result => {
          Logger.info(`geoLocation current location:error: ${JSON.stringify(result)}`)
          // [StartExclude request_permissions]
          this.message = JSON.stringify(result);
          // [EndExclude request_permissions]
        }).catch((error: BusinessError) => {
          Logger.error(`geoLocation getCurrentLocation: error: ${JSON.stringify(error)}`)
        });
        // [End request_permissions]
      }
    })
  }

  build() {
    Column() {
      Text(this.message)
        .fontSize(20)
        .borderRadius(10)
        .backgroundColor('#F1F3F5')
        .padding(12)

      Button($r('app.string.use_approximately_location'))
        .height(40)
        .width('100%')
        .onClick(() => {
          this.getLocation();
        })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(16)
  }
}