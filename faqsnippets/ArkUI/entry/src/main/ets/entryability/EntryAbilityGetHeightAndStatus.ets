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
* FAQ:如何获取状态栏和导航栏高度
*/

// [Start entry_ability_height_and_status]
// MainAbility.ets
import { common, UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

/**
 * Get the height of the system status bar and navigation bar
 * @param context
 * @returns
 */
async function getWindowAvoidArea(context: common.UIAbilityContext): Promise<window.AvoidArea | null> {
  try {
    // The default area of the system includes the status bar and navigation bar
    const mainWindow = await window.getLastWindow(context);
    const avoidAreaType = window.AvoidAreaType.TYPE_SYSTEM;
    const avoidArea = mainWindow.getWindowAvoidArea(avoidAreaType);
    const avoidAreaTypeNavigationBar = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
    const avoidAreaNavigationBar = mainWindow.getWindowAvoidArea(avoidAreaTypeNavigationBar);
    const height = avoidArea.topRect.height;
    const heightNavigationBar = avoidAreaNavigationBar.bottomRect.height;
    return avoidArea
  } catch (e) {
    console.log('getWindowAvoidArea fail');
    return null
  }
}

export default class MainAbility extends UIAbility {
  // do something
  async onWindowStageCreate(windowStage: window.WindowStage) {
    getWindowAvoidArea(this.context);
    windowStage.loadContent('pages/index');
  }

  // do something
}

// [End entry_ability_height_and_status]