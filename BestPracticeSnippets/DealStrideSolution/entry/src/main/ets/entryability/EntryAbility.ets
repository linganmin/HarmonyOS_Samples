/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { abilityAccessCtrl, UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../utils/Logger';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'Ability onWindowStageCreate');
    windowStage.getMainWindow()
      .then((win: window.Window): void => {
        win.setWindowLayoutFullScreen(true).then((): void => {
        })
          .catch((err: BusinessError) => {
            hilog.error(0x000, 'testTag', `setWindowLayoutFullScreen failed, code=${err.code}, message=${err.message}`);
          })
        win.setWindowSystemBarProperties({
          // Navigation bar color
          navigationBarColor: '#F1F3F5',
          // Status bar color
          statusBarColor: '#F1F3F5'
        })
          .catch((err: BusinessError) => {
            hilog.error(0x000, 'testTag', `setWindowSystemBarProperties failed, code=${err.code}, message=${err.message}`);
          })
      })
      .catch((err: BusinessError) => {
        hilog.error(0x000, 'testTag', `getMainWindow failed, code=${err.code}, message=${err.message}`);
      })

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        Logger.info(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
      // Get camera permissions
      let atManager = abilityAccessCtrl.createAtManager();
      atManager.requestPermissionsFromUser(this.context, [
        'ohos.permission.CAMERA',
      ]).then((): void => {
        Logger.info(TAG, 'request Permissions success!');
      }).catch((error: BusinessError): void => {
        Logger.info(TAG, `requestPermissionsFromUser call Failed! error: ${error.code}`);
      });
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