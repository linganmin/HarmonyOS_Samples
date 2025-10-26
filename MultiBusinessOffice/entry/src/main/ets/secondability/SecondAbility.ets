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

import { UIAbility, AbilityConstant, Want } from '@kit.AbilityKit';
import { display, window } from '@kit.ArkUI';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import Logger from '../constants/utils/Logger';

const TAG: string = 'SecondAbility';

export default class SecondAbility extends UIAbility {
  private windowObj?: window.Window;

  private updateBreakpoint(windowWidth: number, windowHeight: number): void {
    try {
      let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels;
      let curBp: string = '';
      if (windowWidthVp < 600) {
        curBp = 'sm';
      } else if (windowWidthVp < 840) {
        curBp = 'md';
      } else {
        curBp = 'lg';
      }
      AppStorage.setOrCreate('secondBreakPoint', curBp);
      // Obtains the window size.
      AppStorage.setOrCreate('secondWindowSize', windowWidthVp);
      AppStorage.setOrCreate('secondWindowSizeHeight', windowHeight / display.getDefaultDisplaySync().densityPixels);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `updateBreakpoint failed, error code=${err.code}, message=${err.message}`);
    }
  };

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    Logger.info(TAG, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/NotesPage', (err) => {
      if (err.code) {
        Logger.error(TAG, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'testTag', 'Succeeded in loading the content.');
    });

    windowStage.getMainWindow().then((data: window.Window) => {
      // Hide PC/2in1 title bar.
      try {
        data.setWindowDecorVisible(false);
      } catch (exception) {
        Logger.error(TAG, 'testTag', 'Failed to set the visibility of window decor. Cause: %{public}s',
          JSON.stringify(exception) ?? '');
      }

      try {
        data.setWindowDecorHeight(64);
      } catch (exception) {
        Logger.error(TAG, 'testTag', 'Failed to set the decor height of window decor. Cause: %{public}s',
          JSON.stringify(exception) ?? '');
      }

      // Window immersive.
      let deviceTypeInfo: string = deviceInfo.deviceType;
      if (deviceTypeInfo !== '2in1') {
        data.setWindowLayoutFullScreen(true)
          .then((data) => {
            Logger.info(TAG, 'Succeeded in setting the window layout to full-screen mode. Data: %{public}s',
              JSON.stringify(data) ?? '');
          })
          .catch((err: BusinessError) => {
            Logger.error(TAG, 'Failed to set the window layout to full-screen mode. Cause: %{public}s',
              JSON.stringify(err) ?? '');
          });
      }

      this.windowObj = data;
      this.updateBreakpoint(this.windowObj.getWindowProperties().windowRect.width,
        this.windowObj.getWindowProperties().windowRect.height);
      this.windowObj.on('windowSizeChange', (windowSize: window.Size) => {
        this.updateBreakpoint(windowSize.width, windowSize.height);
      })
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `getMainWindow failed, error code=${err.code}, message=${err.message}`);
    })

    try {
      // Set mini window.
      let windowClass: window.Window = windowStage.getMainWindowSync();
      let windowLimits: window.WindowLimits = {
        minWidth: 350
      };
      let promise = windowClass.setWindowLimits(windowLimits);
      promise.then(() => {
        Logger.info(TAG, 'testTag', 'Succeeded in changing the window limits.');
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'testTag', 'Failed to change the window limits. Cause: %{public}s',
          JSON.stringify(err) ?? '');
      })
    } catch (exception) {
      Logger.error(TAG, 'testTag', 'Failed to change the window limits. Cause: %{public}s',
        JSON.stringify(exception) ?? '');
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info(TAG, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info(TAG, 'testTag', '%{public}s', 'Ability onBackground');
  }
}