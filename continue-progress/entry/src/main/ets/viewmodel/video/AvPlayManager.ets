/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import { resourceManager } from '@kit.LocalizationKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { GlobalContext } from '../../utils/GlobalContext';
import { hilog } from '@kit.PerformanceAnalysisKit';

const CASE_ZERO = 0;
const CASE_ONE = 1;
const CASE_TWO = 2;
const CASE_THREE = 3;

export default class AvPlayManage {
  public state: string = '';
  public avPlayer: media.AVPlayer | null = null;
  private tag: string = 'AVPlayManage';
  private surfaceID: string = '';
  private mgr: resourceManager.ResourceManager = {} as resourceManager.ResourceManager;
  // Current time of the video.
  private currentTime: number = 0;
  // Total video length.
  private durationTime: number = 0;
  // Playback rate selection.
  private speedSelect: number = 0;
  private fileDescriptor: resourceManager.RawFileDescriptor | null = null;
  private videoSrc: string = '';
  private fileSrc: string = '';
  private continue: boolean = false;
  private isSliderAction: boolean = false;

  async initPlayer(surfaceId: string, file: string, isContinue: boolean, continueTime: number,
    callback: (avPlayer: media.AVPlayer) => void): Promise<void> {
    this.surfaceID = surfaceId;
    try {
      // Creates the avPlayer instance object.
      this.avPlayer = await media.createAVPlayer();
      // Creates a callback function for state machine changes.
      this.continue = isContinue;
      await this.setAVPlayerCallback(isContinue, continueTime, callback);
      this.mgr = (GlobalContext.getContext().getObject('context') as (common.UIAbilityContext)).resourceManager;
      if (file === 'network.mp4') {
        this.fileSrc =
          'https:\/\/vd3.bdstatic.com\/mda-pdc2kmwtd2vxhiy4\/cae_h264\/1681502407203843413\/mda-pdc2kmwtd2vxhiy4.mp4';
      } else {
        this.fileSrc = file;
      }
      let regex: RegExp = new RegExp('^(http|https)', 'i');
      let bool = regex.test(this.fileSrc);
      if (bool) {
        this.avPlayer.url = this.fileSrc;
      } else {
        this.fileDescriptor = await this.mgr.getRawFd(this.fileSrc);
        this.avPlayer.fdSrc = this.fileDescriptor;
      }
    } catch (e) {
      hilog.error(0x000, 'progress',
        `setAVPlayerCallback Invoke avPlayer failed, code is ${e.code}, message is ${e.message}`);
    }
  }

