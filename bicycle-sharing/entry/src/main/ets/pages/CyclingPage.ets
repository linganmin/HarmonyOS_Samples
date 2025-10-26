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
// [Start map_component]
import { MapComponent, mapCommon, map } from '@kit.MapKit';
// [End map_component]
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { ScanUtil } from '../utils/ScanUtil';
import { geoLocationManager } from '@kit.LocationKit';
import { router } from '@kit.ArkUI';
import { CyclingConstants } from '../constants/CyclingConstants';
import { MapUtil } from '../utils/MapUtil';
import Logger from '../utils/Logger';

@Entry
@Component
struct CyclingPage {
  mapOption?: mapCommon.MapOptions = {
    position: {
      target: {
        latitude: CyclingConstants.LATITUDE,
        longitude: CyclingConstants.LONGITUDE
      },
      zoom: CyclingConstants.ZOOM
    },
    mapType: mapCommon.MapType.STANDARD,
    compassControlsEnabled: false
  };
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private marker?: map.Marker;
  private mapPolyline?: map.MapPolyline;
  private myPosition?: mapCommon.LatLng;

  // [Start about_to_appear]
  aboutToAppear(): void {
    // initialize map
    this.callback = async (err, mapController) => {
      let hasPermissions = false;
      if (!err) {
        this.mapController = mapController;
        this.mapController.on('mapLoad', async () => {
          hasPermissions = await MapUtil.checkPermissions(this.mapController);
          if (!hasPermissions) {
            this.requestPermissions();
          }
          if (hasPermissions) {
            let requestInfo: geoLocationManager.CurrentLocationRequest = {
              'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
              'scenario': geoLocationManager.LocationRequestScenario.UNSET,
              'maxAccuracy': 0
            };
            let locationChange = async (): Promise<void> => {
            };
            geoLocationManager.on('locationChange', requestInfo, locationChange);
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
          }
        });
        // [StartExclude map_controller]
        this.mapController.on('mapClick', async (position) => {
          this.mapController?.clear();
          this.marker?.remove();
          let requestInfo: geoLocationManager.CurrentLocationRequest = {
            'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
            'scenario': geoLocationManager.LocationRequestScenario.UNSET,
            'maxAccuracy': 0
          };
          let locationChange = async (location: geoLocationManager.Location): Promise<void> => {
            let wgs84Position: mapCommon.LatLng = {
              latitude: location.latitude,
              longitude: location.longitude
            };
            let gcj02Posion: mapCommon.LatLng =
              await map.convertCoordinate(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02,
                wgs84Position);
            this.myPosition = gcj02Posion
          };
          geoLocationManager.on('locationChange', requestInfo, locationChange);
          // add walking marker
          this.marker = await MapUtil.addMarker(position, this.mapController);
          const walkingRoutes = await MapUtil.walkingRoutes(position, this.myPosition);
          await MapUtil.paintRoute(walkingRoutes!, this.mapPolyline, this.mapController);
        });
        // [EndExclude map_controller]
      }
    };
  }

  // [End about_to_appear]

  aboutToDisappear(): void {
    this.callback = async (err, mapController) => {
      if (!err) {
        mapController.off('mapClick', async () => {
        })
      }
    };
  }

  onPageHide(): void {
    this.mapController?.clear();
  }

