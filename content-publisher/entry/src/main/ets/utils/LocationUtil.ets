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
import Logger from './Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'LocationUtil';

class LocationUtil {
  static getCurrentAddresses(): Promise<string[]> {
    return geoLocationManager.getCurrentLocation({
      locatingTimeoutMs: 2000,
      locatingPriority: geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED
    }).then(location => {
      return geoLocationManager.getAddressesFromLocation({
        latitude: location.latitude,
        longitude: location.longitude
      });
    }).then(addresses => {
      if (!addresses[0]) return [];
      return [
        addresses[0].countryName || '',
        addresses[0].administrativeArea || '',
        addresses[0].subAdministrativeArea || '',
        addresses[0].subLocality || '',
        addresses[0].placeName || ''
      ].filter(add => add);
    }).catch((e: BusinessError) => {
      Logger.error(TAG, 'Failed to getCurrentAddresses: ' + e.message);
      return [];
    });
  }
}

export default LocationUtil;