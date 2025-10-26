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

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import Logger from '../model/Logger';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility';
const FORMAT = '%{public}s';

export default class MainAbility extends UIAbility {
  windowClass: window.Window | undefined = undefined;

  onCreate() {
    Logger.info('[Sample_AdaptiveCapabilities]', 'MainAbility onCreate');
  }

  onDestroy() {
    Logger.info('[Sample_AdaptiveCapabilities]', 'MainAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    Logger.info('[Sample_AdaptiveCapabilities]', 'onWindowStageCreate');


    windowStage.getMainWindow((err: BusinessError, data) => {
      const errCode: number = err.code;
      if (errCode) {
        hilog.error(DOMAIN, TAG, FORMAT,
          `Failed to obtain the main window. Cause code: ${err.code}, message: ${err.message}`);
        return;
      }
      this.windowClass = data;
      let isLayoutFullScreen = true;
      try {
        let promise = this.windowClass.setWindowLayoutFullScreen(isLayoutFullScreen).catch((err: BusinessError) => {
          hilog.error(DOMAIN, TAG, FORMAT,
            `Failed to set the window layout to full-screen mode. Cause code: ${err.code},message: ${err.message}`);
        });
        promise.then(() => {
          hilog.info(DOMAIN, TAG, FORMAT, 'Succeeded in setting the window layout to full-screen mode.');
        }).catch((err: BusinessError) => {
          hilog.error(DOMAIN, TAG, FORMAT,
            `Failed to set the window layout to full-screen mode. Cause code: ${err.code},message: ${err.message}`);
        });
      } catch (err) {
        hilog.error(DOMAIN, TAG, FORMAT,
          `Failed to set the window layout to full-screen mode. Cause code: ${err.code},message: ${err.message}`);
      }
      this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', false).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, FORMAT,
          `Failed to set the system bar to be invisible. Cause code: ${err.code},message: ${err.message}`);
      });
    });

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, FORMAT, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(DOMAIN, TAG, FORMAT, 'Succeeded in loading the content.');
      try {
        let windowObj = windowStage.getMainWindowSync();
        AppStorage.setOrCreate('windowObj', windowObj);
        AppStorage.setOrCreate('uiContext', windowObj.getUIContext());
      } catch (err) {
        hilog.error(DOMAIN, TAG, FORMAT, `Failed. Cause code: ${err.code}, message: ${err.message}`);
      }
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    Logger.info('[Sample_AdaptiveCapabilities]', 'onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    Logger.info('[Sample_AdaptiveCapabilities]', 'onForeground');
  }

  onBackground() {
    // Ability has back to background
    Logger.info('[Sample_AdaptiveCapabilities]', 'onBackground');
  }
}