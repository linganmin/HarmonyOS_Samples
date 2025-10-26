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

import { map, mapCommon, navi } from '@kit.MapKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { RouteInfomation } from 'communication';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'DrawRouteUtils';

// Navigation line drawing tool class
export class DrawRouteUtils {
  // [Start drawRoute]
  /*
   * Draw a navigation route on a map
   * The first parameter needs to be transferred to MapComponentController to operate the map.
   * The second parameter needs to pass in the navigation information to draw the navigation route.
   * @param mapController : map controller for drawing markers or routes on a map.
   * @param steps : Navigation route information obtained through the Map Kit
   */
  async drawRoute(mapController: map.MapComponentController | undefined, steps: Array<navi.RouteRoad>) {
    if (mapController === undefined) {
      hilog.info(0X0000, TAG, 'Drawing failed');
      return;
    }
    let roads: Array<mapCommon.LatLng> = [];
    let des_arr: RouteInfomation[] = [];
    for (let index = 0; index < steps.length; index++) {
      for (let i = 0; i < steps[index].polyline.length; i++) {
        roads.push(steps[index].polyline[i]);
        des_arr.push(new RouteInfomation(steps[index].action as string, steps[index].distance, steps[index].duration))
      }
    }

    // The route segment information is stored in the AppStorage and then sent to the watch through the WearEngine.
    AppStorage.setOrCreate('routeInfomation', des_arr);

    let polylineOption: mapCommon.MapPolylineOptions = {
      points: roads,
      color: 0xFF089C57,
      jointType: mapCommon.JointType.ROUND,
      width: 24
    };

    // Use MapComponentController to draw a route on a map
    mapController.addPolyline(polylineOption).catch((error: Error) => {
      let err = error as BusinessError;
      if (err.code) {
        hilog.error(0x0000, TAG,
          `Failed to add poly line. Cause code: ${err.code}, message: ${err.message}`);
      }
    }).then(() => {
      hilog.info(0X0000, TAG, 'Drawing success');
    });
  }
  // [End drawRoute]

  /*
   * Use MapComponentController to draw a route on a map.
   * @param mapController : map controller for drawing markers or routes on a map.
   * @param position : Indicates the longitude and latitude information of a marker, which is used to add a marker to the map.
   */
  async addMarker(mapController: map.MapComponentController, position: mapCommon.LatLng) {
    let markerOptions: mapCommon.MarkerOptions = {
      position: position,
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: false,
      draggable: false,
      flat: false
    };
    try {
      await mapController.addMarker(markerOptions);
    } catch (error) {
      let err = error as BusinessError;
      if (err.code) {
        hilog.error(0x0000, TAG,
          `Failed to add marker. Cause code: ${err.code}, message: ${err.message}`);
      }
    }
  }
}