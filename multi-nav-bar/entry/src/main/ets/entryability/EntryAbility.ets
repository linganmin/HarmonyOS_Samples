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
import { window } from '@kit.ArkUI';
import { WindowUtil } from '../common/utils/WindowUtils';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';

export default class EntryAbility extends UIAbility {
  private windowUtil?: WindowUtil = WindowUtil.getInstance();
  private onWindowSizeChange: (windowSize: window.Size, context: UIContext) => void = (_, context) => {
    this.windowUtil!.updateWidthBp(context);
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'xxx', `setColorMode failed, error code=${err.code}, message=${err.message}`);
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    this.windowUtil?.setWindowStage(windowStage);
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');

      try {
        let uiContext: UIContext | undefined = windowStage.getMainWindowSync().getUIContext();
        AppStorage.setOrCreate('uiContext', uiContext);
      } catch (error) {
        hilog.error(0x0000, 'testTag', 'Failed to get main window. Cause: %{public}s', JSON.stringify(error) ?? '');
      }
    });
    let windowClass: window.Window | undefined = undefined;
    windowStage.getMainWindow((err: BusinessError, data: window.Window) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to get the main window. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }

      try {
        this.windowUtil!.updateWidthBp(windowStage.getMainWindowSync().getUIContext());
        data.on('windowSizeChange', (windowSize: window.Size) => this.onWindowSizeChange(windowSize,
          windowStage.getMainWindowSync().getUIContext()));
        windowClass = data;
        if (deviceInfo.deviceType === '2in1') {
          data.setWindowDecorVisible(false);
          data.setWindowDecorHeight(64);
        } else {
          windowClass.setWindowLayoutFullScreen(true).catch((error: BusinessError) => {
            hilog.error(0x0000, 'testTag', 'Failed to set window layout full screen. Cause: %{public}s', JSON.stringify(error) ?? '');
          });
        }
      } catch (error) {
        hilog.error(0x0000, 'testTag', 'Failed to  get main window. Cause: %{public}s', JSON.stringify(error) ?? '');
      }
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}