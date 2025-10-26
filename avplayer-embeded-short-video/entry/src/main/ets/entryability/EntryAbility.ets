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

import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ConfigurationConstant, UIAbility } from '@kit.AbilityKit';
import { Constants } from '../common/constants/Constants';
import { WindowUtil } from '../common/utils/WindowUtil';

const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      hilog.info(Constants.DOMAIN, TAG, '%{public}s', 'Ability onCreate');
    } catch (error) {
      if (error.code !== null && error.message !== null) {
        hilog.error(Constants.DOMAIN, TAG, `onCreate failed, code is ${error.code}, message is ${error.message}`);
      }
    }
  }

  onDestroy(): void {
    hilog.info(Constants.DOMAIN, TAG, '%{public}s', 'Ability onDestroy');
  }

  // [Start on_window_stage_create]
  onWindowStageCreate(windowStage: window.WindowStage): void {
    try {
      // [StartExclude on_window_stage_create]
      // Main window is created, set main page for this ability
      hilog.info(Constants.DOMAIN, TAG, '%{public}s', 'Ability onWindowStageCreate');
      // [EndExclude on_window_stage_create]
      WindowUtil.getInstance().setWindowStage(windowStage);
      AppStorage.setOrCreate('windowStage', windowStage);
      windowStage.loadContent('pages/PlayVideo', (error: BusinessError) => {
        let windowClass: window.Window = windowStage.getMainWindowSync(); // Get the main application window
        AppStorage.setOrCreate('windowClass', windowClass);

        windowClass.setWindowSystemBarProperties({
          // Status bar color
          statusBarContentColor: '#E6FFFFFF'
        });

        let context: UIContext = windowStage.getMainWindowSync().getUIContext();
        AppStorage.setOrCreate(Constants.UI_CONTEXT, context);
        AppStorage.setOrCreate('context', context.getHostContext());
        // [StartExclude on_window_stage_create]
        AppStorage.setOrCreate('windowStage', windowStage);
        if (error.code) {
          hilog.error(Constants.DOMAIN, TAG,
            `Failed to load the content. code: ${error.code};message:${error.message}`);
          return;
        }
        hilog.info(Constants.DOMAIN, TAG, 'Succeeded in loading the content.');
        // [EndExclude on_window_stage_create]
      });
    } catch (error) {
      hilog.error(Constants.DOMAIN, TAG,
        `onWindowStageCreate failed, Code:${error.code}, message:${error.message}`);
    }
  }

  // [End on_window_stage_create]
  onWindowStageDestroy():
    void {
    // Main window is destroyed, release UI related resources
    hilog.info(Constants.DOMAIN, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground():
    void {
    // Ability has brought to foreground
    hilog.info(Constants.DOMAIN, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground():
    void {
    // Ability has back to background
    hilog.info(Constants.DOMAIN, TAG, '%{public}s', 'Ability onBackground');
  }
}