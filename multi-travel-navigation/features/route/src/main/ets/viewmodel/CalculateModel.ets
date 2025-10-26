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

import { navi } from '@kit.MapKit';
import { Logger } from '@ohos/commons/Index';

export class CalculateModel {
  /**
   * Get the total duration of the route.
   * @param route
   * @returns
   */
  getTotalTime(route: navi.Route): number {
    if (route === undefined || route.steps === undefined) {
      return 0;
    }
    let time: number = 0;
    for (let index = 0; index < route.steps.length; index++) {
      if (route.steps[index] !== undefined && route.steps[index].duration !== undefined) {
        time += route.steps[index].duration!;
        Logger.info('Time is ' + time);
      }
    }
    return time / 60;
  }

  /**
   * Get the total distance of the route.
   * @param route
   * @returns
   */
  getTotalDistance(route: navi.Route): number {
    if (route === undefined || route.steps === undefined) {
      return 0;
    }
    let distance: number = 0;
    for (let index = 0; index < route.steps.length; index++) {
      if (route.steps[index] !== undefined && route.steps[index].distance !== undefined) {
        distance += route.steps[index].distance!;
        Logger.info('Distance is ' + distance);
      }
    }
    return distance / 1000;
  }
}