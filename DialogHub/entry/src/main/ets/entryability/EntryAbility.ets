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
import CommonConstant from '../utils/CommonConstant';
import { BusinessError } from '@kit.BasicServicesKit';

export default class EntryAbility extends UIAbility {
  private windowObj?: window.Window;
  private curBp: ResourceStr = '';

  // Update breakpoints based on the current window size
  private updateBreakpoint(windowWidth: number): void {
    // Retrieve the current window object and obtain the current display ID
    try {
      let displayId = this.windowObj?.getWindowProperties().displayId;
      // Convert the unit of length from px to vp
      let windowWidthVp = windowWidth / display.getDisplayByIdSync(displayId).densityPixels;
      let newBp: ResourceStr = '';
      if (windowWidthVp < CommonConstant.CURRENT_BREAK_POINT_XS_SIZE) {
        newBp = CommonConstant.CURRENT_BREAK_POINT_XS;
      } else if (windowWidthVp < CommonConstant.CURRENT_BREAK_POINT_SM_SIZE) {
        newBp = CommonConstant.CURRENT_BREAK_POINT_SM;
      } else if (windowWidthVp < CommonConstant.CURRENT_BREAK_POINT_md_SIZE) {
        newBp = CommonConstant.CURRENT_BREAK_POINT_md;
      } else {
        newBp = CommonConstant.CURRENT_BREAK_POINT_lg;
      }
      if (this.curBp !== newBp) {
        this.curBp = newBp
        // Use state variables to record the current breakpoint value
        AppStorage.setOrCreate(CommonConstant.CURRENT_BREAK_POINT, this.curBp);
      }
    } catch (err) {
      console.log("getDisplayByIdSync failed err" + err.code);
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'EntryAbility', `setColorMode failed, error code=${err.code}, message=${err.message}`);
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');

      windowStage.getMainWindow().then((windowObj) => {
        windowObj.setWindowLayoutFullScreen(true).catch((err: BusinessError) => {
          hilog.error(0x0000, 'EntryAbility',
            `setWindowLayoutFullScreen failed, error code=${err.code}, message=${err.message}`);
        })
        this.windowObj = windowObj;
        // Get the window size at application startup
        try {
          this.updateBreakpoint(windowObj.getWindowProperties().windowRect.width);
          // Register callback function to listen for changes in window size
          windowObj.on('windowSizeChange', (windowSize) => {
            this.updateBreakpoint(windowSize.width);
          })
          let uiContext: UIContext | undefined = windowStage.getMainWindowSync().getUIContext()
          AppStorage.setOrCreate('uiContext', uiContext);
        } catch (error) {
          hilog.error(0x0000, 'EntryAbility',
            `getWindowProperties failed, error code=${err.code}, message=${err.message}`);
        }
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'EntryAbility', `getMainWindow failed, error code=${err.code}, message=${err.message}`);
      })
    });
  }

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
}