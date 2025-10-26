/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
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
import Constants, { AVPlayerState } from '../constants/Constants';
import GlobalContext from './GlobalContextUtils';
import Logger from './Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'MediaPlayer';

/**
 * Create the AVPlayer playback class.
 */
export default class MediaPlayer {
  private context: common.UIAbilityContext | undefined =
    GlobalContext.getContext().getObject(Constants.CONTEXT) as common.UIAbilityContext;
  public avPlayer?: media.AVPlayer;
  public state: string = '';
  public surfaceId: string = '';
  private callbackMap: Record<string, object | null> = {};

  public async init(): Promise<media.AVPlayer|undefined> {
    try {
      this.avPlayer = await media.createAVPlayer();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `init failed. error code=${err.code}, message=${err.message}`);
    }
    this.setAVPlayerCallback();
    return this.avPlayer;
  }

  /**
   * Listens to AVPlayer status callback.
   */
  setAVPlayerCallback(): void {
    this.avPlayer?.on('seekDone', (seekDoneTime) => {
      Logger.info(TAG, `AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    });
    this.avPlayer?.on('error', (err) => {
      Logger.error(TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      this.avPlayer?.reset();
    });
    this.avPlayer?.on('stateChange', async (state, _) => {
      this.state = state;
      Logger.info(TAG, 'AVPlayer state: ' + JSON.stringify(state));
      switch (state) {
        case AVPlayerState.IDLE:
          Logger.info(TAG, 'AVPlayer state idle called.');
          this.callbackMap = {};
          break;
        case AVPlayerState.INITIALIZED:
          Logger.info(TAG, 'AVPlayer state initialized called, callbackMap = ' + JSON.stringify(this.callbackMap));
          if (this.surfaceId) {
            this.avPlayer!.surfaceId = this.surfaceId;
          }
          await this.avPlayer?.prepare();
          break;
        case AVPlayerState.PREPARED:
          Logger.info(TAG,
            'AVPlayer state prepared called callbackMap ' + JSON.stringify(this.callbackMap[AVPlayerState.PREPARED]));
          if (this.callbackMap[AVPlayerState.PREPARED]) {
            Logger.info(TAG,
              'AVPlayer state prepared called callbackMap ' + JSON.stringify(this.callbackMap[AVPlayerState.PREPARED]));
            let callbackPre: Function = this.callbackMap[AVPlayerState.PREPARED] as Function;
            callbackPre();
            this.callbackMap[AVPlayerState.PREPARED] = null;
          }
          break;
        case AVPlayerState.PLAYING:
          Logger.info(TAG, 'AVPlayer state playing called.');
          break;
        case AVPlayerState.PAUSED:
          Logger.info(TAG, 'AVPlayer state paused called.');
          break;
        case AVPlayerState.COMPLETED:
          Logger.info(TAG, 'AVPlayer state completed called.');
          let callback: Function = this.callbackMap[AVPlayerState.COMPLETED] as Function;
          callback();
          this.callbackMap[AVPlayerState.COMPLETED] = null;
          break;
        case AVPlayerState.STOPPED:
          Logger.info(TAG, 'AVPlayer state stopped called.');
          break;
        case AVPlayerState.RELEASED:
          Logger.info(TAG, 'AVPlayer state released called.');
          break;
        default:
          Logger.error(TAG, 'AVPlayer state unknown called.');
          break;
      }
    });
  }

  public on(event: string, callback: Function): void {
    Logger.info(TAG, 'AVPlayer on callback event ' + event);
    this.callbackMap[event] = callback;
  }

  /**
   * Play a local resource.
   */
  async loadFromRawFile(fileName: string): Promise<void> {
    Logger.info(TAG, 'loadFromRawFile: ' + fileName + ' state: ' + this.state);
    if (!this.avPlayer) {
      Logger.error(TAG, 'no avplayer');
      return;
    }
    if (this.state !== AVPlayerState.IDLE) {
      try {
        await this.avPlayer.reset();
        Logger.info(TAG, 'avPlayer.reset called');
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'loadFromRawFile', `reset failed. error code=${error.code}, message=${error.message}`);
      }
    }
    try {
      const fileDescriptor: resourceManager.RawFileDescriptor | undefined =
        await this.context?.resourceManager.getRawFd(fileName);
      Logger.info(TAG, 'fileDescriptor: ' + fileDescriptor);
      if (fileDescriptor) {
        let avFileDescriptor: media.AVFileDescriptor = {
          fd: fileDescriptor.fd,
          offset: fileDescriptor.offset,
          length: fileDescriptor.length
        };
        this!.avPlayer!.fdSrc = avFileDescriptor;
      } else {
        Logger.error(TAG, 'load from raw file failed: fileName = ' + fileName);
      }
    } catch (error) {
      Logger.error(TAG, 'resourceManager getRawFd error: ' + JSON.stringify(error));
    }
  }
}