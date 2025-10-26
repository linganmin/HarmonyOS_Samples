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

import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';

const TAG: string = 'WindowUtil';

export class WindowUtil {
  private windowStage?: window.WindowStage;
  private mainWindowClass?: window.Window;

  static getInstance(): WindowUtil | undefined {
    if (!AppStorage.get<WindowUtil>('windowUtil')) {
      AppStorage.setOrCreate('windowUtil', new WindowUtil());
    } else {
      hilog.info(0x0000, TAG, '%{public}s', 'WindowUtil already exists.');
    }
    return AppStorage.get<WindowUtil>('windowUtil');
  }

  setWindowStage(windowStage: window.WindowStage): void {
    this.windowStage = windowStage;
    this.windowStage.getMainWindow((err, windowClass: window.Window) => {
      if (err.code) {
        hilog.error(0x0000, TAG, 'Failed to obtain the main window: ' + JSON.stringify(err));
        return;
      }
      this.mainWindowClass = windowClass;
    });
  }

  updateWidthBp(context: UIContext): void {
    try {
      let mainWindow: window.WindowProperties = this.mainWindowClass!.getWindowProperties();
      let windowWidth: number = mainWindow.windowRect.width;
      let windowWidthVp = context.px2vp(windowWidth);
      if (deviceInfo.deviceType === '2in1') {
        windowWidthVp -= 2 * 5.4;
      }
      let widthBp: string = '';
      if (windowWidthVp < 320) {
        widthBp = 'xs';
      } else if (windowWidthVp >= 320 && windowWidthVp < 600) {
        widthBp = 'sm';
      } else if (windowWidthVp >= 600 && windowWidthVp < 840) {
        widthBp = 'md';
      } else if (windowWidthVp >= 840 && windowWidthVp < 1440) {
        widthBp = 'lg';
      } else {
        widthBp = 'xl';
      }
      AppStorage.setOrCreate('currentWidthBreakpoint', widthBp);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `getWindowProperties failed, error code=${err.code}, message=${err.message}`);
    }
  }
}