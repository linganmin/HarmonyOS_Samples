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

import { geoLocationManager } from '@kit.LocationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Context } from '@kit.AbilityKit';
import { PermissionUtil } from './PermissionUtil';

const TAG = 'LocationUtil'

export class LocationUtil {
  private static request: geoLocationManager.SingleLocationRequest = {
    'locatingPriority': geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED,
    'locatingTimeoutMs': 10000
  };

  public static async getLocation(context: Context): Promise<string> {
    try {
      let location: geoLocationManager.Location = await geoLocationManager.getCurrentLocation(LocationUtil.request);
      let latitude: string = context.resourceManager.getStringSync($r('app.string.latitude').id, location.latitude);
      let longitude: string = context.resourceManager.getStringSync($r('app.string.longitude').id, location.longitude);;
      return latitude + longitude;
    } catch (err) {
      hilog.error(0x0000, TAG, `get location failed, errorCode: ${err.code}`);
    }
    return '';
  }

  public static async updateLocation(context: Context): Promise<string> {
    if (await PermissionUtil.hasLocationPermission()) {
      return LocationUtil.getLocation(context);
    }
    let requestPermission: boolean = await PermissionUtil.requestLocationPermission(context);
    if (requestPermission) {
      return LocationUtil.getLocation(context);
    }
    return '';
  }
}