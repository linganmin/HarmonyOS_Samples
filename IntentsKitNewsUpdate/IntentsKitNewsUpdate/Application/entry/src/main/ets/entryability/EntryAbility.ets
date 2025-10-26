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
import { window } from '@kit.ArkUI';
import CommonConstants from '../common/constants/CommonConstants';
import Logger from '../common/utils/Logger';
import { IIntentParam } from '../model/IntentParam';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = '[EntryAbility]';
let IPara: IIntentParam = {
  entityId: '',
  blogCategory: '',
  items: []
};

export default class EntryAbility extends UIAbility {
  storage: LocalStorage = new LocalStorage(IPara);

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      if (launchParam.launchReason === AbilityConstant.LaunchReason.INSIGHT_INTENT && want && want.parameters) {
        const param = (want.parameters?.['ohos.insightIntent.executeParam.param'] as IIntentParam);
        Logger.showInfo(TAG, `cold launch, param is => ${JSON.stringify(param)}`);
        this.storage.setOrCreate(CommonConstants.STORAGE_KEY, param);
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.showError(TAG, `onCreate error.code is ${error.code}, error.message is ${error.message}`);
    }
    Logger.showInfo(TAG, 'Ability onCreate');
  }

  onDestroy(): void {
    Logger.showInfo(TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.showInfo(TAG, 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', this.storage, (err) => {
      if (err.code) {
        Logger.showError(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      Logger.showInfo(TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.showInfo(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.showInfo(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.showInfo(TAG, 'Ability onBackground');
  }
}
