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

import { RouteData } from '../model/RouteDataModel';

const LEFT_STATE: RouteData = {
  laneData: {
    laneNum: 1,
    lightTime: 90
  },
  distance: 800,
  roadName: $r('app.string.road_name')
};

const RIGHT_STATE: RouteData = {
  laneData: {
    laneNum: 2,
    lightTime: 90
  },
  distance: 800,
  roadName: $r('app.string.road_name')
};

let isLeftState: boolean = false;

export const getRouteData = (): RouteData => {
  isLeftState = !isLeftState;
  return isLeftState ? LEFT_STATE : RIGHT_STATE;
};