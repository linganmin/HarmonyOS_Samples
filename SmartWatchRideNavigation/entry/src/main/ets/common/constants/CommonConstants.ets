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

import { LocationInfo } from '../../model/LocationInfo';
import { RouteInformation } from '../../model/RouteInfo';

export class CommonConstants {
  /**
   * Search results informations.
   */
  static readonly RESULT: LocationInfo[] = [
    new LocationInfo($r('app.string.search_result_one'), '6.4km  xxxx'),
    new LocationInfo($r('app.string.search_result_two'), '6.4km  xxxx'),
    new LocationInfo($r('app.string.search_result_three'), '6.4km  xxxx'),
    new LocationInfo($r('app.string.search_result_four'), '6.4km  xxxx'),
    new LocationInfo($r('app.string.search_result_five'), '6.4km  xxxx'),
    new LocationInfo($r('app.string.search_result_six'), '6.4km  xxxx'),
    new LocationInfo($r('app.string.search_result_seven'), '6.4km  xxxx'),
    new LocationInfo($r('app.string.search_result_eight'), '6.4km  xxxx'),
    new LocationInfo($r('app.string.search_result_nine'), '6.4km  xxxx'),
    new LocationInfo($r('app.string.search_result_ten'), '6.4km  xxxx')
  ];
  /**
   * Route information.
   */
  static readonly ROUTES: RouteInformation[] = [
    new RouteInformation($r('app.string.route_information_duration'), $r('app.string.route_information_distance'), 1,
      $r('app.string.route_information_description')),
    new RouteInformation($r('app.string.route_information_duration'), $r('app.string.route_information_distance'), 2,
      $r('app.string.route_information_description')),
    new RouteInformation($r('app.string.route_information_duration'), $r('app.string.route_information_distance'), 3,
      $r('app.string.route_information_description')),
    new RouteInformation($r('app.string.route_information_duration'), $r('app.string.route_information_distance'), 4,
      $r('app.string.route_information_description')),
    new RouteInformation($r('app.string.route_information_duration'), $r('app.string.route_information_distance'), 5,
      $r('app.string.route_information_description')),
    new RouteInformation($r('app.string.route_information_duration'), $r('app.string.route_information_distance'), 6,
      $r('app.string.route_information_description')),
    new RouteInformation($r('app.string.route_information_duration'), $r('app.string.route_information_distance'), 7,
      $r('app.string.route_information_description')),
    new RouteInformation($r('app.string.route_information_duration'), $r('app.string.route_information_distance'), 8,
      $r('app.string.route_information_description'))
  ];
}