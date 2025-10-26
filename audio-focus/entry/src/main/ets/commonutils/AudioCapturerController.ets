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
import { audio } from '@kit.AudioKit';
import { fileIo, WriteOptions } from '@kit.CoreFileKit';
import { AVSessionController } from './AVSessionController';
import { MediaController } from './MediaController';
import { avSession } from '@kit.AVSessionKit';
import Logger from './Logger';

const TAG = 'AudioCapturerController';

export class AudioCapturerController implements MediaController {
  audioCapturer?: audio.AudioCapturer;
  avSessionController?: AVSessionController;
  currentOffset: number = 0;
  filePath: string = '';
  fileFd?: fileIo.File;

  // [Start init_audio_capturer]
  async createAndInitAudioCapturer(
    avSessionController: AVSessionController, audioName: string, sourceType: audio.SourceType) {
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
    let audioCapturerInfo: audio.AudioCapturerInfo = {
      source: sourceType,
      capturerFlags: 0
    };

    let audioCapturerOptions: audio.AudioCapturerOptions = {
      streamInfo: audioStreamInfo,
      capturerInfo: audioCapturerInfo
    };
    // Create an AudioCapturer instance
    this.audioCapturer = await audio.createAudioCapturer(audioCapturerOptions);
    await this.setAudioFdSrcByName(audioName);
    this.setReadDataCallback();
    this.setAudioStateChangeCallBack();
    this.setAudioInterruptCallBack();
    let playbackState: avSession.AVPlaybackState = {
      state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      loopMode: avSession.LoopMode.LOOP_MODE_SINGLE
    };
    try {
      await this.avSessionController?.session?.setAVPlaybackState(playbackState);
    } catch (error) {
      Logger.error(TAG, `setAVPlaybackState failed, code is ${error.code}, message is ${error.message}}`);
    }
  }

  // [End init_audio_capturer]

  // Use the getRawFd API of the resourceManager member of UIAbilityContext to obtain the playback address of a media resource
  async setAudioFdSrcByName(audioName: string) {
    let context = AppStorage.get('EntryAbilityContext') as common.UIAbilityContext;
    this.filePath = context.cacheDir + audioName;
    try {
      this.fileFd = fileIo.openSync(this.filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    } catch (error) {
      Logger.error(TAG, `openSync file fail. error message is ${error.message}`);
    }
  }

  setReadDataCallback() {
    if (!this.audioCapturer) {
      Logger.info(TAG, 'write audio data failed, audioCapturer is null.');
      return;
    }
    try {
      this.audioCapturer.on('readData', (buffer) => {
        let options: WriteOptions = {
          offset: this.currentOffset,
          length: buffer.byteLength
        };
        fileIo.writeSync(this.fileFd?.fd, buffer, options);
        this.currentOffset += buffer.byteLength;
      });
    } catch (error) {
      Logger.error(TAG, `setReadDataCallback fail. error message is ${error.message}`);
    }
  }

  setAudioStateChangeCallBack() {
    if (!this.audioCapturer) {
      Logger.info(TAG, 'state change callback failed, audioCapturer is null.');
      return;
    }
    this.audioCapturer.on('stateChange', async (state: audio.AudioState) => {
      // The initial playback status of AVSession is paused
      let playbackState: avSession.AVPlaybackState = {
        state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
        loopMode: avSession.LoopMode.LOOP_MODE_SINGLE
      };
      switch (state) {
        case audio.AudioState.STATE_RUNNING:
          Logger.info('AudioCapturer running state.');
          playbackState.state = avSession.PlaybackState.PLAYBACK_STATE_PLAY;
          break;
        case audio.AudioState.STATE_STOPPED:
          Logger.info('AudioCapturer stopped.');
          playbackState.state = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
          this.audioCapturer?.release();
          break;
        default:
          Logger.info('AudioCapturer state unknown.');
          break;
      }
      await this.avSessionController?.session?.setAVPlaybackState(playbackState);
    });
  }

  setAudioInterruptCallBack() {
    if (!this.audioCapturer) {
      Logger.info(TAG, 'set interrupt callback failed, audioCapturer is null.');
      return;
    }
    Logger.info(TAG, 'setAudioInterruptCallBack.');
    try {
      this.audioCapturer.on('audioInterrupt', async (interruptInfo: audio.InterruptEvent) => {
        let playbackState: avSession.AVPlaybackState = {
          state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
          loopMode: avSession.LoopMode.LOOP_MODE_SINGLE
        };
        if (interruptInfo.forceType === audio.InterruptForceType.INTERRUPT_SHARE &&
          interruptInfo.hintType === audio.InterruptHint.INTERRUPT_HINT_RESUME) {
          Logger.info('audio resume play.');
          this.audioCapturer?.start().catch((err: BusinessError) => {
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
      Logger.error(TAG, `setAudioInterruptCallBack fail. error message is ${error.message}`);
    }
  }

  async MediaPlay(): Promise<void> {
    if (!this.audioCapturer) {
      Logger.info(TAG, 'start audioCapturer failed, audioCapturer is null.');
      return;
    }
    Logger.info(TAG, 'play AudioCapturer.');
    await this.audioCapturer.start().catch((err: BusinessError) => {
      Logger.error(TAG, `start failed,code is ${err.code},message is ${err.message}}`);
    })
  }

  async MediaPause(): Promise<void> {
    Logger.info(TAG, 'audioCapturer have no pause function.');
  }

  async MediaStop(): Promise<void> {
    if (!this.audioCapturer) {
      Logger.info(TAG, 'stop audioCapturer failed, audioCapturer is null.');
      return;
    }
    Logger.info(TAG, 'stop AudioCapturer.');
    await this.audioCapturer.stop().catch((err: BusinessError) => {
      Logger.error(TAG, `stop failed,code is ${err.code},message is ${err.message}}`);
    })
  }

  async releaseAudioCapturer() {
    try {
      fileIo.closeSync(this.fileFd);
    } catch (error) {
      Logger.error(TAG, `closeSync file fail. error message is ${error.message}`);
    }
    if (!this.audioCapturer) {
      Logger.info(TAG, 'stop audioCapturer failed, audioCapturer is null.');
      return;
    }
    try {
      this.audioCapturer.off('readData');
    } catch (error) {
      Logger.error(TAG, `off readData fail. error message is ${error.message}`);
    }
    await this.audioCapturer.release();
    Logger.info('releasePlayer success')
  }
}