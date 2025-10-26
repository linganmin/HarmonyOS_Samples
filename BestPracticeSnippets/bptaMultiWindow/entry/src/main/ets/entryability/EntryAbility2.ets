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

// [Start onavoid_areachange]
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window as arkWindow } from '@kit.ArkUI'; // Renamed the imported window
import { UIAbility } from '@kit.AbilityKit';

export default class EntryAbility extends UIAbility {
  private onAvoidAreaChange: (avoidArea: arkWindow.AvoidAreaOptions) => void =
    (avoidArea: arkWindow.AvoidAreaOptions) => {
      const uiContext: UIContext | undefined = AppStorage.get('uiContext');
      if (avoidArea.type === arkWindow.AvoidAreaType.TYPE_SYSTEM) {
        // Updates the height of the top status bar.
        AppStorage.setOrCreate('topAvoidHeight', uiContext?.px2vp(avoidArea.area.topRect.height));
      } else if (avoidArea.type === arkWindow.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        // Updated the bottom navigation bar.
        AppStorage.setOrCreate('bottomAvoidHeight', uiContext?.px2vp(avoidArea.area.bottomRect.height));
      }
    };

  onWindowStageCreate(windowStage: arkWindow.WindowStage): void {
    windowStage.getMainWindow((err, window: arkWindow.Window) => {
      if (err) {
        console.error('Failed to get main window. Error: ' + JSON.stringify(err));
        return;
      }
      window.setWindowLayoutFullScreen(true)
        .catch((err: BusinessError) => {
          hilog.error(0x000, 'testTag', `setWindowLayoutFullScreen failed, code=${err.code}, message=${err.message}`)
        })
      try {
        AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
        const uiContext: UIContext | undefined = AppStorage.get('uiContext');
        let topAvoidHeight: arkWindow.AvoidArea = window.getWindowAvoidArea(arkWindow.AvoidAreaType.TYPE_SYSTEM);
        AppStorage.setOrCreate('topAvoidHeight', uiContext?.px2vp(topAvoidHeight.topRect.height));
        let bottomAvoidHeight: arkWindow.AvoidArea =
          window.getWindowAvoidArea(arkWindow.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        AppStorage.setOrCreate('bottomAvoidHeight', uiContext?.px2vp(bottomAvoidHeight.bottomRect.height));
        window.on('avoidAreaChange', this.onAvoidAreaChange);
      } catch (error) {
        let err = error as BusinessError;
        hilog.warn(0x000, 'testTag', `getWindowAvoidArea failed, code=${err.code}, message=${err.message}`);
      }
    });
  }
}

// [End onavoid_areachange]