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

// Defining city type classes.
export class CityType {
  public name: string;
  public city: string[];

  constructor(name: string, city: string[]) {
    this.name = name;
    this.city = city;
  }
}

// Defines the keyword city class.
export class CityGroup {
  public name: string;
  public city: string[];

  constructor(name: string, city: string[]) {
    this.name = name;
    this.city = city;
  }
}

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

// City list data.
export const CITY_DATA = [
  new CityType('A',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_A').id)),
  new CityType('B',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_B').id)),
  new CityType('C',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_C').id)),
  new CityType('D',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_D').id)),
  new CityType('E',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_E').id)),
  new CityType('F',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_F').id)),
  new CityType('G',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_G').id)),
  new CityType('H',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_H').id)),
  new CityType('J',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_J').id)),
  new CityType('K',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_K').id)),
  new CityType('L',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_L').id)),
  new CityType('M',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_M').id)),
  new CityType('N',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_N').id)),
  new CityType('P',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_P').id)),
  new CityType('Q',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_Q').id)),
  new CityType('R',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_R').id)),
  new CityType('S',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_S').id)),
  new CityType('T',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_T').id)),
  new CityType('W',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_W').id)),
  new CityType('X',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_X').id)),
  new CityType('Y',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_Y').id)),
  new CityType('Z',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_Z').id))
];

// Search for keywords and related city data.
export const ALL_CITY2 = [
  new CityGroup('a',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_A').id)),
  new CityGroup('an',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_an').id)),
  new CityGroup('b',
    uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.city_data_B').id)),
];

// Data of popular cities in China.
export const HOT_CITY =
  uiContext!.getHostContext()!.resourceManager.getStringArrayValueSync($r('app.strarray.hot_city').id);

// AlphabetIndexer Alphabetical index bar data.
export const TAB_VALUE =
  ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'W', 'X', 'Y', 'Z'];