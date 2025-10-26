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

import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants as Const } from '../CommonConstants';

const TAG: string = 'AVPLAYER_UTIL';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');

export class AVPlayerUtil {
  private avPlayer?: media.AVPlayer;
  private context: common.UIAbilityContext = uiContext?.getHostContext() as common.UIAbilityContext;
  private url: resourceManager.RawFileDescriptor | null = null;
  private surfaceId: string = '';
  private sliderBegin: number = 0;
  private isMoving: boolean = false;
  private onError: (err: BusinessError) => void = (err: BusinessError) => {
    hilog.error(0x0000, TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
    this.avPlayer?.reset();
  }
  private onTimeUpdateFunction: (updateTime: number) => void = (updateTime: number) => {
    AppStorage.setOrCreate<string>(Const.AV_PLAYER_CURRENT_TIME, this.formatTime(updateTime));
    AppStorage.setOrCreate<number>(Const.AV_PLAYER_UPDATE_TIME, updateTime);
    AppStorage.setOrCreate<number>(Const.AV_PLAYER_PROGRESS, updateTime / this.avPlayer!.duration *
    Const.PROGRESS_HUNDRED);
  }
  private onStateChange: (state: media.AVPlayerState) => void = async (state: media.AVPlayerState) => {
    if (this.avPlayer === undefined) {
      hilog.error(0x0000, TAG, `AvPlayer is undefined`);
      return;
    }
    switch (state) {
      case 'idle':
        hilog.info(0x0000, TAG, 'AVPlayer state idle called.');
        break;
      case 'initialized':
        hilog.info(0x0000, TAG, 'AVPlayer initialized called.');
        this.avPlayer.surfaceId = this.surfaceId;
        this.avPlayer.prepare().then(() => {
          hilog.info(0x0000, TAG, 'AVPlayer prepare succeeded.');
        }, (err: BusinessError) => {
          hilog.error(0x0000, TAG, `Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          if (this.avPlayer === undefined) {
            hilog.error(0x0000, TAG, `AvPlayer is undefined`);
            return;
          }
          this.avPlayer.reset();
        });
        break;
      case 'prepared':
        this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT;
        hilog.info(0x0000, TAG, 'AVPlayer state prepared called.');
        this.avPlayer.play();
        AppStorage.setOrCreate<string>(Const.AV_PLAYER_TOTAL_TIME, this.formatTime(this.avPlayer.duration));
        break;
      case 'playing':
        hilog.info(0x0000, TAG, 'AVPlayer state playing called.');
        AppStorage.setOrCreate('avplayerState', this.avPlayer.state);
        break;
      case 'paused':
        hilog.info(0x0000, TAG, 'AVPlayer state paused called.');
        AppStorage.setOrCreate('avplayerState', this.avPlayer.state);
        break;
      case 'completed':
        hilog.info(0x0000, TAG, 'AVPlayer state completed called.');
        AppStorage.setOrCreate('avplayerState', this.avPlayer.state);
        this.avPlayer.play();
        break;
      case 'stopped':
        hilog.info(0x0000, TAG, 'AVPlayer state stopped called.');
        break;
      case 'released':
        hilog.info(0x0000, TAG, 'AVPlayer state released called.');
        break;
      case 'error':
        hilog.error(0x0000, TAG, 'AVPlayer state error called.');
        break;
      default:
        hilog.info(0x0000, TAG, 'AVPlayer state unknown called.');
        break;
    }
  }

  static getInstance(): AVPlayerUtil | undefined {
    if (!AppStorage.get<AVPlayerUtil>('avPlayerUtil')) {
      AppStorage.setOrCreate('avPlayerUtil', new AVPlayerUtil());
    } else {
      hilog.info(0x0000, TAG, `AppStorage does not have avPlayerUtil`);
    }
    return AppStorage.get<AVPlayerUtil>('avPlayerUtil');
  }

  async createAvPlayer(surfaceId: string): Promise<void> {
    if (this.avPlayer === undefined || this.avPlayer.state === 'released') {
      this.avPlayer = await media.createAVPlayer();
      this.surfaceId = surfaceId;
      hilog.info(0x0000, TAG, 'Created AvPlayer successfully.');
      // Entering idle state.
      this.url = await this.context.resourceManager.getRawFd(Const.PRODUCT_VIDEO_NAME);
      this.avPlayer.fdSrc = this.url;
      this.setAVPlayerCallback();
    } else {
      hilog.info(0x0000, TAG, `AvPlayer has been created`);
      this.surfaceId = surfaceId!;
      this.url = await this.context.resourceManager.getRawFd(Const.PRODUCT_VIDEO_NAME);
      this.avPlayer.fdSrc = this.url;
    }
  }

  setAVPlayerCallback(): void {
    this.avPlayer?.on('error', this.onError);
    this.onTimeUpdate();
    this.setStateChange();
  }

  onTimeUpdate(): void {
    this.avPlayer?.on('timeUpdate', this.onTimeUpdateFunction);
  }

  offTimeUpdate(): void {
    try {
      this.avPlayer?.off('timeUpdate');
    } catch (exception) {
      hilog.error(0x0000, TAG, 'Failed to unregister callback. Code: ' + JSON.stringify(exception));
    }
  }

  setStateChange(): void {
    this.avPlayer?.on('stateChange', this.onStateChange);
  }

  release(): void {
    if (this.avPlayer !== undefined && this.avPlayer.state !== 'released') {
      try {
        this.avPlayer.off('error');
        this.avPlayer.off('stateChange');
      } catch (exception) {
        hilog.error(0x0000, TAG, 'Failed to unregister callback. Code: ' + JSON.stringify(exception));
      }
      this.avPlayer.release();
    } else {
      hilog.info(0x0000, TAG, `AvPlayer release failed`);
    }
  }

  sliderChange(value: number, mode: SliderChangeMode): void {
    let seekType: media.SeekMode = value > this.sliderBegin ? media.SeekMode.SEEK_PREV_SYNC :
      media.SeekMode.SEEK_NEXT_SYNC;
    switch (mode) {
      case SliderChangeMode.Begin:
        hilog.info(0x0000, TAG, `AvPlayer SliderChangeMode Begin`);
        this.sliderBegin = value;
        this.avPlayer?.pause();
        break;
      case SliderChangeMode.Moving:
        hilog.info(0x0000, TAG, `AvPlayer SliderChangeMode Moving`);
        this.isMoving = true;
        break;
      case SliderChangeMode.End:
        hilog.info(0x0000, TAG, `AvPlayer SliderChangeMode End`);
        if (this.isMoving) {
          this.avPlayer?.seek(value / Const.PROGRESS_HUNDRED * this.avPlayer.duration, seekType);
          this.isMoving = false;
        }
        this.avPlayer?.play();
        break;
      case SliderChangeMode.Click:
        hilog.info(0x0000, TAG, `AvPlayer SliderChangeMode Click`);
        this.avPlayer?.seek(this.sliderBegin / Const.PROGRESS_HUNDRED * this.avPlayer.duration, seekType);
        break;
      default:
        break;
    }
  }

  playerStateControl(): void {
    if (this.avPlayer?.state === 'stopped') {
      this.avPlayer.prepare();
    } else if (this.avPlayer?.state === 'paused') {
      this.avPlayer.play();
    } else if (this.avPlayer?.state === 'playing') {
      this.avPlayer.pause();
    }
  }

  resetAVPlayer(): void {
    this.avPlayer?.reset();
  }

  pauseAVPlayer(): void {
    this.avPlayer?.pause();
  }

  formatTime(duration: number): string {
    let totalSecond: number = Math.round(duration / Const.PROGRESS_THOUSAND);
    let hourNum: number = Math.floor(totalSecond / Const.SECOND_IN_HOUR);
    let minNum: number = Math.floor((totalSecond % Const.SECOND_IN_HOUR) / Const.SECOND_IN_MINUTE);
    let secNum: number = (totalSecond % Const.SECOND_IN_HOUR) % Const.SECOND_IN_MINUTE;
    return this.formatUnitTime(hourNum) + Const.COLON + this.formatUnitTime(minNum) + Const.COLON +
      this.formatUnitTime(secNum);
  }

  formatUnitTime(time: number): string {
    if (time >= 1 && time < 10) {
      let zero: string = Const.TIME_PREFIX;
      return zero.concat(time.toString());
    } else if (time >= 0 && time < 1) {
      return Const.EMPTY_TIME;
    }
    return time.toString();
  }
}