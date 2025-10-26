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

import { BusinessError } from '@kit.BasicServicesKit';
import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { WindowUtil } from '../utils/WindowUtil';
import { Logger } from '@ohos/MediaService';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    AppStorage.setOrCreate('context', this.context);
    Logger.info(TAG, `Ability onCreate`);
  }

  onDestroy(): void {
    Logger.info(TAG, `Ability onDestroy`);
  }

  // [Start stage_creat]
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // [StartExclude stage_creat]
    // Main window is created, set main page for this ability
    Logger.info(TAG, `Ability onWindowStageCreate`);
    try {
      let windowClass: window.Window = windowStage.getMainWindowSync();
      AppStorage.setOrCreate('windowStage', windowStage);
      windowClass.setWindowLayoutFullScreen(true).catch((err: BusinessError) => {
        Logger.error(TAG, `setWindowLayoutFullScreen failed, err.code:${err.code}, err.message:${err.message}`);
      });
      windowClass.setWindowSystemBarProperties({
        statusBarContentColor: '#e6ffffff'
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `setWindowSystemBarProperties failed, err.code:${err.code}, err.message:${err.message}`);
      });
      windowStage.loadContent('pages/IndexPage', (err) => {
        AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
        WindowUtil.getInstance().setWindowStage(windowStage);
        if (err.code) {
          Logger.error(TAG, `failed to load the content, err.code:${err.code}, err.message:${err.message}`);
          return;
        }
        Logger.info(TAG, `Succeeded in loading the content`);
      });
    } catch (err) {
      Logger.error(TAG, `onWindowStageCreate failed, err.code:${err.code}, err.message:${err.message}`);
    }
    // [EndExclude stage_creat]
  }
  // [End stage_creat]

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, `Ability onWindowStageDestroy`);
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info(TAG, `Ability onForeground`);
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info(TAG, `Ability onBackground`);
  }
}
