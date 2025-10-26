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

import { window } from "@kit.ArkUI";
import { CommonConstants } from "../constant/CommonConstants";
import Logger from "./Logger";
import { deviceInfo } from "@kit.BasicServicesKit";

@Observed
export class WindowUtil {
  private windowStage?: window.WindowStage;
  private mainWindowClass?: window.Window;

  static getInstance(): WindowUtil | undefined {
    if (!AppStorage.get<WindowUtil>(CommonConstants.WINDOW_UTIL)) {
      AppStorage.setOrCreate(CommonConstants.WINDOW_UTIL, new WindowUtil());
    } else {
      Logger.info('AppStorage does not have windowUtil');
    }
    return AppStorage.get<WindowUtil>(CommonConstants.WINDOW_UTIL);
  }

  setWindowStage(windowStage: window.WindowStage): void {
    this.windowStage = windowStage;
  }

  setMainWindowPortrait(): void {
    if (this.windowStage === undefined) {
      Logger.error('windowStage is undefined');
      return;
    }
    this.windowStage.getMainWindow((err, windowClass: window.Window)=> {
      this.mainWindowClass = windowClass;
      if (err.code) {
        Logger.error(`Failed to obtain the main window, Code: ${err.code}, message: ${err.message}`);
        return;
      }
      if (deviceInfo.deviceType !== CommonConstants.DEVICE_TYPES[0]
        && deviceInfo.deviceType !== CommonConstants.DEVICE_TYPES[1]) {
        this.mainWindowClass.setPreferredOrientation(window.Orientation.PORTRAIT);
      }
    });
  }

  setMainWindowOrientation(orientation: window.Orientation): void {
    if (this.mainWindowClass === undefined) {
      Logger.error('mainWindowClass is undefined');
      return;
    }
    this.mainWindowClass.setPreferredOrientation(orientation);
  }

  disableWindowSystemBar(): void {
    if (this.mainWindowClass === undefined) {
      Logger.error('mainWindowClass is undefined');
      return;
    }
    this.mainWindowClass.setWindowSystemBarEnable([]);
  }

  enableWindowSystemBar(): void {
    if (this.mainWindowClass === undefined) {
      Logger.error('mainWindowClass is undefined');
      return;
    }
    this.mainWindowClass.setWindowSystemBarEnable(['status', 'navigation']);
  }

  getMainWindow(): window.Window | undefined {
    return this.mainWindowClass;
  }

  offWindowSizeChange(): void {
    if (this.mainWindowClass === undefined) {
      Logger.error('mainWindowClass is undefined');
      return;
    }
    this.mainWindowClass.off('windowSizeChange');
  }
}