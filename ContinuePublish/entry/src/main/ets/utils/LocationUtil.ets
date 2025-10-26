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

import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'LocationUtil';
const FORMAT = '%{public}s';

class LocationUtil {
  geolocationOn(locationChange: (location: geoLocationManager.Location) => void): void {
    let requestInfo: geoLocationManager.LocationRequest = {
      'priority': 0x203,
      'scenario': 0x300,
      'timeInterval': 100,
      'distanceInterval': 0,
      'maxAccuracy': 0
    };
    try {
      geoLocationManager.on('locationChange', requestInfo, locationChange);
    } catch (err) {
      hilog.error(DOMAIN, TAG, FORMAT, 'locationChange error:' + JSON.stringify(err));
    }
  }

  getCurrentLocation(locationChange: (err: BusinessError, location: geoLocationManager.Location) => void) {
    geoLocationManager.getCurrentLocation(locationChange);
  }

  geolocationOff(): void {
    try {
      geoLocationManager.off('locationChange');
    } catch (err) {
      hilog.error(DOMAIN, TAG, FORMAT, `Off locationChange failed. Cause code: ${err.code}, message: ${err.message}`);
    }
  }
}

let locationUtil = new LocationUtil();

export default locationUtil as LocationUtil;