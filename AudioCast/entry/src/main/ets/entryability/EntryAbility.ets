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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import { fileIo } from '@kit.CoreFileKit';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  private windowObj?: window.Window;

  async onCreate(): Promise<void> {
    AppStorage.setOrCreate('context', this.context);
    let fileList: Array<string> = [];
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      fileList = this.context.resourceManager.getRawFileListSync('');
    } catch (err) {
      hilog.error(DOMAIN, TAG, `setColorMode failed.`);
    }

    for (const fileName of fileList) {
      if (fileName.includes('.')) {
        try {
          let value = await this.context.resourceManager.getRawFileContent(fileName);
          let myBuffer: ArrayBufferLike = value.buffer;
          let filePath = this.context.filesDir + `/${fileName}`;
          let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
          fileIo.writeSync(file.fd, myBuffer);
          fileIo.closeSync(file);
        } catch (error) {
          hilog.error(DOMAIN, TAG, `fileIO failed Cause, the error is ${JSON.stringify(error)}`);
        }
      }
    }
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      windowStage.getMainWindow().then((data: window.Window) => {
        this.windowObj = data;
        AppStorage.setOrCreate<window.Window>('window', data);
        data.setWindowLayoutFullScreen(true);
        let topArea = this.windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
        const uiContext = data.getUIContext();
        AppStorage.setOrCreate('uiContext', uiContext);
        let topHeight = uiContext.px2vp(topArea.topRect.height)
        AppStorage.setOrCreate('topHeight', topHeight)
        let bottomArea = this.windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
        let bottomHeight = uiContext.px2vp(bottomArea.bottomRect.height)
        AppStorage.setOrCreate('bottomHeight', bottomHeight)
        this.updateBreakpoint(this.windowObj.getWindowProperties().windowRect.width);
        this.windowObj.on('windowSizeChange', (windowSize: window.Size) => {
          this.updateBreakpoint(windowSize.width);
        })
      })
      hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');
    });
  }

  private updateBreakpoint(windowWidth: number): void {
    try {
      let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels;
      let curBp: string = '';
      if (windowWidthVp < BreakpointConstants.BREAKPOINT_VALUE_NUMBER[1]) {
        curBp = BreakpointConstants.BREAKPOINT_SM;
      } else if (windowWidthVp < BreakpointConstants.BREAKPOINT_VALUE_NUMBER[2]) {
        curBp = BreakpointConstants.BREAKPOINT_MD;
      } else {
        curBp = BreakpointConstants.BREAKPOINT_LG;
      }
      AppStorage.setOrCreate('currentBreakpoint', curBp);
    } catch (err) {
      hilog.error(DOMAIN, TAG, `getDefaultDisplaySync failed.error is ${JSON.stringify(err)}`);
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onBackground');
  }
}