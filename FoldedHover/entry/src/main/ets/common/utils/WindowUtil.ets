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

import { display, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants as Const } from '../CommonConstants';

const TAG: string = 'WINDOW_UTIL';

export class WindowUtil {
  private windowStage?: window.WindowStage;
  private mainWindowClass?: window.Window;

  static getInstance(): WindowUtil | undefined {
    if (!AppStorage.get<WindowUtil>(Const.WINDOW_UTIL)) {
      AppStorage.setOrCreate(Const.WINDOW_UTIL, new WindowUtil());
    } else {
      hilog.info(0x0000, TAG, 'AppStorage does not have windowUtil');
    }
    return AppStorage.get<WindowUtil>(Const.WINDOW_UTIL);
  }

  setWindowStage(windowStage: window.WindowStage): void {
    this.windowStage = windowStage;
    this.windowStage.getMainWindow((err, windowClass: window.Window) => {
      this.mainWindowClass = windowClass;
      if (err.code) {
        hilog.error(0x0000, TAG, `Failed to obtain the main window. Code:${err.code}, message:${err.message}`);
        return;
      }
    });
  }

  getTopHeight(uiContext: UIContext): undefined | number {
    if (this.mainWindowClass === undefined) {
      hilog.error(0x0000, TAG, 'MainWindowClass is undefined');
      return;
    }
    return uiContext.px2vp(this.mainWindowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height);
  }

  getBottomHeight(uiContext: UIContext): undefined | number {
    if (this.mainWindowClass === undefined) {
      hilog.error(0x0000, TAG, 'MainWindowClass is undefined');
      return -1;
    }
    return uiContext.px2vp(this.mainWindowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      .bottomRect
      .height);
  }

  setMainWindowOrientation(orientation: window.Orientation): void {
    if (this.mainWindowClass === undefined) {
      hilog.error(0x0000, TAG, 'MainWindowClass is undefined');
      return;
    }
    if (this.getMainWindowOrientation() === orientation) {
      return;
    }
    // Setting orientation.
    this.mainWindowClass.setPreferredOrientation(orientation).then(() => {
      hilog.info(0x0000, TAG, 'orientation to ' + orientation.toString());
    })
  }

  getMainWindowOrientation(): window.Orientation {
    if (this.mainWindowClass === undefined) {
      hilog.error(0x0000, TAG, 'MainWindowClass is undefined');
      return 0;
    }
    // Setting orientation.
    return this.mainWindowClass.getPreferredOrientation();
  }

  disableWindowSystemBar(): void {
    if (this.mainWindowClass === undefined) {
      hilog.error(0x0000, TAG, 'MainWindowClass is undefined');
      return;
    }
    // Set the status bar and navigation bar to be invisible in full-screen mode.
    this.mainWindowClass.setWindowSystemBarEnable([]);
  }

  enableWindowSystemBar(): void {
    if (this.mainWindowClass === undefined) {
      hilog.error(0x0000, TAG, 'MainWindowClass is undefined');
      return;
    }
    this.mainWindowClass.setWindowSystemBarEnable(['status', 'navigation']);
  }

  setFullScreen(): void {
    if (this.mainWindowClass === undefined) {
      hilog.error(0x0000, TAG, 'MainWindowClass is undefined');
      return;
    }
    // Set full-screen display.
    this.mainWindowClass.setWindowLayoutFullScreen(true);
  }

  getMainWindow(): window.Window | undefined {
    return this.mainWindowClass;
  }

  offWindowSizeChange(): void {
    if (this.mainWindowClass === undefined) {
      hilog.error(0x0000, TAG, 'MainWindowClass is undefined');
      return;
    }
    this.mainWindowClass?.off('windowSizeChange');
  }


  updateHeightBp(): void {
    let mainWindow: window.WindowProperties = this.mainWindowClass!.getWindowProperties();
    let windowHeight: number = mainWindow.windowRect.height;
    let windowWidth: number = mainWindow.windowRect.width;
    let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels;
    let windowHeightVp = windowHeight / display.getDefaultDisplaySync().densityPixels;
    let heightBp: string = '';
    let aspectRatio: number = windowHeightVp / windowWidthVp;
    if (aspectRatio < 0.8) {
      heightBp = 'sm';
    } else if (aspectRatio >= 0.8 && aspectRatio < 1.2) {
      heightBp = 'md';
    } else {
      heightBp = 'lg';
    }
    AppStorage.setOrCreate('currentHeightBreakpoint', heightBp);
  }

  updateWidthBp(): void {
    let mainWindow: window.WindowProperties = this.mainWindowClass!.getWindowProperties();
    let windowWidth: number = mainWindow.windowRect.width;
    let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels;
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
  }
}