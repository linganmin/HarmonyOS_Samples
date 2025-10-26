/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the 'License');
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an 'AS IS' BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
export class CommonConstants {
  /**
   * locatingTimeoutMs
   */
  static LOCATING_TIMEOUT_MS: number = 10000;

  /**
   * locatingPriority
   */
  static PRIORITY_LOCATING_SPEED: number = 0x502;

  /**
   * locationScenario
   */
  static NAVIGATION: number = 0x401;

  /**
   * locationSwitch
   */
  static LOCATION_SWITCH_OFF: number = 3301100;

  /**
   * locationFail
   */
  static LOCATION_FAILED: number = 3301200;

  /**
   * reverseGeocodingFailed
   */
  static REVERSE_GEOCODING_FAILED: number = 3301300;

  /**
   * reverseGeocodingFailed
   */
  static WIFI_BLUETOOTH_OFF: number = 3301800;

  /**
   * Information Window Title
   */
  static MARKER_TITLE: (uiContext: UIContext) => string = (uiContext: UIContext) =>
    uiContext.getHostContext()!.resourceManager.getStringByNameSync('geocoded_location');
}