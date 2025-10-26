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
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility';
const FORMAT = '%{public}s';

export default class EntryAbility extends UIAbility {
  windowClass: window.Window | undefined = undefined;
  isLayoutFullScreen = true;

  onCreate(): void {
    hilog.info(DOMAIN, TAG, FORMAT, 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, FORMAT, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, TAG, FORMAT, 'Ability onWindowStageCreate');

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
      } catch (exception) {
        hilog.error(DOMAIN, TAG, FORMAT,
          `Failed to set the window layout to full-screen mode. Cause code: ${exception.code},
        message: ${exception.message}`);
      }
      this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', false).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, FORMAT,
          `Failed to set the system bar to be invisible. Cause code: ${err.code},message: ${err.message}`);
      });
      this.windowClass.setSpecificSystemBarEnabled('status', false).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, FORMAT,
          `Failed to set the system bar to be invisible. Cause code: ${err.code},message: ${err.message}`);
      });
    });
    windowStage.loadContent('pages/Index', (err) => {
      try {
        AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
      } catch (err) {
        hilog.error(DOMAIN, TAG, FORMAT, `GetMainWindowSync failed. Cause code: ${err.code}, message: ${err.message}`);
      }
      if (err.code) {
        hilog.error(DOMAIN, TAG, FORMAT, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(DOMAIN, TAG, FORMAT, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, TAG, FORMAT, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, TAG, FORMAT, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, TAG, FORMAT, 'Ability onBackground');
  }
}