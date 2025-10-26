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

import { AsyncCallback } from '@kit.BasicServicesKit';
import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { PermissionUtil } from '../common/utils/PermissionUtil';

@Entry
@Component
struct Index {
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private style: mapCommon.MyLocationStyle = {
    anchorU: 0.5,
    anchorV: 0.5,
    radiusFillColor: 0xff00FFFFFF,
    displayType: mapCommon.MyLocationDisplayType.FOLLOW
  };

  aboutToAppear(): void {
    this.mapOptions = {
      position: {
        target: {
          latitude: 39.91,
          longitude: 116.3975
        },
        zoom: 15
      }
    };

    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapController.setMyLocationEnabled(true);
        mapController.setMyLocationStyle(this.style);
        let util = new PermissionUtil(this.mapController);
        util.checkPermissions().then((flag: Boolean) => {
          if (!flag) {
            util.requestPermissions(this.getUIContext());
          }
        });
      }
    };
  }

  onPageShow(): void {
    // Switch the map to the frontend.
    if (this.mapController !== undefined) {
      this.mapController.show();
    }
  }

  onPageHide(): void {
    // Switch the map to the background.
    if (this.mapController !== undefined) {
      this.mapController.hide();
    }
  }

  build() {
    Column() {
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
        .width('100%')
        .height('100%')
    }
  }
}