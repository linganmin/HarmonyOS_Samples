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

/*
* 最佳实践: 桌面快捷方式开发实践
*/

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

export default class EntryAbility extends UIAbility {
  funcAbilityWant: Want | undefined = undefined;
  uiContext: UIContext | undefined = undefined;
  path: string = 'pages/Index';

  // [Start onNewWant]
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // Receive the parameters passed by UIAbility from the caller
    AppStorage.setOrCreate('want', want);
    AppStorage.setOrCreate('newWantFlag', true);
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onNewWant');
  }

  // [End onNewWant]

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    let shortCutKey = want.parameters?.shortCutKey;
    if (shortCutKey && shortCutKey === 'CompanyPage') {
      this.path = 'pages/GoCompany';
    }
    if (shortCutKey && shortCutKey === 'HousePage') {
      this.path = 'pages/GoHouse';
    }
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent(this.path, (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }

      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');

      let windowClass: window.Window;
      windowStage.getMainWindow((err, data) => {
        if (err.code) {
          hilog.error(0x0000, 'testTag',
            `Failed to obtain the main window. Code is ${err.code},message is ${err.message}`);
        }
        windowClass = data;
        this.uiContext = windowClass.getUIContext();
      })
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
