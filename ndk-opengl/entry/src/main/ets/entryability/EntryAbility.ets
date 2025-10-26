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
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../utils/Logger';
import { hilog } from '@kit.PerformanceAnalysisKit';

// [Start get_breakPoint]
export default class EntryAbility extends UIAbility {
  public uiContext?: UIContext;
  public onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    let widthBp: WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
    AppStorage.setOrCreate('currentWidthBreakpoint', widthBp);
    let heightBp: HeightBreakpoint = this.uiContext!.getWindowHeightBreakpoint();
    AppStorage.setOrCreate('currentHeightBreakpoint', heightBp);
    AppStorage.setOrCreate('windowHeight', windowSize.height);
    AppStorage.setOrCreate('windowWidth', windowSize.width);
  };
  // [StartExclude get_breakPoint]
  // [Start onAvoidAreaChange]
  public onAvoidAreaChange: (avoidArea: window.AvoidAreaOptions) => void = (avoidArea: window.AvoidAreaOptions) => {
    if (avoidArea.type === window.AvoidAreaType.TYPE_CUTOUT) {
      AppStorage.setOrCreate('cutout', avoidArea);
    }
  }

  // [StartExclude onAvoidAreaChange]
  onCreate() {
    Logger.info('Ability onCreate');
  }

  onDestroy() {
    Logger.info('Ability onDestroy');
  }

  // [EndExclude get_breakPoint]

  // [EndExclude onAvoidAreaChange]
  // [Start immersive]
  onWindowStageCreate(windowStage: window.WindowStage) {
    // [StartExclude onAvoidAreaChange]
    // [StartExclude immersive]
    // Main window is created, set main page for this ability
    // [StartExclude get_breakPoint]
    Logger.info('Ability onWindowStageCreate');

    // [EndExclude immersive]
    try {
      // Set the main window to immersive and hide the navigation bar.
      windowStage.getMainWindowSync().setWindowLayoutFullScreen(true);
      windowStage.getMainWindowSync().setWindowSystemBarEnable([]);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'EntryAbility',
        `Failed to set the window state. Error code=${err.code}, message=${err.message}`);
    }

    // [StartExclude immersive]
    // Set the display direction of the main window.
    let windowClass: window.Window | undefined = undefined;
    // [EndExclude onAvoidAreaChange]
    windowStage.getMainWindow((err: BusinessError, data) => {
      // [StartExclude onAvoidAreaChange]
      if (err.code) {
        Logger.error('Failed to obtain the main window. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      windowClass = data;
      // [Start set_rotate]
      // Automatically rotate vertically following the sensor.
      let orientation = window.Orientation.AUTO_ROTATION_PORTRAIT;
      try {
        windowClass.setPreferredOrientation(orientation, (err: BusinessError) => {
          if (err.code) {
            Logger.error('Failed to set window orientation. Cause: %{public}s', JSON.stringify(err) ?? '');
            return;
          }
          Logger.info('Succeeded in setting window orientation. Data: %{public}s');
        })
      } catch (exception) {
        Logger.error('Failed to set window orientation. Cause: %{public}s', JSON.stringify(exception) ?? '');
      }
      // [End set_rotate]
    })
    // [EndExclude get_breakPoint]
    // [EndExclude onAvoidAreaChange]
    windowStage.loadContent('pages/Index', (err, data) => {
      // [StartExclude onAvoidAreaChange]
      // [StartExclude get_breakPoint]
      if (err.code) {
        Logger.error('Failed to load the content. Cause: ' + JSON.stringify(err));
        return;
      }
      Logger.info('Succeeded in loading the content. Data: ' + JSON.stringify(data));
      // [EndExclude get_breakPoint]
      windowStage.getMainWindow((err: BusinessError, data) => {
        if (err.code) {
          Logger.error('Failed to obtain the main window. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }
        // Window size acquisition and monitoring.
        let properties = data.getWindowProperties();
        AppStorage.setOrCreate('windowHeight', properties.windowRect.height);
        AppStorage.setOrCreate('windowWidth', properties.windowRect.width);
        // Breakpoint acquisition and listening.
        this.uiContext = data.getUIContext();
        let widthBp: WidthBreakpoint = this.uiContext.getWindowWidthBreakpoint();
        let heightBp: HeightBreakpoint = this.uiContext.getWindowHeightBreakpoint();
        AppStorage.setOrCreate('currentWidthBreakpoint', widthBp);
        AppStorage.setOrCreate('currentHeightBreakpoint', heightBp);
        data.on('windowSizeChange', this.onWindowSizeChange);
        // [EndExclude onAvoidAreaChange]
        // [StartExclude get_breakPoint]
        // Monitor changes in the location of the cutout area.
        let avoidArea: window.AvoidArea = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT);
        this.onAvoidAreaChange({ type: window.AvoidAreaType.TYPE_CUTOUT, area: avoidArea });
        data.on('avoidAreaChange', this.onAvoidAreaChange);
        // [EndExclude get_breakPoint]
      })
    });
    // [EndExclude immersive]
  }

  // [End immersive]
  // [End onAvoidAreaChange]

  // [StartExclude get_breakPoint]
  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    Logger.info('Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    Logger.info('Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    Logger.info('%{public}s', 'Ability onBackground');
  }

  // [EndExclude get_breakPoint]
};

// [End get_breakPoint]