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
import { window } from '@kit.ArkUI';
import { Logger } from './Logger';

const TAG = 'WindowUtilsLogTag';

class WindowUtils {
  public initWindow(windowStage: window.WindowStage) {
    try {
      let windowClass: window.Window = windowStage.getMainWindowSync();
      let context: UIContext = windowClass.getUIContext()!;
      windowClass.setWindowLayoutFullScreen(true).catch((error: BusinessError) => {
        Logger.error(TAG, `setWindowLayoutFullScreen err, code: ${error.code}, mesage: ${error.message}`);
      });
      let statusBarArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      let statusBarHeight = context.px2vp(statusBarArea.topRect.height);
      AppStorage.setOrCreate('statusBarHeight', statusBarHeight);

      let naviBarArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      let naviIndicatorHeight = context.px2vp(naviBarArea.bottomRect.height);
      AppStorage.setOrCreate('naviIndicatorHeight', naviIndicatorHeight);

      let size = windowClass.getWindowProperties().windowRect;
      AppStorage.setOrCreate('windowHeight', context.px2vp(size.height));
      AppStorage.setOrCreate('windowWidth', context.px2vp(size.width));

      windowClass.on('windowSizeChange', (data) => {
        AppStorage.setOrCreate('windowHeight', context.px2vp(data.height));
        AppStorage.setOrCreate('windowWidth', context.px2vp(data.width));
      });

      windowClass.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          let statusBarHeight = context.px2vp(data.area.topRect.height);
          AppStorage.setOrCreate('statusBarHeight', statusBarHeight);
        } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          let naviIndicatorHeight = context.px2vp(data.area.bottomRect.height);
          AppStorage.setOrCreate('naviIndicatorHeight', naviIndicatorHeight);
        }
      });
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `onAddForm err, code: ${error.code}, mesage: ${error.message}`);
    }
  }

  public setStatusbarContentColor(color: string) {
    try {
      let windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
      let mainWindow = windowStage.getMainWindowSync();
      let SystemBarProperties: window.SystemBarProperties = {
        statusBarContentColor: color,
      };
      mainWindow.setWindowSystemBarProperties(SystemBarProperties).catch((error: BusinessError) => {
        Logger.error(TAG, `setWindowSystemBarProperties err, code: ${error.code}, mesage: ${error.message}`);
      });
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `setStatusbarContentColor err, code: ${error.code}, mesage: ${error.message}`);
    }
  }
}

export default new WindowUtils();
