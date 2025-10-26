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

import { mapCommon } from '@kit.MapKit';
import { RouteInfomation } from './RouteInfomation';

// Information Entity Class Used in Interconnection Communication
export class CommunicationInformation {
  // Indicates the flag bit.
  tag: number;
  // Indicates navigation route information.
  routeInfomation?: RouteInfomation;
  // Indicates the destination location information.
  location?: mapCommon.LatLng;

  constructor(tag: number, routeInfomation?: RouteInfomation, location?: mapCommon.LatLng) {
    this.tag = tag;
    this.routeInfomation = routeInfomation;
    this.location = location;
  }
}