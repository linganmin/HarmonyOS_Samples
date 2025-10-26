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

import { resourceManager } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { Constants } from '../constants/Constants';
import Logger from '../utils/Logger';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let UIContext = uiContext!.getHostContext()!;

export class AVPlayer {
  private avPlayer?: media.AVPlayer;
  // The surfaceID is used to display the screen.
  private surfaceID: string;
  private jumpNext: boolean = false;
  // It is used to distinguish between the player of the main interface and the player of the pip interface.
  type: number = 0;
  State: string = '';
  playStatus: boolean = true;

  constructor(surfaceID: string, type: number) {
    this.surfaceID = surfaceID;
    this.type = type;
    UIContext.eventHub.on('appStateChange', (fg: boolean) => {
      if (fg) {
        if (this.State === Constants.PAUSED_STATUS) {
          this.avPlayer?.play().catch((err: BusinessError) => {
            Logger.error(`Play failed. Cause code: ${err.code}, message: ${err.message}`);
          });
        }
      } else {
        if (this.State === Constants.PLAYING_STATUS) {
          this.avPlayer?.pause().catch((err: BusinessError) => {
            Logger.error(`Pause failed. Cause code: ${err.code}, message: ${err.message}`);
          });
        }
      }
    });
  }

  updatePlayStatus(status: boolean) {
    this.playStatus = status;
  }

  // Register the avplayer callback function.
  setAVPlayerCallback() {
    // Callback function for seek operation result.
    this.avPlayer?.on('seekDone', (seekDoneTime: number) => {
      Logger.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    });
    // error callback listens to the function.
    this.avPlayer?.on('error', (err: BusinessError) => {
      Logger.info(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      // Call the RESET call to reset the resource to trigger the idle state.
      this.avPlayer?.reset().catch((err: BusinessError) => {
        Logger.error(`Reset failed. Cause code: ${err.code}, message: ${err.message}`);
      });
      this.avPlayer?.play().catch((err: BusinessError) => {
        Logger.error(`Play failed. Cause code: ${err.code}, message: ${err.message}`);
      });
    });
    // The callback function for state machine changes.
    this.avPlayer?.on('stateChange', async (state) => {
      if (!this.avPlayer) {
        return;
      }
      this.State = state;
      switch (state) {
        // After the RESET API is successfully called, the state machine is triggered.
        case Constants.idle_STATUS:
          Logger.info('AVPlayer state idle called.');
          if (!this.jumpNext) {
            // Call the release operation to destroy the instance object.
            this.avPlayer.release().catch((err: BusinessError) => {
              Logger.error(`Release failed. Cause code: ${err.code}, message: ${err.message}`);
            });
          } else {
            try {
              let context = UIContext as common.UIAbilityContext;
              let fileDescriptor: resourceManager.RawFileDescriptor;
              fileDescriptor = await context.resourceManager.getRawFd('video.mp4');
              this.avPlayer.fdSrc = fileDescriptor;
            } catch (err) {
              Logger.error(`GetRawFd failed. Cause code: ${err.code}, message: ${err.message}`);
            }
          }
          break;
        // After avplayer sets the playback source, this status is reported.
        case Constants.INITIALIZED_STATUS:
          Logger.info('AVPlayer state initialized called.');
          // You don't need to set the display screen when the playback asset is audio-only.
          this.avPlayer.surfaceId = this.surfaceID;
          this.avPlayer.prepare().then(() => {
            Logger.info('AVPlayer prepare succeeded.');
          }).catch((err: BusinessError) => {
            Logger.error(`Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          });
          break;
        // After the prepare call is successful, the state machine is reported.
        case Constants.PREPARED_STATUS:
          Logger.info('AVPlayer state prepared called.');
          // Call the playback API to start playback.
          if (this.playStatus) {
            this.avPlayer.play().catch((err: BusinessError) => {
              Logger.error(`Play failed. Cause code: ${err.code}, message: ${err.message}`);
            });
          }
          break;
        // After the play is successfully invoked, the state machine is triggered.
        case Constants.PLAYING_STATUS:
          Logger.info('AVPlayer state playing called.');
          this.jumpNext = false;
          break;
        // After pause is successfully invoked, the state machine is triggered.
        case Constants.PAUSED_STATUS:
          Logger.info('AVPlayer state paused called.');
          break;
        // After the playback ends, the state machine is triggered.
        case Constants.COMPLETED_STATUS:
          Logger.info('AVPlayer state completed called.');
          // Call the playback end API.
          this.playNext();
          break;
        // After the stop API is successfully called, the state machine is triggered.
        case Constants.STOPPED_STATUS:
          Logger.info('AVPlayer state stopped called.');
          // Call the reset operation to initialize the avplayer state.
          this.avPlayer.reset().catch((err: BusinessError) => {
            Logger.error(`Reset failed. Cause code: ${err.code}, message: ${err.message}`);
          });
          break;
        case Constants.RELEASED_STATUS:
          Logger.info('AVPlayer state released called.');
          this.avPlayer.release().catch((err: BusinessError) => {
            Logger.error(`Release failed. Cause code: ${err.code}, message: ${err.message}`);
          });
          break;
        default:
          Logger.info('AVPlayer state unknown called.');
          break;
      }
    });
    this.avPlayer?.on('videoSizeChange', (width: number, height: number) => {
      UIContext.eventHub.emit('videoSizeRatio', width, height);
    })
  }

  /**
   * The following demo shows how to use the Resource Management API to obtain a media resource file packaged in HAP
   * and use the fdSrc attribute to play back.
   */
  async avPlayerFdSrc() {
    try {
      // Create an avPlayer instance object.
      this.avPlayer = await media.createAVPlayer();
      // Create a callback function for state machine changes.
      this.setAVPlayerCallback();
      let context = UIContext as common.UIAbilityContext;
      let fileDescriptor = await context.resourceManager.getRawFd('video.mp4');
      // Assign a value to fdSrc to trigger an initialized state machine report.
      this.avPlayer.fdSrc = fileDescriptor;
    } catch (e) {
      Logger.error(`Failed to create AVPlayer, error message:${e.message}`);
    }
  }

  async playNext() {
    if (this.avPlayer === null) {
      return;
    }
    this.jumpNext = true;
    this.avPlayer?.stop().catch((err: BusinessError) => {
      Logger.error(`Stop failed. Cause code: ${err.code}, message: ${err.message}`);
    });
  }

  play() {
    if ((this.State === Constants.PAUSED_STATUS || this.State === Constants.PREPARED_STATUS) &&
      this.playStatus === true) {
      this.avPlayer?.play().catch((err: BusinessError) => {
        Logger.error(`Play failed. Cause code: ${err.code}, message: ${err.message}`);
      });
    }
  }

  pause() {
    if (this.State === Constants.PLAYING_STATUS) {
      this.avPlayer?.pause().catch((err: BusinessError) => {
        Logger.error(`Pause failed. Cause code: ${err.code}, message: ${err.message}`);
      });
    }
  }

  stopAvPlayer() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.stop().catch((err: BusinessError) => {
      Logger.error(`Stop failed. Cause code: ${err.code}, message: ${err.message}`);
    });
    this.avPlayer.reset().catch((err: BusinessError) => {
      Logger.error(`Reset failed. Cause code: ${err.code}, message: ${err.message}`);
    });
  }
}