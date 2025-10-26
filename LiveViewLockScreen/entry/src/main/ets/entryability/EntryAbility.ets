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

import { ConfigurationConstant, UIAbility } from '@kit.AbilityKit';
import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../constant/Constant';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  private horizontalBreakpoint: string = '';
  private verticalBreakpoint: string = '';

  private updateBreakpoint(windowSize: window.Size): void {
    try {
      let windowWidthVp: number = windowSize.width / display.getDefaultDisplaySync().densityPixels;
      let windowHeightVp: number = windowSize.height / display.getDefaultDisplaySync().densityPixels;
      let windowRatio: number = windowWidthVp / windowHeightVp;
      let horizontalBreakpoint: string = '';
      let verticalBreakpoint: string = '';
      if (windowWidthVp < 600) {
        horizontalBreakpoint = Constants.BREAK_POINT_SM;
      } else if (windowWidthVp < 840) {
        horizontalBreakpoint = Constants.BREAK_POINT_MD;
      } else {
        horizontalBreakpoint = Constants.BREAK_POINT_LG;
      }
      if (this.horizontalBreakpoint !== horizontalBreakpoint) {
        this.horizontalBreakpoint = horizontalBreakpoint;
        AppStorage.setOrCreate('horizontalBreakpoint', this.horizontalBreakpoint);
      }
      if (windowRatio < 0.8) {
        verticalBreakpoint = Constants.BREAK_POINT_SM;
      } else if (windowRatio > 1.2) {
        verticalBreakpoint = Constants.BREAK_POINT_LG;
      } else {
        verticalBreakpoint = Constants.BREAK_POINT_MD;
      }
      if (this.verticalBreakpoint !== verticalBreakpoint) {
        this.verticalBreakpoint = verticalBreakpoint;
        AppStorage.setOrCreate('verticalBreakpoint', this.verticalBreakpoint);
      }
    } catch (error) {
      hilog.error(0x0000, TAG, `updateBreakpoint catch err:`, (error as BusinessError).message);
    }
  }

  onCreate(): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onCreate');
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, TAG, '%{public}s', `Set colorMode failed: ${err.code}, ${err.message}`);
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onWindowStageCreate');
    windowStage.getMainWindow().then((windowObj: window.Window) => {
      try {
        windowObj.on('windowSizeChange', (windowSize) => {
          this.updateBreakpoint(windowSize);
          const type: window.AvoidAreaType = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
          const avoidArea: window.AvoidArea = windowObj.getWindowAvoidArea(type);
          const bottomRectHeight: number = avoidArea.bottomRect.height;
          AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight);
        });

        windowObj.setWindowSystemBarProperties({
          statusBarContentColor: '#ffffff',
        }).then(() => {
          hilog.info(0x0000, TAG, '%{public}s', 'Succeeded in setting the system bar properties.');
        }).catch((err: BusinessError) => {
          hilog.error(0x0000, TAG, 'Failed to set the window layout to full-screen mode. Cause:', err.message);
        });

        windowObj.setWindowLayoutFullScreen(true).then(() => {
          hilog.info(0x0000, TAG, '%{public}s', 'Succeeded in setting the window layout to full-screen mode');
        }).catch((err: BusinessError) => {
          hilog.error(0x0000, TAG, 'Failed to set the window layout to full-screen mode. Cause:', err.message);
        });
      } catch (error) {
        hilog.error(0x0000, TAG, '%{public}s',
          `onWindowStageCreate failed. Cause code: ${error.code}, message: ${error.message}`);
      }
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Failed to get main window. Cause:`, err.message);
    });
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, TAG, 'Succeeded in loading the content.');
    });
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