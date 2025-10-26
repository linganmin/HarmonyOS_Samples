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

import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { CameraUtil } from '../utils/CameraUtil';
import { WindowUtil } from '../utils/WindowUtil';

const DOMAIN = 0x0000;

// [Start WindowSizeChange]
export default class EntryAbility extends UIAbility {
  // [StartExclude WindowSizeChange]
  windowData?: window.Window;
  uiContext?: UIContext;
  cameraUtil?: CameraUtil;
  windowUtil?: WindowUtil;
  // [EndExclude WindowSizeChange]
  isFirstTime: boolean = true;
  // [Start Bp2]
  onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    // [StartExclude WindowSizeChange]
    this.setOrientation(this.uiContext!.px2vp(windowSize.width), this.uiContext!.px2vp(windowSize.height));
    // [StartExclude Bp2]
    AppStorage.setOrCreate('windowSize', windowSize);
    let widthBp: WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
    AppStorage.setOrCreate('widthBp', widthBp);
    let heightBp: HeightBreakpoint = this.uiContext!.getWindowHeightBreakpoint();
    AppStorage.setOrCreate('heightBp', heightBp);
    let displayOrientation: display.Orientation = display.getDefaultDisplaySync().orientation;
    AppStorage.setOrCreate('displayOrientation', displayOrientation);
    // [EndExclude WindowSizeChange]
    if (!this.isFirstTime) {
      this.cameraUtil!.setXComponentRect(this.windowUtil!.getWindowSize());
    } else {
      this.isFirstTime = false;
    }
    // [EndExclude Bp2]
  }
  // [StartExclude WindowSizeChange]

  setOrientation(width: number, height: number): void {
    // When the minimum value of window width and height is greater than the md breakpoint threshold, rotation is supported.
    if (Math.min(width, height) >= 600) {
      this.windowData?.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED).catch((error: BusinessError) => {
        hilog.error(0x0000, `MultiDeviceCamera`,
          `Set window orientation failed. Code: ${error.code}, message: ${error.message}`);
      });
    } else {
      this.windowData?.setPreferredOrientation(window.Orientation.PORTRAIT).catch((error: BusinessError) => {
        hilog.error(0x0000, `MultiDeviceCamera`,
          `Set window orientation failed. Code: ${error.code}, message: ${error.message}`);
      });
    }
  }

  // [StartExclude Bp2]
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'MultiDeviceCamera', `Failed to set color mode. Code: ${err.code}, message: ${err.message}`);
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  // [EndExclude Bp2]
  // [EndExclude WindowSizeChange]
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // [StartExclude Bp2]
    // [StartExclude WindowSizeChange]
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    AppStorage.setOrCreate('cameraUtil', new CameraUtil());
    this.cameraUtil = AppStorage.get<CameraUtil>('cameraUtil');
    AppStorage.setOrCreate('windowUtil', new WindowUtil());
    this.windowUtil = AppStorage.get<WindowUtil>('windowUtil');
    this.windowUtil!.setWindowStage(windowStage);
    // [EndExclude WindowSizeChange]
    // [EndExclude Bp2]
    windowStage.loadContent('pages/Index', (err) => {
      // [StartExclude Bp2]
      // [StartExclude WindowSizeChange]
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      // [EndExclude Bp2]
      // [EndExclude WindowSizeChange]
      windowStage.getMainWindow().then((data: window.Window) => {
        // [StartExclude Bp2]
        // [StartExclude WindowSizeChange]
        this.windowData = data;
        data.setWindowLayoutFullScreen(true);
        data.setWindowSystemBarEnable([]);
        this.uiContext = data.getUIContext();
        // Obtain the crease area of the folding screen.
        this.windowUtil!.getFoldCreaseRegion(this.uiContext);
        let windowSize: window.Size = {
          width: data.getWindowProperties().windowRect.width,
          height: data.getWindowProperties().windowRect.height
        };
        AppStorage.setOrCreate('windowSize', windowSize);
        // First time obtaining breakpoint and screen display orientation.
        let widthBp: WidthBreakpoint = this.uiContext.getWindowWidthBreakpoint();
        let heightBp: HeightBreakpoint = this.uiContext.getWindowHeightBreakpoint();
        AppStorage.setOrCreate('widthBp', widthBp);
        AppStorage.setOrCreate('heightBp', heightBp);
        let displayOrientation: display.Orientation = display.getDefaultDisplaySync().orientation;
        AppStorage.setOrCreate('displayOrientation', displayOrientation);
        AppStorage.setOrCreate('isBackground', false);
        // [EndExclude Bp2]
        // [EndExclude WindowSizeChange]
        // Monitor window size changes and update breakpoints.
        data.on('windowSizeChange', this.onWindowSizeChange);
        // [StartExclude WindowSizeChange]
        let rect: window.Rect = data.getWindowProperties().windowRect;
        this.setOrientation(this.uiContext.px2vp(rect.width), this.uiContext.px2vp(rect.height));
        // [EndExclude WindowSizeChange]
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag', `Error occured, error code: ${err.code}, error message: ${err.message}`);
      })
    });
  }
  // [StartExclude WindowSizeChange]
  // [End Bp2]

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }
  // [EndExclude WindowSizeChange]
}
// [End WindowSizeChange]