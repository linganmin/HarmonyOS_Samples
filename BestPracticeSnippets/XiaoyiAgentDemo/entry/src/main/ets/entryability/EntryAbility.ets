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

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { url } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

const DOMAIN = 0x0000;
let uiContext: UIContext | null = null;

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    AppStorage.setOrCreate('context', this.context);
    hilog.info(DOMAIN, 'testTag', '[EntryAbility] onCreate completed');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '[EntryAbility] onDestroy completed');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/MainPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      windowStage.getMainWindow((err: BusinessError, data) => {
        try {
          let windowClass = data;
          uiContext = windowClass.getUIContext();
          AppStorage.set('uiContext', uiContext);
        } catch (error) {
          let err = error as BusinessError;
          hilog.error(0x000, 'testTag', `getUIContext failed. code=${err.code}, message=${err.message}`);
        }
      })

      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  // [Start onNewWant]
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', 'Received URI:', want.uri);
    const uri = want.uri;
    let pathname = '';
    if (uri) {
      try {
        const urlObj = url.URL.parseURL(uri);
        pathname = urlObj.pathname;
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x000, 'testTag', `getUIContext failed. code=${err.code}, message=${err.message}`);
      }
      uiContext?.getRouter().pushUrl({ url: 'pages' + pathname })
        .catch((error: BusinessError) => {
          hilog.error(0x000, 'testTag', `pushUrl failed. code=${error.code}, message=${error.message}`);
        })
    }
  }
  // [End onNewWant]
}