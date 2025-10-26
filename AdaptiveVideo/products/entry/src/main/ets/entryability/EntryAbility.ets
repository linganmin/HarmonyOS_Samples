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
 *
 */
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { BreakpointConstants, CommonConstants } from 'base';

const DOMAIN = 0x0000;
const LOG_TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  private uiContext?: UIContext;

  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (error) {
      hilog.error(DOMAIN, LOG_TAG, '%{public}s', 'Set context color mode failed.');
    }
    hilog.info(DOMAIN, LOG_TAG, '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, LOG_TAG, '%{public}s', 'Ability onDestroy');
  }


  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, LOG_TAG, '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, LOG_TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, LOG_TAG, 'Succeeded in loading the content.');
      AppStorage.setOrCreate(CommonConstants.WINDOW_STAGE, windowStage);
      windowStage.getMainWindow().then((windowClass: window.Window) => {
        // [Start fullscreen]
        // Set full screen
        windowClass.setWindowLayoutFullScreen(true).catch(() => {
          hilog.error(DOMAIN, LOG_TAG, '%{public}s', 'Set WindowLayoutFullScreen failed.');
        })
        let deviceTypeInfo: string = deviceInfo.deviceType;
        if (deviceTypeInfo === '2in1') {
          if (canIUse('SystemCapability.Window.SessionManager')) {
            // 2in1 device settings hide title bar and title bar height
            try {
              windowClass.setWindowDecorVisible(false);
            } catch (error) {
              hilog.error(DOMAIN, LOG_TAG, '%{public}s', 'Set WindowDecorVisible failed.');
            }
            // [StartExclude fullscreen]
            try {
              windowClass.setWindowDecorHeight(56)
            } catch (error) {
              hilog.error(DOMAIN, LOG_TAG, '%{public}s', 'Set WindowDecorHeight failed.');
            }
            // [EndExclude fullscreen]
          }
        }
        // [End fullscreen]
        this.uiContext = windowClass.getUIContext();
        let widthBp: WidthBreakpoint = this.uiContext.getWindowWidthBreakpoint();
        let heightBp: HeightBreakpoint = this.uiContext.getWindowHeightBreakpoint();
        AppStorage.setOrCreate(BreakpointConstants.CURRENT_WIDTH_BREAKPOINT, widthBp);
        AppStorage.setOrCreate('currentHeightBreakpoint', heightBp);
        const windowRect = windowClass.getWindowProperties().windowRect;
        AppStorage.setOrCreate(CommonConstants.WINDOW_SIZE, {
          width: this.uiContext.px2vp(windowRect.width), height: this.uiContext.px2vp(windowRect?.height)
        } as window.Size);
        // Monitor changes and refresh data
        windowClass.on('windowSizeChange', this.onWindowSizeChange);
        // Obtain the area where the layout avoids the obstruction
        let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // navigationBar
        let avoidArea: window.AvoidArea;
        avoidArea = windowClass.getWindowAvoidArea(type);

        let bottomRectHeight = avoidArea.bottomRect.height; // get navigationBar height
        AppStorage.setOrCreate(CommonConstants.NAVIGATION_INDICATOR_HEIGHT, this.uiContext.px2vp(bottomRectHeight));
        type = window.AvoidAreaType.TYPE_SYSTEM; // statusBar
        avoidArea = windowClass.getWindowAvoidArea(type);
        hilog.error(DOMAIN, LOG_TAG, '%{public}s', 'Get WindowAvoidArea failed.');
        let topRectHeight = avoidArea.topRect.height; // get statusBar height
        AppStorage.setOrCreate(CommonConstants.SYSTEM_HEIGHT, this.uiContext.px2vp(topRectHeight));
        // Register a listener function to dynamically obtain the avoidance area data.
        windowClass.on('avoidAreaChange', this.onAvoidAreaChange);
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, LOG_TAG,
          `Failed to obtain the main window. Cause code: ${err.code}, message: ${err.message}`);
      });
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, LOG_TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, LOG_TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, LOG_TAG, '%{public}s', 'Ability onBackground');
  }

  /**
   * Window change listener function
   */
  private onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    let widthBp: WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
    AppStorage.setOrCreate(BreakpointConstants.CURRENT_WIDTH_BREAKPOINT, widthBp);
    // 2in1 device: Full screen and non-full screen scenarios only trigger onWindowSizeChange, not onDisplayChange
    const currentWindowSize: window.Size = {
      width: this.uiContext!.px2vp(windowSize.width), height: this.uiContext!.px2vp(windowSize.height)
    };
    AppStorage.setOrCreate(CommonConstants.WINDOW_SIZE, currentWindowSize);
  };
  /**
   * Regional avoidance listening function
   */
  private onAvoidAreaChange: (avoidAreaOptions: window.AvoidAreaOptions) => void =
    (avoidAreaOptions: window.AvoidAreaOptions) => {
      if (avoidAreaOptions.type === window.AvoidAreaType.TYPE_SYSTEM) {
        let topRectHeight = avoidAreaOptions.area.topRect.height;
        AppStorage.setOrCreate(CommonConstants.SYSTEM_HEIGHT, this.uiContext!.px2vp(topRectHeight));
      } else if (avoidAreaOptions.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        let bottomRectHeight = avoidAreaOptions.area.bottomRect.height;
        AppStorage.setOrCreate(CommonConstants.NAVIGATION_INDICATOR_HEIGHT, this.uiContext!.px2vp(bottomRectHeight));
      }
    };
}