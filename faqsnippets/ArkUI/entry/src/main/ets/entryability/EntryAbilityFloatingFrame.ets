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
* FAQ:如何实现通过侧滑手势关闭打开的悬浮框
*/

import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  // [Start entry_ability_floating_frame]
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Create application subwindow
    let windowClass: window.Window | undefined = undefined;
    windowStage.createSubWindow('mySubWindow', (err: BusinessError, data) => {
      if (err.code) {
        console.error(`Failed to create the subwindow. Cause code: ${err.code}, message: ${err.message}`);
        return;
      }
      windowClass = data;
      console.info('Succeeded in creating the subwindow. Data: ' + JSON.stringify(data));
      // After the child window is created successfully, set the position, size, and related properties of the child window.
      windowClass.moveWindowTo(300, 300);
      windowClass.resize(200, 200);
      windowClass.setWindowTouchable(true);
      // Load the corresponding target page for the child window.
      windowClass.setUIContent('pages/Index',(err: BusinessError) => {
        if (err.code) {
          console.error(`Failed to load the content. Cause code: ${err.code}, message: ${err.message}`);
          return;
        }
        if (windowClass) {
          windowClass.setWindowBackgroundColor('#64b38c');
        }
      });
      (windowClass as window.Window).showWindow();
    })
    // ...
  }
  // [End entry_ability_floating_frame]
}