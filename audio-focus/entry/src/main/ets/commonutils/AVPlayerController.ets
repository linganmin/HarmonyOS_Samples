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

import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import Logger from './Logger';
import { AVSessionController } from './AVSessionController'
import { MediaController } from './MediaController';
import { avSession } from '@kit.AVSessionKit';

const TAG = 'AVPlayerController';

export class AVPlayerController implements MediaController {
  avPlayer?: media.AVPlayer;
  avSessionController?: AVSessionController;

  async createAndActiveAVPlayer(avSessionController: AVSessionController, surfaceID: string, videoUrl: string) {
    if (this.avPlayer) {
      Logger.info(TAG, 'AVPlayer has existed.');
      return;
    }
    this.avSessionController = avSessionController;
    try {
      this.avPlayer = await media.createAVPlayer();
    } catch (error) {
      Logger.error(TAG, `createAVPlayer fail. error message is ${error.message}`);
    }
    await this.setVideoFdSrcByName(videoUrl);
    this.setStateChangeCallBack(surfaceID);
    this.setAudioInterruptCallBack();
    Logger.info(TAG, 'createAndActiveAVPlayer SUCCESS');
  }

  async setVideoFdSrcByName(videoUrl: string) {
    if (!this.avPlayer) {
      Logger.info(TAG, 'AVPlayer setVideoFdSrcByName failed, avPlayer is null.');
      return;
    }
    let context = AppStorage.get('EntryAbilityContext') as common.UIAbilityContext;
    try {
      let fileDescriptor: resourceManager.RawFileDescriptor = await context.resourceManager.getRawFd(videoUrl);
      let avFileDescriptor: media.AVFileDescriptor =
        { fd: fileDescriptor.fd, offset: fileDescriptor.offset, length: fileDescriptor.length };
      this.avPlayer.fdSrc = avFileDescriptor;
    } catch (error) {
      Logger.error(TAG, `setVideoFdSrcByName failed, code is ${error.code}, message is ${error.message}}`);
    }

  }

  // [Start video_stream_usage]
  setStateChangeCallBack(surfaceID: string) {
    this.avPlayer?.on('stateChange', async (state: string) => {
      if (!this.avPlayer) {
        Logger.info(TAG, 'AVPlayer on stateChange failed, avPlayer is null.');
        return;
      }
      // The initial playback status of AVSession is paused
      let playbackState: avSession.AVPlaybackState = {
        state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
        loopMode: avSession.LoopMode.LOOP_MODE_SINGLE
      };
      switch (state) {
        case 'initialized':
          Logger.info('AVPlayer state initialized called.');
          this.avPlayer.surfaceId = surfaceID;
          // Set the audio stream type
          if (this.avPlayer.audioRendererInfo) {
            this.avPlayer.audioRendererInfo.usage = audio.StreamUsage.STREAM_USAGE_MOVIE;
          }
          this.avPlayer.prepare();
          break;
        case 'prepared':
          Logger.info('AVPlayer state prepared called.');
          this.avPlayer.play();
          break;
        case 'playing':
          Logger.info('AVPlayer state playing called.');
          playbackState.state = avSession.PlaybackState.PLAYBACK_STATE_PLAY;
          break;
        case 'paused':
          Logger.info('AVPlayer state paused called.');
          playbackState.state = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
          break;
        case 'completed':
          Logger.info('AVPlayer state completed called.');
          this.avPlayer.stop();
          break;
        case 'stopped':
          Logger.info('AVPlayer state stopped called.');
          playbackState.state = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
          this.avPlayer.reset();
          break;
        default:
          Logger.info('AVPlayer other state called.');
          break;
      }
      await this.avSessionController?.session?.setAVPlaybackState(playbackState);
    });
  }

  // [End video_stream_usage]

  setAudioInterruptCallBack() {
    this.avPlayer?.on('audioInterrupt', async (interruptInfo: audio.InterruptEvent) => {
      // Before the interruption, AVPlayer is in the playback state, so the playback status of AVSession Broadcast Control Center is PLAY
      let playbackState: avSession.AVPlaybackState = {
        state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
        loopMode: avSession.LoopMode.LOOP_MODE_SINGLE
      };
      if (interruptInfo.forceType === audio.InterruptForceType.INTERRUPT_SHARE &&
        interruptInfo.hintType === audio.InterruptHint.INTERRUPT_HINT_RESUME) {
        Logger.info('Video resume play.');
        this.avPlayer?.play();
      } else if (interruptInfo.forceType === audio.InterruptForceType.INTERRUPT_FORCE &&
        (interruptInfo.hintType === audio.InterruptHint.INTERRUPT_HINT_PAUSE ||
          interruptInfo.hintType === audio.InterruptHint.INTERRUPT_HINT_STOP)) {
        playbackState.state = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
      }
      await this.avSessionController?.session?.setAVPlaybackState(playbackState);
    })
  }

  async MediaPlay(): Promise<void> {
    if (!this.avPlayer) {
      Logger.info(TAG, 'start AVPlayer failed, avPlayer is null.');
      return;
    }
    Logger.info(TAG, 'play AVPlayer.');
    try {
      await this.avPlayer.play();
    } catch (error) {
      Logger.error(TAG, `avPlayer play failed, code is ${error.code}, message is ${error.message}}`);
    }
  }

  async MediaPause(): Promise<void> {
    if (!this.avPlayer) {
      Logger.info(TAG, 'pause AVPlayer failed, avPlayer is null.');
      return;
    }
    Logger.info(TAG, 'pause AVPlayer.');
    try {
      await this.avPlayer.pause();
    } catch (error) {
      Logger.error(TAG, `avPlayer pause failed, code is ${error.code}, message is ${error.message}}`);
    }
  }

  async MediaStop(): Promise<void> {
    if (!this.avPlayer) {
      Logger.info(TAG, 'stop AVPlayer failed, avPlayer is null.');
      return;
    }
    Logger.info(TAG, 'stop AVPlayer.');
    try {
      await this.avPlayer.stop();
    } catch (error) {
      Logger.error(TAG, `avPlayer stop failed, code is ${error.code}, message is ${error.message}}`);
    }
  }

  async releasePlayer(videoUrl: string) {
    if (!this.avPlayer) {
      Logger.info(TAG, 'release AVPlayer failed, avPlayer is null.');
      return;
    }
    this.avPlayer.off('audioInterrupt');
    this.avPlayer.off('stateChange');
    try {
      await this.avPlayer.release();
      let context = AppStorage.get('EntryAbilityContext') as common.UIAbilityContext;
      await context.resourceManager.closeRawFd(videoUrl);
      Logger.info('releasePlayer success');
    } catch (error) {
      Logger.error(TAG, `releasePlayer failed, code is ${error.code}, message is ${error.message}}`);
    }
  }
}