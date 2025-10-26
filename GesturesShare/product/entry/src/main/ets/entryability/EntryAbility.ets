/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
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

import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { url } from '@kit.ArkTS';
import { BreakpointConstants } from '@ohos/common';

export default class EntryAbility extends UIAbility {
  private mainWindowClass?: window.Window;
  private uiContext?: UIContext;

  // [Start onCreate]
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // [StartExclude onCreate]
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'GesturesShare', `setColorMode failed, error: ${error.code} ${error.message}`);
    }
    hilog.info(0x0000, 'GesturesShare', '%{public}s', 'Ability onCreate');
    // [EndExclude onCreate]
    let videoIndex = this.getVideoIndex(want);
    if (videoIndex !== '') {
      AppStorage.setOrCreate('GesturesShare_shareVideoIndex', Number.parseInt(videoIndex));
      AppStorage.setOrCreate('GesturesShare_isShareLink', true);
    }
  }
  // [End onCreate]

  // [Start onNewWant]
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    let videoIndex = this.getVideoIndex(want);
    if (videoIndex !== '') {
      AppStorage.setOrCreate('GesturesShare_shareVideoIndex', Number.parseInt(videoIndex));
      AppStorage.setOrCreate('GesturesShare_isShareLink', true);
    }
  }
  // [End onNewWant]

  // [Start getVideoIndex]
  private getVideoIndex(want: Want): string {
    try {
      let uri = want?.uri;
      let videoIndex: string = '';
      // Parse the parameters to obtain the app linking
      if (uri) {
        let urlObject = url.URL.parseURL(want?.uri);
        videoIndex = urlObject.params.get('videoIndex') as string;
        hilog.info(0x0000, 'GesturesShare', `getAid aid:${videoIndex}`);
      }
      return videoIndex;
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'GesturesShare', `Failed to getVideoIndex, error: ${error.code} ${error.message}`);
    }
    return '';
  }
  // [End getVideoIndex]

  onDestroy(): void {
    hilog.info(0x0000, 'GesturesShare', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'GesturesShare', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error( 0x0000, 'GesturesShare', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      windowStage.getMainWindow().then((data: window.Window) => {
        this.mainWindowClass = data;
        this.updateWidthBp();
        try {
          this.uiContext = data.getUIContext();
        } catch (err) {
          let error = err as BusinessError;
          hilog.error(0x0000, 'GesturesShare', `getUIContext error ${error.code} ${error.message}`);
        }
        data.on('windowSizeChange', this.onWindowSizeChange);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'GesturesShare',
          `Failed to obtain the main window. Cause code: ${err.code}, message: ${err.message}`);
      });
      hilog.info(0x0000, 'GesturesShare', 'Succeeded in loading the content.');
    });
  }

  private onWindowSizeChange: () => void = () => {
    this.updateWidthBp();
  };

  /**
   * Update breakpoints according to the application window size.
   */
  updateWidthBp(): void {
    if (!this.uiContext) {
      return;
    }
    try {
      let mainWindow: window.WindowProperties = this.mainWindowClass!.getWindowProperties();
      let windowWidth: number = mainWindow.windowRect.width;
      let windowWidthVp = this.uiContext.px2vp(windowWidth);
      let widthBp: string = '';
      if (windowWidthVp < 320) {
        widthBp = BreakpointConstants.BREAKPOINT_XS;
      } else if (windowWidthVp >= 320 && windowWidthVp < 600) {
        widthBp = BreakpointConstants.BREAKPOINT_SM;
      } else if (windowWidthVp >= 600 && windowWidthVp < 840) {
        widthBp = BreakpointConstants.BREAKPOINT_MD;
      } else if (windowWidthVp >= 840 && windowWidthVp < 1440) {
        widthBp = BreakpointConstants.BREAKPOINT_LG;
      } else {
        widthBp = BreakpointConstants.BREAKPOINT_XL;
      }
      AppStorage.setOrCreate(BreakpointConstants.BREAKPOINT_NAME, widthBp);
      AppStorage.setOrCreate('windowWidth', windowWidth);
      let windowHeight: number = mainWindow.windowRect.height;
      AppStorage.setOrCreate('windowHeight', windowHeight);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'GesturesShare', `updateWidthBp error ${error.code} ${error.message}`);
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'GesturesShare', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'GesturesShare', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'GesturesShare', '%{public}s', 'Ability onBackground');
  }
}