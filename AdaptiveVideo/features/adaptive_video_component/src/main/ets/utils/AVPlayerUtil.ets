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
 *
 */
import { AVPlayerState } from '@hadss/adaptive_video';
import { CommonConstants } from 'base';
import { media } from '@kit.MediaKit';

export class AVPlayerUtil {
  private static instance: AVPlayerUtil;

  private constructor() {
  }

  static getInstance(): AVPlayerUtil {
    if (!AVPlayerUtil.instance) {
      AVPlayerUtil.instance = new AVPlayerUtil()
    }
    return AVPlayerUtil.instance;
  }

  /**
   * Format display time
   * @param duration duration
   * @returns Display time after formatting
   */
  public formatTime(duration: number): string {
    let totalSecond: number = Math.round(duration / CommonConstants.PROGRESS_THOUSAND);
    let hourNum: number = Math.floor(totalSecond / CommonConstants.SECOND_IN_HOUR);
    let minNum: number = Math.floor((totalSecond % CommonConstants.SECOND_IN_HOUR) / CommonConstants.SECOND_IN_MINUTE);
    let secNum: number = (totalSecond % CommonConstants.SECOND_IN_HOUR) % CommonConstants.SECOND_IN_MINUTE;
    if (hourNum === 0) {
      return this.formatUnitTime(minNum) + CommonConstants.COLON +
      this.formatUnitTime(secNum);
    } else {
      return this.formatUnitTime(hourNum) + CommonConstants.COLON + this.formatUnitTime(minNum) +
      CommonConstants.COLON + this.formatUnitTime(secNum);
    }
  }

  /**
   * Time compensation
   * @param time
   * @returns Time padding (add a 0 in front if insufficient)
   */
  public formatUnitTime(time: number): string {
    if (time >= CommonConstants.ONE && time < CommonConstants.TEN) {
      let zero: string = CommonConstants.TIME_PREFIX;
      return zero.concat(time.toString());
    } else if (time >= CommonConstants.ZERO && time < CommonConstants.ONE) {
      return CommonConstants.EMPTY_TIME;
    }
    return time.toString();
  }

  public isUrl(path: string) {
    return path.startsWith('http') || path.startsWith('https')
  }

  // Is the current player state seekable
  public isCanSeek(avPlayerState: media.AVPlayerState): boolean {
    return avPlayerState == AVPlayerState.PREPARED || avPlayerState == AVPlayerState.PAUSED ||
      avPlayerState == AVPlayerState.COMPLETED || avPlayerState == AVPlayerState.PLAYING;
  }
}