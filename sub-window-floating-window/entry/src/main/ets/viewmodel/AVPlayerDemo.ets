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
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import Logger from '../utils/Logger';

export class AVPlayerDemo {
  private surfaceID: string = '';
  private avPlayer: media.AVPlayer | null = null;
  private status: string = '';

  constructor(surfaceID: string) {
    this.surfaceID = surfaceID;
  }

  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('startRenderFrame', () => {
      Logger.info(`AVPlayer start render frame`);
    })
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      Logger.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    })
    avPlayer.on('error', (err: BusinessError) => {
      Logger.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      avPlayer.reset();
    })
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle':
          Logger.info('AVPlayer state idle called.');
          avPlayer.release();
          break;
        case 'initialized':
          Logger.info('AVPlayer state initialized called.');
          avPlayer.surfaceId = this.surfaceID;
          avPlayer.prepare();
          break;
        case 'prepared':
          Logger.info('AVPlayer state prepared called.');
          avPlayer.play();
          break;
        case 'playing':
          Logger.info('AVPlayer state playing called.');
          this.status = state;
          break;
        case 'paused':
          Logger.info('AVPlayer state paused called.');
          this.status = state;
          break;
        case 'completed':
          Logger.info('AVPlayer state completed called.');
          avPlayer.stop();
          break;
        case 'stopped':
          Logger.info('AVPlayer state stopped called.');
          avPlayer.prepare();
          break;
        case 'released':
          Logger.info('AVPlayer state released called.');
          break;
        default:
          Logger.info('AVPlayer state unknown called.');
          break;
      }
    })
  }

  async avPlayerFdSrcDemo(context: common.UIAbilityContext) {
    try {
      let avPlayer: media.AVPlayer = await media.createAVPlayer();
      this.setAVPlayerCallback(avPlayer);
      let fileDescriptor = await context.resourceManager.getRawFd('product.mp4');
      let avFileDescriptor: media.AVFileDescriptor =
        { fd: fileDescriptor.fd, offset: fileDescriptor.offset, length: fileDescriptor.length };
      avPlayer.fdSrc = avFileDescriptor;
      this.avPlayer = avPlayer;
    } catch (e) {
      Logger.error(`AVPlayer catch error happened,error ${JSON.stringify(e)}`);
    }
  }

  switchPlayOrPause() {
    if (this.avPlayer === null) {
      return;
    }
    if (this.status === 'playing') {
      this.avPlayer.pause().catch((error: BusinessError) => {
        Logger.error(`pause error, code is ${error.code}, message is ${error.message}`);
      });
    } else {
      this.avPlayer.play().catch((error: BusinessError) => {
        Logger.error(`play error, code is ${error.code}, message is ${error.message}`);
      });
    }
  }

  pause() {
    if (this.avPlayer === null) {
      return;
    }
    this.avPlayer.pause().catch((error: BusinessError) => {
      Logger.error(`pause error, code is ${error.code}, message is ${error.message}`);
    });
  }

  play() {
    if (this.avPlayer === null) {
      return;
    }
    this.avPlayer.play().catch((error: BusinessError) => {
      Logger.error(`play error, code is ${error.code}, message is ${error.message}`);
    });
  }
}