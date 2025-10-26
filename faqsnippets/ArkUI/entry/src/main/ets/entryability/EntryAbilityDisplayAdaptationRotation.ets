/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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
* FAQ:如何实现折叠屏折叠态不适配旋转，展示态适配旋转
*/

// [Start entry_ability_display_adaptation_rotation]
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');


    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });

    windowStage.getMainWindow().then((windowObj) => {
      // Set orientation based on fold status: auto-rotation when expanded, portrait when folded
      let orientation = display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED ?
        window.Orientation.AUTO_ROTATION : window.Orientation.PORTRAIT;
      windowObj?.setPreferredOrientation(orientation);

      // Monitor the unfolded or folded state of the foldable screen
      display.on('foldStatusChange', (foldStatus: display.FoldStatus) => {
        orientation = foldStatus === display.FoldStatus.FOLD_STATUS_EXPANDED ? window.Orientation.AUTO_ROTATION :
          window.Orientation.PORTRAIT;
        try {
          windowObj?.setPreferredOrientation(orientation, (err: BusinessError) => {
            if (err.code) {
              console.error(`Failed to set window orientation. Cause code: ${err.code}, message: ${err.message}`);
              return;
            }
            console.info('Succeeded in setting window orientation.');
          });
        } catch (exception) {
          console.error(`Failed to set window orientation. Cause code: ${exception.code}, message: ${exception.message}`);
        }
      })
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

// [End entry_ability_display_adaptation_rotation]