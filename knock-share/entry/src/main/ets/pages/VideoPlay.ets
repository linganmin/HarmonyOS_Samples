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

import { Router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
// [Start knock_on_off]
import { common } from '@kit.AbilityKit';
import { KnockController } from '../controller/KnockController';
// [StartExclude knock_on_off]
import { VideoPlayingView } from '../view/VideoPlayingView';
import { EpisodeChoose } from '../view/EpisodeChoose';
import { VIDEO_SOURCES } from '../model/VideoData';
import { AVPlayerController } from '../controller/AVPlayerController';
import { Logger } from '../utils/Logger';
import { deviceInfo } from '@kit.BasicServicesKit';

const TAG = 'VideoPlay';
// [EndExclude knock_on_off]
// [Start get_video_index]
@Entry
@Component
struct VideoPlay {
  // [StartExclude knock_on_off]
  // [StartExclude get_video_index]
  @StorageLink('avPlayerController') avPlayerController ?: AVPlayerController = undefined;
  // [EndExclude get_video_index]
  @StorageLink('videoIndex') videoIndex: number = 0;
  // [StartExclude get_video_index]
  @State videoEpisode: number[] = [];
  @State immersiveStatus: boolean = false;
  private knockController: KnockController | undefined = undefined;
  // [EndExclude knock_on_off]
  // [EndExclude get_video_index]
  aboutToAppear(): void {
    // [StartExclude knock_on_off]
    let params = this.getUIContext().getRouter().getParams() as Record<string, string>;
    if (params && params.videoIndex) {
      this.videoIndex = Number.parseInt(params.videoIndex);
    }
    // [StartExclude get_video_index]
    Logger.info(TAG, `aboutToAppear videoIndex is ${this.videoIndex}`);
    VIDEO_SOURCES.forEach((item, index: number) => {
      this.videoEpisode.push(index + 1);
    })
    // [EndExclude knock_on_off]
    let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.knockController = KnockController.getInstance(context);
    if (deviceInfo.deviceType === '2in1') {
      this.knockController?.immersiveListeningPC();
    } else {
      this.knockController?.immersiveListening();
    }
    // [EndExclude get_video_index]
  }
  // [StartExclude knock_on_off]
  // [StartExclude get_video_index]
  onBackPress(): boolean | void {
    let router: Router = this.getUIContext().getRouter();
    let page = router.getStateByIndex(1);
    if (page?.name !== 'Index') {
      router.replaceUrl({
        url: 'pages/Index'
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `replaceUrl err, code: ${error.code}, mesage: ${error.message}`);
      })
      return true;
    }
    return false;
  }
  // [EndExclude knock_on_off]
  onPageShow(): void {
    if (deviceInfo.deviceType === '2in1') {
      this.knockController?.immersiveListeningPC();
    } else {
      this.knockController?.immersiveListening();
    }
  }

  onPageHide(): void {
    if (deviceInfo.deviceType === '2in1') {
      this.knockController?.immersiveDisableListeningPC();
    } else {
      this.knockController?.immersiveDisableListening();
    }
  }

  aboutToDisappear(): void {
    if (deviceInfo.deviceType === '2in1') {
      this.knockController?.immersiveDisableListeningPC();
    } else {
      this.knockController?.immersiveDisableListening();
    }
    this.videoIndex=0;
    // [StartExclude knock_on_off]
    if (this.avPlayerController) {
      this.avPlayerController.releasePlayer();
      this.avPlayerController = undefined;
    }
    // [EndExclude knock_on_off]
  }
  // [StartExclude knock_on_off]
  // [EndExclude get_video_index]
  build() {
    Column() {
      VideoPlayingView({
        videoList: VIDEO_SOURCES,
        videoIndex: this.videoIndex
      })
      // [StartExclude get_video_index]
      Column() {
        Text($r('app.string.play_list'))
          .height(48)
          .fontWeight(FontWeight.Medium)
          .fontSize(16)
          .alignSelf(ItemAlign.Start)
          .fontColor($r('sys.color.font_primary'))
        EpisodeChoose({ numberTest: this.videoEpisode, videoIndex: this.videoIndex })
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        bottom: 16
      })
      // [EndExclude get_video_index]
    }
    .width('100%')
  }
  // [EndExclude knock_on_off]
}
// [End get_video_index]
// [End knock_on_off]

