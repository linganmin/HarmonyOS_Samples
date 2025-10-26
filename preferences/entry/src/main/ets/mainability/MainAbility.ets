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

import { UIAbility,AbilityConstant,Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import Logger from '../util/Logger';

const TAG: string = '[MainAbility]';

export default class MainAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'MainAbility onCreate is called');
  }

  onDestroy() {
    Logger.info(TAG, 'MainAbility onDestroy is called');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'MainAbility onWindowStageCreate is called');
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        Logger.error(TAG, `Failed to load the content. Cause:${JSON.stringify(err) ?? ''}`);
        return;
      }
      Logger.info(TAG, `Succeeded in loading the content. Data:${JSON.stringify(data) ?? ''}`);
    });
  }

  onWindowStageDestroy() {
    Logger.info(TAG, 'MainAbility onWindowStageDestroy is called');
  }

  onForeground() {
    Logger.info(TAG, 'MainAbility onForeground is called');
  }

  onBackground() {
    Logger.info(TAG, 'MainAbility onBackground is called');
  }
}