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

import { mapCommon, site, navi, map } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { i18n } from '@kit.LocalizationKit';
import { Common, Logger } from '@ohos/commons/Index';
import { CommonConstants } from '@ohos/commons/src/main/ets/constants/CommonConstants';

export class SearchSiteModel {
  /**
   * Search for nearby locations based on the input location.
   * @param position
   * @param text
   * @returns
   */
  async getNearByLocation(position: mapCommon.LatLng, text: string): Promise<site.NearbySearchResult | undefined> {
    let params: site.NearbySearchParams = {
      location: position,
      language: CommonConstants.languageMap.get(i18n.System.getSystemLanguage()),
      radius: 10000,
      query: text
    };
    let result: site.NearbySearchResult | undefined = undefined;
    try {
      result = await site.nearbySearch(params);
      Logger.info('NearbySearch success, result = ' + JSON.stringify(result));
    } catch (err) {
      Logger.error('NearbySearch fail, err = ' + JSON.stringify(err));
    }
    return result;
  }

  /**
   * Plan driving route.
   * @param beginPoint
   * @param terminalPoint
   * @returns
   */
  async getDrivingRoutes(beginPoint: geoLocationManager.Location, terminalPoint: site.Site): Promise<navi.RouteResult | undefined> {
    if (!terminalPoint || !terminalPoint.location) {
      return undefined;
    }

    let origin: mapCommon.LatLng = {
      latitude: beginPoint.latitude,
      longitude: beginPoint.longitude
    };

    let originPosition: mapCommon.LatLng =
      map.convertCoordinateSync(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, origin);

    let params: navi.DrivingRouteParams = {
      origins: [
        originPosition
      ],
      destination: {
        latitude: terminalPoint.location.latitude,
        longitude: terminalPoint.location.longitude
      },
      language: CommonConstants.languageMap.get(i18n.System.getSystemLanguage()),
      alternatives: true,
      avoids: Common.AVOIDS
    };

    let result: navi.RouteResult | undefined = undefined;
    try {
      result = await navi.getDrivingRoutes(params);
      Logger.info('Driving routes plan success, result = ' + JSON.stringify(result));
    } catch (err) {
      Logger.error('Driving routes plan fail, err = ' + JSON.stringify(err));
    }
    return result;
  }
}