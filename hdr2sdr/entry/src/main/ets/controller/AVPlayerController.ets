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

import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';

const TAG = '[AVPlayerController]';

export class AVPlayerController {
  private surfaceID: string = '';
  @Track isPlaying: boolean = false;
  private avPlayer?: media.AVPlayer;
  private context: common.UIAbilityContext | undefined = AppStorage.get('uiContext');
  // [Start create_instance]
  // Create an AVPlayer instance
  public async initAVPlayer(surfaceId: string, path: string) {
    try {
      this.avPlayer = await media.createAVPlayer();
    } catch (error) {
      hilog.error(0x0000, TAG, `AVPlayer error, code is ${error.code}, message is ${error.message}`);
    }
    if (!this.context || !this.avPlayer) {
      return
    }
    this.surfaceID = surfaceId;
    const srcUri: string = fileUri.getUriFromPath(path);
    try {
      const srcFd = await fileIo.open(srcUri, fileIo.OpenMode.READ_ONLY);
      let fdUrl = `fd://${srcFd.fd}`;
      this.avPlayer.url = fdUrl;
    } catch (error) {
      hilog.error(0x0000, TAG, `file open failed. error is: ${JSON.stringify(error)}`);
    }
    this.setAVPlayerCallback();
  }

  // [End create_instance]
  private setAVPlayerCallback() {
    if (!this.avPlayer) {
      return;
    }
    // The error callback function is triggered when an error occurs during avPlayer operations,
    // at which point the reset interface is called to initiate the reset process
    this.avPlayer.on('error', (error: BusinessError) => {
      if (!this.avPlayer) {
        return;
      }
      hilog.error(0x0000, TAG, `AVPlayer error, code is ${error.code}, message is ${error.message}`);
      this.avPlayer.reset().catch((error: BusinessError) => {
        hilog.error(0x0000, TAG, `avPlayer reset fail. code is =${error.code}, message is = ${error.message}`);
      }); // resets the resources and triggers the idle state
    })
    this.setStateChangeCallback();
  }

  private setStateChangeCallback() {
    if (!this.avPlayer) {
      return;
    }
    // [Start loop_playback]
    /**
     * Loop playback
     */
    // Callback function for state machine changes
    this.avPlayer.on('stateChange', async (state) => {
      if (!this.avPlayer) {
        return;
      }
      switch (state) {
        case 'idle': // This state machine is triggered after the reset interface is successfully invoked.
          break;
        case 'initialized': // This status is reported after the playback source is set on the AVPlayer.
          // Set the display screen. This parameter is not required when the resource to be played is audio-only.
          this.avPlayer.surfaceId = this.surfaceID;
          try {
            await this.avPlayer.setPlaybackStrategy({
              // preferredBufferDurationForPlaying: 0.1,
              preferredBufferDuration: 20,
              showFirstFrameOnPrepare: true
            });
          } catch (error) {
            hilog.error(0x0000, TAG,
              `AVPlayer setPlaybackStrategy error, code is ${error.code}, message is ${error.message}`);
          }
          this.avPlayer.prepare().catch((error: BusinessError) => {
            hilog.error(0x0000, TAG, `avPlayer prepare fail. code is =${error.code}, message is = ${error.message}`);
          });
          break;
        case 'prepared': // This state machine is reported after the prepare interface is successfully invoked.
          //this.avPlayer.play(); // Invoke the playback interface to start playback.
          break;
        case 'playing': // After the play interface is successfully invoked, the state machine is reported.
          this.isPlaying = true;
          break;
        case 'completed': // This state machine is triggered to report when the playback ends.
          this.avPlayer.seek(0);
          this.avPlayer.play().catch((error: BusinessError) => {
            hilog.error(0x0000, TAG, `avPlayer prepare play. code is =${error.code}, message is = ${error.message}`);
          });
          break;
        default:
          break;
      }
    });
    // [End loop_playback]
  }

  videoPlay(): void {
    if (this.avPlayer) {
      this.avPlayer.play().catch((error: BusinessError) => {
        hilog.error(0x0000, TAG, `avPlayer play fail. code is =${error.code}, message is = ${error.message}`);
      });
      this.isPlaying = true;
    }
  }

  videoPause(): void {
    if (this.avPlayer) {
      this.avPlayer.pause().catch((error: BusinessError) => {
        hilog.error(0x0000, TAG, `avPlayer prepare fail. code is =${error.code}, message is = ${error.message}`);
      });
      this.isPlaying = false;
    }
  }

  // Toggle play/pause state
  videoStop(): void {
    if (this.avPlayer) {
      this.avPlayer.stop().catch((error: BusinessError) => {
        hilog.error(0x0000, TAG, `avPlayer stop fail. code is =${error.code}, message is = ${error.message}`);
      });
      this.isPlaying = false;
    }
  }

  async videoRelease(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.release((error) => {
      if (!error) {
        hilog.info(0x0000, TAG, 'videoRelease release success');
      } else {
        hilog.error(0x0000, TAG, `videoRelease release fail. code is =${error.code}, message is = ${error.message}`);
      }
    });
  }
}