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
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  private windowObj?: window.Window;
  private onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    try {
      AppStorage.setOrCreate('windowHeight', this.windowObj!.getWindowProperties().windowRect.height);
      AppStorage.setOrCreate('windowWidth', this.windowObj!.getWindowProperties().windowRect.width);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG,
        `onWindowSizeChange getWindowProperties failed, code=${err.code}, message=${err.message}`);
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onWindowStageCreate');

    try {
      windowStage.getMainWindow((err, data) => {
        if (err && err.code) {
          hilog.error(0x0000, TAG, 'Failed to obtain the main');
          return;
        }
        this.windowObj = data;

        // Set the window effect to immersive.
        this.windowObj.setWindowLayoutFullScreen(true).catch((err: BusinessError) => {
          hilog.error(0x0000, TAG,
            `setWindowLayoutFullScreenfailed. Cause: code=${err.code}, message=${err.message}`);
        });

        // Obtains the width and height of the window, in pixels.
        AppStorage.setOrCreate('windowHeight', this.windowObj.getWindowProperties().windowRect.height);
        AppStorage.setOrCreate('windowWidth', this.windowObj.getWindowProperties().windowRect.width);

        // Reader doesn't show navigation bar.
        this.windowObj.setWindowSystemBarEnable([]).catch((err: BusinessError) => {
          hilog.error(0x0000, TAG,
            `setWindowSystemBarEnable([]) failed. Cause: code=${err.code}, message=${err.message}`);
        });
        this.windowObj.on('windowSizeChange', this.onWindowSizeChange);
      });
    } catch (error) {
      hilog.error(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    }

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
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
