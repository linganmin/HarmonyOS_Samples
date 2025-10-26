/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the 'License');
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an 'AS IS' BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { promptAction } from '@kit.ArkUI';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { connection } from '@kit.NetworkKit';
import { CommonConstants } from '../common/CommonConstants';
import { LocationInter } from '../model/LocationInter';

const TAG = '[Index]';

@Entry
@Component
struct LocationService {
  @State address: string = '';
  @State isBackgroundRunning: boolean = false;
  @State isOnLocationChange: boolean = false;
  @State isCacheLocation: boolean = false;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  private mapController?: map.MapComponentController;
  private callback?: AsyncCallback<map.MapComponentController>;
  private marker?: map.Marker;
  private mapOption?: mapCommon.MapOptions;

  aboutToAppear(): void {
    if (!this.judgeHasNet()) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.internet_switch'),
          duration: 2000
        });
      } catch (error) {
        hilog.error(0x0000, TAG, `showToast catch error, code: ${error.code}, message: ${error.message}`);
      }
    }
    let cameraPosition: mapCommon.CameraPosition = {
      target: { longitude: 113.886642, latitude: 22.878538 },
      zoom: 15
    };
    this.mapOption = {
      position: cameraPosition,
      scaleControlsEnabled: true
    };
    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
      }
    };
  }

  aboutToDisappear(): void {
    if (this.isBackgroundRunning) {
      this.stopContinuousTask();
    } else {
      if (this.isOnLocationChange) {
        this.offLocationChange();
      }
    }
  }

  /**
   * Get cache location information
   */
  getPreLocationPosition(): void {
    try {
      // [Start get_last_location]
      let location = geoLocationManager.getLastLocation();
      // [End get_last_location]
      this.getAddress({
        latitude: location.latitude,
        longitude: location.longitude
      });
    } catch (err) {
      hilog.error(0x0000, TAG, `getPreLocationPosition failed, code: ${err.code}, message: ${err.message}`);
      this.locationFailedAlert(err.code);
    }
  }

  /**
   * Get current location information
   */
  getLocationPosition(): void {
    // [Start get_location_position]
    let request: geoLocationManager.SingleLocationRequest = {
      locatingPriority: 0x502,
      locatingTimeoutMs: 10000
    };
    // [End get_location_position]
    // [Start get_current_location]
    geoLocationManager.getCurrentLocation(request).then((location: geoLocationManager.Location) => {
      // [StartExclude get_current_location]
      this.getAddress({
        latitude: location.latitude,
        longitude: location.longitude
      })
      // [EndExclude get_current_location]
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `getCurrentLocationPosition failed, code: ${err.code}, message: ${err.message}`);
      // [StartExclude get_current_location]
      this.locationFailedAlert(err.code);
      // [EndExclude get_current_location]
    });
    // [End get_current_location]
  }

  /**
   * Start position change listening
   */
  // [Start on_location_change]
  onLocationChange(): void {
    // [Start Continuous_location_request]
    let request: geoLocationManager.ContinuousLocationRequest = {
      interval: 1,
      locationScenario: 0x401
    };
    // [End Continuous_location_request]
    try {
      // [Start location_change_on]
      geoLocationManager.on('locationChange', request, this.locationChange);
      // [End location_change_on]
      // [StartExclude on_location_change]
      if (!this.judgeHasNet()) {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.internet_switch'),
          duration: 2000
        });
        this.marker?.setInfoWindowVisible(false);
        this.address = '';
      }
      // [EndExclude on_location_change]
    } catch (err) {
      hilog.error(0x0000, TAG, `onLocationChange failed, code: ${err.code}, message: ${err.message}`);
      // [StartExclude on_location_change]
      this.locationFailedAlert(err.code);
      // [EndExclude on_location_change]
    }
  }
  // [End on_location_change]

  /**
   * Stop position change listening
   */
  // [Start off_location_change]
  offLocationChange(): void {
    // [Start location_change_off]
    try {
      geoLocationManager.off('locationChange', this.locationChange);
    } catch (err) {
      hilog.error(0x0000, TAG, `offLocationChange failed, code: ${err.code}, message: ${err.message}`);
    }
    // [End location_change_off]
  }
  // [End off_location_change]

  locationChange = (location: geoLocationManager.Location): void => {
    this.getAddress({
      latitude: location.latitude,
      longitude: location.longitude
    });
  }

  /**
   * Reverse geocoding and drawing the marker on the map
   * @param location
   */
  async getAddress(location: LocationInter) {
    try {
      let mapLocation: mapCommon.LatLng =
        await map.convertCoordinate(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, {
          latitude: location.latitude,
          longitude: location.longitude
        });
      let cameraPosition: mapCommon.CameraPosition = {
        target: mapLocation,
        zoom: 15,
        tilt: 0,
        bearing: 0
      };
      let cameraUpdate = map.newCameraPosition(cameraPosition);
      this.mapController?.animateCamera(cameraUpdate, 100);
      let makerOptions: mapCommon.MarkerOptions = {
        position: mapLocation,
        icon: $r('app.media.point'),
        clickable: true,
        title: CommonConstants.MARKER_TITLE(this.getUIContext())
      };
      if (this.marker === undefined) {
        this.marker = await this.mapController?.addMarker(makerOptions);
      } else {
        this.marker.setPosition(mapLocation);
      }
      let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest = {
        locale: this.getUIContext().getHostContext()!.resourceManager.getStringByNameSync('language'),
        latitude: location.latitude,
        longitude: location.longitude,
        maxItems: 1
      };
      // [Start get_addresses_from_location]
      geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest, async (err, data) => {
        if (data) {
          this.address = data[0]?.placeName || '';
          // [StartExclude  get_addresses_from_location]
          this.marker?.setInfoWindowVisible(true);
          this.marker?.setSnippet(this.address);
          hilog.info(0x0000, TAG, `The address is: ${this.address}`);
          if (this.isBackgroundRunning || this.isOnLocationChange) {
            this.isCacheLocation = false;
          }
          // [EndExclude  get_addresses_from_location]
        } else {
          hilog.error(0x0000, TAG, `getAddressesFromLocation failed, code: ${err.code}, message: ${err.message}`);
          // [StartExclude  get_addresses_from_location]
          if (!this.isOnLocationChange && !this.isBackgroundRunning) {
            this.locationFailedAlert(err.code);
          }
          // [EndExclude  get_addresses_from_location]
        }
      });
      // [End get_addresses_from_location]
    } catch (error) {
      hilog.error(0x0000, TAG, `getAddress failed, code: ${error.code}, message: ${error.message}`);
    }
  }

  /**
   * Start Background Location
   */
  // [Start start_continuous_task]
  startContinuousTask(): void {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    if (!context) {
      return;
    }
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: context.abilityInfo.bundleName,
          abilityName: context.abilityInfo.name
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 1,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj) => {
      backgroundTaskManager.startBackgroundRunning(context,
        backgroundTaskManager.BackgroundMode.LOCATION, wantAgentObj).then(() => {
        this.onLocationChange();
        hilog.info(0x0000, TAG, 'startBackgroundRunning succeeded');
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `startBackgroundRunning failed, cause:  ${JSON.stringify(err)}`);
      });
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `getWantAgent failed, cause:  ${JSON.stringify(err)}`);
    });
  }
  // [End start_continuous_task]

  /**
   * Stop Background Location
   */
  // [Start stop_continuous_task]
  stopContinuousTask(): void {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    if (!context) {
      return;
    }
    backgroundTaskManager.stopBackgroundRunning(context).then(() => {
      if (!this.isOnLocationChange) {
        this.offLocationChange();
      }
      hilog.info(0x0000, TAG, 'stopBackgroundRunning succeeded');
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `stopBackgroundRunning failed, cause:  ${JSON.stringify(err)}`);
    });
  }
  // [End stop_continuous_task]

  locationFailedAlert(errCode: number) {
    try {
      if (errCode === CommonConstants.LOCATION_SWITCH_OFF) {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.location_switch'),
          duration: 2000
        });
      } else if (errCode === CommonConstants.LOCATION_FAILED) {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.internet_switch'),
          duration: 2000
        });
      } else if (errCode === CommonConstants.REVERSE_GEOCODING_FAILED) {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.internet_switch'),
          duration: 2000
        });
      } else if (errCode === CommonConstants.WIFI_BLUETOOTH_OFF) {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.wifi_bluetooth_switch'),
          duration: 2000
        });
      }
    } catch (error) {
      hilog.error(0x0000, TAG, `locationFailedAlert catch error, code: ${error.code}, message: ${error.message}`);
    }
    this.marker?.setInfoWindowVisible(false);
    this.address = '';
  }

  judgeHasNet(): boolean {
    try {
      let netHandle = connection.getDefaultNetSync();
      if (!netHandle || netHandle.netId === 0) {
        return false;
      }
      let netCapability = connection.getNetCapabilitiesSync(netHandle);
      let cap = netCapability.networkCap || [];
      if (cap.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
        return true;
      } else {
        return false;
      }
    } catch (err) {
      hilog.error(0x0000, TAG, `JudgeHasNet failed, code: ${err.code}, message: ${err.message}`);
    }
    return false;
  }

  build() {
    Column() {
      Row() {
        if (canIUse('SystemCapability.Map.Core')) {
          MapComponent({
            mapOptions: this.mapOption,
            mapCallback: this.callback,
            customInfoWindow: this.customInfoWindow
          })
            .width('100%')
            .height('100%')
        }
      }
      .height('83%')
      .width('100%')

      Column() {
        Row() {
          Text()
            .width(8)
            .height(8)
            .margin({ right: 7 })
            .backgroundColor($r('app.color.green'))
            .borderRadius(4)
            .offset({ y: 6 })
          Text() {
            Span(this.isCacheLocation ? $r('app.string.cache_geocoded_location') :
            $r('app.string.current_geocoded_location'))
              .fontSize(14)
              .lineHeight(19)
              .fontFamily('Medium')
              .fontColor($r('app.color.shallow_green'))
            Span(this.address)
              .fontSize(14)
              .lineHeight(19)
              .fontFamily('Medium')
              .fontColor($r('app.color.black'))
          }
          .margin({ right: 16 })
        }
        .width('100%')
        .padding({
          top: 24,
          bottom: 16,
          left: 16,
          right: 16
        })
        .margin({
          left: 16,
          right: 16
        })
        .constraintSize({ maxWidth: '100%' })
        .alignItems(VerticalAlign.Top)

        Column() {
          Row() {
            Text($r('app.string.continuous_positioning'))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)

            Toggle({ type: ToggleType.Switch })
              .onChange((isOn: boolean) => {
                if (isOn) {
                  this.isOnLocationChange = true;
                  this.onLocationChange();
                } else {
                  this.isOnLocationChange = false;
                  if (!this.isBackgroundRunning) {
                    this.offLocationChange();
                  }
                }
              })
          }
          .height(48)
          .width('100%')
          .constraintSize({ maxWidth: '100%' })
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({
            left: 16,
            right: 16
          })

          Row() {
            Text($r('app.string.background_positioning'))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)

            Toggle({ type: ToggleType.Switch })
              .onChange((isOn: boolean) => {
                if (isOn) {
                  this.isBackgroundRunning = true;
                  this.startContinuousTask();
                } else {
                  this.isBackgroundRunning = false;
                  this.stopContinuousTask();
                }
              })
          }
          .height(48)
          .width('100%')
          .constraintSize({ maxWidth: '100%' })
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({
            left: 16,
            right: 16
          })
          .margin({
            bottom: 24
          })

          Button($r('app.string.get_cache_location'))
            .onClick(() => {
              this.getPreLocationPosition();
              this.isCacheLocation = true;
            })
            .width('100%')
            .height(40)
            .backgroundColor($r('app.color.blue'))
            .fontColor($r('app.color.white'))
            .fontWeight(FontWeight.Medium)
            .margin({
              bottom: 12
            })

          Button($r('app.string.get_current_location'))
            .onClick(() => {
              this.getLocationPosition();
              this.isCacheLocation = false;
            })
            .width('100%')
            .height(40)
            .backgroundColor($r('app.color.blue'))
            .fontColor($r('app.color.white'))
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .constraintSize({ maxWidth: '100%' })
        .margin({
          left: 16,
          right: 16,
          bottom: 16
        })
      }
      .width('100%')
      .borderRadius({
        topLeft: 32,
        topRight: 32
      })
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .position({ bottom: 0 })
    }
    .height('100%')
    .padding({
      bottom: this.getUIContext().px2vp(this.bottomRectHeight)
    })
  }

  @BuilderParam customInfoWindow: (params: map.MarkerDelegate) => void = this.customInfoWindowBuilder;

  @Builder
  customInfoWindowBuilder(params: map.MarkerDelegate) {
    if (params.marker) {
      Column() {
        Text(params.marker.getTitle())
          .width(180)
          .height(24)
          .backgroundColor($r('app.color.green'))
          .borderRadius({
            topLeft: 12,
            topRight: 12
          })
          .padding({
            top: 4,
            bottom: 4,
            left: 12
          })
          .fontSize(12)
          .fontColor($r('app.color.white_e6'))
          .lineHeight(16)
          .textAlign(TextAlign.Start)
        Text(params.marker.getSnippet())
          .width(180)
          .backgroundColor($r('app.color.white'))
          .borderRadius({
            bottomLeft: 12,
            bottomRight: 12
          })
          .padding({
            top: 4,
            bottom: 6,
            left: 12,
            right: 8
          })
          .fontSize(14)
          .fontColor($r('app.color.black_e6'))
          .lineHeight(19)
          .textAlign(TextAlign.Start)
      }
    }
  }
}