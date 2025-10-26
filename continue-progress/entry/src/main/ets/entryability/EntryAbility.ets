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

import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UIContext, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalContext } from '../utils/GlobalContext';
import { BreakpointConstants } from '../constants/BreakpointConstants';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private mainWindowClass?: window.Window;
  private uiContext?: UIContext;

  // [Start on_create]
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    GlobalContext.getContext().setObject('abilityWant', want);
    GlobalContext.getContext().setObject('context', this.context);
    if (want.parameters) {
      if (want.parameters.currentTime) {
        GlobalContext.getContext().setObject('currentTime', want.parameters.currentTime);
      }
    }
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      if (want.parameters) {
        this.continueRestore(want);
      }
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  // [End on_create]

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    GlobalContext.getContext().setObject('abilityWant', want);
    GlobalContext.getContext().setObject('context', this.context)
    if (want.parameters) {
      if (want.parameters.currentTime) {
        GlobalContext.getContext().setObject('currentTime', want.parameters.currentTime);
      }
    }
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      if (want.parameters) {
        this.continueRestore(want);
      }
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onNewWant');
  }

  // [Start continue_restore]
  continueRestore(want: Want) {
    if (!want.parameters) {
      hilog.error(0x0000, 'EntryAbility', 'missing sessionId');
      return;
    }
    let currentPage = want.parameters.currentPage as string;
    AppStorage.setOrCreate('currentPage', currentPage);
    want.parameters.continueIndex && AppStorage.setOrCreate('continueWaterOffset', want.parameters.continueIndex);
    want.parameters.currentOffset && AppStorage.setOrCreate('continueOffset', want.parameters.currentOffset);
    want.parameters.continueHeight && AppStorage.setOrCreate('continueHeight', want.parameters.continueHeight);
    AppStorage.setOrCreate('continueEntry', true);
    AppStorage.setOrCreate('setCurrentOffset', true);
    want.parameters.continueTime && AppStorage.setOrCreate('currentTime', want.parameters.continueTime);
    want.parameters.continueItem && AppStorage.setOrCreate('videoIndex', want.parameters.continueItem);
    want.parameters.continueItem && AppStorage.setOrCreate('videoSelect', want.parameters.continueItem);
    want.parameters.flag && AppStorage.setOrCreate('flag', want.parameters.flag);
    AppStorage.setOrCreate('continue', true);
    AppStorage.setOrCreate('continueRestore', true);
    want.parameters.pageUrl && AppStorage.setOrCreate('pageUrl', want.parameters.pageUrl);
    want.parameters.scrollDistance && AppStorage.setOrCreate('scrollDistance', want.parameters.scrollDistance);
    want.parameters.breakpoint && AppStorage.setOrCreate('continueBreakpoint', want.parameters.breakpoint);

    this.context.restoreWindowStage(new LocalStorage());
  }

  // [End continue_restore]

  // [Start on_continue]
  async onContinue(wantParam: Record<string, Object>): Promise<AbilityConstant.OnContinueResult> {
    // 1.1 Retrieve the data to be connected and transmit it via wantParam.
    let continueIndex = AppStorage.get('continueIndex') as number;
    wantParam.continueIndex = continueIndex;
    let currentOffset = AppStorage.get('currentOffset') as number;
    wantParam.currentOffset = currentOffset;
    let continueHeight = AppStorage.get('listItemHeight') as number;
    wantParam.continueHeight = continueHeight;
    let currentTime = AppStorage.get('currentTime') as number;
    wantParam.continueTime = currentTime;
    let videoIndex = AppStorage.get('videoIndex') as number;
    wantParam.continueItem = videoIndex;
    let flag = AppStorage.get('flag') as boolean;
    wantParam.flag = flag;
    let url = AppStorage.get('pageUrl') as string;
    wantParam.pageUrl = url;
    let distance = AppStorage.get('scrollDistance') as number;
    wantParam.scrollDistance = distance;
    let breakpoint = AppStorage.get(BreakpointConstants.BREAKPOINT_NAME) as string;
    wantParam.breakpoint = breakpoint;
    let pageInfos = AppStorage.get('pageInfos') as NavPathStack;
    let pageArr = pageInfos.getAllPathName();
    let currentPage = '';
    if (pageArr.length > 0) {
      currentPage = pageArr[pageArr.length - 1];
    }
    AppStorage.setOrCreate('continue', false);
    wantParam.currentPage = currentPage;

    return AbilityConstant.OnContinueResult.AGREE;
  }

  // [End on_continue]

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability.
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      windowStage.getMainWindow().then((data: window.Window) => {
        this.mainWindowClass = data;
        this.updateWidthBp();
        this.uiContext = data.getUIContext();
        data.on('windowSizeChange', this.onWindowSizeChange);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'WebAbility',
          `Failed to obtain the main window. Cause code: ${err.code}, message: ${err.message}`);
      });
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageRestore(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability.
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageRestore');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      windowStage.getMainWindow().then((data: window.Window) => {
        this.mainWindowClass = data;
        this.updateWidthBp();
        this.uiContext = data.getUIContext();
        data.on('windowSizeChange', this.onWindowSizeChange);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'WebAbility',
          `Failed to obtain the main window. Cause code: ${err.code}, message: ${err.message}`);
      });
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  private onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    this.updateWidthBp();
  };

  updateWidthBp(): void {
    if (!this.uiContext) {
      return
    }
    let mainWindow: window.WindowProperties = this.mainWindowClass!.getWindowProperties();
    let windowWidth: number = mainWindow.windowRect.width;
    let windowWidthVp = this.uiContext.px2vp(windowWidth);
    let widthBp: string = '';
    if (windowWidthVp < 320) {
      widthBp = 'xs';
    } else if (windowWidthVp >= 320 && windowWidthVp < 600) {
      widthBp = 'sm';
    } else if (windowWidthVp >= 600 && windowWidthVp < 840) {
      widthBp = 'md';
    } else if (windowWidthVp >= 840 && windowWidthVp < 1440) {
      widthBp = 'lg';
    } else {
      widthBp = 'xl';
    }
    AppStorage.setOrCreate(BreakpointConstants.BREAKPOINT_NAME, widthBp);
    AppStorage.setOrCreate('windowWidth', windowWidth);
    let windowHeight: number = mainWindow.windowRect.height;
    AppStorage.setOrCreate('windowHeight', windowHeight);
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources.
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground.
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background.
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}