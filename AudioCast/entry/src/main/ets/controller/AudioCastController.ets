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
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { SongItem } from '../model/SongData';
import { MediaTools } from '../common/utils/MediaTools';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo } from '@kit.CoreFileKit';
import { media } from '@kit.MediaKit';
import { getRawStringData } from '../common/utils/LrcUtils';
import { Controller } from '../model/SongData';

const TAG = 'AudioCastController';

// [Start AudioCastController]
export class AudioCastController implements Controller {
  // [StartExclude AudioCastController]
  @Track state: avSession.PlaybackState = avSession.PlaybackState.PLAYBACK_STATE_INITIAL;
  // [EndExclude AudioCastController]
  @Track elapsedTime: number = 0;
  // [StartExclude AudioCastController]
  @Track duration: number = 0;
  @Track volume: number = 0;
  @Track musicIndex: number = 0;
  public avCastController: avSession.AVCastController | undefined;
  private context: common.UIAbilityContext | undefined = undefined;
  private songList: SongItem[] = [];

  constructor(avCastController: avSession.AVCastController | undefined) {
    this.avCastController = avCastController;
  }

  /**
   * Sets and casts the specified video resource for playback.
   * @param videoIndex Index of the video in videoDataArray.
   * @param startPosition Starting position for playback in milliseconds.
   */
  async setCastResource(startPosition: number) {
    this.context = AppStorage.get('context');
    let songItem: SongItem = this.songList[this.musicIndex];
    let curSrc = MediaTools.getSrcFromPlayMode(songItem.src);
    let lyricContent = '';
    // [Start AVQueueItem]
    let playItem: avSession.AVQueueItem;
    if (this.context && songItem.lyric) {
      lyricContent = await getRawStringData(this.context, songItem.lyric);
    }
    try {
      let file = await fileIo.open(this.context?.filesDir + '/' + curSrc);
      let avFileDescriptor: media.AVFileDescriptor = { fd: file.fd };
      playItem = {
        itemId: this.musicIndex,
        description: {
          assetId: 'AUDIO-' + JSON.stringify(this.musicIndex),
          title: songItem.title,
          artist: songItem.singer,
          subtitle: 'audio',
          mediaType: 'AUDIO',
          albumCoverUri: songItem.albumCoverUri,
          fdSrc: avFileDescriptor,
          startPosition: startPosition,
          duration: AppStorage.get('durationTime'),
          lyricContent: lyricContent,
        }
      };
      await this.avCastController?.prepare(playItem);
      await this.avCastController?.start(playItem);
    } catch (err) {
      hilog.error(0x0000, TAG, `open file ${err}`);
    }
    // [End AVQueueItem]
  }

  /**
   * Initializes AV casting session with specified video data.
   * @param videoDataArray Array of video data objects.
   * @param videoIndex Initial video index to play.
   * @param videoType Type of video source ('network' or 'local').
   * @param startPosition Initial playback position in milliseconds.
   */
  public async initAVCast(songList: SongItem[], musicIndex: number, startPosition: number) {
    this.songList = songList;
    this.musicIndex = musicIndex;
    await this.setCastResource(startPosition);
    try {
      let currentItem = await this.avCastController?.getCurrentItem();
      this.duration = currentItem?.description!.duration!;
    } catch (error) {
      hilog.error(0x0000, TAG, `avCastController getCurrentItem failed, the error is: ${JSON.stringify(error)}`);
    }
    this.setAVCastCallback();
  }

