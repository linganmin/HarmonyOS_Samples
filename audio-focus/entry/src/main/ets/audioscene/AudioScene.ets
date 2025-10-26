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
import { AudioRenderController } from '../commonutils/AudioRenderController';
import { AVSessionController } from '../commonutils/AVSessionController';
import { avSession } from '@kit.AVSessionKit';
import Logger from '../commonutils/Logger';

const TAG = '[AudioScene]'

@Builder
export function AudioScenePageBuilder() {
  AudioScenePage()
}

@Component
export struct AudioScenePage {
  @StorageLink('audioIsPlaying') @Watch('playingStateChange') isPlaying: boolean = false;
  private audioUrl: string = 'audio.pcm';
  private audioRenderController: AudioRenderController = new AudioRenderController();
  private avSessionController: AVSessionController = new AVSessionController();
  private audioSessionManager: audio.AudioSessionManager = audio.getAudioManager().getSessionManager();

  aboutToAppear() {
    this.initAVResource();
  }

  aboutToDisappear(): void {
    this.releaseAVResource();
  }

  onPageHide(): void {
    this.avSessionController.startContinuousTask();
  }

  onPageShow(): void {
    this.avSessionController.stopContinuousTask();
  }

  async initAVResource() {
    // Create an AVSession instance
    let audioMetadata: avSession.AVMetadata = { assetId: '0', title: 'audio', artist: 'none' }
    await this.avSessionController.createAndActiveSession(audioMetadata, 'EntryAbility', 'audio');
    // Create an instance of AudioRenderer and set the audio stream type to STREAM_USAGE_MUSIC
    await this.audioRenderController.createAndInitAudioRender(this.avSessionController,
      this.audioUrl, audio.StreamUsage.STREAM_USAGE_MUSIC);
    await this.avSessionController.registerSessionListener(this.audioRenderController);
  }

  async releaseAVResource() {
    if (this.audioRenderController) {
      await this.audioRenderController.releaseAudioRender(this.audioUrl);
    }
    if (this.avSessionController) {
      await this.avSessionController.avSessionRelease();
    }
    // Deactivate an audio session
    try {
      this.audioSessionManager.deactivateAudioSession().then(() => {
        Logger.info('deactivateAudioSession SUCCESS');
      });
    } catch (error) {
      Logger.error(TAG, `deactivateAudioSession failed,code is ${error.code},message is ${error.message}}`);
    }
    // The play icon reverts to pause
    AppStorage.setOrCreate('audioIsPlaying', false);
  }

  playingStateChange() {
    if (this.isPlaying) {
      // Set the audio concurrency mode
      let strategy: audio.AudioSessionStrategy = {
        concurrencyMode: AppStorage.get('audioConcurrencyMode') as audio.AudioConcurrencyMode
      };
      // Activate the audio session
      try {
        this.audioSessionManager.activateAudioSession(strategy).then(() => {
          Logger.info('activateAudioSession SUCCESS');
        });
      } catch (error) {
        Logger.error(TAG, `activateAudioSession failed,code is ${error.code},message is ${error.message}}`);
      }
      this.audioRenderController.MediaPlay();
    } else {
      this.audioRenderController.MediaPause();
      // Deactivate an audio session
      try {
        this.audioSessionManager.deactivateAudioSession().then(() => {
          Logger.info('deactivateAudioSession SUCCESS');
        });
      } catch (error) {
        Logger.error(TAG, `deactivateAudioSession failed,code is ${error.code},message is ${error.message}}`);
      }
    }
    AppStorage.setOrCreate('audioIsPlaying', this.isPlaying);
  }

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        Stack() {
          Image($r('app.media.music_background'))
            .width('100%')
            .margin({ top: 32 })

          Button({ stateEffect: true }) {
            Image(this.isPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
          }
          .height(56)
          .aspectRatio(1)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.isPlaying = !this.isPlaying;
          })
        }
        .margin({ left: 16, right: 16 })
      }
      .width('100%')
      .height('100%')
      .backgroundImage($r('app.media.ic_background'))
      .backgroundImageSize(ImageSize.Cover)
    }
    .title($r('app.string.audio_scene_button'))
  }
}