/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { display } from '@kit.ArkUI';
import AVPlayerManager from './AVPlayerManager';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

@Component
export struct VideoNode {
  @Prop @Watch('onIsPlayingUpdated') isPlaying: boolean;
  @Prop xComponentId: string;
  @Prop videoSrc: string;
  private surfaceId: string = '';
  private xComponentController: XComponentController = new XComponentController();
  @State avPlayManager: AVPlayerManager = new AVPlayerManager();
  @State durationTime: number = 0;
  @State currentTime: number = 0
  @State surfaceW: number | null = null;
  @State surfaceH: number | null = null;
  @State percent: number = 0;
  @State windowWidth: number = 300;
  @State windowHeight: number = 300;

  onIsPlayingUpdated() {
    if (this.isPlaying) {
      this.avPlayManager.videoPlay();
    } else {
      this.avPlayManager.videoPause();
    }
  }

  setVideoWH(): void {
    if (this.percent >= 1) { // Landscape video
      this.surfaceW = Math.round(this.windowWidth * 0.99);
      this.surfaceH = Math.round(this.surfaceW / this.percent);
    } else { // Portrait video.
      this.surfaceH = Math.round(this.windowHeight * 0.99);
      this.surfaceW = Math.round(this.surfaceH * this.percent);
    }
  }

  aboutToAppear() {
    try {
      this.windowWidth = display.getDefaultDisplaySync().width;
      this.windowHeight = display.getDefaultDisplaySync().height;
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'VideoNode', `aboutToAppear failed. error code=${error.code}, message=${error.message}`);
    }
  }

  aboutToDisappear() {
    this.avPlayManager.videoRelease();
  }

  onPageHide() {
    this.avPlayManager.videoPause();
  }

  build() {
    Stack() {
      XComponent({
        // Loading video container.
        id: this.xComponentId,
        type: XComponentType.SURFACE,
        controller: this.xComponentController
      })
        .id(this.xComponentId)
        .onLoad(() => {
          this.surfaceId = this.xComponentController.getXComponentSurfaceId();
          this.avPlayManager.initPlayer(uiContext?.getHostContext() as common.UIAbilityContext, this.surfaceId,
            this.videoSrc,
            this.isPlaying, (avPlayer: media.AVPlayer) => {
              this.percent = avPlayer.width / avPlayer.height;
              this.setVideoWH(); // Set the true width and height based on the video size.
              this.durationTime = this.avPlayManager.getDurationTime();
              this.currentTime = this.avPlayManager.getCurrentTime();
            })
        })
        .width('100%')
        .aspectRatio(this.percent)
      // Add a cover to a video that does not automatically play during initialization.
      if (!this.avPlayManager.isPlaying && this.avPlayManager.isPrepared) {
        Image($r(`app.media.cover_${this.xComponentId?.split('_')[1]}`))// img_{index}
          .width('100%')
      }
    }
  }
}