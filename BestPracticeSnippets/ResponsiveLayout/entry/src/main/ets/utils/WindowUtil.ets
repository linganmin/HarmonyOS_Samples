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

import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants } from '../constants/CommonConstants';

@Observed
export class WindowUtil {
  private mainWindowClass?: window.Window;

  static getInstance(): WindowUtil | undefined {
    if (!AppStorage.get<WindowUtil>(CommonConstants.WINDOW_UTIL)) {
      AppStorage.setOrCreate(CommonConstants.WINDOW_UTIL, new WindowUtil());
    } else {
      hilog.info(0x0000, 'testTag', '%{public}s', `AppStorage does not have windowUtil.`);
    }
    return AppStorage.get<WindowUtil>(CommonConstants.WINDOW_UTIL);
  }

  setMainWindowOrientation(orientation: window.Orientation): void {
    // Setting orientation.
    this.mainWindowClass!.setPreferredOrientation(orientation)
      .then(() => {
        hilog.info(0x0000, 'testTag', '%{public}s', `Succeed in setting the orientation.`);
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag', `Failed to set the orientation. Code: ${err.code}, message: ${err.message}`,
          JSON.stringify(err) ?? '');
      });
  }

  disableWindowSystemBar(): void {
    // Set the status bar and navigation bar to be invisible in full-screen mode.
    this.mainWindowClass!.setWindowSystemBarEnable([])
      .then(() => {
        hilog.info(0x0000, 'testTag', '%{public}s', `Succeed in setting the window system bar disable.`);
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag',
          `Failed to set the window system bar disable. Code: ${err.code}, message: ${err.message}`,
          JSON.stringify(err) ?? '');
      });
  }

  enableWindowSystemBar(): void {
    this.mainWindowClass!.setWindowSystemBarEnable(['status', 'navigation'])
      .then(() => {
        hilog.info(0x0000, 'testTag', '%{public}s', `Succeed in setting the window system bar enable.`);
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag', `Failed to set the orientation. Code: ${err.code}, message: ${err.message}`,
          JSON.stringify(err) ?? '');
      });
  }

  recover(): void {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        if (this.mainWindowClass!.getWindowStatus() === window.WindowStatusType.FULL_SCREEN) {
          this.mainWindowClass!.recover()
            .then(() => {
              hilog.info(0x0000, 'testTag', '%{public}s', `Succeed in rovering the window.`);
            })
            .catch((err: BusinessError) => {
              hilog.error(0x0000, 'testTag', `Failed to rover the window. Code: ${err.code}, message: ${err.message}`,
                JSON.stringify(err) ?? '');
            });
        }
      } catch (error) {
        let err = error as BusinessError
        hilog.error(0x0000, 'testTag', `Failed to rover. Code: ${err.code}, message: ${err.message}`);
      }
    }
  }
}