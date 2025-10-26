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
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowUtil } from '../utils/WindowUtils';
import { CommonConstants } from '../constants/CommonConstants';

// [Start get_avoid]
export default class EntryAbility extends UIAbility {
  private uiContext ?: UIContext;
  private windowUtil?: WindowUtil = WindowUtil.getInstance();
  private windowObj?: window.Window;
  private onAvoidAreaChange: (avoidArea: window.AvoidAreaOptions) => void = (avoidArea: window.AvoidAreaOptions) => {
    if (avoidArea.type === window.AvoidAreaType.TYPE_SYSTEM) {
      AppStorage.setOrCreate('topAvoidHeight', this.windowObj!.getUIContext().px2vp(avoidArea.area.topRect.height));
    } else if (avoidArea.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
      AppStorage.setOrCreate('bottomAvoidHeight', this.windowObj!.getUIContext().px2vp(avoidArea.area.bottomRect.height));
    }
  };
  // [StartExclude get_avoid]
  // [Start fold_window]
  private onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    AppStorage.setOrCreate('currentWidthBreakpoint', this.uiContext!.getWindowWidthBreakpoint());
    AppStorage.setOrCreate('currentHeightBreakpoint', this.uiContext!.getWindowHeightBreakpoint());
  };
  // [End fold_window]

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TestLog', `Failed to set color mode. Code: ${err.code}, message: ${err.message}`);
    }
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  // [EndExclude get_avoid]
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    this.windowUtil?.setWindowStage(windowStage);

    // [StartExclude get_avoid]
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      windowStage.getMainWindow((err: BusinessError, data: window.Window) => {
        if (err.code) {
          hilog.error(0x0000, 'testTag', 'Failed to get the main window. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }
        this.windowObj = data;
        this.uiContext = data.getUIContext();
        this.windowUtil!.setFullScreen();
        // [StartExclude get_avoid]
        AppStorage.setOrCreate('currentWidthBreakpoint', this.uiContext.getWindowWidthBreakpoint());
        AppStorage.setOrCreate('currentHeightBreakpoint', this.uiContext.getWindowHeightBreakpoint());
        data.on('windowSizeChange', this.onWindowSizeChange);
        // [EndExclude get_avoid]
        let topAvoidHeight: window.AvoidArea = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        AppStorage.setOrCreate('topAvoidHeight', this.uiContext.px2vp(topAvoidHeight.topRect.height));
        let bottomAvoidHeight: window.AvoidArea =
          data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        AppStorage.setOrCreate('bottomAvoidHeight', this.uiContext.px2vp(bottomAvoidHeight.bottomRect.height));
        data.on('avoidAreaChange', this.onAvoidAreaChange);
        if (AppStorage.get('currentWidthBreakpoint') === WidthBreakpoint.WIDTH_SM &&
          (AppStorage.get('currentHeightBreakpoint') === HeightBreakpoint.HEIGHT_MD ||
            AppStorage.get('currentHeightBreakpoint') === HeightBreakpoint.HEIGHT_SM)) {
          // Set top bar height when the application is in small screen.
          AppStorage.setOrCreate('topBarHeight',
            CommonConstants.UTIL_HEIGHTS[1] + this.uiContext!.px2vp(topAvoidHeight.topRect.height));
        } else {
          // Set top bar height when the application is in full screen.
          AppStorage.setOrCreate('topBarHeight',
            CommonConstants.UTIL_HEIGHTS[2] + this.uiContext!.px2vp(topAvoidHeight.topRect.height));
        }
      })
      // [StartExclude get_avoid]
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
    // [EndExclude get_avoid]
  }
  // [StartExclude get_avoid]

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  // [EndExclude get_avoid]
}

// [End get_avoid]