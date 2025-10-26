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

import { window } from '@kit.ArkUI';
import { AbilityConstant, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';

const TAG: string = '[WindowUtil]';



export class WindowUtil {
  public static updateStatusBarColor(context: common.BaseContext, isDark: boolean): void {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      try {
        windowClass.setWindowSystemBarProperties({ statusBarContentColor: isDark ? '#FFFFFF' : '#000000' })
          .catch((error: Error) => {
            Logger.error(TAG, 'Failed to set the system bar properties. Cause: ' + JSON.stringify(error));
          });
      } catch (exception) {
        Logger.error(TAG, 'Failed to set the system bar properties. Cause: ' + JSON.stringify(exception));
      }
    })
      .catch((error: Error) => {
      Logger.error(TAG, 'Failed to get last window. Cause: ' + JSON.stringify(error));
    });
  }

  public static requestFullScreen(windowStage: window.WindowStage, context: Context): void {
    windowStage.getMainWindow((err: BusinessError, data: window.Window) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to obtain the main window. Cause: ' + JSON.stringify(err));
        return;
      }
      let windowClass: window.Window = data;
      Logger.info(TAG, 'Succeeded in obtaining the main window. Data: ' + JSON.stringify(data));

      // Realize the immersive effect
      let isLayoutFullScreen = true;
      try {
        // Get status bar height
        let area: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        let naviBarArea: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        Logger.info(TAG,
          'Succeeded get the window navigation indicator HEIGHT: ' + data.getUIContext().px2vp(naviBarArea.bottomRect.height) + ' area: ' +
          JSON.stringify(naviBarArea));
        WindowUtil.getDeviceSize(context, area, naviBarArea);
        if (area.topRect.height > 0) {
          let promise: Promise<void> = windowClass.setWindowLayoutFullScreen(isLayoutFullScreen);
          promise.then(() => {
            Logger.info(TAG, 'Succeeded in setting the window layout to full-screen mode.');
          }).catch((err: BusinessError) => {
            Logger.error(TAG, 'Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
          });
        }
      } catch {
        Logger.error(TAG, 'Failed to set the window layout to full-screen mode. ');
      }
    });
  }

  static getDeviceSize(context: Context, area: window.AvoidArea, naviBarArea: window.AvoidArea): void {
    // Get device height
    window.getLastWindow(context).then((data: window.Window) => {
      let properties: window.WindowProperties;
      try {
        properties = data.getWindowProperties();
        AppStorage.setOrCreate<number>('statusBarHeight', WindowUtil.getDataUIContext(data, area.topRect.height));
        AppStorage.setOrCreate<number>('naviIndicatorHeight', WindowUtil.getDataUIContext(data, naviBarArea.bottomRect.height));
        AppStorage.setOrCreate<number>('deviceHeight', WindowUtil.getDataUIContext(data, properties.windowRect.height));
        AppStorage.setOrCreate<number>('deviceWidth', WindowUtil.getDataUIContext(data, properties.windowRect.width));
      } catch (exception) {
        Logger.error(TAG, 'Failed to get Last Window. Cause: ' + JSON.stringify(exception));
      }
    }).catch((exception: Error)=> {
      Logger.error(TAG, 'Failed to get Last Window. Cause: ' + JSON.stringify(exception));
    })
    ;
  }

  static getDataUIContext(data: window.Window, px2vp: number): number {
    let newValue = 0;
    try {
      newValue = data.getUIContext().px2vp(px2vp)
    } catch(exception) {
      Logger.error(TAG, 'Failed to get UI context. Cause: ' + JSON.stringify(exception));
    }
    return newValue;
  }

  static setMainWindowRestricted(context: Context): void {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      if (windowClass === undefined) {
        Logger.error(`MainWindowClass is undefined`);
        return;
      }
      // Setting restricted display
      windowClass.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED).catch((exception: Error) => {
        Logger.error(TAG, 'Failed to set orientation. Cause: ' + JSON.stringify(exception));
      });
    }).catch((exception: Error) => {
      Logger.error(TAG, 'Failed to set main window. Cause: ' + JSON.stringify(exception));
    });
  }

  static setMainWindowPortrait(context: Context): void {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      if (windowClass === undefined) {
        Logger.error(`MainWindowClass is undefined`);
        return;
      }
      // Setting restricted display
      windowClass.setPreferredOrientation(window.Orientation.PORTRAIT).catch((exception: Error) => {
        Logger.error(TAG, 'Failed to set orientation. Cause: ' + JSON.stringify(exception));
      });
    }).catch((exception: Error) => {
      Logger.error(TAG, 'Failed to set main window. Cause: ' + JSON.stringify(exception));
    });
  }

  static setMissionContinueActive(context: common.UIAbilityContext, active: boolean) {
    let activeState = active ? AbilityConstant.ContinueState.ACTIVE : AbilityConstant.ContinueState.INACTIVE;
    context.setMissionContinueState(activeState).then(() => {
      Logger.info('setMissionContinueState success');
    }).catch((err: BusinessError) => {
      Logger.error(`setMissionContinueState failed, code is ${err.code}, message is ${err.message}`);
    });
  }
}