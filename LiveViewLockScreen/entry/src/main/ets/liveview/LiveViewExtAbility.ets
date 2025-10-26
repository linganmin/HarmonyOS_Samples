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

// [Start windowSizeListener]
import { AbilityConstant, UIExtensionContentSession, Want } from '@kit.AbilityKit';
// [Start updateBreakPoint]
import { display, window } from '@kit.ArkUI';
// [StartExclude updateBreakPoint]
// [StartExclude windowSizeListener]
// [Start subscribeCommonEvent]
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
// [StartExclude subscribeCommonEvent]
import { LiveViewLockScreenExtensionAbility } from '@kit.LiveViewKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../constant/Constant';
import { LaneData } from '../model/RouteDataModel';

const TAG: string = '[LiveViewExtAbility]';

// Main class for lock screen live view extension, handles live view presentation on lock screen.
export default class LiveViewExtAbility extends LiveViewLockScreenExtensionAbility {
  // Common event subscriber for handling system events.
  private subscriber: commonEventManager.CommonEventSubscriber | null = null;
  private verticalBreakpoint: string = '';

  // [EndExclude updateBreakPoint]
  // Distinguish page layout using vertical breakpoints.
  private updateBreakPoint(windowSize: window.Size): void {
    try {
      let windowWidthVp: number = windowSize.width / display.getDefaultDisplaySync().densityPixels;
      let windowHeightVp: number = windowSize.height / display.getDefaultDisplaySync().densityPixels;
      let windowRatio: number = windowWidthVp / windowHeightVp;
      let verticalBreakpoint: string = Constants.BREAK_POINT_SM;
      // Vertical breakpoints are distinguished by aspect ratio.
      if (windowRatio < 0.8) {
        verticalBreakpoint = Constants.BREAK_POINT_SM;
      } else if (windowRatio > 1.2) {
        verticalBreakpoint = Constants.BREAK_POINT_LG;
      } else {
        verticalBreakpoint = Constants.BREAK_POINT_MD;
      }
      if (this.verticalBreakpoint !== verticalBreakpoint) {
        this.verticalBreakpoint = verticalBreakpoint;
        AppStorage.setOrCreate('verticalBreakpoint', this.verticalBreakpoint);
      }
      hilog.info(0x0000, TAG, `updateBreakpoint ${verticalBreakpoint}`);
    } catch (error) {
      hilog.error(0x0000, TAG, `updateBreakpoint catch err:`, (error as BusinessError).message);
    }
  }

  // [End updateBreakPoint]

  onCreate(_launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'LiveViewLockScreenExtAbility onCreate begin.');
  }

  onForeground(): void {
    hilog.info(0x0000, TAG, 'LiveViewLockScreenExtAbility onForeground begin.');
  }

  onBackground(): void {
    hilog.info(0x0000, TAG, 'LiveViewLockScreenExtAbility onBackground begin.');
  }

  onDestroy(): void | Promise<void> {
    hilog.info(0x0000, TAG, 'LiveViewLockScreenExtAbility onDestroy begin.');
  }

  // [Start createLiveView]
  // Core logic when creating UI session.
  onSessionCreate(_want: Want, session: UIExtensionContentSession): void {
    // [StartExclude createLiveView]
    hilog.info(0x0000, TAG, 'LiveViewLockScreenExtAbility onSessionCreate begin.');
    // [EndExclude windowSizeListener]
    try {
      // Window size listener.
      const extensionWindow = session.getUIExtensionWindowProxy();
      extensionWindow.on('windowSizeChange', (windowSize: window.Size) => {
        this.updateBreakPoint(windowSize);
      });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, TAG, `Session update break point failed. code: ${err.code}, message: ${err.message}`);
    }
    // [End windowSizeListener]
    // [EndExclude subscribeCommonEvent]

    // Initialize event subscription.
    let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: ['live_view_lock_screen'],
      publisherBundleName: 'com.example.mapliveviewsample',
      priority: 0
    };
    commonEventManager.createSubscriber(subscribeInfo,
      (error: BusinessError, data: commonEventManager.CommonEventSubscriber) => {
        if (error) {
          hilog.error(0x0000, TAG, '%{public}s',
            `Failed to create subscriber. code is ${error.code} message is ${error.message}.`);
          return;
        }
        this.subscriber = data;
        hilog.info(0x0000, TAG, '%{public}s', 'Succeeded in creating subscriber.');
        // Event handling logic.
        commonEventManager.subscribe(this.subscriber,
          async (error: BusinessError, data: commonEventManager.CommonEventData) => {
            if (error) {
              hilog.error(0x0000, TAG, '%{public}s',
                `Failed to subscribe commonEvent. code is ${error.code} message is ${error.message}.`);
              return;
            }
            hilog.info(0x0000, TAG, '%{public}s', 'Succeeded in subscribe commonEvent success.');
            if (data.parameters) {
              let laneData = data.parameters['laneData'] as LaneData;
              AppStorage.setOrCreate('laneData', laneData);
              hilog.info(0x0000, TAG, '%{public}s', 'Succeeded in receive commonEvent.');
            }
          });
      })
    // [End subscribeCommonEvent]
    // [EndExclude createLiveView]
    try {
      session.loadContent('liveview/LockScreenPage');
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, TAG, `Session load content failed. code: ${err.code}, message: ${err.message}`);
    }
  }

  // [End createLiveView]

  // Cleanup operations when destroying UI session
  onSessionDestroy(): void {
    commonEventManager.unsubscribe(this.subscriber, () => {
      this.subscriber = null;
    });
    hilog.info(0x0000, TAG, 'LiveViewLockScreenExtAbility onSessionDestroy begin.');
  }

  onConfigurationUpdate(): void {
    hilog.info(0x0000, TAG, 'LiveViewLockScreenExtAbility onConfigurationUpdate begin.');
  }
}