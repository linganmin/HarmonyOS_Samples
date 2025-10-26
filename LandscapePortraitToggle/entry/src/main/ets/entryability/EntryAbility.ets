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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import Logger from '../utils/Logger';

const TAG = 'EntryAbilityLogTag';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    try {
      let windowClass: window.Window = windowStage.getMainWindowSync();
      windowStage.getMainWindowSync().setWindowLayoutFullScreen(true).catch((error: BusinessError) => {
        Logger.error(TAG, `setWindowLayoutFullScreen err, errCode: ${error.code}, error mesage: ${error.message}`);
      });
      let naviBarArea: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      let area: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);

      let mainWindow = windowStage.getMainWindowSync();
      let SystemBarProperties: window.SystemBarProperties = {
        statusBarContentColor: '#ffffff'
      };
      mainWindow.setWindowSystemBarProperties(SystemBarProperties).catch((error: BusinessError) => {
        Logger.error(TAG, `setWindowSystemBarProperties err, errCode: ${error.code}, error mesage: ${error.message}`);
      });

      windowStage.loadContent('pages/VideoDetail', (err) => {
        if (err.code) {
          hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }

        windowStage.getMainWindow((err: BusinessError, data) => {
          let errCode: number = err.code;
          if (errCode) {
            console.error(`Failed to obtain the main window. Cause code: ${err.code}, message: ${err.message}`);
            return;
          }
          windowClass = data;
          console.info('Succeeded in obtaining the main window. Data: ' + JSON.stringify(data));
          // 获取UIContext实例。
          let UIContext: UIContext | null = null;
          UIContext = windowClass.getUIContext();

          AppStorage.setOrCreate<number>('naviIndicatorHeight', UIContext.px2vp(naviBarArea.bottomRect.height));
          AppStorage.setOrCreate<number>('statusBarHeight', UIContext.px2vp(area.topRect.height));
        });
        hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      });
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `onWindowStageCreate err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
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
