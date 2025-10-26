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

/**
 * 易错API的使用规范
 */
import { BusinessError } from '@kit.BasicServicesKit';
import { avSession } from '@kit.AVSessionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

class avSessionClass {
  castController!: avSession.AVCastController;
  session!: avSession.AVSession;
  currentState: avSession.AVPlaybackState | undefined = undefined;
  currentTime: number = 1;
  playStateCallback: (state: avSession.AVPlaybackState) => void = () => {
  }

  create(context: Context, tag: string): void {
    avSession.createAVSession(context, tag, "audio").then(async (currentAVSession: avSession.AVSession) => {
      this.session = currentAVSession;
      let sessionController: avSession.AVCastController = await currentAVSession.getAVCastController();
      this.castController = sessionController;
      // [Start play_state_callback]
      let playStateCallback: (state: avSession.AVPlaybackState) => void = (state: avSession.AVPlaybackState) => {
      }
      sessionController.on('playbackStateChange', 'all', this.playStateCallback);
      sessionController.off('playbackStateChange', this.playStateCallback);
      // [End play_state_callback]
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag', `CreateAVSession BusinessError: code: ${err.code}, message: ${err.message}`);
    });
  }

  prepare(): void {
    let playItem: avSession.AVQueueItem = {
      itemId: 0,
      description: {
        assetId: '12345',
        mediaType: 'AUDIO',
        mediaUri: 'http://resource1_address',
        mediaSize: 12345,
        startPosition: 0,
        duration: 0,
        artist: 'mysong',
        albumTitle: 'song1_title',
        albumCoverUri: "http://resource1_album_address",
        lyricUri: "http://resource1_lyric_address",
        appName: 'MyMusic'
      }
    };
    // [Start prepare]
    // Preparing to play, this will not trigger actual playback, it will load and buffer
    this.castController?.prepare(playItem, () => {
      // Start playback, truly triggering the playback on the other end. Please call start after Prepare is successful.
      this.castController?.start(playItem, () => {
        hilog.info(0x0000, 'testTag', 'Playback started');
      });
    });
    // [End prepare]
  }

  onPrepare(): void {
    // [Start on_prepare]
    this.session?.on('pause', async () => {
      // Execute player pause
      // Set the status and progress during pause
      this.currentState = {
        state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
        position: {
          elapsedTime: this.currentTime,
          updateTime: new Date().getTime(),
        }
      };
      await this.session?.setAVPlaybackState(this.currentState);
    });
    // [End on_prepare]
  }
}
