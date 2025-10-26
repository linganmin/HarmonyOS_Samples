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

import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';
import { audio } from '@kit.AudioKit';
import { fileIo, ReadOptions } from '@kit.CoreFileKit';
import { AVSessionController } from './AVSessionController';
import { MediaController } from './MediaController';
import { avSession } from '@kit.AVSessionKit';
import Logger from './Logger';

const TAG = 'AudioRenderController';

export class AudioRenderController implements MediaController {
  audioRenderer?: audio.AudioRenderer;
  avSessionController?: AVSessionController;
  audioFd?: resourceManager.RawFileDescriptor;
  currentOffset: number = 0;

  // [Start init_audio_render]
  async createAndInitAudioRender(
    avSessionController: AVSessionController, audioUrl: string, mediaUsage: audio.StreamUsage) {
    // Set up AVSession
    this.avSessionController = avSessionController;
    // Set the audio encoding information
    let audioStreamInfo: audio.AudioStreamInfo = {
      samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000,
      channels: audio.AudioChannel.CHANNEL_2,
      sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
      encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
    };
    // Set the audio stream type
    let audioRendererInfo: audio.AudioRendererInfo = {
      usage: mediaUsage,
      rendererFlags: 0
    };

    let audioRendererOptions: audio.AudioRendererOptions = {
      streamInfo: audioStreamInfo,
      rendererInfo: audioRendererInfo
    };
    // Create an AudioRender instance
    this.audioRenderer = await audio.createAudioRenderer(audioRendererOptions);
    await this.setAudioFdSrcByName(audioUrl);
    this.setWriteDataCallback();
    this.setAudioStateChangeCallBack();
    this.setAudioInterruptCallBack();
    let playbackState: avSession.AVPlaybackState = {
      state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      loopMode: avSession.LoopMode.LOOP_MODE_SINGLE
    };
    try {
      await this.avSessionController?.session?.setAVPlaybackState(playbackState);
    } catch (error) {
      Logger.error(TAG, `setAVPlaybackState fail. code is ${error.code}, error message is ${error.message}`);
    }
  }

  // [End init_audio_render]

  async setAudioFdSrcByName(audioUrl: string) {
    try {
      let context = AppStorage.get('EntryAbilityContext') as common.UIAbilityContext;
      this.audioFd = await context.resourceManager.getRawFd(audioUrl);
      this.currentOffset = this.audioFd.offset;
    } catch (error) {
      Logger.error(TAG, `setAudioFdSrcByName fail. code is ${error.code}, error message is ${error.message}`);
    }
  }

  setWriteDataCallback() {
    try {
      if (!this.audioRenderer) {
        Logger.info(TAG, 'write audio data failed, audioRenderer is null.');
        return;
      }
      Logger.info(TAG, 'setWriteDataCallback.');
      this.audioRenderer.on('writeData', (buffer) => {
        let options: ReadOptions = {
          offset: this.currentOffset,
          length: buffer.byteLength
        };
        try {
          fileIo.readSync(this.audioFd?.fd, buffer, options);
        } catch (error) {
          Logger.error(TAG, `read file fail. error message is ${error.message}`);
        }
        this.currentOffset += buffer.byteLength;
        if ((this.currentOffset - this.audioFd!.offset) >= this.audioFd!.length) {
          // loop playback
          this.currentOffset = this.audioFd!.offset;
        }
      });
    } catch (error) {
      Logger.error(TAG, `setWriteDataCallback fail. code is ${error.code}, error message is ${error.message}`);
    }
  }

