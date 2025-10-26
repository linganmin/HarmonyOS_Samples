/*
 * Copyright 2023. Huawei Technologies Co., Ltd. All rights reserved.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

import { common } from '@kit.AbilityKit';
import { AdComponent, advertising } from '@kit.AdsKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AdStatus } from '../../constant/AdStatus';
import { AdType } from '../../constant/AdType';
import { AdsViewModel } from '../../viewmodel/AdsViewModel';

const TAG: string = 'Ads Demo-RollAdPage';

@ComponentV2
export struct RollAdPage {
  @Local private countDownText: string = '';
  @Local private rollPlayState: number = 1;
  @Local private isPlayVideo: boolean = false;
  @Local private ratio: number = 16 / 9;
  // Number of roll ads that have been played.
  private playedAdCnt: number = 0;
  // Used to render the countdown in the upper right corner.
  private countDownTextPlaceholder: string = '%d | %s';
  private viewModel: AdsViewModel = new AdsViewModel(this.getUIContext());
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear() {
    try {
      const countDownTextDesc = this.context.resourceManager.getStringSync($r('app.string.ad_free_for_VIP_members').id);
      this.countDownTextPlaceholder = this.countDownTextPlaceholder.replace('%s', countDownTextDesc);
    } catch (e) {
      hilog.error(0x0000, 'testTag', `Failed to get count down text. Code is ${e.code}, message is ${e.message}`);
    }
    const adRequestParams = this.viewModel.getParamsFromNav(AdType.ROLL) as advertising.AdRequestParams;
    // Set the roll ad display duration.
    this.viewModel.adOptions.totalDuration = 30;
    this.viewModel.loadAd(adRequestParams);
  }

  aboutToDisappear(): void {
    // Set screen orientation to the default value. You can change the value based on the actual situation.
    this.setWindowPreferredOrientation(window.Orientation.UNSPECIFIED);
    // Display the three-button navigation bar, status bar and bottom navigation bar. You can change the value based on the actual situation.
    this.setWindowSystemBar(['status', 'navigation']);
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopEnd }) {
        if (this.viewModel.ads.length !== 0 && !this.isPlayVideo) {
          AdComponent({
            ads: [...this.viewModel.ads],
            rollPlayState: this.rollPlayState,
            displayOptions: this.viewModel.adDisplayOptions,
            interactionListener: {
              onStatusChanged: (status: string, ad: advertising.Advertisement, data: string) => {
                switch (status) {
                  case AdStatus.AD_FAIL:
                    hilog.info(0x0000, TAG, 'Status is onAdFail');
                    this.isPlayVideo = true;
                    break;
                  case AdStatus.PORTRAIT:
                    hilog.info(0x0000, TAG, 'Status is onPortrait');
                    // Set the screen to portrait.
                    this.setWindowPreferredOrientation(window.Orientation.PORTRAIT);
                    // Display the three-button navigation bar, status bar and bottom navigation bar.
                    this.setWindowSystemBar(['status', 'navigation']);
                    this.ratio = 16 / 9;
                    break;
                  case AdStatus.LANDSCAPE:
                    hilog.info(0x0000, TAG, 'Status is onLandscape');
                    // Set the screen to landscape.
                    this.setWindowPreferredOrientation(window.Orientation.LANDSCAPE);
                    // Hide the three-button navigation bar, status bar and bottom navigation bar.
                    this.setWindowSystemBar([]);
                    this.ratio = -1;
                    break;
                  case AdStatus.MEDIA_PROGRESS:
                    hilog.info(0x0000, TAG, 'Status is onMediaProgress');
                    break;
                  case AdStatus.MEDIA_START:
                    hilog.info(0x0000, TAG, 'Status is onMediaStart');
                    break;
                  case AdStatus.MEDIA_PAUSE:
                    hilog.info(0x0000, TAG, 'Status is onMediaPause');
                    break;
                  case AdStatus.MEDIA_STOP:
                    hilog.info(0x0000, TAG, 'Status is onMediaStop');
                    break;
                  case AdStatus.MEDIA_COMPLETE:
                    hilog.info(0x0000, TAG, 'Status is onMediaComplete');
                    this.playedAdCnt++;
                    if (this.playedAdCnt === this.viewModel.ads.length) {
                      // After all ads are complete, the main video starts to be played.
                      this.isPlayVideo = true;
                    }
                    break;
                  case AdStatus.MEDIA_ERROR:
                    hilog.error(0x0000, TAG, 'Status is onMediaError');
                    break;
                  case AdStatus.MEDIA_COUNTDOWN:
                    hilog.info(0x0000, TAG, 'Status is onMediaCountdown');
                    const parseData: Record<string, Object> = this.safeParseData(data);
                    this.countDownText = this.countDownTextPlaceholder.replace('%d', String(parseData.countdownTime));
                    break;
                  case AdStatus.BACK_CLICKED:
                    hilog.info(0x0000, TAG, 'Status is onBackClicked');
                    this.viewModel.navPathStack.pop();
                    break;
                }
              }
            }
          })
            .width('100%')
            .height('100%')

          Text(this.countDownText)
            .fontSize(12)
            .lineHeight(12)
            .maxLines(1)
            .textAlign(TextAlign.Center)
            .fontColor($r('sys.color.font_on_primary'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .backgroundColor($r('app.color.count_down_background'))
            .border({ radius: 25 })
            .padding(8)
            .margin(16)
            .height(24)
            .onClick(() => {
              hilog.info(0x0000, TAG, 'OnVipClicked, do something...');
              this.isPlayVideo = true;
            })
            .visibility(this.countDownText ? Visibility.Visible : Visibility.None)
        }

        Video({
          src: $rawfile('videoTest.mp4'),
          previewUri: $r('app.media.video_preview'),
          controller: new VideoController()
        })
          .visibility(this.isPlayVideo ? Visibility.Visible : Visibility.None)
          .autoPlay(this.isPlayVideo)
          .controls(false)
          .width('100%')
          .height('100%')
      }
      .width('100%')
      .height('100%')
      .aspectRatio(this.ratio)
    }
    .hideTitleBar(true)
  }

  private async setWindowPreferredOrientation(orientation: Orientation): Promise<void> {
    try {
      const win: window.Window = await window.getLastWindow(this.context);
      await win.setPreferredOrientation(orientation);
    } catch (e) {
      hilog.error(0x0000, 'testTag', `Failed to set preferred orientation. Code is ${e.code}, message is ${e.message}`);
    }
  }

  private async setWindowSystemBar(names: Array<'status' | 'navigation'>): Promise<void> {
    try {
      const win: window.Window = await window.getLastWindow(this.context);
      await win.setWindowSystemBarEnable(names);
    } catch (e) {
      hilog.error(0x0000, 'testTag', `Failed to set window system bar. Code is ${e.code}, message is ${e.message}`);
    }
  }

  private safeParseData(data: string): Record<string, Object> {
    try {
      if (typeof data === 'string') {
        return JSON.parse(data);
      }
      return JSON.parse(JSON.stringify(data));
    } catch (e) {
      hilog.error(0x0000, 'testTag', `Failed to parse data. Code is ${e.code}, message is ${e.message}`);
    }
    return {};
  }
}