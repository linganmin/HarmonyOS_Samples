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

// [Start geo_location_manager]
// Index.ets
import { geoLocationManager } from '@kit.LocationKit';
// [End geo_location_manager]
import { abilityAccessCtrl } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { CommonConstants } from '../constants/CommonConstants';
import { Home } from '../view/Home';
import { i18n } from '@kit.LocalizationKit';

// [Start location_change]
// Index.ets
let locationChange: (err: BusinessError, location: geoLocationManager.Location) => void = (err, location) => {
  if (err) {
    hilog.error(0x00000, 'locationChanger: err=', JSON.stringify(err));
  }
  if (location) {
    let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest = {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'maxItems': CommonConstants.MAX_ITEMS
    };
    geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest, (err, data) => {
      if (data) {
        hilog.info(0x00000, 'getAddressesFromLocation: data=', JSON.stringify(data));
        if (data[0].locality !== undefined) {
          if (i18n.System.getSystemLanguage() === 'zh-Hans') {
            AppStorage.setOrCreate('local', data[0].locality.replace(/"/g, '').slice(0, -1));
            AppStorage.setOrCreate('currentLocal', data[0].locality.replace(/"/g, '').slice(0, -1));
          } else {
            AppStorage.setOrCreate('local', data[0].locality.replace(/"/g, ''));
            AppStorage.setOrCreate('currentLocal', data[0].locality.replace(/"/g, ''));
          }
        }
      }
    });
  }
};

// [End location_change]

@Entry
@Component
struct Index {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @State status: boolean = true;

  // [Start on_page_show]
  // Index.ets
  onPageShow(): void {
    abilityAccessCtrl.createAtManager().requestPermissionsFromUser(this.getUIContext().getHostContext(), [
      'ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION']).then(() => {
      if (this.status) {
        geoLocationManager.getCurrentLocation(locationChange);
        this.status = false;
      }
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'Index', `requestPermissionsFromUser fail, code: ${err.code}, message: ${err.message}`);
    });
  }

  // [End on_page_show]

  build() {
    GridRow({
      columns: {
        sm: BreakpointConstants.GRID_ROW_COLUMNS[0],
        md: BreakpointConstants.GRID_ROW_COLUMNS[1],
        lg: BreakpointConstants.GRID_ROW_COLUMNS[2]
      }
    }) {
      GridCol({
        span: {
          sm: BreakpointConstants.GRID_COLUMN_SPANS[0],
          md: BreakpointConstants.GRID_COLUMN_SPANS[1],
          lg: BreakpointConstants.GRID_COLUMN_SPANS[4]
        }
      }) {
        Home()
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
    }
    .onBreakpointChange((breakPoint) => {
      this.currentBreakpoint = breakPoint;
    })
  }
}