  setAudioStateChangeCallBack() {
    if (!this.audioRenderer) {
      Logger.info(TAG, 'state change callback failed, audioRenderer is null.');
      return;
    }
    this.audioRenderer.on('stateChange', async (state: audio.AudioState) => {
      let playbackState: avSession.AVPlaybackState = {
        state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
        loopMode: avSession.LoopMode.LOOP_MODE_SINGLE
      };
      switch (state) {
        case audio.AudioState.STATE_RUNNING:
          Logger.info('AudioRender running state.');
          playbackState.state = avSession.PlaybackState.PLAYBACK_STATE_PLAY;
          break;
        case audio.AudioState.STATE_PAUSED:
          Logger.info('AudioRender paused state.');
          playbackState.state = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
          break;
        case audio.AudioState.STATE_STOPPED:
          Logger.info('AudioRender stopped state.');
          playbackState.state = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
          break;
        default:
          Logger.info('AudioRender other state.');
          break;
      }
      await this.avSessionController?.session?.setAVPlaybackState(playbackState);
    });
  }

  // [Start interrupt_call_back]
  setAudioInterruptCallBack() {
    if (!this.audioRenderer) {
      Logger.info(TAG, 'set interrupt callback failed, audioRenderer is null.');
      return;
    }
    Logger.info(TAG, 'setAudioInterruptCallBack.');
    try {
      this.audioRenderer.on('audioInterrupt', async (interruptInfo: audio.InterruptEvent) => {
        let playbackState: avSession.AVPlaybackState = {
          state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
          loopMode: avSession.LoopMode.LOOP_MODE_SINGLE
        };
        if (interruptInfo.forceType === audio.InterruptForceType.INTERRUPT_SHARE &&
          interruptInfo.hintType === audio.InterruptHint.INTERRUPT_HINT_RESUME) {
          Logger.info('audio resume play.');
          this.audioRenderer?.start().catch((err: BusinessError) => {
            Logger.error(TAG, `audio resume failed,code is ${err.code},message is ${err.message}}`);
          })
        } else if (interruptInfo.forceType === audio.InterruptForceType.INTERRUPT_FORCE &&
          (interruptInfo.hintType === audio.InterruptHint.INTERRUPT_HINT_PAUSE ||
            interruptInfo.hintType === audio.InterruptHint.INTERRUPT_HINT_STOP)) {
          playbackState.state = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
        }
        await this.avSessionController?.session?.setAVPlaybackState(playbackState);
      })
    } catch (error) {
      Logger.error(TAG, `setAudioInterruptCallBack fail. code is ${error.code}, error message is ${error.message}`);
    }
  }

  // [End interrupt_call_back]

  async MediaPlay(): Promise<void> {
    if (!this.audioRenderer) {
      Logger.info(TAG, 'start audioRender failed, audioRenderer is null.');
      return;
    }
    Logger.info(TAG, 'play AudioRender.');
    await this.audioRenderer.start().catch((err: BusinessError) => {
      Logger.error(TAG, `start failed,code is ${err.code},message is ${err.message}}`);
    })
  }

  async MediaPause(): Promise<void> {
    if (!this.audioRenderer) {
      Logger.info(TAG, 'pause audioRender failed, audioRenderer is null.');
      return;
    }
    Logger.info(TAG, 'pause AudioRender.');
    await this.audioRenderer.pause().catch((err: BusinessError) => {
      Logger.error(TAG, `pause failed,code is ${err.code},message is ${err.message}}`);
    })
  }

  async MediaStop(): Promise<void> {
    if (!this.audioRenderer) {
      Logger.info(TAG, 'stop audioRender failed, audioRenderer is null.');
      return;
    }
    Logger.info(TAG, 'stop AudioRender.');
    await this.audioRenderer.stop().catch((err: BusinessError) => {
      Logger.error(TAG, `stop failed,code is ${err.code},message is ${err.message}}`);
    })
  }

  async releaseAudioRender(audioUrl: string) {
    try {
      let context = AppStorage.get('EntryAbilityContext') as common.UIAbilityContext;
      await context.resourceManager.closeRawFd(audioUrl);
      if (!this.audioRenderer) {
        Logger.info(TAG, 'release audioRender failed, audioRenderer is null.');
        return;
      }
      this.audioRenderer.off('writeData');
      await this.audioRenderer.release();
      Logger.info('releasePlayer success')
    } catch (error) {
      Logger.error(TAG, `releasePlayer failed,code is ${error.code},message is ${error.message}}`);
    }
  }
}