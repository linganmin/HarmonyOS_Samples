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
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../utils/Logger';

const TAG: string = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    Logger.info(TAG, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(TAG, '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'testTag', 'Succeeded in loading the content.');

      try {
        let windowClass: window.Window = windowStage.getMainWindowSync();
        let isLayoutFullScreen = true;
        let uiContext:  UIContext | undefined = windowStage.getMainWindowSync().getUIContext();
        AppStorage.setOrCreate('uiContext', uiContext);
        windowClass.setWindowLayoutFullScreen(isLayoutFullScreen)
          .then(() => {
            Logger.info(TAG, 'testTag', 'Succeeded in setting the window layout to full-screen mode. Data: %{public}s',
              JSON.stringify(data) ?? '');
          })
          .catch((err: BusinessError) => {
            Logger.error(TAG, 'testTag', 'Failed to set the window layout to full-screen mode. Cause: %{public}s',
              JSON.stringify(err) ?? '');
          })
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `getMainWindowSync or getUIContext failed, code=${err.code}, message=${err.message}`);
      }
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.error(TAG, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.error(TAG, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.error(TAG, 'testTag', '%{public}s', 'Ability onBackground');
  }
}