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

import { UIAbility , Want ,AbilityConstant } from '@kit.AbilityKit';
import { window  } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit'
import { Logger } from '../utils/Logger';

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
    requestFullScreen(windowStage, this.context);
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      let uiContext:  UIContext | undefined = windowStage.getMainWindowSync().getUIContext();
      AppStorage.setOrCreate('uiContext', uiContext);
      Logger.info(TAG, 'testTag', 'Succeeded in loading the content.');
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

function requestFullScreen(windowStage: window.WindowStage, context: Context): void {
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
      getDeviceSize(context, area);
      let promise: Promise<void> = windowClass.setWindowLayoutFullScreen(isLayoutFullScreen);
      promise.then(() => {
        Logger.info(TAG, 'Succeeded in setting the window layout to full-screen mode.');
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
      });
    } catch {
      Logger.error(TAG, 'Failed to set the window layout to full-screen mode. ');
    }
  });
}

function getDeviceSize(context: Context, area: window.AvoidArea): void {
  // Get device height.
  window.getLastWindow(context).then((data: window.Window) => {
    const uiContext: UIContext | undefined = AppStorage.get('uiContext');
    let properties = data.getWindowProperties();
    if (area.topRect.height > 0) {
      AppStorage.setOrCreate<number>('statusBarHeight', uiContext?.px2vp(area.topRect.height));
    }
    AppStorage.setOrCreate<number>('deviceHeight', uiContext?.px2vp(properties.windowRect.height));
    AppStorage.setOrCreate<number>('deviceWidth', uiContext?.px2vp(properties.windowRect.width));
  });
}