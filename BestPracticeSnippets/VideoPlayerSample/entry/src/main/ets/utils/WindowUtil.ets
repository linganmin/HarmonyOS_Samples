/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import { Logger } from '@ohos/MediaService';
import { BusinessError } from '@kit.BasicServicesKit';
import { BreakpointSystem } from './BreakpointSystem';

const TAG: string = '[WindowUtil]';


export class WindowUtil {
  private static instance: WindowUtil;
  private windowStage?: window.WindowStage;
  private mainWindowClass?: window.Window;

  public static getInstance(): WindowUtil {
    if (!WindowUtil.instance) {
      WindowUtil.instance = new WindowUtil();
    }
    return WindowUtil.instance;
  }

  // [Start set_stage1]
  public setWindowStage(windowStage: window.WindowStage): void {
    const uiContext: UIContext | undefined = AppStorage.get('uiContext');
    this.windowStage = windowStage;
    this.windowStage.getMainWindow((err, windowClass: window.Window) => {
      // [StartExclude set_stage1]
      if (err.code) {
        Logger.error(TAG, `Failed to obtain the main window. Code:${err.code}, message:${err.message}`);
        return;
      }
      // [EndExclude set_stage1]
      this.mainWindowClass = windowClass;
      try {
        const properties: window.WindowProperties = windowClass.getWindowProperties(); // Get window information
        // [StartExclude set_stage1]
        // Get status bar height.
        let area: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        let naviBarArea: window.AvoidArea =
          windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        // [EndExclude set_stage1]
        AppStorage.setOrCreate('deviceWidth', properties.windowRect.width); // Set the window width
        AppStorage.setOrCreate('deviceHeight', properties.windowRect.height); // Set the window height
        // [StartExclude set_stage1]
        AppStorage.setOrCreate('statusBarHeight', uiContext?.px2vp(area.topRect.height));
        AppStorage.setOrCreate('navBarHeight', uiContext?.px2vp(naviBarArea.bottomRect.height));
        windowClass.on('windowSizeChange', () => BreakpointSystem.getInstance().onWindowSizeChange(windowClass));
        windowClass.on('avoidAreaChange', (avoidAreaOption) => {
          WindowUtil.setAvoidArea(avoidAreaOption.type, avoidAreaOption.area);
        });
        // [EndExclude set_stage1]
      } catch (error) {
        Logger.error(TAG, `setWindowStage getWindowProperties failed. Code:${err.code}, message:${err.message}`);
      }
    });
  }
  // [End set_stage1]

  // Get status bar height and indicator height.
  public static setAvoidArea(type: window.AvoidAreaType, area: window.AvoidArea): void {
    const uiContext: UIContext = AppStorage.get<UIContext>('uiContext')!;
    if (type === window.AvoidAreaType.TYPE_SYSTEM) {
      AppStorage.setOrCreate('statusBarHeight', uiContext?.px2vp(area.topRect.height));
    } else {
      AppStorage.setOrCreate('navBarHeight',  uiContext?.px2vp(area.bottomRect.height));
    }
  }

  // [Start set_main]
  // Select the corresponding parameters according to the rotation strategy of the application itself.
  setMainWindowOrientation(orientation: window.Orientation, callback?: Function): void {
    // [StartExclude set_main]
    if (this.mainWindowClass === undefined) {
      Logger.error(`MainWindowClass is undefined`);
      return;
    }
    // Setting orientation.
    // [EndExclude set_main]
    this.mainWindowClass.setPreferredOrientation(orientation).then(() => {
      callback?.();
    }).catch((err: BusinessError) => {
      Logger.error(`Failed to set the ${orientation} of main window. Code:${err.code}, message:${err.message}`);
    });
  }
  // [End set_main]

  disableWindowSystemBar(): void {
    if (this.mainWindowClass === undefined) {
      Logger.error(`MainWindowClass is undefined`);
      return;
    }
    // Set the status bar and navigation bar to be invisible in full-screen mode.
    this.mainWindowClass.setWindowSystemBarEnable([]).catch((err: BusinessError) => {
      Logger.error(TAG, `disableWindowSystemBar failed, err.code:${err.code}, err.message:${err.message}`);
    });
  }

  enableWindowSystemBar(): void {
    if (this.mainWindowClass === undefined) {
      Logger.error(`MainWindowClass is undefined`);
      return;
    }
    this.mainWindowClass.setWindowSystemBarEnable(['status', 'navigation']).catch((err: BusinessError) => {
      Logger.error(TAG, `enableWindowSystemBar failed, err.code:${err.code}, err.message:${err.message}`);
    });
  }

  setLandscapeMultiWindow(enable: boolean): void {
    if (this.mainWindowClass === undefined) {
      Logger.error(`MainWindowClass is undefined`);
      return;
    }
    if (enable) {
      this.mainWindowClass?.enableLandscapeMultiWindow().catch((err: BusinessError) => {
        Logger.error(TAG, `enableLandscapeMultiWindow failed, err.code:${err.code}, err.message:${err.message}`);
      });
    } else {
      this.mainWindowClass?.disableLandscapeMultiWindow().catch((err: BusinessError) => {
        Logger.error(TAG, `disableLandscapeMultiWindow failed, err.code:${err.code}, err.message:${err.message}`);
      });
    }
  }
  // [Start size_change]
  // [Start about_appear]
  registerOnWindowSizeChange(callback?: (size: window.Size) => void): void {
    // [StartExclude about_appear]
    // [StartExclude size_change]
    if (this.mainWindowClass === undefined) {
      Logger.error(`MainWindowClass is undefined`);
      return;
    }
    // [StartExclude about_appear]
    // [EndExclude size_change]
    this.mainWindowClass.on('windowSizeChange', (size) => {
      //Because the real width of the application window is the screen width in the mobile phone, there is no need to change the width.
      AppStorage.setOrCreate('deviceHeight', size.height);
      callback?.(size);
    });
  }
  // [End about_appear]
  // [End size_change]

  registerOffWindowSizeChange(): void {
    if (this.mainWindowClass === undefined) {
      Logger.error(`MainWindowClass is undefined`);
      return;
    }
    this.mainWindowClass.off('windowSizeChange');
  }
}