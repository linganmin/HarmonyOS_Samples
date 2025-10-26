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

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

export default class EntryAbility extends UIAbility {
  private color: string = '#F5F5F5';

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'Sample', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'Sample', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'Sample', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'Sample', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'Sample', 'Succeeded in loading the content.');
      try {
        AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
      } catch (error) {
        hilog.error(0x0000, 'Sample', 'Failed to getMainWindowSync. Cause: %{public}s', JSON.stringify(error) ?? '');
      }
    });

    windowStage.getMainWindow().then((windowObj) => {
      windowObj.setWindowPrivacyMode(true);
      let windowClass: window.Window = windowObj;
      windowClass.setWindowLayoutFullScreen(true);
      let sysBarProps: window.SystemBarProperties = {
        statusBarColor: this.color,
        navigationBarColor: this.color,
        statusBarContentColor: this.color,
        navigationBarContentColor: this.color
      };
      windowClass.setWindowSystemBarProperties(sysBarProps)
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
    })
  }

  onWindowStageDestroy():
    void {
    // Main window is destroyed, release UI related resources
    hilog
      .info
      (
        0x0000,
        'Sample',
        '%{public}s',
        'Ability onWindowStageDestroy'
      )
    ;
  }

  onForeground():
    void {
    // Ability has brought to foreground
    hilog
      .info
      (
        0x0000,
        'Sample',
        '%{public}s',
        'Ability onForeground'
      )
    ;
  }

  onBackground():
    void {
    // Ability has back to background
    hilog
      .info
      (
        0x0000,
        'Sample',
        '%{public}s',
        'Ability onBackground'
      )
    ;
  }
}
