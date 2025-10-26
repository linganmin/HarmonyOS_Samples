/*
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
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
import { deviceInfo } from '@kit.BasicServicesKit'
import { display } from '@kit.ArkUI';
import { window } from '@kit.ArkUI';
import { Logger } from '@ohos/common';

const TAG: string = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  storage: LocalStorage = new LocalStorage();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'EntryAbility onCreate');
    this.storage = new LocalStorage();
    this.storage.setOrCreate('selectedLabel', '');
    this.storage.setOrCreate('isSplitMode', deviceInfo.deviceType === 'tablet' || deviceInfo.deviceType === '2in1');
  }

  onDestroy(): void {
    Logger.info(TAG, 'EntryAbility onDestroy');
  }

  updateBreakpoint(windowWidth: number): void {
    let windowWidthVp = 0
    try {
      windowWidthVp = windowWidth / (display.getDefaultDisplaySync().densityDPI / 160);
    } catch (err) {
      if (err.code) {
        Logger.error(TAG, `Failed to get window width. Cause: ${JSON.stringify(err)}`);
        return;
      }
    }
    let curBp: string;
    if (windowWidthVp < 600) {
      curBp = 'sm';
    } else if (windowWidthVp < 840) {
      curBp = 'md';
    } else {
      curBp = 'lg';
    }
    Logger.info(TAG, 'window width: ' + windowWidth + ', window width vp: ' + windowWidthVp + ', breakpoint: ' + curBp);
    this.storage.setOrCreate('currentBreakpoint', curBp);
    this.storage.setOrCreate('windowWidth', windowWidthVp);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'EntryAbility onWindowStageCreate');
    try {
      windowStage.getMainWindow().then((windowObj) => {
        this.updateBreakpoint(windowObj.getWindowProperties().windowRect.width);
        windowObj.on('windowSizeChange', (newSize) => {
          this.updateBreakpoint(newSize.width);

          if (windowObj.getWindowProperties().isFullScreen) {
            Logger.info(TAG, 'isFullScreen');
          }
          if (windowObj.getWindowProperties().isLayoutFullScreen) {
            Logger.info(TAG, 'isLayoutFullScreen');
          }
        })
      }).catch((err: Error)=> {
        Logger.error(TAG, `Failed to get window width. Cause: ${JSON.stringify(err)}`);
      });

      windowStage.loadContent('pages/Index', this.storage, (err, data) => {
        if (err.code) {
          Logger.error(TAG, `Failed to load the content. Cause: ${JSON.stringify(err)}`);
          return;
        }
        AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
        Logger.info(TAG, `Succeeded in loading the content. Data:  ${JSON.stringify(data)}`);
      });
    } catch (err) {
      if (err.code) {
        Logger.error(TAG, `Failed to get window. Cause: ${JSON.stringify(err)}`);
        return;
      }
    }

  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, `EntryAbility onWindowStageDestroy`);
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info(TAG, `EntryAbility onForeground`);
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info(TAG, `EntryAbility onBackground`);
  }
}
