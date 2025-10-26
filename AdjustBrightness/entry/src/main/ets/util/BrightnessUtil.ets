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

import { hilog } from '@kit.PerformanceAnalysisKit';
import Constants from '../commom/Constants';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'BrightnessUtil';

export default class BrightnessUtil {
  private static readonly DEFAULT_BRIGHTNESS: number = -1;
  private static readonly MAX_BRIGHTNESS: number = 1;
  private static windowClass: window.Window | undefined = undefined;
  // [Start brightness_map]
  private static brightnessMap: Map<string, number> =
    new Map([[Constants.NAV_DESTINATION_DEFAULT, this.DEFAULT_BRIGHTNESS],
      [Constants.NAV_DESTINATION_ITEM_PAY_CODE, this.MAX_BRIGHTNESS]]);
  // [End brightness_map]

  /**
   * init windowClass
   *
   * @param windowClass Window object
   */
  public static initWindow(windowClass: window.Window) {
    BrightnessUtil.windowClass = windowClass;
  }

  // [Start updateVideo_brightness]
  /**
   * Video playback page brightness adjustment execution function
   *
   * @param brightness Brightness value
   */
  public static updateVideoBrightness(brightness: number): void {
    BrightnessUtil.setBrightness(brightness, Constants.SET_BRIGHTNESS_SLIDE);
    BrightnessUtil.brightnessMap.set(Constants.NAV_DESTINATION_ITEM_VIDEO, brightness);
  }
  // [End updateVideo_brightness]

  /**
   * Set brightness
   *
   * @param brightness Page key cached in brightness map | brightness
   * @param setMode There are two modes for setting brightness based on business differentiation.
   * 0: Enter the page or return to the homepage to set the brightness once, and read the page brightness from the map;
   * 1: Continuous sliding adjustment of brightness on video page
   */
  public static setBrightness(brightness: string | number, setMode: number): void {
    try {
      if (setMode === Constants.SET_BRIGHTNESS_CLICK) {
        BrightnessUtil.windowClass?.setWindowBrightness(BrightnessUtil.brightnessMap.get(brightness as string));
      } else {
        BrightnessUtil.windowClass?.setWindowBrightness(brightness as number);
      }
    } catch (err) {
      hilog.error(0x0000, TAG, `Failed Set brightness, errorCode: ${err.code}`);
    }
  }

  // [Start set_window_keep_screen_state]
  /**
   * Keep screen brightness
   *
   * @param isKeepOn true：keep；false:cancel keep
   */
  public static setWindowKeepScreenState(isKeepOn: boolean): void {
    try {
      BrightnessUtil.windowClass?.setWindowKeepScreenOn(isKeepOn, (err: BusinessError) => {
        const errCode: number = err.code;
        if (errCode) {
          hilog.error(0x0000, TAG, `Failed set window keep screen state, errorCode: ${err.code}`);
          return;
        }
        hilog.info(0x0000, TAG, `Success set window keep screen state`);
      });
    } catch (err) {
      hilog.error(0x0000, TAG, `Failed set window keep screen state, errorCode: ${err.code}`);
    }
  }
  // [End set_window_keep_screen_state]

  /**
   * Set the font color of the status bar
   *
   * @param name Page name
   * @param colorRes Font color of status bar
   */
  public static setStateBarContentColor(name: string, colorRes: string): void {
    if (name !== Constants.NAV_DESTINATION_ITEM_PAY_CODE) {
      return;
    }
    let sysBarPros: window.SystemBarProperties = {
      statusBarContentColor: colorRes
    }
    try {
      BrightnessUtil.windowClass?.setWindowSystemBarProperties(sysBarPros).then(() => {
        hilog.info(0x0000, TAG, `Success set window systemBar content color`);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `Failed set window systemBar content color, errorCode:${err.code}`);
      })
    } catch (err) {
      hilog.error(0x0000, TAG, `Success set window systemBar content color, errorCode:${err.code}`);
    }
  }
}