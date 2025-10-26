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

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import { WindowUtils } from '../utils/windowutils/WindowUtils';
import { WindowUtility } from '../utils/windowutils/WindowUtility';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  private currentBreakPoint: string = '';

  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    try {
      // Main window is created, set main page for this ability
      hilog.info(0x0000, TAG, '%{public}s', 'Ability onWindowStageCreate');

      WindowUtility.setWindow(windowStage)
      // Gets the window width and height.
      WindowUtils.window = windowStage.getMainWindowSync();
      WindowUtils.windowWidth_px = WindowUtils.window.getWindowProperties().windowRect.width;
      WindowUtils.windowHeight_px = WindowUtils.window.getWindowProperties().windowRect.height;

      this.updateBreakpoint(WindowUtils.windowWidth_px);

      // Gets the height of the upper escape zone (status bar, etc.).
      let avoidArea = WindowUtils.window.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      WindowUtils.topAvoidAreaHeight_px = avoidArea.topRect.height;

      // Obtain the navigation bar height.
      let navigationArea = WindowUtils.window.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      WindowUtils.navigationIndicatorHeight_px = navigationArea.bottomRect.height;

      hilog.info(0x0000, TAG, 'the width is ' + WindowUtils.windowWidth_px + '  ' + WindowUtils.windowHeight_px + '  ' +
      WindowUtils.topAvoidAreaHeight_px + '  ' + WindowUtils.navigationIndicatorHeight_px);
      // Monitor and update changes in window size, status bar height and navigation bar height.
      WindowUtils.window.on('windowSizeChange', (data) => {
        hilog.info(0x0000, TAG, 'on windowSizeChange, the width is ' + data.width + ', the height is ' + data.height);
        WindowUtils.windowWidth_px = data.width;
        WindowUtils.windowHeight_px = data.height;
        this.updateBreakpoint(data.width);
        AppStorage.setOrCreate('windowSizeChanged', Date.now());
      })

      WindowUtils.window.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          let topRectHeight = data.area.topRect.height;
          hilog.info(0x0000, TAG, 'on avoidAreaChange, the top avoid area height is ' + topRectHeight);
          WindowUtils.topAvoidAreaHeight_px = topRectHeight;
        } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          let bottomRectHeight = data.area.bottomRect.height;
          hilog.info(0x0000, TAG, 'on avoidAreaChange, the navigation indicator height is ' + bottomRectHeight);
          WindowUtils.navigationIndicatorHeight_px = bottomRectHeight;
        }
      })

      windowStage.loadContent('pages/Index', (err) => {
        AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
        if (err.code) {
          hilog.error(0x0000, TAG, 'TAG',
            `Failed to load the content. Cause: Code is ${err.code}, message is ${err.message}`);
          return;
        }
        hilog.info(0x0000, TAG, 'Succeeded in loading the content.');
      });
    } catch (exception) {
      let error = exception as BusinessError;
      hilog.error(0x0000, TAG, `register failed. Code is ${error.code}, message is ${error.message}`);
    }
  }

  updateBreakpoint(width: number) {
    try {
      let windowWidthVp = width / (display.getDefaultDisplaySync().densityDPI / 160);
      let newBreakPoint: string = '';
      if (windowWidthVp < 400) {
        newBreakPoint = 'xs';
      } else if (windowWidthVp < 600) {
        newBreakPoint = 'sm';
      } else if (windowWidthVp < 800) {
        newBreakPoint = 'md';
      } else {
        newBreakPoint = 'lg';
      }
      hilog.info(0x0000, 'LOG--', this.currentBreakPoint, newBreakPoint);
      if (this.currentBreakPoint !== newBreakPoint) {
        this.currentBreakPoint = newBreakPoint;
        // Record the current breakpoint value using the state variable.
        AppStorage.setOrCreate('currentBreakpoint', this.currentBreakPoint);
      }
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, TAG, `updateBreakpoint failed. error code=${error.code}, message=${error.message}`);
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onBackground');
  }
}