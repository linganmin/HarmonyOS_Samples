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
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import { url } from '@kit.ArkTS';
import { Logger } from '../utils/Logger';

const TAG = 'EntryAbility';
// [Start deal_jump_background2forward]
export default class EntryAbility extends UIAbility {
  private uiContext: UIContext | undefined = undefined;
  private mVideoIndex: string = '';

  private getVideoIndex(want: Want): string {
    // [StartExclude deal_jump_background2forward]
    let uri = want?.uri;
    let videoIndex: string = '';
    // Parse the parameters to obtain the app linking
    if (uri) {
      try {
        let urlObject = url.URL.parseURL(want?.uri);
        videoIndex = urlObject.params.get('videoIndex') as string;
      } catch (err) {
        let error = err as BusinessError;
        Logger.error(TAG, `parseURL err, errCode: ${error.code}, error mesage: ${error.message}`);
      }
      Logger.info(TAG, `getAid aid:${videoIndex}`);
    }
    return videoIndex;
    // [EndExclude deal_jump_background2forward]
  }
  // [StartExclude deal_jump_background2forward]
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // [StartExclude deal_jump_launch]
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `setColorMode err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
    Logger.info(TAG, 'Ability onCreate');
    // [EndExclude deal_jump_launch]
    this.mVideoIndex = this.getVideoIndex(want);
  }
  // [StartExclude deal_jump_launch]
  // [Start deal_jump_launch_url]
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // [StartExclude deal_jump_launch_url]
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'Ability onWindowStageCreate');
    // [EndExclude deal_jump_launch_url]
    let pageUrl: string = 'pages/Index';
    if (this.mVideoIndex && this.mVideoIndex !== '') {
      AppStorage.setOrCreate('videoIndex', Number.parseInt(this.mVideoIndex));
      pageUrl = 'pages/VideoPlay';
    }

    windowStage.loadContent(pageUrl, (err) => {
      // [StartExclude deal_jump_launch_url]
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      Logger.info(TAG, 'testTag', 'Succeeded in loading the content.');
      // [EndExclude deal_jump_launch_url]
      try {
        let windowObj = windowStage.getMainWindowSync();
        this.uiContext = windowObj.getUIContext();
      } catch (err) {
        let error = err as BusinessError;
        Logger.error(TAG, `getMainWindowSync err, errCode: ${error.code}, error mesage: ${error.message}`);
      }
    });
  }
  // [End deal_jump_launch_url]
  // [EndExclude deal_jump_background2forward]
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    let videoIndex: string = this.getVideoIndex(want);
    if (videoIndex && videoIndex !== '') {
      let page = this.uiContext?.getRouter().getState();
      if (page?.name === 'VideoPlay') {
        AppStorage.setOrCreate('videoIndex', Number.parseInt(videoIndex));
      } else {
        this.uiContext?.getRouter().pushUrl({
          url: 'pages/VideoPlay',
          params: {
            videoIndex: videoIndex
          }
        }).catch((error: BusinessError) => {
          Logger.error(TAG, `pushUrl err, errCode: ${error.code}, error mesage: ${error.message}`);
        });
      }
    }
  }
  // [StartExclude deal_jump_background2forward]
  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
  }

  onWindowStageDestroy(): void {
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    Logger.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    Logger.info(TAG, 'Ability onBackground');
  }
  // [EndExclude deal_jump_launch]
  // [EndExclude deal_jump_background2forward]
}
// [End deal_jump_launch]
// [End deal_jump_background2forward]