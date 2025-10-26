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
import { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';

export class MapUtil {
  public static initializeMapWithLocation(mapController: map.MapComponentController): void {
    mapController?.setMyLocationEnabled(true);
    mapController?.setMyLocationControlsEnabled(true);
    let requestInfo: geoLocationManager.CurrentLocationRequest = {
      'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
      'scenario': geoLocationManager.LocationRequestScenario.UNSET,
      'maxAccuracy': 0
    };
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
      mapController?.moveCamera(cameraUpdate);
    })
  }

  // [Start walking_routes]
  public static async walkingRoutes(position: mapCommon.LatLng, myPosition?: mapCommon.LatLng) {
    let params: navi.RouteParams = {
      origins: [myPosition!],
      destination: position,
      language: 'zh_CN'
    };
    try {
      const result = await navi.getWalkingRoutes(params);
      Logger.info('naviDemo', 'getWalkingRoutes success result =' + JSON.stringify(result));
      return result;
    } catch (err) {
      Logger.error('naviDemo', 'getWalkingRoutes fail err =' + JSON.stringify(err));
    }
    return undefined;
  }

  // [End walking_routes]
  // [Start paint_route]
  public static async paintRoute(routeResult: navi.RouteResult, mapPolyline?: map.MapPolyline,
    mapController?: map.MapComponentController) {
    mapPolyline?.remove();
    let polylineOption: mapCommon.MapPolylineOptions = {
      points: routeResult.routes[0].overviewPolyline!,
      clickable: true,
      startCap: mapCommon.CapStyle.BUTT,
      endCap: mapCommon.CapStyle.BUTT,
      geodesic: false,
      jointType: mapCommon.JointType.BEVEL,
      visible: true,
      width: 20,
      zIndex: 10,
      gradient: false,
      color: 0xFF2970FF
    }
    mapPolyline = await mapController?.addPolyline(polylineOption);
  }

  // [End paint_route]

  public static async addMarker(position: mapCommon.LatLng,
    mapController?: map.MapComponentController): Promise<map.Marker | undefined> {
    let markerOptions: mapCommon.MarkerOptions = {
      position: position,
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.35,
      anchorV: 1,
      clickable: true,
      draggable: true,
      flat: false
    };
    return await mapController?.addMarker(markerOptions);
  }

  public static async checkPermissions(mapController?: map.MapComponentController): Promise<boolean> {
    const permissions: Permissions[] = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];
    for (let permission of permissions) {
      let grantStatus: abilityAccessCtrl.GrantStatus = await MapUtil.checkAccessToken(permission);
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        mapController?.setMyLocationEnabled(true);
        mapController?.setMyLocationControlsEnabled(true);
        return true;
      }
    }
    return false;
  }

  public static async checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }

    return grantStatus;
  }
}