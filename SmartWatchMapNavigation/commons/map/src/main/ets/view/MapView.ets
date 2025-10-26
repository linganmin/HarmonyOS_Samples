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

import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommunicationInformation, CommunicationUtils } from 'communication';

const TAG = 'MapView';

// Map view
@Component
export struct MapView {
  // Update the destination location based on the map click event.
  // After the value is updated, the changeDestinationPositionMark method is triggered to update the map mark.
  @StorageLink('destination_Position') @Watch('changeDestinationPositionMark') destination_Position: mapCommon.LatLng =
    {
      longitude: 0,
      latitude: 0
    };
  // Obtains the current location based on the location.
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
  @State mapOptions: mapCommon.MapOptions | undefined = undefined;
  // Communication entity class object
  private connectUtils: CommunicationUtils = new CommunicationUtils(this.getUIContext().getHostContext() as Context);
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;

  /*
   * Refresh Map Destination Markers.
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
        flat: false
      };
      try {
        await this.mapController.addMarker(markerOptions);
      } catch (error) {
        let err = error as BusinessError
        if (err.code) {
        hilog.error(0x0000, TAG,
          `Failed to add marker. Cause code: ${err.code}, message: ${err.message}`);
        }
      }
    }
  }

  aboutToAppear(): void {
    this.mapOptions = {
      position: {
        target: {
          latitude: this.myLocation.latitude,
          longitude: this.myLocation.longitude
        },
        zoom: 15
      }
    };

    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapEventManager = this.mapController.getEventManager();
        let callback = () => {
          hilog.info(0x0000, TAG, `on-mapLoad`);
        }
        // Map click callback to send the destination location
        // to the peer end for synchronizing the destination location.
        let mapOnclickCallBack = async (position: mapCommon.LatLng) => {
          this.connectUtils.sendMessage(JSON.stringify(new CommunicationInformation(1, undefined, position)));
          this.destination_Position = position;
        };
        this.mapEventManager.on('mapLoad', callback);
        this.mapEventManager.on('mapClick', mapOnclickCallBack);
      }
    };
    this.connectUtils.getConnectedDevices();
  }

  onPageShow(): void {
    if (this.mapController) {
      this.mapController?.show();
    }
  }

  onPageHide(): void {
    if (this.mapController) {
      this.mapController.hide();
    }
  }

  build() {
    Column() {
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
        .width('100%')
        .height('100%');
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height('100%')
  }
}
