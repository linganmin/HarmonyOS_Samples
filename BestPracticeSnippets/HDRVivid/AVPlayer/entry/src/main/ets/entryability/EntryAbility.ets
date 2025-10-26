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

import { UIAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UIContext, window } from '@kit.ArkUI';
import { WindowUtil } from '../utils/WindowUtil';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    AppStorage.setOrCreate('context', this.context);
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    let windowClass: window.Window | undefined = undefined;
    try {
      windowClass = windowStage.getMainWindowSync();
    } catch (err) {
      hilog.error(0x0000, 'testTag',`getMainWindowSync failed, Code:${err.code}, message:${err.message}`);
    }
    AppStorage.setOrCreate('windowStage', windowStage);
    windowClass?.setWindowLayoutFullScreen(true)
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag',`getMainWindowSync failed, Code:${err.code}, message:${err.message}`);
      })
    WindowUtil.getInstance().setWindowStage(windowStage);
    windowClass?.setWindowSystemBarProperties({
      statusBarContentColor: '#e6ffffff'
    })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag',`getMainWindowSync failed, Code:${err.code}, message:${err.message}`);
      })
    windowStage.loadContent('pages/IndexPage', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      try {
        let uiContext:  UIContext | undefined = windowStage.getMainWindowSync().getUIContext();
        AppStorage.setOrCreate('uiContext', uiContext);
        hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      } catch (error) {
        hilog.error(0x0000, 'testTag',`getMainWindowSync or getUIContext failed, Code:${err.code}, message:${err.message}`);
      }
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
