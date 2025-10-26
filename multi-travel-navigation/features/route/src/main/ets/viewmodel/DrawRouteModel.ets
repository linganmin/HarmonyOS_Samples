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

import { map, mapCommon, navi } from '@kit.MapKit';
import { Logger } from '@ohos/commons/Index';
import { BusinessError } from '@kit.BasicServicesKit';

export class DrawRouteModel {
  async drawRoute(mapController: map.MapComponentController | undefined, steps: Array<navi.RouteRoad>) {
    if (mapController === undefined) {
      Logger.info('Drawing failed');
      return;
    }
    let roads: Array<mapCommon.LatLng> = [];
    let start: mapCommon.LatLng = {
      latitude: steps[0].startLocation.latitude,
      longitude: steps[0].startLocation.longitude
    };

    let end: mapCommon.LatLng = {
      latitude: steps[steps.length - 1].endLocation.latitude,
      longitude: steps[steps.length - 1].endLocation.longitude
    };

    for (let index = 0; index < steps.length; index++) {
      for (let i = 0; i < steps[index].polyline.length; i++) {
        roads.push(steps[index].polyline[i]);
      }
    }

    let polylineOption: mapCommon.MapPolylineOptions = {
      points: roads,
      color: 0xFF089C57,
      jointType: mapCommon.JointType.ROUND,
      width: 24
    };
    this.addMarker(mapController, start).then(() => {
      this.addMarker(mapController, end).then(() => {
        mapController.addPolyline(polylineOption).then(() => {
          Logger.info('Drawing success');
        }).catch((err: BusinessError) => {
          Logger.error(`addPolyline failed, error code=${err.code}, message=${err.message}`);
        })
      });
    });
  }

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
      Logger.error(`addMarker failed, error code=${err.code}, message=${err.message}`);
    }
  }
}