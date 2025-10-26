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
* FAQ:如何实现状态栏背景颜色沉浸？
*/

import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  // [Start entry_ability_immersing_background_color_one]
  // EntryAbility.ets


  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Example', (err, data) => {
      if (err?.code) {
        return;
      }
      // Set the full window color to match the color of the application elements
      windowStage.getMainWindowSync().setWindowBackgroundColor('#008000');
    });
  }
  // [End entry_ability_immersing_background_color_one]
}