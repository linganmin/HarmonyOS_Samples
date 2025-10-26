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

export default class EntryAbility extends UIAbility {
  private localStore = new LocalStorage();

  onCreate(want: Want): void {
    Logger.info('Ability onCreate');
    this.localStore.setOrCreate('want', want);
  }

  onNewWant(want: Want): void {
    Logger.info('Ability onNewWant');
    this.localStore.setOrCreate('want', want);
  }

  onDestroy(): void {
    Logger.info('Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    Logger.info('Ability onWindowStageCreate');
    try {
      await windowStage.loadContent('pages/Index', this.localStore);
      Logger.info('Succeeded in loading the content');
    } catch (e) {
      const err: BusinessError = e;
      Logger.error('Failed to load the content: %{public}d %{public}s', err.code, err.message);
    }
  }

  onWindowStageDestroy(): void {
    Logger.info('Ability onWindowStageDestroy');
  }

  onForeground(): void {
    Logger.info('Ability onForeground');
  }

  onBackground(): void {
    Logger.info('Ability onBackground');
  }
}
