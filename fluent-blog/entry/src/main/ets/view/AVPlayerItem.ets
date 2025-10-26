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
import { hilog } from '@kit.PerformanceAnalysisKit';

// Video name
const VIDEO_NAME = 'videoTest.mp4';
const TAG = 'AVPlayerItem';

@Observed
export class AVPlayerItem {
  public avPlayer: media.AVPlayer | null = null;
  public count: number = 0;
  public surfaceID: string = '';
  public isSeek: boolean = false;
  public totalTime: number = 0;
  public curTime: number = 0;
  public sliderValue: number = 0;

  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('timeUpdate', () => {
      this.curTime = avPlayer.currentTime / 1000;
    })
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle':
          avPlayer.release();
          break;
        case 'initialized':
          avPlayer.surfaceId = this.surfaceID;
          avPlayer.prepare();
          avPlayer.pause();
          break;
        case 'prepared':
          avPlayer.play();
          this.totalTime = avPlayer.duration / 1000;
          break;
        case 'paused':
          avPlayer.play();
          break;
        case 'completed':
          avPlayer.seek(0);
          avPlayer.pause();
          break;
        case 'stopped':
          this.curTime = 0;
          avPlayer.reset();
          break;
        case 'released':
          break;
        default:
          break;
      }
    })
  }

  async avPlayerPlay(uiContext: UIContext) {
    try {
      this.avPlayer = await media.createAVPlayer();
      this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_00_X);
      this.setAVPlayerCallback(this.avPlayer);
      let context = uiContext.getHostContext() as common.UIAbilityContext;
      let fileDescriptor = await context.resourceManager.getRawFd(VIDEO_NAME);
      this.totalTime = fileDescriptor.length;
      this.curTime = fileDescriptor.offset;
      let avFileDescriptor: media.AVFileDescriptor = {
        fd: fileDescriptor.fd,
        offset: fileDescriptor.offset,
        length: fileDescriptor.length
      };
      this.isSeek = true;
      this.avPlayer.fdSrc = avFileDescriptor;
      this.avPlayer.prepare();
    } catch (error) {
      hilog.error(0x0000, TAG, `avPlayerPlay catch error, code: ${error.code}, message: ${error.message}`);
    }
  }
}