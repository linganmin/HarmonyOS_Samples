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
import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../common/Constants';

const TAG: string = '[SingletonAbility]';

export default class EntryAbility extends UIAbility {
  private curBp: string = '';

  private updateBreakpoint(windowWidth: number): void {
    try {
      let windowWidthVp: number = windowWidth / display.getDefaultDisplaySync().densityPixels;
      let newBp: string = '';
      if (windowWidthVp < 600) {
        newBp = Constants.BREAK_POINT_SM;
      } else if (windowWidthVp < 840) {
        newBp = Constants.BREAK_POINT_MD;
      } else {
        newBp = Constants.BREAK_POINT_LG;
      }
      if (this.curBp !== newBp) {
        this.curBp = newBp;
        AppStorage.setOrCreate('currentBreakpoint', this.curBp);
      }
    } catch (error) {
      hilog.error(0x0000, TAG, '%{public}s', 'updateBreakpoint catch err:', (error as BusinessError).message);
    }
  }

  onCreate(): void {
    hilog.info(0x0000, TAG, '%{public}s', 'EntryAbility onCreate');
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `set color mode failed. code=${err.code}, message=${err.message}`);
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.getMainWindow().then((windowObj: window.Window) => {
      try {
        let type: window.AvoidAreaType = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
        let avoidArea: window.AvoidArea = windowObj.getWindowAvoidArea(type);
        let bottomRectHeight: number = avoidArea.bottomRect.height;
        AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight);
        type = window.AvoidAreaType.TYPE_SYSTEM;
        avoidArea = windowObj.getWindowAvoidArea(type);
        let topRectHeight: number = avoidArea.topRect.height;
        AppStorage.setOrCreate('topRectHeight', topRectHeight);
        this.updateBreakpoint(windowObj.getWindowProperties().windowRect.width);
        windowObj.on('windowSizeChange', (windowSize) => {
          this.updateBreakpoint(windowSize.width);
        });
      } catch (err) {
        hilog.error(0x0000, TAG, `Set window properties err. Cause: ${err.code}`);
      }
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `Get main window failed. Cause: ${err.message}`);
    });
    // Main window is created, set main page for this ability
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onWindowStageCreate');
    let resourceManager: resourceManager.ResourceManager = this.context.resourceManager;
    AppStorage.setOrCreate('resourceManager', resourceManager);
    windowStage.loadContent('pages/Index', (error, _) => {
      if (error.code) {
        hilog.error(0x0000, TAG, '%{public}s', 'Failed to load the content. Cause:', error.message);
        return;
      }
      hilog.info(0x0000, TAG, '%{public}s', 'Succeeded in loading the content');
      let windowClass: window.Window = windowStage.getMainWindowSync();
      let isLayoutFullScreen: boolean = true;
      windowClass.setWindowLayoutFullScreen(isLayoutFullScreen).then(() => {
        hilog.info(0x0000, TAG, '%{public}s', 'Succeeded in setting the window layout to full-screen mode');
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, 'Failed to set the window layout to full-screen mode. Cause:', err.message);
      });
    });
  }
}