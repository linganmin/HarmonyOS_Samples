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

import { MapComponent, mapCommon, map, navi } from '@kit.MapKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { wearEngine } from '@kit.WearEngine';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { CommunicationInformation, CommunicationUtils, RouteInfomation } from 'communication';
import { DrawRouteUtils } from 'map';

const TAG: string = 'phoneIndex';

@Entry
@Component
struct HuaweiMapDemo {
  // Window object obtained from EntryAbility, which is used to ensure that the screen is steady on during navigation.
  @StorageLink('windowClass') windowClass: window.Window | undefined = undefined;
  // Route information obtained from the route drawing method.
  @StorageLink('routeInfomation') routeInfomation: RouteInfomation[] = [];
  // Current location information obtained through the location kit.
  @StorageLink('myLocation') myLocation: geoLocationManager.Location = {
    latitude: 0,
    longitude: 0,
    altitude: 0,
    accuracy: 0,
    speed: 0,
    timeStamp: 0,
    direction: 0,
    timeSinceBoot: 0
  };
  // Signals for synchronizing the start and end of navigation on both sides of the phone and watch.
  @StorageLink('isStartNavigation') @Watch('navigationStatusChange') isStartNavigation: boolean = false;
  // [Start changeDestinationPositionMark]
  // [Start mapOnclick]
  // Destination location information obtained based on the map click event.
  @StorageLink('destination_Position') @Watch('changeDestinationPositionMark') destination_Position: mapCommon.LatLng =
    {
      longitude: 0,
      latitude: 0
    };
  // [StartExclude changeDestinationPositionMark]
  // [StartExclude mapOnclick]
  // Boolean value used to determine whether the action bar is displayed.
  @State isBarShow: boolean = false;
  // Map Options.
  private mapOptions: mapCommon.MapOptions | undefined = undefined;
  // intercom entity class object.
  private connectUtils: CommunicationUtils = new CommunicationUtils(this.getUIContext().getHostContext() as Context);
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;

  /*
   * Triggered when isStartNavigation changes.
   * Used to set the screen to steady on during navigation. Turn off the screen when non-navigation is always on.
   */
  navigationStatusChange() {
    if (this.windowClass) {
      this.windowClass.setWindowKeepScreenOn(this.isStartNavigation, (err: BusinessError) => {
        const errCode: number = err.code;
        if (errCode) {
          hilog.error(0x0000, TAG,
            `Failed to set the screen to be always on. Cause code: ${err.code}, message: ${err.message}`);
          return;
        }
        hilog.info(0x0000, TAG, 'Succeeded in setting the screen to be always on.');
      });
    }
  }

  // [EndExclude changeDestinationPositionMark]
  /*
   * Triggered when destination_Position changes.
   * Used to refresh the destination marker on the map when the destination changes.
   */
  async changeDestinationPositionMark() {
    if (this.mapController) {
      this.mapController.clear();
      let markerOptions: mapCommon.MarkerOptions = {
        position: this.destination_Position,
        rotation: 0,
        visible: true,
        zIndex: 0,
        alpha: 1,
        anchorU: 0.5,
        anchorV: 1,
        clickable: true,
        draggable: true,
        flat: false,
      };
      try {
        await this.mapController.addMarker(markerOptions);
      } catch (err) {
        hilog.error(0x0000, TAG,
          `Failed to add marker. Cause code: ${err.code}, message: ${err.message}`);
      }
    }
  }
  // [End changeDestinationPositionMark]

