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
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';

const TAG = 'EntryAbility';
const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  public uiContext?: UIContext;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, TAG, '%{public}s',
        `Failed to set colorMode. Cause code: ${err.code}, message: ${err.message}`);
    }
    hilog.info(DOMAIN, TAG, '%{public}s', `Ability onCreate. want:${want}, launchParam:${launchParam}`);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onDestroy');
  }
  // [Start available_area]
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageCreate');
    try {
      let mainWindow = windowStage.getMainWindowSync();
      let displayId = mainWindow.getWindowProperties().displayId;
      let displayClass = display.getDisplayByIdSync(displayId);
      displayClass.getAvailableArea().then(() => {
        mainWindow.resize(mainWindow.getUIContext().px2vp(600), mainWindow.getUIContext().px2vp(600))
          .catch((err: BusinessError) => {
            hilog.error(DOMAIN, TAG, '%{public}s',
              `Failed to change the window size. Code: ${err.code}, message: ${err.message}`);
          });
        mainWindow.moveWindowTo(0, 0).catch((err: BusinessError) => {
          hilog.error(DOMAIN, TAG, '%{public}s',
            `Failed to move the window. Code: ${err.code}, message: ${err.message}`);
        });
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, '%{public}s',
          `Failed to get the available area in this display. Code: ${err.code}, message: ${err.message}`);
      })
    } catch (err) {
      hilog.error(DOMAIN, TAG, '%{public}s',
        `Failed to move the window. Cause code: ${err.code}, message: ${err.message}`);
    }
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', err);
        return;
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');
    });
  }
  // [End available_area]
  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onBackground');
  }
}