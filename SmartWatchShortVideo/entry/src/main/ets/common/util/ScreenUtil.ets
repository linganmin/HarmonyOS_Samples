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

import { common } from '@kit.AbilityKit';
import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'ScreenUtil';

export class ScreenUtil {
  public static changeScreenState(context: common.UIAbilityContext | undefined, state: boolean) {
    if (!context) {
      return;
    }
    try {
      let windowClass: window.Window | undefined = undefined;
      window.getLastWindow(context, (err: BusinessError, data) => {
        if (err.code) {
          hilog.error(0x0000, TAG, 'Failed to obtain the top window. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }
        windowClass = data;
        hilog.info(0x0000, TAG, 'Succeeded in obtaining the top window.');
        try {
          windowClass.setWindowKeepScreenOn(state, (err) => {
            if (err) {
              hilog.error(0x0000, TAG, 'Failed to set the state of screen. Cause: %{public}s',
                JSON.stringify(err) ?? '');
              return;
            }
            hilog.info(0x0000, TAG, 'Succeeded in setting the state of screen.');
          });
        } catch (exception) {
          hilog.error(0x0000, TAG, 'Failed to set the state of screen. Cause: %{public}s',
            JSON.stringify(exception) ?? '');
        }
      });
    } catch (exception) {
      hilog.error(0x0000, TAG, 'Failed to obtain the top window. Cause: %{public}s', JSON.stringify(exception) ?? '');
    }
  }

  public static getDeviceHeight(): number {
    let height = 0;
    try {
      let displayObject = display.getDefaultDisplaySync();
      let screenPixelHeight = displayObject.height;
      let screenDensityDPI = displayObject.densityDPI;
      height = screenPixelHeight * (160 / screenDensityDPI);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `getDefaultDisplaySync failed, error code=${err.code}, message=${err.message}`);
    }
    return height;
  }
}