  // [EndExclude mapOnclick]
  aboutToAppear(): void {
    // [StartExclude mapOnclick]
    // Map initialization parameter, which is used to set the coordinates and levels of the map center.
    this.mapOptions = {
      position: {
        target: {
          latitude: this.myLocation.latitude,
          longitude: this.myLocation.longitude
        },
        zoom: 15
      }
    };

    // [EndExclude mapOnclick]
    // Map initialization callback
    this.callback = async (err, mapController) => {
      if (!err) {
        // [StartExclude mapOnclick]
        // Obtains the controller class of the map, which is used to operate the map.
        this.mapController = mapController;
        this.mapEventManager = this.mapController.getEventManager();
        let mapLoadCallback = () => {
          hilog.info(0x0000, TAG, `on-mapLoad`);
        };
        // [EndExclude mapOnclick]
        let mapOnclickCallBack = async (position: mapCommon.LatLng) => {
          if (this.isStartNavigation) {
            // If the navigation has started, you are not allowed to click on the mobile phone.
            this.isBarShow = false;
          } else {
            // Send destination information to the watch for synchronization
            this.connectUtils.sendMessage(JSON.stringify(new CommunicationInformation(1, undefined, position)));
            // Modify destination_Position to trigger changeDestinationPositionMark
            // To refresh the destination mark on the map.
            this.destination_Position = position;
            this.isBarShow = true;
          }
        };
        this.mapEventManager.on('mapLoad', mapLoadCallback);
        this.mapEventManager.on('mapClick', mapOnclickCallBack);
      }
    };
    // Obtains the connected watch device and subscribes to the watch's message sending event.
    this.connectUtils.getConnectedDevices();
    // [Start notifyClient_init]
    try {
      this.connectUtils.notifyClient = wearEngine.getNotifyClient(this.getUIContext().getHostContext());
    } catch (err) {
      hilog.error(0x0000, TAG,
        `Failed to get notify client. Cause code: ${err.code}, message: ${err.message}`);
    }
    // [End notifyClient_init]
  }
  // [End mapOnclick]

  // This event is triggered each time the page is displayed
  // Including the routing process and application entering the foreground.
  // Only the customized component decorated by @Entry takes effect.
  onPageShow(): void {
    // Switch the map to the foreground
    if (this.mapController) {
      this.mapController.show();
    }
  }

  // This event is triggered each time a page is hidden
  // Including the routing process and application entering the background.
  // Only the customized component decorated by @Entry takes effect.
  onPageHide(): void {
    // Switch the map to the background.
    if (this.mapController) {
      this.mapController.hide();
    }
  }

  @Builder
  myBuilder() {
    Column() {
      Row() {
        // [Start route]
        Button($r('app.string.DrawRoute'))
          .width(158)
          .height(40)
          .onClick(async () => {
            let params: navi.RouteParams = {
              origins: [
                {
                  latitude: this.myLocation.latitude,
                  longitude: this.myLocation.longitude
                }
              ],
              destination: this.destination_Position,
              language: 'zh_CN'
            };
            const result = await navi.getWalkingRoutes(params);
            let drawRouteUtil: DrawRouteUtils = new DrawRouteUtils();
            // Draw a route on a map using navigation route information.
            drawRouteUtil.drawRoute(this.mapController, result.routes[0].steps[0].roads)
          })
          // [End route]
          .margin({ right: 16 })

        Button($r('app.string.Start_navigating'))
          .width(158)
          .height(40)
          .onClick(() => {
            // Modify isStartNavigation to trigger navigationStatusChange
            // To set the screen to steady on during navigation.
            this.isStartNavigation = true;
            this.connectUtils.notifyMessage();
            // Synchronize to the watch to start navigation signal.
            this.connectUtils.sendMessage(JSON.stringify(new CommunicationInformation(2, undefined, undefined)));
            // Send route navigation information to the watch periodically to simulate the real navigation process.
            this.routeInfomation.forEach((item, index) => {
              setTimeout(() => {
                this.connectUtils.sendMessage(JSON.stringify(new CommunicationInformation(0, item, undefined)));
              }, index * 5000);
            });
          })
      }
      .margin({ top: 24 })
    }
  }

  build() {
    Column() {
      Stack() {
        // Invoke the MapComponent component to initialize the map.
        MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
          .width('100%')
          .height('100%')
      }.height('100%')
    }
    .bindSheet($$this.isBarShow, this.myBuilder(), {
      height: 135,
      enableOutsideInteractive: true,
      showClose: false,
      onWillAppear: () => {
        hilog.info(0x0000, TAG, 'BindSheet onWillAppear.');
      },
      onAppear: () => {
        hilog.info(0x0000, TAG, 'BindSheet onAppear.');
      },
      onWillDisappear: () => {
        hilog.info(0x0000, TAG, 'BindSheet onWillDisappear.');
      },
      onDisappear: () => {
        hilog.info(0x0000, TAG, 'BindSheet onDisappear.');
      }
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height('100%')
  }
}