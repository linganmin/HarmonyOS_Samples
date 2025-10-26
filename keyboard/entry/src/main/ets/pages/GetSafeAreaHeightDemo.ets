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

// [Start Get_safe_area_height_demo]
import { KeyboardAvoidMode, window } from '@kit.ArkUI';
import { UIAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct GetSafeAreaHeightDemo {
  @State screenHeight: number = 0; // The height of the safe area
  @State isKeyBoardHidden: boolean = false; // Whether the soft keyboard is hidden

  aboutToAppear(): void {
    try {
      window.getLastWindow(this.getUIContext().getHostContext()).then(currentWindow => {
        let property = currentWindow.getWindowProperties();
        let avoidArea = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD);
        // Initialize the display area height
        this.screenHeight = this.getUIContext()
          .px2vp(property.windowRect.height - avoidArea.topRect.height - avoidArea.bottomRect.height);
        // Enables the monitoring of changes in the avoidance zone of the current window
        currentWindow.on('avoidAreaChange', data => {
          if (data.type !== window.AvoidAreaType.TYPE_KEYBOARD) {
            return;
          }
          if (data.area.bottomRect.height <= 0) {
            this.isKeyBoardHidden = true;
          } else {
            this.isKeyBoardHidden = false;
          }
          this.screenHeight = this.getUIContext()
            .px2vp(property.windowRect.height - data.area.topRect.height - data.area.bottomRect.height);
          hilog.info(0x0000, 'GetSafeAreaHeightDemo', `screen height is: ${this.screenHeight}`);
        })
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'GetSafeAreaHeightDemo',
        `getLastWindow failed, error code=${err.code}, message=${err.message}`);
    }
  }

  build() {
    Column() {
      TextInput()
    }
  }
}

// [End Get_safe_area_height_demo]

// [Start Entry_ability_set_keyboard_avoid_mode_offset]
export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/GetSafeAreaHeightDemo', (err) => {
      // Lift up mode
      windowStage.getMainWindowSync().getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
    });
  }
}

// [End Entry_ability_set_keyboard_avoid_mode]



