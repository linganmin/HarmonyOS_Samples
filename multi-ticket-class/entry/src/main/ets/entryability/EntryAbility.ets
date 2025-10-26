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

import { ConfigurationConstant, UIAbility } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import Logger from '../utils/Logger';

export default class EntryAbility extends UIAbility {
  private uiContext?: UIContext;
  private onWindowSizeChange: (windowSize: window.Size) => void = () => {
    let widthBp: WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
    AppStorage.setOrCreate('currentWidthBreakpoint', widthBp);
    let heightBp: HeightBreakpoint = this.uiContext!.getWindowHeightBreakpoint();
    AppStorage.setOrCreate('currentHeightBreakpoint', heightBp);
  };
  private windowStatusChange: (WindowStatusType: window.WindowStatusType) => void =
    (WindowStatusType: window.WindowStatusType) => {
      if (WindowStatusType === 4 || WindowStatusType === 5) {
        AppStorage.setOrCreate('isSplitScreen', true);
      } else if (WindowStatusType === 1) {
        AppStorage.setOrCreate('isSplitScreen', false);
      } else {
        Logger.info('Succeeded in enabling the listener for window status changes. Data: ' + WindowStatusType);
      }
    };

  onCreate(): void {
    Logger.info('EntryAbility', '%{public}s', 'Ability onCreate');
    AppStorage.setOrCreate('systemColorMode', this.context.config.colorMode);
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (exception) {
      Logger.error(`Failed to setColorMode. Cause code: ${exception.code}, message: ${exception.message}`);
    }
  }

  onDestroy(): void {
    Logger.info('EntryAbility', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info('EntryAbility', '%{public}s', 'Ability onWindowStageCreate');
    let context = this.context;
    let resourceManager: resourceManager.ResourceManager = context.resourceManager;
    AppStorage.setOrCreate('resourceManager', resourceManager);
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        Logger.error('EntryAbility', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info('EntryAbility', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');


      // Immersive Adaptation
      this.immersionFuc(windowStage);

      const isWindowAvailable = canIUse('SystemCapability.Window.SessionManager');
      if (isWindowAvailable) {
        // Determine the current application window mode.
        // 1: Full-screen split-screen mode, 5: Split-screen mode, 4: Panoramic multi-window mode
        try {
          let windowClass: window.Window = windowStage.getMainWindowSync();
          windowClass.on('windowStatusChange', this.windowStatusChange);
        } catch (exception) {
          Logger.error(`Failed to unregister callback. Cause code: ${exception.code}, message: ${exception.message}`);
        }
      } else {
        Logger.info('Window not by this device.');
      }
      windowStage.getMainWindow().then((data: window.Window) => {
        try {
          this.uiContext = data.getUIContext();
          let widthBp: WidthBreakpoint = this.uiContext.getWindowWidthBreakpoint();
          let heightBp: HeightBreakpoint = this.uiContext.getWindowHeightBreakpoint();
          AppStorage.setOrCreate('currentWidthBreakpoint', widthBp);
          AppStorage.setOrCreate('currentHeightBreakpoint', heightBp);
          data.on('windowSizeChange', this.onWindowSizeChange);
        } catch (error) {
          Logger.error(`GetUIContext failed. Cause code: ${err.code}, message: ${err.message}`);
        }
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to obtain the main window. Cause code: ${err.code}, message: ${err.message}`);
      });
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info('EntryAbility', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info('EntryAbility', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info('EntryAbility', '%{public}s', 'Ability onBackground');
  }

  /**
   * Page immersion.
   */
  immersionFuc(windowStage: window.WindowStage): void {
    try {
      let windowClass: window.Window = windowStage.getMainWindowSync();
      windowClass.setWindowLayoutFullScreen(true);
      let navigationBarArea: window.AvoidArea =
        windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      let area: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      AppStorage.setOrCreate<number>('naviIndicatorHeight',
        windowClass.getUIContext().px2vp(navigationBarArea.bottomRect.height));
      AppStorage.setOrCreate<number>('statusBarHeight', windowClass.getUIContext().px2vp(area.topRect.height));
      AppStorage.setOrCreate<window.Window>('windowClass', windowClass);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error('EntryAbility', `immersionFuc failed, error code=${err.code}, message=${err.message}`);
    }
  }
}