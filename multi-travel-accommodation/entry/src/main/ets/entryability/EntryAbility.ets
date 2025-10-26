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
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import { BreakpointConstants } from '../commons/constants/BreakpointConstants';

export default class EntryAbility extends UIAbility {
  private windowObj?: window.Window;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.getMainWindow().then((data: window.Window) => {
      this.windowObj = data;
      try {
        this.updateBreakpoint(this.windowObj.getWindowProperties().windowRect.width);
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x00, 'testTag', `getWindowProperties failed, code = ${err.code}, message = ${err.message}`);
      }
      this.windowObj.on('windowSizeChange', (windowSize: window.Size) => {
        this.updateBreakpoint(windowSize.width);
      });
    }).catch((error: BusinessError) => {
      hilog.error(0x00, 'testTag', `getMainWindow failed, code = ${error.code}, message = ${error.message}`);
    })

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');

      try {
        let uiContext: UIContext | undefined = windowStage.getMainWindowSync().getUIContext();
        AppStorage.setOrCreate('uiContext', uiContext);
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x00, 'testTag', `getUIContext failed, code = ${err.code}, message = ${err.message}`);
      }

    });
  }

  private updateBreakpoint(windowWidth: number): void {
    try {
      let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels;
      let curBp: string = '';
      if (windowWidthVp < 600) {
        curBp = BreakpointConstants.BREAKPOINT_SM;
      } else if (windowWidthVp < 840) {
        curBp = BreakpointConstants.BREAKPOINT_MD;
      } else {
        curBp = BreakpointConstants.BREAKPOINT_LG;
      }
      AppStorage.setOrCreate('breakPoint', curBp);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x00, 'testTag', `getDefaultDisplaySync failed, code = ${err.code}, message = ${err.message}`);
    }
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
