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

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../common/Logger';

export default class EntryAbility extends UIAbility {
  public curBp: string = '';

  public updateBreakpoint(windowWidth: number): void {
    try {
      let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels;
      let newBp: string = '';
      if (windowWidthVp < 600) {
        newBp = 'sm';
      } else if (windowWidthVp < 840) {
        newBp = 'md';
      } else {
        newBp = 'lg';
      }
      if (this.curBp !== newBp) {
        this.curBp = newBp;
        AppStorage.setOrCreate('currentBreakpoint', this.curBp);
      }
    } catch (error) {
      Logger.error('Entry',
        `updateBreakpoint catch err, ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Home', (err, data) => {
      AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      windowStage.getMainWindowSync().setWindowLayoutFullScreen(true);
      windowStage.getMainWindow((err: BusinessError, data) => {
        const errCode: number = err.code;
        if (errCode) {
          hilog.error(0x0000, '[EntryAbility]', 'Failed to obtain the main window. Cause: ' + JSON.stringify(err));
          return;
        }
        try {
          let avoidArea = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
          // Set the height of the status bar.
          AppStorage.setOrCreate('statusBarHeight', data.getUIContext().px2vp(avoidArea.topRect.height));
          AppStorage.setOrCreate('bottomHeight', data.getUIContext()
            .px2vp(data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height));
          this.updateBreakpoint(data.getWindowProperties().windowRect.width);

          data.on('windowSizeChange', (windowSize) => {
            this.updateBreakpoint(windowSize.width);
          });
        } catch (exception) {
          hilog.error(0x0000, '[EntryAbility]',
            `Failed to set the system bar to be invisible. Cause code: ${exception.code}, message: ${exception.message}`);
        }
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