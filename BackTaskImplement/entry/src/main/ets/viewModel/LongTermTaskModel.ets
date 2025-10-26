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

import { abilityAccessCtrl, common, PermissionRequestResult, Permissions, wantAgent, WantAgent } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { geoLocationManager } from '@kit.LocationKit';

const TAG: string = '[LongTermTaskModel]';

export class LongTermTaskModel {
  private context: common.UIAbilityContext = AppStorage.get("context") as common.UIAbilityContext;

  // [Start requestPermissionsFromUser_start]
  // Apply for location-related permissions
  requestPermissionsFromUser(): void {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let permissionList: Permissions[] = [
      'ohos.permission.INTERNET',
      'ohos.permission.LOCATION',
      'ohos.permission.APPROXIMATELY_LOCATION'
    ];
    atManager.requestPermissionsFromUser(this.context, permissionList)
      .then((data: PermissionRequestResult) => {
        hilog.info(0x0000, TAG, `data: ${JSON.stringify(data)}`);
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `requestPermissionsFromUser fail: ${JSON.stringify(err)}`);
      });
  }
  // [End requestPermissionsFromUser_start]

  // [Start locationCallback_start]
  locationCallback = async (location: geoLocationManager.Location) => {
    hilog.info(0x0000, TAG, `locationCallback: data: ${JSON.stringify(location)}`);
  };

  // Get the location
  async getLocation() {
    let request: geoLocationManager.LocationRequest = {
      priority: geoLocationManager.LocationRequestPriority.FIRST_FIX, // Quick location acquisition is preferred
      scenario: geoLocationManager.LocationRequestScenario.UNSET, // Indicates that no scenario information is set
      timeInterval: 1, // Interval for reporting the location information
      distanceInterval: 0, // Distance for reporting location information
      maxAccuracy: 100 // The precision value required when the application requests location information from the system
    };
    try {
      geoLocationManager.on('locationChange', request, this.locationCallback);
    } catch (err) {
      hilog.error(0x0000, TAG, `errCode: ${JSON.stringify(err)}`);
    }
  }
  // [End locationCallback_start]

  // [Start startLongTask_start]
  // Start a long task
  startLongTask(): void {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: this.context.abilityInfo.bundleName,
          abilityName: this.context.abilityInfo.name
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    try {
      // wantAgent object is obtained by getWantAgent method in WantAgent module
      wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
        backgroundTaskManager.startBackgroundRunning(this.context, backgroundTaskManager.BackgroundMode.LOCATION,
          wantAgentObj)
          .then(() => {
            hilog.info(0x0000, TAG, `Operation startBackgroundRunning succeeded`);
          })
          .catch((error: BusinessError) => {
            hilog.error(0x0000, TAG,
              `Operation startBackgroundRunning failed. code is ${error.code} message is ${error.message}`);
          });
      });
    } catch (error) {
      hilog.error(0x0000, TAG, `Operation getWantAgent failed. error is ${JSON.stringify(error)} `);
    }
  }
  // [End startLongTask_start]

  // [Start stopLongTask_start]
  // Stop a long task
  stopLongTask(): void {
    backgroundTaskManager.stopBackgroundRunning(this.context).then(() => {
      hilog.info(0x0000, TAG, `Operation stopBackgroundRunning succeeded`);
    }).catch((error: BusinessError) => {
      hilog.error(0x0000, TAG, `Operation stopBackgroundRunning failed. error is ${JSON.stringify(error)} `);
    });
  }
  // [End stopLongTask_start]
}