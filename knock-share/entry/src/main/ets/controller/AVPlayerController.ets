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

import { BusinessError } from '@kit.BasicServicesKit';
import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { Logger } from '../utils/Logger';

const TAG = 'AVPlayerController logInfo';

@Observed
export class AVPlayerController {
  // Video play state
  @Track state: string = 'default';
  @Track durationTime: number = 0;
  @Track currentTime: number = 0;
  // Is user drag or click progress slider
  public isSliderAction: boolean = false;
  private avPlayer: media.AVPlayer;
  private surfaceID: string;
  private fileName: string = '';
  private context: common.UIAbilityContext | undefined = undefined;

  private constructor(context: common.UIAbilityContext, avPlayer: media.AVPlayer, surfaceID: string) {
    this.context = context;
    this.surfaceID = surfaceID;
    this.avPlayer = avPlayer;
  }

  /**
   * Build an AVPlayerController
   * @param context sUIAbilityContext
   * @param surfaceID surface id
   * @param resource Video resource.
   * @returns AVPlayerController object.
   */
  static async create(context: common.UIAbilityContext, surfaceID: string, resource: string) {
    let avPlayerController: AVPlayerController | undefined = undefined;
    try {
      const avPlayer = await media.createAVPlayer();
      avPlayerController = new AVPlayerController(context, avPlayer, surfaceID);
      await avPlayerController.avPlayerLocal(resource);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `createAVPlayer err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
    return avPlayerController;
  }

  /**
   * Register the callback function for AVPlayer.
   */
  setAVPlayerCallback() {
    this.avPlayer.on('timeUpdate', (currentTime: number) => {
      if (!this.isSliderAction) {
        this.currentTime = currentTime;
      }
    })
    this.avPlayer.on('durationUpdate', (duration: number) => {
      this.durationTime = duration;
    })
    this.avPlayer.on('error', (err: BusinessError) => {
      Logger.error(TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      this.avPlayer.reset().catch((error: BusinessError) => {
        Logger.error(TAG, `avPlayer reset err, errCode: ${error.code}, error mesage: ${error.message}`);
      });
    });
    // State machine change callback function
    this.avPlayer.on('stateChange', async (state: string) => {
      this.state = state;
      switch (state) {
        case 'idle':
          Logger.info(TAG, 'AVPlayer state idle called.');
          break;
      // Automatically call prepare after initialization.
        case 'initialized':
          Logger.info(TAG, 'AVPlayer state initialized called.');
          this.avPlayer.surfaceId = this.surfaceID;
          this.avPlayer.prepare().catch((error: BusinessError) => {
            Logger.error(TAG, `avPlayer prepare err, errCode: ${error.code}, error mesage: ${error.message}`);
          });
          break;
      // Automatically start playing after the prepare call succeeds.
        case 'prepared':
          Logger.info(TAG, 'AVPlayer state prepared called.');
          this.avPlayer.play().catch((error: BusinessError) => {
            Logger.error(TAG, `avPlayer play err, errCode: ${error.code}, error mesage: ${error.message}`);
          });
          break;
        case 'playing':
          Logger.info(TAG, 'AVPlayer state playing called.');
          break;
        case 'paused':
          Logger.info(TAG, 'AVPlayer state paused called.');
          break;
        case 'completed':
          Logger.info(TAG, 'AVPlayer state completed called.');
          this.avPlayer.stop().catch((error: BusinessError) => {
            Logger.error(TAG, `avPlayer stop err, errCode: ${error.code}, error mesage: ${error.message}`);
          });
          break;
        case 'stopped':
          Logger.info(TAG, 'AVPlayer state stopped called.');
          this.avPlayer.reset().catch((error: BusinessError) => {
            Logger.error(TAG, `avPlayer reset err, errCode: ${error.code}, error mesage: ${error.message}`);
          });
          break;
        case 'released':
          Logger.info(TAG, 'AVPlayer state released called.');
          break;
        default:
          Logger.info(TAG, 'AVPlayer state unknown called.');
          break;
      }
    });
  }

  /**
   * Configures AVPlayer for local file playback.
   * @param fileName The name/path of the local media file.
   */
  async avPlayerLocal(fileName: string) {
    this.fileName = fileName;
    this.setAVPlayerCallback();
    if (this.context) {
      try {
        let fileDescriptor = await this.context.resourceManager.getRawFd(fileName);
        let avFileDescriptor: media.AVFileDescriptor =
          { fd: fileDescriptor.fd, offset: fileDescriptor.offset, length: fileDescriptor.length };
        this.avPlayer.fdSrc = avFileDescriptor;
      } catch (err) {
        let error = err as BusinessError;
        Logger.error(TAG, `getRawFd err, errCode: ${error.code}, error mesage: ${error.message}`);
      }
    }
  }

  /**
   * Seek in the video
   * @param timeMs seek time
   * @param mode seek mode
   */
  async avPlayerSeek(timeMs: number, mode: media.SeekMode) {
    const validSeekStates = ['prepared', 'playing', 'paused', 'completed'];
    if (!validSeekStates.includes(this.state)) {
      Logger.info(TAG, `avPlayerSeek error,this state is ${this.state}`);
    } else {
      this.avPlayer.seek(timeMs, mode);
    }
  }

  async setAVPlayerPlaying() {
    const validPlayingStates = ['prepared', 'paused', 'completed'];
    if (validPlayingStates.includes(this.state)) {
      try {
        await this.avPlayer.play();
      } catch (err) {
        let error = err as BusinessError;
        Logger.error(TAG, `play err, errCode: ${error.code}, error mesage: ${error.message}`);
      }
    } else {
      Logger.error(TAG, `setAVPlayerPlaying error,this state is ${this.state}`);
    }
  }

  async setAVPlayerPause() {
    if (this.state === 'playing') {
      try {
        await this.avPlayer.pause();
      } catch (err) {
        let error = err as BusinessError;
        Logger.error(TAG, `pause err, errCode: ${error.code}, error mesage: ${error.message}`);
      }
    }
  }

  async setAVPlayerStop() {
    const validStopStates = ['prepared', 'paused', 'completed', 'playing'];
    if (validStopStates.includes(this.state)) {
      try {
        await this.avPlayer.stop();
      } catch (err) {
        let error = err as BusinessError;
        Logger.error(TAG, `stop err, errCode: ${error.code}, error mesage: ${error.message}`);
      }
    } else {
      Logger.error(TAG, `setAVPlayerStop  error,this state is ${this.state}`);
    }
  }

  async releasePlayer() {
    try {
      if (this.fileName !== '') {
        this.context?.resourceManager.closeRawFdSync(this.fileName);
        this.fileName = '';
      }
      this.avPlayer.off('timeUpdate');
      this.avPlayer.off('durationUpdate');
      this.avPlayer.off('error');
      this.avPlayer.off('stateChange');
      await this.avPlayer.release();
      Logger.info(TAG, 'releasePlayer success');
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `releasePlayer err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }
}