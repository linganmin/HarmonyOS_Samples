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

import { BusStationModel } from '../model/BusStationModel';

export class BusStationViewModel {
  public getNearbyBusStation(): Array<BusStationModel> {
    let nearbyBusStation: Array<BusStationModel> = [];
    const busStation1: BusStationModel = new BusStationModel('0', $r('app.string.bus_station_name'),
      [$r('app.string.station_1'), $r('app.string.station_2')]);
    const busStation2: BusStationModel = new BusStationModel('1', $r('app.string.bus_station_name_1'),
      [$r('app.string.station_1'), $r('app.string.station_2')]);
    const busStation3: BusStationModel = new BusStationModel('2', $r('app.string.bus_station_name_2'),
      [$r('app.string.station_1'), $r('app.string.station_2')]);
    nearbyBusStation.push(busStation1);
    nearbyBusStation.push(busStation2);
    nearbyBusStation.push(busStation3);
    return nearbyBusStation;
  }
  
  public getNowBusDes(): Array<BusStationModel> {
    let nowBusStation: Array<BusStationModel> = [];
    const busStation1: BusStationModel = new BusStationModel('0', $r('app.string.bus_station_name'),
      [$r('app.string.station_1'), $r('app.string.station_2')]);
    const busStation2: BusStationModel = new BusStationModel('1', $r('app.string.bus_station_name_1'),
      [$r('app.string.station_1'), $r('app.string.station_2')]);
    nowBusStation.push(busStation1);
    nowBusStation.push(busStation2);
    return nowBusStation;
  }
}