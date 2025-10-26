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

import { UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import Logger from '../utils/Logger';
import { BusinessError } from '@kit.BasicServicesKit';

export default class ClickActionAbility extends UIAbility {
  private localStorage = new LocalStorage();

  onCreate(want: Want): void {
    Logger.info('ClickActionAbility onCreate');
    this.localStorage.setOrCreate('want', want);
  }

  onNewWant(want: Want): void {
    Logger.info('ClickActionAbility onNewWant');
    this.localStorage.setOrCreate('want', want);
  }

  onDestroy(): void {
    Logger.info('ClickActionAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
      windowStage.loadContent('pages/ClickActionInnerPage', this.localStorage).catch((err: BusinessError) => {
        Logger.error(`Failed to load inner page. Cause code: ${err.code}, message: ${err.message}`);
      });
  }
}
