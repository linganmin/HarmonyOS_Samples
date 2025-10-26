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

import { avSession } from '@kit.AVSessionKit';
import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { VideoData } from '../model/VideoData';
import { getPixmapFromMedia } from '../common/utils/ImageUtil';

const TAG = 'AVCastPlayerController ';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');

// [Start VideoCastController]
@Observed
export class VideoCastController {
  @Track state: avSession.PlaybackState = avSession.PlaybackState.PLAYBACK_STATE_INITIAL;
  // [StartExclude VideoCastController]
  @Track elapsedTime: number = 0;
  @Track duration: number = 0;
  @Track volume: number = 0;
  @Track maxVolume: number = 0;
  @Track videoIndex: number = -1;
  public avCastController: avSession.AVCastController;
  private videoDataArray: VideoData[] = [];
  videoType: string = '';

  constructor(avCastController: avSession.AVCastController) {
    this.avCastController = avCastController;
  }

  /**
   * Sets and casts the specified video resource for playback.
   * @param videoIndex Index of the video in videoDataArray.
   * @param startPosition Starting position for playback in milliseconds.
   */
  async setCastResource(videoIndex: number, startPosition: number) {
    let imgPixel = await getPixmapFromMedia(this.videoDataArray[videoIndex].head);
    this.videoIndex = videoIndex;
    if (this.videoType === 'network') {
      // [Start ArticleCitationsInitNetwork]
      let playItem: avSession.AVQueueItem = {
        itemId: videoIndex,
        description: {
          assetId: 'VIDEO-' + JSON.stringify(videoIndex),
          title: this.videoDataArray[videoIndex].name,
          subtitle: 'video',
          mediaUri: this.videoDataArray[videoIndex].url as string,
          mediaType: 'VIDEO',
          mediaImage: imgPixel,
          startPosition: startPosition,
          duration: this.videoDataArray[videoIndex].duration
        }
      };
      await this.avCastController.prepare(playItem);
      await this.avCastController.start(playItem);
      // [End ArticleCitationsInitNetwork]
    } else {
      let context = uiContext?.getHostContext() as common.UIAbilityContext;
      try {
        // [Start ArticleCitationsInitLocalWork]
        let file = await fileIo.open(context.filesDir + '/' + this.videoDataArray[videoIndex].url);
        let avFileDescriptor: media.AVFileDescriptor = { fd: file.fd };
        let playItem: avSession.AVQueueItem = {
          itemId: videoIndex,
          description: {
            assetId: 'VIDEO-' + JSON.stringify(videoIndex),
            title: this.videoDataArray[videoIndex].name,
            subtitle: 'video',
            mediaType: 'VIDEO',
            mediaImage: imgPixel,
            fdSrc: avFileDescriptor,
            startPosition: startPosition,
            duration: this.videoDataArray[videoIndex].duration
          }
        };
        await this.avCastController.prepare(playItem);
        await this.avCastController.start(playItem);
        // [End ArticleCitationsInitLocalWork]
      } catch (err) {
        hilog.error(0x0000, TAG, `open file ${err}`);
      }
    }
  }

  /**
   * Initializes AV casting session with specified video data.
   * @param videoDataArray Array of video data objects.
   * @param videoIndex Initial video index to play.
   * @param videoType Type of video source ('network' or 'local').
   * @param startPosition Initial playback position in milliseconds.
   */
  public async initAVCast(videoDataArray: VideoData[], videoIndex: number, videoType: string, startPosition: number) {
    this.videoDataArray = videoDataArray;
    this.videoType = videoType;
    await this.setCastResource(videoIndex, startPosition);
    let currentItem = await this.avCastController.getCurrentItem();
    this.duration = currentItem.description!.duration!;
    this.setAVCastCallback();
  }

