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

// [Start deal_jump_launch]
// entry/src/main/ets/entryability/EntryAbility.ets
import { BusinessError } from '@kit.BasicServicesKit';
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { url } from '@kit.ArkTS';
import { Logger } from '../common/Logger';

const DOMAIN = 0x0000;
const TAG = 'EntryAbilityLogTag';

// [Start deal_jump_background2forward]
export default class EntryAbility extends UIAbility {
  private mAid: string = '';

  private getAid(want: Want): string {
    // [StartExclude deal_jump_background2forward]
    let uri = want?.uri;
    let aid: string = '';
    // Parse the parameters to obtain the app linking
    if (uri) {
      try {
        let urlObject = url.URL.parseURL(want?.uri);
        aid = urlObject.params.get('aid') as string;
        hilog.info(DOMAIN, 'testTag', '%{public}s', `getAid aid:${aid}`);
      } catch (err) {
        let error = err as BusinessError;
        Logger.error(TAG, `onAddForm err, code: ${error.code}, mesage: ${error.message}`);
      }
    }
    return aid;
    // [EndExclude deal_jump_background2forward]
  }

  // [StartExclude deal_jump_background2forward]
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `setColorMode err, code: ${error.code}, mesage: ${error.message}`);
    }
    this.mAid = this.getAid(want);
  }

  // [StartExclude deal_jump_launch]
  // [Start deal_jump_launch_url]
  // entry/src/main/ets/entryability/EntryAbility.ets
  onWindowStageCreate(windowStage: window.WindowStage): void {

    let pageUrl: string = 'pages/Index';
    if (this.mAid && this.mAid !== '') {
      pageUrl = 'pages/Detail';
      AppStorage.setOrCreate('aid', this.mAid);
    }

    windowStage.loadContent(pageUrl, (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      try {
        // [StartExclude deal_jump_launch_url]
        // Main window is created, set main page for this ability
        hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
        let windowObj = windowStage.getMainWindowSync();
        const uiContext = windowObj.getUIContext();
        windowObj.setWindowLayoutFullScreen(true).catch((error:BusinessError) => {
          Logger.error(TAG, `setWindowLayoutFullScreen err, code: ${error.code}, mesage: ${error.message}`);
        });
        let statusBarArea = windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        let statusBarHeight = uiContext.px2vp(statusBarArea.topRect.height);
        AppStorage.setOrCreate('statusBarHeight', statusBarHeight);
        let naviBarArea = windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        let naviIndicatorHeight = uiContext.px2vp(naviBarArea.bottomRect.height);
        AppStorage.setOrCreate('naviIndicatorHeight', naviIndicatorHeight);
        // [EndExclude deal_jump_launch_url]
        hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      } catch (err) {
        let error = err as BusinessError;
        Logger.error(TAG, `loadContent err, code: ${error.code}, mesage: ${error.message}`);
      }
    });
  }

  // [End deal_jump_launch_url]
  // [EndExclude deal_jump_background2forward]
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    let aid: string = this.getAid(want);
    if(aid){
      AppStorage.setOrCreate('aid',aid);
      AppStorage.setOrCreate('newWantFlag',true);
    }
  }

  // [StartExclude deal_jump_background2forward]
  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
  // [EndExclude deal_jump_launch]
  // [EndExclude deal_jump_background2forward]
}
// [End deal_jump_launch]
// [End deal_jump_background2forward]