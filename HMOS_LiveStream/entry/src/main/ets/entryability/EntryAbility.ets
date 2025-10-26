/*
 * Copyright (C) 2025 Huawei Device Co., Ltd.
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

import { abilityAccessCtrl, AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import Logger from '../common/utils/Logger';

const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  onCreate(_: Want, __: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    try {
      let atManager = abilityAccessCtrl.createAtManager();
      atManager.requestPermissionsFromUser(this.context,
        ['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE', 'ohos.permission.DISTRIBUTED_DATASYNC'])
        .then((data) => {
          Logger.info(TAG, `requestPre() data: ${JSON.stringify(data)}.`);
        }).catch((err: BusinessError) => {
        Logger.error(TAG, `requestPre() data failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      })
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `requestPre() data failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }

    try {
      windowStage.getMainWindowSync().setWindowKeepScreenOn(true).catch((err: BusinessError) => {
        Logger.error(TAG, `setWindowKeepScreenOn failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      });
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `setWindowKeepScreenOn failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }

    try {
      windowStage.getMainWindowSync().setWindowLayoutFullScreen(true)
        .catch((err: BusinessError) => {
          Logger.error(TAG, `setWindowLayoutFullScreen failed, errCode = ${err.code}, errMessage = ${err.message}.`);
        });
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `setWindowLayoutFullScreen failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      try {
        AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `create uiContext failed, errCode = ${err.code}, errMessage = ${err.message}.`);
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
};