  // [EndExclude VideoCastController]
  /**
   * Sets up AV cast playback state change callbacks.
   * Handles playback completion, position updates, volume changes and errors.
   */
  setAVCastCallback() {
    this.avCastController.on('playbackStateChange', ['state'], async (playbackState: avSession.AVPlaybackState) => {
      if (playbackState.state) {
        this.state = playbackState.state;
      }
    });
    // [StartExclude VideoCastController]
    this.avCastController.on('playbackStateChange', ['position'], (playbackState: avSession.AVPlaybackState) => {
      if (playbackState.position) {
        this.elapsedTime = playbackState.position.elapsedTime;
      }
    });
    this.avCastController.on('playbackStateChange', ['volume'], (playbackState: avSession.AVPlaybackState) => {
      if (playbackState.volume) {
        this.volume = playbackState.volume;
      }
    });
    this.avCastController.on('playbackStateChange', ['maxVolume'], (playbackState: avSession.AVPlaybackState) => {
      if (playbackState.maxVolume) {
        this.maxVolume = playbackState.maxVolume;
      }
    });
    this.avCastController.on('playNext',async  () => {
      if (this.videoIndex < this.videoDataArray.length - 1) {
        this.videoIndex = this.videoIndex + 1;
      } else {
        this.videoIndex = 0;
      }
    });
    this.avCastController.on('playPrevious', () => {
      if (this.videoIndex === 0) {
        this.videoIndex = 0;
      } else {
        this.videoIndex = this.videoIndex - 1;
      }
    });
    this.avCastController.on('endOfStream',async () => {
      if (this.videoIndex < this.videoDataArray.length - 1) {
        this.videoIndex = this.videoIndex + 1;
      } else {
        this.videoIndex = 0;
      }
    });
    this.avCastController.on('error', (error: BusinessError) => {
      hilog.error(0x0000, TAG, `error happened, error code: ${error.code}, error message : ${error.message}.`);
    })
    this.avCastController.on('playbackStateChange', 'all', (playbackState: avSession.AVPlaybackState) => {
      hilog.info(0x0000, TAG, `playbackStateChange state ${playbackState}`);
    });
    // [EndExclude VideoCastController]
  }

  // [StartExclude VideoCastController]
  // [Start AVCastControlCommand]
  public async setAVCastPlay() {
    let avCommand: avSession.AVCastControlCommand = { command: 'play' };
    await this.avCastController.sendControlCommand(avCommand);
  }
  // [End AVCastControlCommand]

  public async setAVCastPause() {
    let avCommand: avSession.AVCastControlCommand = { command: 'pause' };
    await this.avCastController.sendControlCommand(avCommand);
  }

  /**
   * Sends fast forward command to AV cast controller.
   * Fast forwards playback by 15 seconds.
   */
  public async setAVCastFastForward() {
    let avCommand: avSession.AVCastControlCommand = { command: 'fastForward', parameter: 15 };
    await this.avCastController.sendControlCommand(avCommand);
  }

  /**
   * Sends rewind command to AV cast controller.
   * Rewinds playback by 15 seconds.
   */
  public async setAVCastRewind() {
    let avCommand: avSession.AVCastControlCommand = { command: 'rewind', parameter: 15 };
    await this.avCastController.sendControlCommand(avCommand);
  }

  // [Start OtherAVCastControlCommand]
  public async setAVCastSeek(timeMS: number) {
    let avCommand: avSession.AVCastControlCommand = { command: 'seek', parameter: timeMS };
    await this.avCastController.sendControlCommand(avCommand);
  }

  public async setAVCastVolume(volume: number) {
    let avCommand: avSession.AVCastControlCommand = { command: 'setVolume', parameter: volume };
    await this.avCastController.sendControlCommand(avCommand);
  }

  public async setAVCastSpeed(speed: media.PlaybackSpeed) {
    let avCommand: avSession.AVCastControlCommand = { command: 'setSpeed', parameter: speed };
    await this.avCastController.sendControlCommand(avCommand);
  }
  // [End OtherAVCastControlCommand]

  /**
   * Releases AV cast controller resources and removes event listeners.
   */
  public async releaseAVCast() {
    this.avCastController.off('playbackStateChange');
    this.avCastController.off('playNext');
    this.avCastController.off('playPrevious');
    this.avCastController.off('endOfStream');
    await this.avCastController.release();
  }
  // [EndExclude VideoCastController]
}
// [End VideoCastController]