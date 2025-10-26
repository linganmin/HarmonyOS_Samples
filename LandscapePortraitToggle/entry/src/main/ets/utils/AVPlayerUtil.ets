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

import { BusinessError } from '@kit.BasicServicesKit';
import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import Logger from '../utils/Logger';

const TAG = 'AVPlayerUtilLogTag';

export class AVPlayerUtil {
  private surfaceId: string = '';
  private avPlayer: media.AVPlayer | undefined = undefined;
  private callBack: Function = () => {
  };
  private UIContext: UIContext

  constructor(UIContext: UIContext) {
    this.UIContext = UIContext
  }

  setSurfaceId(surfaceId: string) {
    this.surfaceId = surfaceId;
  }

  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('stateChange', async (state: string) => {
      switch (state) {
        case 'idle':
          Logger.info('AVPlayer state idle called.');
          avPlayer.release().catch((error: BusinessError) => {
            Logger.error(TAG, `avPlayer release err, error code: ${error.code}, error mesage: ${error.message}`);
          });
          break;
        case 'initialized':
          Logger.info('AVPlayer state initialized called.');
          avPlayer.surfaceId = this.surfaceId;
          avPlayer.prepare().catch((error: BusinessError) => {
            Logger.error(TAG, `avPlayer initialized err, error code: ${error.code}, error mesage: ${error.message}`);
          });
          break;
        case 'prepared':
          Logger.info('AVPlayer state prepared called.');
          avPlayer.play().catch((error: BusinessError) => {
            Logger.error(TAG, `avPlayer play err, error code: ${error.code}, error mesage: ${error.message}`);
          });
          break;
        case 'playing':
          Logger.info('AVPlayer state playing called.');
          break;
        case 'paused':
          Logger.info('AVPlayer state paused called.');
          break;
        case 'completed':
          Logger.info('AVPlayer state completed called.');
          avPlayer.play().catch((error: BusinessError) => {
            Logger.error(TAG, `avPlayer play err, error code: ${error.code}, error mesage: ${error.message}`);
          });
          break;
        case 'stopped':
          Logger.info('AVPlayer state stopped called.');
          avPlayer.reset().catch((error: BusinessError) => {
            Logger.error(TAG, `avPlayer reset err, error code: ${error.code}, error mesage: ${error.message}`);
          });
          break;
        case 'released':
          Logger.info('AVPlayer state released called.');
          break;
        default:
          break;
      }
    })

    // get video height and width
    avPlayer.on('videoSizeChange', (width: number, height: number) => {
      Logger.info('videoSizeChange called,and width is:' + width + ', height is :' + height);
      this.callBack(height / width);
    })
  }

  async initPlayer(url: string, callBack: Function) {
    try {
      this.avPlayer = await media.createAVPlayer();
      this.callBack = callBack;
      this.setAVPlayerCallback(this.avPlayer);

      let context = this.UIContext.getHostContext() as common.UIAbilityContext;
      let fileDescriptor = await context.resourceManager.getRawFd(url);
      let avFileDescriptor: media.AVFileDescriptor =
        { fd: fileDescriptor.fd, offset: fileDescriptor.offset, length: fileDescriptor.length };
      this.avPlayer.fdSrc = avFileDescriptor;
      Logger.info('fdSrc: ' + this.avPlayer.fdSrc);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `initPlayer err, error code: ${error.code}, error mesage: ${error.message}`);
    }
  }
}
