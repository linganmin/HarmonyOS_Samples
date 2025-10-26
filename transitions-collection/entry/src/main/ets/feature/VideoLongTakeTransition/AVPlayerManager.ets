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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';
import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';

export default class AVPlayerManager {
  private tag: string = 'AVPlayer';
  private avPlayer: media.AVPlayer | null = null;
  private surfaceID: string | null = null;
  private mgr: resourceManager.ResourceManager | null = null;
  private currentTime: number = 0;
  private durationTime: number = 0;
  private fileDescriptor: resourceManager.RawFileDescriptor | null = null;
  private videoSrc: string | null = null;
  isPlaying: boolean = false;
  isPrepared: boolean = false;

  // Initialize video.
  async initPlayer(ctx: common.UIAbilityContext, surfaceId: string, videoSrc: string, isPlaying: boolean,
    callback: (avPlayer: media.AVPlayer) => void): Promise<void> {
    this.surfaceID = surfaceId;
    try {
      // Create an avPlayer instance object.
      this.avPlayer = await media.createAVPlayer();
      await this.setAVPlayerCallback(callback, isPlaying);
      this.mgr = ctx.resourceManager;
      this.videoSrc = videoSrc;
      this.fileDescriptor = await this.mgr.getRawFd(this.videoSrc);
      this.avPlayer.fdSrc = this.fileDescriptor;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, this.tag, `initPlayer initPlayer err：Code is ${err.code}, message is ${err.message}`);
    }
  }

  // Register the avplayer callback function.
  async setAVPlayerCallback(callback: (avPlayer: media.AVPlayer) => void, isPlaying: boolean): Promise<void> {
    if (this.avPlayer === null) {
      hilog.info(0x0000, this.tag, 'avPlayer has not init');
      return;
    }
    this.avPlayer.on('seekDone', (seekDoneTime) => {
      hilog.info(0x0000, this.tag, `setAVPlayerCallback AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    });
    // error callback listening function. When avPlayer makes an error during operation, it calls the reset interface to trigger the reset process.
    this.avPlayer.on('error', (err) => {
      hilog.error(0x0000, this.tag, `setAVPlayerCallback Invoke avPlayer failed ${JSON.stringify(err)}`);
      if (this.avPlayer === null) {
        hilog.info(0x0000, this.tag, 'avPlayer has not init');
        return;
      }
      this.avPlayer.reset();
    });
    // State machine change callback function.
    this.avPlayer.on('stateChange', async (state) => {
      hilog.info(0x0000, this.videoSrc, 'stateChange is called >> state = ' + state);
      if (this.avPlayer === null) {
        hilog.info(0x0000, this.tag, 'avPlayer has not init');
        return;
      }
      switch (state) {
        case 'idle':
          this.avPlayer.reset();
          break;
        case 'initialized':
          if (this.surfaceID) {
            this.avPlayer.surfaceId =
              this.surfaceID; // Set the display screen. You do not need to set it when the playback resource is pure audio.
            this.avPlayer.prepare();
          }
          break;
        case 'prepared':
          this.durationTime = this.avPlayer.duration;
          this.currentTime = this.avPlayer.currentTime;
          if (isPlaying) {
            this.avPlayer.play();
          }
          callback(this.avPlayer);
          this.isPrepared = true;
          break;
        case 'playing':
          this.isPlaying = true;
          this.isPrepared = false;
          break;
        case 'completed':
          hilog.info(0x0000, this.tag, 'setAVPlayerCallback AVPlayer state completed called.');
          break;
        case 'paused':
          this.isPlaying = false;
          break;
        default:
          this.isPrepared = false;
          hilog.info(0x0000, this.tag, 'setAVPlayerCallback AVPlayer state unknown called.');
          break;
      }
    });
    // Time report monitor function
    this.avPlayer.on('timeUpdate', (time: number) => {
      this.currentTime = time;
    });
  }

  /**
   * Get total time.
   */
  getDurationTime(): number {
    return this.durationTime;
  }

  // Get current time.
  getCurrentTime(): number {
    return this.currentTime;
  }

  // Play video.
  videoPlay(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.play();
      } catch (e) {
        hilog.info(0x0000, this.tag, `videoPlay = ${JSON.stringify(e)}`);
      }
    }
  }

  // Pause video.
  videoPause(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.pause();
      } catch (error) {
        hilog.error(0x0000, this.tag, `videoPause== ${JSON.stringify(error)}`);
      }
    }
  }

  async videoRelease(): Promise<void> {
    if (this.avPlayer === null) {
      hilog.info(0x0000, this.tag, 'avPlayer has not init');
      return;
    }
    this.avPlayer.release((err) => {
      if (err === null) {
        hilog.info(0x0000, this.tag, 'videoRelease release success');
      } else {
        hilog.info(0x0000, this.tag, `videoRelease release filed,error message is = ${JSON.stringify(err.message)}`);
      }
    });
  }
}