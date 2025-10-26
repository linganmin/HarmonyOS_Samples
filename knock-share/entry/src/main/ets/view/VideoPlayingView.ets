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

import { Logger } from '../utils/Logger';
import { AVPlayerController } from '../controller/AVPlayerController';
import { VideoData } from '../model/VideoData';
import { AVPlayerControllerView } from './AVPlayerControllerView';
import { Router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

const TAG = 'VideoPlayingView';

@Component
export struct VideoPlayingView {
  @StorageLink('avPlayerController') @Watch('avPlayerStateChange') avPlayerController?: AVPlayerController = undefined;
  @Link @Watch('videoIndexChange') videoIndex: number;
  @Prop videoList: VideoData[];
  @State surfaceID: string = '';
  @State currentTime: number = 0;
  @State durationTime: number = 0;
  @State isPlaying: boolean = false;
  @State isShowAVPlayerController: boolean = false;
  @State avPlayerControllerTimeID: number = 0;
  private aspect: number = 16 / 9;
  private xComponentController = new XComponentController();
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  /**
   * Listen to the callback for the change of video playback status
   */
  async avPlayerStateChange() {
    if (this.avPlayerController) {
      this.currentTime = this.avPlayerController.currentTime;
      this.durationTime = this.avPlayerController.durationTime;
      this.isPlaying = Boolean(this.avPlayerController.state === 'playing');
      if (this.avPlayerController.state === 'completed') {
        this.nextVideo();
      }
    }
  }

  /**
   * Initialize AVPlayer
   */
  async initAVPlayer() {
    this.surfaceID = this.xComponentController.getXComponentSurfaceId();
    this.avPlayerController =
      await AVPlayerController.create(this.context, this.surfaceID,
        this.videoList[this.videoIndex].url);
  }

  /**
   * Release AVPlayer
   */
  async releaseAVPlayer() {
    if (this.avPlayerController) {
      Logger.info(TAG, 'releaseAVPlayer')
      await this.avPlayerController.releasePlayer();
      this.avPlayerController = undefined;
    }
  }

  /**
   * Listen for the callback for the change of the video playback index
   */
  async videoIndexChange() {
    Logger.info(TAG, `videoIndexChange index is: ${this.videoIndex}`)
    await this.releaseAVPlayer();
    await this.initAVPlayer();
  }

  /**
   * Displays the video playback control component
   */
  showAVPlayerController() {
    this.isShowAVPlayerController = true;
    clearTimeout(this.avPlayerControllerTimeID);
    this.avPlayerControllerTimeID = setTimeout(() => {
      this.isShowAVPlayerController = false;
    }, 2000);
  }

  /**
   * Displays the video playback control component
   */
  nextVideo() {
    if (this.videoIndex < this.videoList.length - 1) {
      this.videoIndex += 1;
    } else {
      this.videoIndex = 0;
    }
  }

  build() {
    Stack() {
      XComponent({
        id: 'player',
        type: XComponentType.SURFACE,
        controller: this.xComponentController
      })
        .onLoad(async () => {
          await this.releaseAVPlayer();
          await this.initAVPlayer();
        })
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
        Row() {
          Row() {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(24)
              .fontColor([$r('sys.color.font_on_primary')])
          }
          .width(40)
          .height(40)
          .backgroundColor('rgba(255,255,255,0.1)')
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .onClick(async () => {
            let router: Router = this.getUIContext().getRouter();
            // Get the information about the previous page
            let page = router.getStateByIndex(1);
            // If the stack of the previous page contains Index, the previous page is returned.
            // Otherwise, jump to the previous page and add the previous page to the top of the routing stack
            if (page?.name !== 'Index') {
              router.replaceUrl({
                url: 'pages/Index'
              })
            } else {
              this.getUIContext().getRouter().back();
            }
            await this.releaseAVPlayer();
          })

          Blank()
        }
        .width('100%')
        .padding({
          top: 8
        })
        .visibility(this.isShowAVPlayerController ? Visibility.Visible : Visibility.Hidden)

        AVPlayerControllerView({
          currentTime: this.currentTime,
          durationTime: this.durationTime,
          isPlaying: this.isPlaying,
          isShowAVPlayerController: this.isShowAVPlayerController,
          avPlayerControllerTimeID: this.avPlayerControllerTimeID
        })
          .visibility(this.isShowAVPlayerController ? Visibility.Visible : Visibility.Hidden)
      }
      .onClick(() => {
        this.showAVPlayerController();
      })
      .padding({
        left: 16,
        right: 16
      })
    }
    .aspectRatio(this.aspect)
    .backgroundColor(Color.Black)
    .layoutWeight(1)
    .constraintSize({
      maxWidth:'100%',
      maxHeight: '100%'
    })
  }
}