/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* 最佳实践: 一多窗口适配开发实践
*/

// [Start setdefaultorientation]

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

export default class EntryAbility extends UIAbility {
  windowObj?: window.Window;
  uiContext?: UIContext;
  onWindowSizeChange: (data: window.Size) => void = () => {
    this.setDefaultOrientation();
  }

  setDefaultOrientation(): void {
    try {
      let windowRect: window.Rect = this.windowObj!.getWindowProperties().windowRect;
      let windowWidthVp: number = this.uiContext!.px2vp(windowRect.width);
      let windowHeightVp: number = this.uiContext!.px2vp(windowRect.height);

      // If this condition is met, the window can be rotated.
      if (Math.min(windowWidthVp, windowHeightVp) > 348) {
        this.windowObj?.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED)
          .catch((err: BusinessError) => {
            hilog.error(0x000, 'testTag', `setPreferredOrientation failed, code=${err.code}, message=${err.message}`)
          })
      }
      // Otherwise, the window is displayed in portrait mode.
      else {
        this.windowObj?.setPreferredOrientation(window.Orientation.PORTRAIT)
          .catch((err: BusinessError) => {
            hilog.error(0x000, 'testTag', `setPreferredOrientation failed, code=${err.code}, message=${err.message}`)
          })
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.warn(0x000, 'testTag', `getWindowProperties failed, code=${err.code}, message=${err.message}`);
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.getMainWindow().then((windowObj) => {
      this.windowObj = windowObj;
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag',
        `Failed to obtain the main window. Cause code: ${err.code}, message: ${err.message}`);
    });
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      try {
        this.uiContext = this.windowObj!.getUIContext();
        this.setDefaultOrientation();
        this.windowObj!.on('windowSizeChange', this.onWindowSizeChange);
        hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      } catch (error) {
        let err = error as BusinessError;
        hilog.warn(0x000, 'testTag', `getUIContext failed, code=${err.code}, message=${err.message}`);
      }

    });
  }
}

// [End setdefaultorientation]