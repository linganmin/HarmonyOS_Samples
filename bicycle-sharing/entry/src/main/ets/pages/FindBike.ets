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
import { ScanUtil } from '../utils/ScanUtil';
import { geoLocationManager } from '@kit.LocationKit';
import { CyclingConstants } from '../constants/CyclingConstants';
import { MapUtil } from '../utils/MapUtil';

@Entry
@Component
struct FindBike {
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
  private mapController?: map.MapComponentController;
  private marker?: map.Marker;
  private mapPolyline?: map.MapPolyline;
  private myPosition?: mapCommon.LatLng;
  private locationChangeListener?: (location: geoLocationManager.Location) => void;

  aboutToAppear(): void {
    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapController?.setMyLocationEnabled(true);
        this.mapController?.setMyLocationControlsEnabled(true);
        let requestInfo: geoLocationManager.CurrentLocationRequest = {
          'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
          'scenario': geoLocationManager.LocationRequestScenario.UNSET,
          'maxAccuracy': 0
        };

        this.locationChangeListener = async (location: geoLocationManager.Location): Promise<void> => {
          let wgs84Position: mapCommon.LatLng = {
            latitude: location.latitude,
            longitude: location.longitude
          };
          let gcj02Position: mapCommon.LatLng =
            await map.convertCoordinate(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);
          this.myPosition = gcj02Position
        };

        geoLocationManager.on('locationChange', requestInfo, this.locationChangeListener);

        geoLocationManager.getCurrentLocation(requestInfo).then(async (result) => {
          let mapPosition: mapCommon.LatLng =
            await map.convertCoordinate(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, result);
          AppStorage.setOrCreate('longitude', mapPosition.longitude);
          AppStorage.setOrCreate('latitude', mapPosition.latitude);
          let cameraPosition: mapCommon.CameraPosition = {
            target: mapPosition,
            zoom: 15,
            tilt: 0,
            bearing: 0
          };
          let cameraUpdate = map.newCameraPosition(cameraPosition);
          mapController?.animateCamera(cameraUpdate, 1000);
        })

        // [Start map_controller]
        this.mapController.on('mapClick', async (position) => {
          this.mapController?.clear();
          this.marker?.remove();

          if (!this.myPosition) {
            console.error('Current position is not available');
            return;
          }

          this.marker = await MapUtil.addMarker(position, this.mapController);
          const walkingRoutes = await MapUtil.walkingRoutes(position, this.myPosition);
          await MapUtil.paintRoute(walkingRoutes!, this.mapPolyline, this.mapController);
        });
        // [End map_controller]
      }
    };
  }

  onPageHide(): void {
    this.mapController?.clear();

    if (this.locationChangeListener) {
      geoLocationManager.off('locationChange', this.locationChangeListener);
    }
  }

  build() {
    Navigation() {
      Stack({ alignContent: Alignment.Bottom }) {
        MapComponent({ mapOptions: this.mapOption, mapCallback: this.callback })
          .width(CyclingConstants.FULL_PERCENT)
          .height(CyclingConstants.FULL_PERCENT)

        Column() {
          Row() {
            Column() {
              Text($r('app.string.find_text'))
                .fontSize($r('app.float.find_text_fontSize'))
                .fontWeight(FontWeight.Bold)
                .alignSelf(ItemAlign.Start)
              Text($r('app.string.find_text_second'))
                .fontSize($r('app.float.find_text_fontSize_second'))
                .alignSelf(ItemAlign.Start)
                .margin({ top: $r('app.float.find_text_margin'), bottom: $r('app.float.find_image_bottom') })
            }

            Image($r('app.media.bike_page'))
              .height($r('app.float.find_image_height'))
              .width($r('app.float.find_image_width'))
              .margin({ right: $r('app.float.find_image_right'), bottom: $r('app.float.find_image_bottom') })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width(CyclingConstants.FULL_PERCENT)
          .margin({ top: $r('app.float.find_image_top') })

          Blank()
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Row({ space: CyclingConstants.FIND_BIKE_ROW_SPACE }) {
              Image($r('app.media.input_scan'))
                .width($r('app.float.find_button_size'))
                .height($r('app.float.find_button_size'))
              Text($r('app.string.find_scan'))
                .fontSize($r('app.float.find_button_text_fontSize'))
                .fontColor(Color.White)
            }
          }
          .margin({ bottom: $r('app.float.find_button_margin') })
          .width(CyclingConstants.FULL_PERCENT)
          .height($r('app.float.button_height'))
          .backgroundColor($r('app.color.blue'))
          .onClick(() => {
            ScanUtil.scan(this, this.getUIContext());
          })
        }
        .padding({ left: $r('app.float.terms_margin'), right: $r('app.float.terms_margin') })
        .borderRadius({
          topLeft: $r('app.float.find_border_radius'),
          topRight: $r('app.float.find_border_radius')
        })
        .alignItems(HorizontalAlign.Center)
        .height($r('app.string.find_column_height'))
        .width(CyclingConstants.FULL_PERCENT)
        .backgroundColor(Color.White)
      }
      .height(CyclingConstants.FULL_PERCENT)
      .width(CyclingConstants.FULL_PERCENT)
      .backgroundColor($r('app.color.white'))
    }
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .title($r('app.string.navigation_title'))
    .width(CyclingConstants.FULL_PERCENT)
    .height(CyclingConstants.FULL_PERCENT)
  }
}
