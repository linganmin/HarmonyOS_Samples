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

import { audio } from '@kit.AudioKit';
import { AVPlayerController } from '../commonutils/AVPlayerController';
import { AVSessionController } from '../commonutils/AVSessionController';
import { avSession } from '@kit.AVSessionKit';
import Logger from '../commonutils/Logger';

const TAG = '[VideoScene]'

@Builder
export function VideoScenePageBuilder() {
  VideoScenePage()
}

@Component
export struct VideoScenePage {
  private videoUrl: string = 'video.mp4';
  private avPlayerController: AVPlayerController = new AVPlayerController();
  private avSessionController: AVSessionController = new AVSessionController();
  private xComponentController: XComponentController = new XComponentController();
  private audioSessionManager: audio.AudioSessionManager = audio.getAudioManager().getSessionManager();

  // [Start page_audio_session]
  onDidBuild() {
    // Since the SurfaceID needs to be configured when the AVPlayer is initialized, the AVPlayer is initialized after the build is executed
    this.initAVResource();
  }

  // [StartExclude page_audio_session]
  aboutToDisappear(): void {
    this.releaseAVResource();
  }

  onPageHide(): void {
    // Initiate background long-term tasks
    this.avSessionController.startContinuousTask();
  }

  onPageShow(): void {
    // Stop background long-term tasks
    this.avSessionController.stopContinuousTask();
  }

  // [EndExclude page_audio_session]
  // [Start video_audio_session]
  async initAVResource() {
    // Set audio concurrency mode
    let strategy: audio.AudioSessionStrategy = {
      concurrencyMode: AppStorage.get('audioConcurrencyMode') as audio.AudioConcurrencyMode
    };
    // Activate audio session
    try {
      this.audioSessionManager.activateAudioSession(strategy).then(() => {
        Logger.info('activateAudioSession SUCCESS');
      });
    } catch (error) {
      Logger.error(TAG, `activateAudioSession failed,code is ${error.code},message is ${error.message}}`);
    }
    // Create an AVSession instance
    let videoMetadata: avSession.AVMetadata = { assetId: '0', title: 'video', artist: 'none' }
    await this.avSessionController.createAndActiveSession(videoMetadata, 'EntryAbility', 'video');
    // [StartExclude page_audio_session]
    // Create AVPlayer instance
    await this.avPlayerController.createAndActiveAVPlayer(this.avSessionController,
      this.xComponentController.getXComponentSurfaceId(),
      this.videoUrl);
    await this.avSessionController.registerSessionListener(this.avPlayerController);
    // [EndExclude page_audio_session]
  }

  // [End video_audio_session]
  // [End page_audio_session]

  async releaseAVResource() {
    if (this.avPlayerController) {
      await this.avPlayerController.releasePlayer(this.videoUrl);
    }
    if (this.avSessionController) {
      await this.avSessionController.avSessionRelease();
    }
    // Disable audio session
    try {
      this.audioSessionManager.deactivateAudioSession().then(() => {
        Logger.info('deactivateAudioSession SUCCESS');
      });
    } catch (error) {
      Logger.error(TAG, `deactivateAudioSession failed,code is ${error.code},message is ${error.message}}`);
    }
  }

  build() {
    NavDestination() {
      Column() {
        // [Start video_click_resume]
        XComponent({
          id: 'VideoPlayer',
          type: XComponentType.SURFACE,
          controller: this.xComponentController
        })
          .width('100%')
          .height('100%')
          .onClick(() => {
            this.avPlayerController?.MediaPlay();
          })
        // [End video_click_resume]
      }
      .backgroundColor($r('app.color.normal_background_color'))
      .width(360)
      .height(242)
    }
    .title($r('app.string.video_scene_button'))
  }
}

