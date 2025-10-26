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

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

export default class EntryAbility extends UIAbility {
  private windowObj?: window.Window;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'multi-convenient-life', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'multi-convenient-life', '%{public}s', 'Ability onDestroy');
  }

  private updateBreakpoint(windowWidth: number): void {
    try {
      let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels;
      let curBp: string = '';
      if (windowWidthVp < 600) {
        curBp = BreakpointConstants.BREAKPOINT_SM;
      } else if (windowWidthVp < 840) {
        curBp = BreakpointConstants.BREAKPOINT_MD;
      } else {
        curBp = BreakpointConstants.BREAKPOINT_LG;
      }
      AppStorage.setOrCreate('currentBreakpoint', curBp);
    } catch (e) {
      hilog.error(0x0000, 'multi-convenient-life', `getDefaultDisplaySync error. Cause: ${JSON.stringify(e)}`);
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'multi-convenient-life', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.getMainWindow().then((data: window.Window) => {
      try {
        this.windowObj = data;
        this.updateBreakpoint(this.windowObj.getWindowProperties().windowRect.width);
        this.windowObj.on('windowSizeChange', (windowSize: window.Size) => {
          this.updateBreakpoint(windowSize.width);
        })
      } catch (e) {
        hilog.error(0x0000, 'multi-convenient-life', `getWindowProperties error. Cause: ${JSON.stringify(e)}`);
      }
    }).catch((error: BusinessError) => {
      hilog.error(0x0000, 'multi-convenient-life', `getMainWindow error. Cause: ${error.code}`);
    });

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'multi-convenient-life', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'multi-convenient-life', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
      try {
        let windowClass: window.Window = windowStage.getMainWindowSync();

        let uiContext: UIContext | undefined = windowClass.getUIContext()
        AppStorage.setOrCreate('uiContext', uiContext);

        let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
        let avoidArea = windowClass.getWindowAvoidArea(type);
        let bottomRectHeight = avoidArea.bottomRect.height;
        AppStorage.setOrCreate('bottomRectHeight', uiContext.px2vp(bottomRectHeight));
        type = window.AvoidAreaType.TYPE_CUTOUT;
        avoidArea = windowClass.getWindowAvoidArea(type);
        let topRectHeight = avoidArea.topRect.height;
        AppStorage.setOrCreate('topRectHeight', uiContext.px2vp(topRectHeight));
      } catch (e) {
        hilog.error(0x0000, 'multi-convenient-life', `window error. Cause: ${JSON.stringify(e)}`);
      }
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'multi-convenient-life', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'multi-convenient-life', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'multi-convenient-life', '%{public}s', 'Ability onBackground');
  }
}
