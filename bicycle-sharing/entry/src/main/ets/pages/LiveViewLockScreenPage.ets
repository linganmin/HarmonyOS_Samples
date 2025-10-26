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

import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { CyclingConstants } from '../constants/CyclingConstants';
import { MapUtil } from '../utils/MapUtil';

@Entry
@Component
struct LiveViewLockScreenPage {
  @StorageLink('longitude') longitude: number = CyclingConstants.LONGITUDE;
  @StorageLink('latitude') latitude: number = CyclingConstants.LATITUDE;
  mapOption?: mapCommon.MapOptions = {
    position: {
      target: {
        latitude: this.latitude,
        longitude: this.longitude
      },
      zoom: CyclingConstants.ZOOM
    },
    mapType: mapCommon.MapType.STANDARD
  };
  private callback?: AsyncCallback<map.MapComponentController>;

  aboutToAppear(): void {
    this.callback = async (err, mapController) => {
      if (!err) {
        MapUtil.initializeMapWithLocation(mapController)
      }
    };
  }

  build() {
    Column() {
      MapComponent({ mapOptions: this.mapOption, mapCallback: this.callback })
        .width(CyclingConstants.FULL_PERCENT)
        .height(CyclingConstants.FULL_PERCENT)
    }
    .width(CyclingConstants.FULL_PERCENT)
    .height(CyclingConstants.FULL_PERCENT)
  }
}
