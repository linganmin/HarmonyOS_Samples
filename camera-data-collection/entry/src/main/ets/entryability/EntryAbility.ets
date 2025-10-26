/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.isLoggable(0x0000, TAG, hilog.LogLevel.INFO);
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onCreate');
    hilog.info(0x0000, TAG, '%{public}s', 'want param:' + JSON.stringify(want) ?? '');
    hilog.info(0x0000, TAG, '%{public}s', 'launchParam:' + JSON.stringify(launchParam) ?? '');
  }

  onDestroy() {
    hilog.isLoggable(0x0000, TAG, hilog.LogLevel.INFO);
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err, data) => {
      AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
      if (err.code) {
        hilog.error(0x0000, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, TAG, 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
      let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口
      // Set the window to full screen
      let isLayoutFullScreen = true;
      windowClass.setWindowLayoutFullScreen(isLayoutFullScreen)
        .then(() => {
          hilog.info(0x0000, TAG, 'Succeeded in setting the window layout to full-screen mode. Data: %{public}s',
            JSON.stringify(data) ?? '');
        })
        .catch((err: BusinessError) => {
          hilog.error(0x0000, TAG, 'Failed to set the window layout to full-screen mode. Cause: %{public}s',
            JSON.stringify(err) ?? '');
        });
      // Set the font color of the status bar.
      let SystemBarProperties: window.SystemBarProperties = {
        statusBarContentColor: '#FFFFFF'
      };
      windowStage.getMainWindowSync().setWindowSystemBarProperties(SystemBarProperties);
    });
  }
}
