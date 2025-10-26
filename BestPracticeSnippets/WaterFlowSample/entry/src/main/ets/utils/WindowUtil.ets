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

import type { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { CommonConstants } from '../common/constants/CommonConstants';

const TAG: string = '[WindowUtil]';

export class WindowUtil {
  private static windowClass: window.Window;

  public static initialize(windowStage: window.WindowStage): void {
    try {
      WindowUtil.windowClass = windowStage.getMainWindowSync();
      WindowUtil.requestFullScreen();
      WindowUtil.registerBreakPoint();
    } catch (err) {
      hilog.error(0x0000, TAG, `WindowUtil initialize Failed. Cause: ${err.message}`);
    }
  }

  private static requestFullScreen(): void {
    // Realize the immersive effect.
    try {
      const promise: Promise<void> = WindowUtil.windowClass.setWindowLayoutFullScreen(true);
      promise.then(() => {
        hilog.info(0x0000, TAG, 'Succeeded in setting the window layout to full-screen mode.');
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG,
          `Failed to set the window layout to full-screen mode. Cause: ${err.code}, ${err.message}`);
      });
    } catch {
      hilog.error(0x0000, TAG, 'Failed to set the window layout to full-screen mode. ');
    }
  }

  private static registerBreakPoint(): void {
    WindowUtil.updateAvoidArea(WindowUtil.windowClass);
    WindowUtil.windowClass.on('avoidAreaChange',
      (avoidAreaOption) => WindowUtil.setAvoidArea(avoidAreaOption.type, avoidAreaOption.area));
  }

  private static updateAvoidArea(windowObj: window.Window): void {
    try {
      WindowUtil.setAvoidArea(window.AvoidAreaType.TYPE_SYSTEM,
        windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM));
      WindowUtil.setAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR,
        windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR));
    } catch (err) {
      hilog.error(0x0000, 'testTag', 'getWindowAvoidArea get exception. Cause: %{public}s', JSON.stringify(err) ?? '');
    }
  }

  // Get status bar height and indicator height.
  private static setAvoidArea(type: window.AvoidAreaType, area: window.AvoidArea): void {
    try {
      let uiContext: UIContext = WindowUtil.windowClass.getUIContext();
      if (type === window.AvoidAreaType.TYPE_SYSTEM) {
        AppStorage.setOrCreate(CommonConstants.AS_KEY_STATUS_BAR_HEIGHT, uiContext.px2vp(area.topRect.height));
      } else if (type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        AppStorage.setOrCreate(CommonConstants.AS_KEY_NAVIGATOR_BAR_HEIGHT, uiContext.px2vp(area.bottomRect.height));
      }
    } catch (err) {
      hilog.error(0x0000, 'testTag', 'getUIContext get exception. Cause: %{public}s', JSON.stringify(err) ?? '');
    }
  }
}