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
import { BusinessError } from '@kit.BasicServicesKit';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability.
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
    let windowClass: window.Window | undefined = undefined;
    window.getLastWindow(this.context, (err: BusinessError, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to obtain top window. Cause:' + JSON.stringify(err));
        return;
      }
      windowClass = data;
      // Top status bar height for window content avoidance.
      let statusHeight = 0;
      // Height of the bottom security zone that is avoided by the window content.
      let bottomHeight = 0;
      // Gets the region that the window content avoids.
      let type = window.AvoidAreaType.TYPE_SYSTEM;
      try {
        let avoidArea: window.AvoidArea = windowClass.getWindowAvoidArea(type);
        statusHeight = avoidArea.topRect.height;
        bottomHeight = avoidArea.bottomRect.height
      } catch (exception) {
        hilog.error(0x0000, 'testTag', 'Failed to obtain the area. Cause:' + JSON.stringify(exception));
      }
      AppStorage.setOrCreate('statusHeight', statusHeight);
      AppStorage.setOrCreate('bottomHeight', bottomHeight);
      let screenHeight: number = 0;
      let displayClass: display.Display | null = null;
      try {
        displayClass = display.getDefaultDisplaySync();
        screenHeight = displayClass.height;
      } catch (exception) {
        hilog.error(0x0000, 'testTag', 'Failed to obtain the default display object. Code: ' + JSON.stringify(exception));
      }
      hilog.info(0x0000, 'testTag', 'Succeeded to obtain the default display object. Code: ' + JSON.stringify(displayClass));
      AppStorage.setOrCreate('screenHeight', screenHeight);
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