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

import { abilityAccessCtrl, AbilityConstant, PermissionRequestResult, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger, Common, BreakpointConstants } from '@ohos/commons/Index';
import { LiveViewController } from '@ohos/live/Index';

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

    let atManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(this.context, Common.PERMISSIONS).then((data: PermissionRequestResult) => {
        Logger.info('requestPermissionsFromUser' + JSON.stringify(data));
        if (data.authResults[0] !== 0 || data.authResults[1] !== 0) {
          return;
        }

        let windowClass: window.Window | null = null;
        windowStage.getMainWindow((err: BusinessError, data) => {
          let errCode: number = err.code;
          if (errCode) {
            hilog.error(0x0000, 'testTag', 'Failed to obtain the main window. Cause: ' + JSON.stringify(err));
            return;
          }
          windowClass = data;
          hilog.info(0x0000, 'testTag', 'Succeeded in obtaining the main window. Data: ' + JSON.stringify(data));

          let isLayoutFullScreen = true;
          windowClass.setWindowLayoutFullScreen(isLayoutFullScreen);
          let type = window.AvoidAreaType.TYPE_SYSTEM;
          let avoidArea = windowClass.getWindowAvoidArea(type);
          let topRectHeight = avoidArea.topRect.height;
          AppStorage.setOrCreate('topRectHeight', topRectHeight);
        });

        windowStage.getMainWindow().then((data: window.Window) => {
          this.windowObj = data;
          this.updateBreakpoint(this.windowObj.getWindowProperties().windowRect.width);
          this.windowObj.on('windowSizeChange', (windowSize: window.Size) => {
            this.updateBreakpoint(windowSize.width);
          })
        });

        windowStage.loadContent('pages/Index', (err, data) => {
          if (err.code) {
            hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
            return;
          }
          hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s',
            JSON.stringify(data) ?? '');
        });
      }).catch((err: Error) => {
        Logger.error('requestPermissionsFromUser', 'requestPermissionsFromUser err' + JSON.stringify(err));
      })
    } catch (err) {
      Logger.error('requestPermissionsFromUser', 'requestPermissionsFromUser err' + JSON.stringify(err));
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    LiveViewController.stopLiveView();
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
    LiveViewController.startLiveView();
  }

  private updateBreakpoint(windowWidth: number): void {
    try {
      let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels;
      let curBp: string = '';
      if (windowWidthVp < BreakpointConstants.BREAKPOINT_RANGES[1]) {
        curBp = BreakpointConstants.BREAKPOINT_SM;
      } else if (windowWidthVp < BreakpointConstants.BREAKPOINT_RANGES[2]) {
        curBp = BreakpointConstants.BREAKPOINT_MD;
      }
      AppStorage.setOrCreate('currentBreakpoint', curBp);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'EntryAbility', `updateBreakpoint failed, error code=${err.code}, message=${err.message}`);
    }
  }
}