  @Builder
  IndexPage() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Row() {
          Column() {
            Image($r('app.media.find_bike'))
              .width($r('app.float.index_find_bike'))
              .height($r('app.float.index_find_bike'))
            Text($r('app.string.index_find_bike'))
              .height($r('app.float.index_find_height'))
              .fontSize($r('app.float.index_find_fontSize'))
          }
          .justifyContent(FlexAlign.Center)
          .width($r('app.float.index_find_width'))
          //jump to find a car page
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/FindBike' })
          })

          Column() {
            Image($r('app.media.park'))
              .width($r('app.float.index_find_bike'))
              .height($r('app.float.index_find_bike'))
            Text($r('app.string.index_park'))
              .height($r('app.float.index_find_height'))
              .fontSize($r('app.float.index_find_fontSize'))
          }
          .width($r('app.float.index_find_width'))
          .justifyContent(FlexAlign.Center)

          Column() {
            Image($r('app.media.cheap'))
              .width($r('app.float.index_find_bike'))
              .height($r('app.float.index_find_bike'))
            Text($r('app.string.index_cheap'))
              .height($r('app.float.index_find_height'))
              .fontSize($r('app.float.index_find_fontSize'))
          }
          .width($r('app.float.index_find_width'))
          .justifyContent(FlexAlign.Center)

          Column() {
            Image($r('app.media.redbag'))
              .width($r('app.float.index_find_bike'))
              .height($r('app.float.index_find_bike'))
            Text($r('app.string.index_redbag'))
              .height($r('app.float.index_find_height'))
              .fontSize($r('app.float.index_find_fontSize'))
          }
          .width($r('app.float.index_find_width'))
          .justifyContent(FlexAlign.Center)

          Column() {
            Image($r('app.media.fix'))
              .width($r('app.float.index_find_bike'))
              .height($r('app.float.index_find_bike'))
            Text($r('app.string.index_fix'))
              .height($r('app.float.index_find_height'))
              .fontSize($r('app.float.index_find_fontSize'))
          }
          .width($r('app.float.index_find_width'))
          .justifyContent(FlexAlign.Center)

        }
        .height($r('app.float.index_find_row_height'))
        .width(CyclingConstants.FULL_PERCENT)
        .backgroundColor(Color.White)
        .justifyContent(FlexAlign.Center)

        Blank()
          .height($r('app.float.index_find_blank'))
        Image($r('app.media.banner'))
          .width($r('app.string.index_find_image_width'))
          .height($r('app.string.index_find_image_height'))
          .objectFit(ImageFit.Contain)
        Blank()
          .height($r('app.float.index_find_blank'))
        Image($r('app.media.back'))
          .width($r('app.string.index_find_image_width'))
          .height($r('app.string.index_find_image_height_second'))
          .objectFit(ImageFit.Contain)

      }

      Column() {
        Button({ type: ButtonType.Capsule, stateEffect: true }) {
          Row({ space: CyclingConstants.INDEX_ROW_SPACE }) {
            Image($r('app.media.input_scan'))
              .width($r('app.float.index_button_image_size'))
              .height($r('app.float.index_button_image_size'))
            Text($r('app.string.index_use_bike'))
              .fontSize($r('app.float.index_button_text_fontSize'))
              .fontColor(Color.White)
          }
        }
        .width(CyclingConstants.FULL_PERCENT)
        .height($r('app.float.button_height'))
        .backgroundColor($r('app.color.blue'))
        .onClick(() => {
          ScanUtil.scan(this, this.getUIContext());
        })
      }
      .padding({ left: $r('app.float.terms_margin'), right: $r('app.float.terms_margin') })
      .height($r('app.string.index_button_height'))
      .width(CyclingConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .position({ y: $r('app.float.index_button_position') })
      .borderRadius({
        topLeft: $r('app.float.index_button_border_radius'),
        topRight: $r('app.float.index_button_border_radius')
      })
    }
    .height(CyclingConstants.FULL_PERCENT)
    .width(CyclingConstants.FULL_PERCENT)
  }

  // [Start build]
  build() {
    // [StartExclude navigation]
    Navigation() {
      // [StartExclude column]
      Column() {
        MapComponent({
          mapOptions: this.mapOption,
          mapCallback: this.callback
        })
        // [StartExclude index_page]
          .width(CyclingConstants.FULL_PERCENT)
          .height($r('app.string.index_map_height'))
        this.IndexPage();
        // [EndExclude index_page]
      }
      // [EndExclude column]
      .width(CyclingConstants.FULL_PERCENT)
      .height(CyclingConstants.FULL_PERCENT)
      .backgroundColor($r('app.color.white'))
    }
    .hideBackButton(true)
    .mode(NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Mini)
    .title($r('app.string.navigation_title'))
    .width(CyclingConstants.FULL_PERCENT)
    .height(CyclingConstants.FULL_PERCENT)

    // [EndExclude navigation]
  }

  // [End build]

  // request permissions
  // [Start request_permissions]
  requestPermissions(): void {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(this.getUIContext().getHostContext() as common.UIAbilityContext,
      ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'])
      .then(() => {
        this.mapController?.setMyLocationEnabled(true);
        this.mapController?.setMyLocationControlsEnabled(true);
        this.mapController?.setCompassControlsEnabled(false);
        this.mapController?.setMyLocationStyle({ displayType: mapCommon.MyLocationDisplayType.FOLLOW });
        geoLocationManager.getCurrentLocation().then(async (result) => {
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
          this.mapController?.animateCamera(cameraUpdate, 1000);
        })
      })
      .catch((err: BusinessError) => {
        Logger.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
      })
  }

  // [End request_permissions]
}