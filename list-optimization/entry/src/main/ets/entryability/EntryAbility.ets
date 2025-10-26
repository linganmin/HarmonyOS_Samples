/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import { common } from '@kit.AbilityKit';
import { UIAbility , Want ,AbilityConstant } from '@kit.AbilityKit';
import { window  } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit'
import { Logger } from '../utils/Logger';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    Logger.info(TAG, 'EntryAbility onCreate');
    Logger.info(`want: ${JSON.stringify(want)}, launchParam: ${JSON.stringify(launchParam)}`);
  }

  onDestroy(): void {
    Logger.info(TAG, 'EntryAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'EntryAbility onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        return;
      }
    });
    windowStage.getMainWindow((err, data) => {
      if (err.code) {
        return;
      }
      let windowClass: window.Window = data;
      let uiContext: UIContext = windowClass.getUIContext();
      requestFullScreen(windowStage, uiContext);
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, 'MainAbility onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info(TAG, 'MainAbility onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info(TAG, 'MainAbility onBackground');
  }

}

function requestFullScreen(windowStage: window.WindowStage, UIContext: UIContext): void {
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
      let type = window.AvoidAreaType.TYPE_SYSTEM;
      // Get status bar height.
      let area: window.AvoidArea = windowClass.getWindowAvoidArea(type);
      getDeviceSize(UIContext, area);
      let promise: Promise<void> = windowClass.setWindowLayoutFullScreen(isLayoutFullScreen);
      promise.then(() => {
        windowStage.getMainWindowSync().setWindowBackgroundColor('#F1F3F5');
        Logger.info(TAG, 'Succeeded in setting the window layout to full-screen mode.');
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
      });
    } catch {
      Logger.error(TAG, 'Failed to set the window layout to full-screen mode. ');
    }
  });
}

function getDeviceSize(UIContext: UIContext, area: window.AvoidArea): void {
  let context = UIContext.getHostContext() as common.UIAbilityContext;

  // Get device height.
  window.getLastWindow(context).then((data: window.Window) => {
    let properties = data.getWindowProperties();
    if (area.topRect.height > 0) {
      AppStorage.setOrCreate<number>('statusBarHeight', UIContext.px2vp(area.topRect.height));
    }
    AppStorage.setOrCreate<number>('deviceHeight', UIContext.px2vp(properties.windowRect.height));
    AppStorage.setOrCreate<number>('deviceWidth', UIContext.px2vp(properties.windowRect.width));
  }).catch((err: BusinessError) => {
    hilog.error(0xFF00, 'ListOptimization', `getLastWindow fail, code = ${err.code}, message = ${err.message}`);
  });
}