  async setAVPlayerCallback(isContinue: boolean, continueTime: number,
    callback: (avPlayer: media.AVPlayer) => void): Promise<void> {
    if (this.avPlayer === null) {
      return;
    }
    this.avPlayer.on('seekDone', (seekDoneTime) => {
      hilog.info(0x000, 'progress', `setAVPlayerCallback AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    });
    this.avPlayer.on('error', (err) => {
      if (this.avPlayer === null) {
        return;
      }
      hilog.error(0x000, 'progress',
        `setAVPlayerCallback Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      this.avPlayer.reset();
    });
    this.avPlayer.on('stateChange', async (state, reason) => {
      if (this.avPlayer === null) {
        return;
      }
      switch (state) {
        case 'idle': // This state machine is triggered after the reset interface is successfully invoked.
          this.state = 'idle';
          AppStorage.set('videoState', this.state);
          this.avPlayer.release();
          this.avPlayerChoose(callback);
          break;
        case 'initialized': // This status is reported after the playback source is set on the AVPlayer.
          this.state = 'initialized';
          AppStorage.set('videoState', this.state);
          this.avPlayer.surfaceId = this.surfaceID;
          this.avPlayer.prepare();
          break;
        case 'prepared': // This state machine is reported after the prepare interface is successfully invoked.
          this.state = 'prepared';
          AppStorage.set('videoState', this.state);
          this.durationTime = this.avPlayer.duration;
          this.currentTime = this.avPlayer.currentTime;
          this.avPlayer.play(); // Invoke the playback interface to start playback.
          switch (this.speedSelect) {
            case CASE_ZERO:
              this.videoSpeedOne();
              break;
            case CASE_ONE:
              this.videoSpeedOnePointTwentyFive();
              break;
            case CASE_TWO:
              this.videoSpeedOnePointSeventyFive();
              break;
            case CASE_THREE:
              this.videoSpeedTwo();
              break;
          }
          callback(this.avPlayer);
          break;
        case 'playing': // After the play interface is successfully invoked, the state machine is reported.
          this.state = 'playing';
          AppStorage.set('videoState', this.state);
          // [Start video_seek]
          if (this.continue) {
            this.videoSeek(continueTime);
            this.continue = false;
            AppStorage.set('continue', false);
          }
          // [End video_seek]
          let eventDataTrue: emitter.EventData = {
            data: {
              'flag': true
            }
          };
          let innerEventTrue: emitter.InnerEvent = {
            eventId: 2,
            priority: emitter.EventPriority.HIGH
          };
          emitter.emit(innerEventTrue, eventDataTrue);
          break;
        case 'paused':
          this.state = 'paused';
          AppStorage.set('videoState', this.state);
          break;
        case 'stopped':
          this.state = 'stopped';
          AppStorage.set('videoState', this.state);
          break;
        case 'completed': // This state machine is triggered to report when the playback ends.
          this.state = 'completed';
          AppStorage.set('videoState', this.state);
          let eventDataFalse: emitter.EventData = {
            data: {
              'flag': false
            }
          };
          let innerEvent: emitter.InnerEvent = {
            eventId: 1,
            priority: emitter.EventPriority.HIGH
          };
          emitter.emit(innerEvent, eventDataFalse);
          break;
        default:
          this.state = 'unknown';
          AppStorage.set('videoState', this.state);
          break;
      }
    });
    // Listening function for reporting time
    // [Start time_update]
    this.avPlayer.on('timeUpdate', (time: number) => {
      if (this.isSliderAction) {
        return;
      }
      this.currentTime = time;
      AppStorage.set('currentTime', this.currentTime)
    });
    // [End time_update]
  }

  getDurationTime(): number {
    return this.durationTime;
  }

  getCurrentTime(): number {
    return this.currentTime;
  }

  videoPlay(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.play();
      } catch (e) {
        hilog.error(0x000, 'progress', `videoPlay = ${JSON.stringify(e)}`);
      }
    }
  }

  videoPause(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.pause();
      } catch (e) {
        hilog.info(0x000, 'progress', `videoPause== ${JSON.stringify(e)}`);
      }
    }
  }

  videoSpeedOne(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_00_X);
        hilog.info(0x000, 'progress', 'videoSpeed_1_00');
      } catch (e) {
        hilog.info(0x000, 'progress', `videoSpeed_1_00== ${JSON.stringify(e)}`);
      }
    }
  }

  videoSpeedOnePointTwentyFive(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_25_X);
        hilog.info(0x000, 'progress', 'videoSpeed_1_25');
      } catch (e) {
        hilog.info(0x000, 'progress', `videoSpeed_1_25== ${JSON.stringify(e)}`);
      }
    }
  }

  videoSpeedOnePointSeventyFive(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_75_X);
        hilog.info(0x000, 'progress', 'videoSpeed_1_75');
      } catch (e) {
        hilog.info(0x000, 'progress', 'videoSpeed_1_75==' + JSON.stringify(e));
      }
    }
  }

  videoSpeedTwo(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_2_00_X);
        hilog.info(0x000, 'progress', `videoSpeed_2_0`);
      } catch (e) {
        hilog.info(0x000, 'progress', `videoSpeed_2_0== ${JSON.stringify(e)}`);
      }
    }
  }

  videoSeek(seekTime: number): void {
    if (this.state === 'playing' || this.state === 'paused' || this.state === 'prepared' ||
      this.state === 'completed') {
      try {
        this.avPlayer!.seek(seekTime, media.SeekMode.SEEK_CLOSEST);
        hilog.info(0x000, 'progress', `videoSeek== ${seekTime}`);
      } catch (e) {
        hilog.info(0x000, 'progress', `videoSeek== ${JSON.stringify(e)}`);
      }
    }
  }

  async videoReset(): Promise<void> {
    if (this.avPlayer === null) {
      return;
    }
    this.avPlayer.reset();
  }

  async videoRelease(): Promise<void> {
    if (this.avPlayer === null) {
      return;
    }
    this.avPlayer.release((err) => {
      if (err === null) {
        hilog.info(0x000, 'progress', 'videoRelease release success');
      }
    });
  }

  async videoChoose(videoSrc: string): Promise<void> {
    try {
      this.videoSrc = videoSrc;
      let timeInterval = AppStorage.get('timeInterval') as number;
      clearInterval(timeInterval);
      hilog.info(0x000, 'progress', `videoChoose this.videoSrc = ${this.videoSrc}`);
      this.videoReset();
    } catch (e) {
      hilog.info(0x000, 'progress', `videoChoose== ${JSON.stringify(e)}`);
    }
  }

  async avPlayerChoose(callback: (avPlayer: media.AVPlayer) => void): Promise<void> {
    try {
      this.avPlayer = await media.createAVPlayer();
      this.fileDescriptor = null;
      if (this.videoSrc === 'network.mp4') {
        this.fileSrc =
          'https:\/\/vd3.bdstatic.com\/mda-pdc2kmwtd2vxhiy4\/cae_h264\/1681502407203843413\/mda-pdc2kmwtd2vxhiy4.mp4';
      } else {
        this.fileSrc = this.videoSrc;
      }
      let regex: RegExp = new RegExp('^(http|https)', 'i');
      let bool = regex.test(this.fileSrc);
      if (bool) {
        this.avPlayer.url = this.fileSrc;
      } else {
        this.fileDescriptor = await this.mgr.getRawFd(this.fileSrc);
        this.avPlayer.fdSrc = this.fileDescriptor;
      }
      await this.setAVPlayerCallback(this.continue, 0, callback);
    } catch (e) {
      e = e as BusinessError;
      this.videoReset();
    }
  }

  sliderAction(isSliderAction: boolean) {
    this.isSliderAction = isSliderAction;
  }
}