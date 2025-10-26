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

import { abilityAccessCtrl, AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { map, mapCommon } from '@kit.MapKit';

const TAG: string = 'EntryAbility';

let requestInfo: geoLocationManager.CurrentLocationRequest = {
  'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
  'scenario': geoLocationManager.LocationRequestScenario.UNSET,
  'maxAccuracy': 0
};

export default class WearableAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }
  // [Start windowClass]
  onWindowStageCreate(windowStage: window.WindowStage): void {
    let windowClass: window.Window | undefined = undefined;
    window.getLastWindow(this.context, (err: BusinessError, data: window.Window) => {
      const errCode: number = err.code;
      if (errCode) {
        hilog.error(0x0000, TAG, 'Failed to obtain the top window. Cause: ' + JSON.stringify(err));
        return;
      }
      windowClass = data;
      hilog.info(0x0000, TAG, 'Succeeded in obtaining the top window. Data: ' + JSON.stringify(data));
      AppStorage.setOrCreate('windowClass', windowClass);
    });
    // [StartExclude windowClass]
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(this.context,
      ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION']).then(() => {
      try {
        geoLocationManager.getCurrentLocation(requestInfo).then((result) => {
          let wgs84Position: mapCommon.LatLng = {
            latitude: result.latitude,
            longitude: result.longitude
          };
          let gcj02Position: mapCommon.LatLng =
            map.convertCoordinateSync(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);
          AppStorage.setOrCreate('myLocation', result);
          hilog.info(0x0000, TAG, 'current location: ' + JSON.stringify(result));
          windowStage.loadContent('pages/Index', (err) => {
            if (err.code) {
              hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
              return;
            }
            hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
          });
        })
          .catch((error: BusinessError) => {
            hilog.error(0x0000, TAG, 'promise, getCurrentLocation: error=' + JSON.stringify(error));
          });
      } catch (err) {
        hilog.error(0x0000, TAG, 'errCode:' + err.code + ', message:' + err.message);
      }

    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
    });
    // [EndExclude windowClass]
  }
  // [End windowClass]

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