  /**
   * Sets up AV cast playback state change callbacks.
   * Handles playback completion, position updates, volume changes and errors.
   */
  // [EndExclude AudioCastController]
  setAVCastCallback() {
    this.unregisterCastListener();
    try {
      // [StartExclude AudioCastController]
      this.avCastController?.on('playbackStateChange', ['state'], async (playbackState: avSession.AVPlaybackState) => {
        if (playbackState.state) {
          this.state = playbackState.state;
        }
      });
      // [EndExclude AudioCastController]
      this.avCastController?.on('playbackStateChange', ['position'], (playbackState: avSession.AVPlaybackState) => {
        if (playbackState.position) {
          this.elapsedTime = playbackState.position.elapsedTime;
        }
      });
      // [StartExclude AudioCastController]
      this.avCastController?.on('playbackStateChange', ['volume'], (playbackState: avSession.AVPlaybackState) => {
        if (playbackState.volume) {
          this.volume = playbackState.volume;
        }
      });
      this.avCastController?.on('error', (error: BusinessError) => {
        hilog.error(0x0000, TAG, `error happened, error code: ${error.code}, error message : ${error.message}.`);
      })
      this.avCastController?.on('playbackStateChange', 'all', (playbackState: avSession.AVPlaybackState) => {
        hilog.info(0x0000, TAG, `playbackStateChange state ${playbackState}`);
      });
      // [EndExclude AudioCastController]
    } catch (error) {
      hilog.error(0x0000, TAG, `avCastController on event failed, the error is: ${JSON.stringify(error)}`);
    }
  }
  // [StartExclude AudioCastController]
  public async setPlaying() {
    try {
      // [Start SetPlaying]
      let avCommand: avSession.AVCastControlCommand = { command: 'play' };
      await this.avCastController?.sendControlCommand(avCommand);
      // [End SetPlaying]
    } catch (error) {
      hilog.error(0x0000, TAG, `avCastController sendControlCommand failed, the error is: ${JSON.stringify(error)}`);
    }
  }

  public async setPause() {
    let avCommand: avSession.AVCastControlCommand = { command: 'pause' };
    try {
      await this.avCastController?.sendControlCommand(avCommand);
    } catch (error) {
      hilog.error(0x0000, TAG, `avCastController sendControlCommand failed, the error is: ${JSON.stringify(error)}`);
    }
  }
  // [Start SendCommand]
  public async seek(timeMS: number) {
    let avCommand: avSession.AVCastControlCommand = { command: 'seek', parameter: timeMS };
    try {
      await this.avCastController?.sendControlCommand(avCommand);
    } catch (error) {
      hilog.error(0x0000, TAG, `avCastController sendControlCommand failed, the error is: ${JSON.stringify(error)}`);
    }
  }

  public async setAVCastVolume(volume: number) {
    let avCommand: avSession.AVCastControlCommand = { command: 'setVolume', parameter: volume };
    try {
      await this.avCastController?.sendControlCommand(avCommand);
    } catch (error) {
      hilog.error(0x0000, TAG, `avCastController sendControlCommand failed, the error is: ${JSON.stringify(error)}`);
    }
  }

  public async setPlayModel(mode: number) {
    let avCommand: avSession.AVCastControlCommand = { command: 'setLoopMode', parameter: mode };
    try {
      await this.avCastController?.sendControlCommand(avCommand);
    } catch (error) {
      hilog.error(0x0000, TAG, `avCastController sendControlCommand failed, the error is: ${JSON.stringify(error)}`);
    }
  }
  // [End SendCommand]

  public async setStop() {
    let avCommand: avSession.AVCastControlCommand = { command: 'stop' };
    try {
      await this.avCastController?.sendControlCommand(avCommand);
    } catch (error) {
      hilog.error(0x0000, TAG, `avCastController sendControlCommand failed, the error is: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Releases AV cast controller resources and removes event listeners.
   */
  public async releaseAVCast() {
    try {
      await this.avCastController?.release();
    } catch (error) {
      hilog.error(0x0000, TAG, `avCastController release failed, the error is: ${JSON.stringify(error)}`);
    }
    this.unregisterCastListener();
  }

  public async unregisterCastListener() {
    try {
      this.avCastController?.off('playbackStateChange');
      this.avCastController?.off('playNext');
      this.avCastController?.off('playPrevious');
      this.avCastController?.off('endOfStream');
    } catch (error) {
      hilog.error(0x0000, TAG, `avCastController off event failed, the error is: ${JSON.stringify(error)}`);
    }
  }
  // [EndExclude AudioCastController]
}
// [End AudioCastController]