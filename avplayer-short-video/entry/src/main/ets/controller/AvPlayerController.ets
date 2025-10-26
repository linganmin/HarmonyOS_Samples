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
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { AVPlayerState, CommonConstants, VideoDataType } from '../common/constants/CommonConstants';
import { VideoData } from '../model/VideoData';
import Logger from '../common/utils/Logger';
import { audio } from '@kit.AudioKit';

const TAG = '[AvPlayerController]';

@Observed
export class AvPlayerController {
  @Track surfaceID: string = '';
  @Track isPlaying: boolean = false;
  @Track isReady: boolean = false;
  @Track currentTime: number = 0;
  @Track currentBufferTime: number = 0;
  @Track isLoading: boolean = false;
  @Track duration: number = 0;
  @Track durationTime: number = 0;
  @Track currentCaption: string = '';
  private avPlayer?: media.AVPlayer;
  private curSource?: VideoData;
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  private index: number = 0;
  private langFlag?: boolean | undefined = undefined;
  private seekTime?: number;

  // [Start create_instance]
  // Create an AVPlayer instance
  public async initAVPlayer(avPlayer: media.AVPlayer, source: VideoData, surfaceId: string) {
    this.avPlayer = avPlayer;
    if (!this.context) {
      return
    }
    this.curSource = source;
    if (source.seekTime) {
      this.seekTime = source.seekTime;
    }
    if (source.index) {
      this.index = source.index;
    }
    if (!this.curSource) {
      return;
    }
    this.surfaceID = surfaceId;

    try {
      // Creates a callback function for state machine changes.
      this.setAVPlayerCallback();

      if (!this.context) {
        Logger.error(TAG, `initPlayer failed context not set`);
        return
      }
      switch (this.curSource.type) {
        case VideoDataType.RAW_FILE:
          let fileDescriptor = await this.context.resourceManager.getRawFd(this.curSource.videoSrc);
          this.avPlayer.fdSrc = fileDescriptor;
          break;
        case VideoDataType.URL:
          this.avPlayer.url = this.curSource.videoSrc;
          break;
        case VideoDataType.RAW_M3U8_FILE:
          let m3u8Fd = await this.context.resourceManager.getRawFd(this.curSource.videoSrc);
          let fdUrl = 'fd://' + m3u8Fd.fd + '?offset=' + m3u8Fd.offset + '&size=' + m3u8Fd.length;
          let mediaSource = media.createMediaSourceWithUrl(fdUrl);
          mediaSource.setMimeType(media.AVMimeTypes.APPLICATION_M3U8);
          let playbackStrategy: media.PlaybackStrategy = { preferredBufferDuration: 20, showFirstFrameOnPrepare: true };
          await this.avPlayer.setMediaSource(mediaSource, playbackStrategy);
          break;
        case VideoDataType.RAW_MP4_FILE:
          let mp4Fd = await this.context.resourceManager.getRawFd(this.curSource.videoSrc);
          let mp4FdUrl = 'fd://' + mp4Fd.fd;
          this.avPlayer.url = mp4FdUrl;
          break;
        default:
          break;
      }

      if (this.curSource.caption) {
        let fileDescriptorSub = await this.context.resourceManager.getRawFd(this.curSource.caption);
        this.avPlayer.addSubtitleFromFd(fileDescriptorSub.fd, fileDescriptorSub.offset, fileDescriptorSub.length);
      }
    } catch (error) {
      Logger.error(TAG, `initPlayer initPlayer err: ${error.message}`);
    }

  }

  // [End create_instance]
  private setAVPlayerCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer!.on('error', (err: BusinessError) => {
      Logger.error(`AVPlayer error, code is ${err.code}, message is ${err.message}`);
      this.avPlayer!.reset();
    });
    // Listening function for reporting time
    this.avPlayer!.on('startRenderFrame', () => {
      AppStorage.setOrCreate('StartRender', true);
    });
    this.avPlayer!.on('durationUpdate', (time: number) => {
      this.duration = time;
      AppStorage.setOrCreate('DurationTime', time);
    });
    this.avPlayer.on('timeUpdate', (time: number) => {
      this.currentTime = time;
      AppStorage.setOrCreate('CurrentTime', time);
    });

    // The error callback function is triggered when an error occurs during avPlayer operations,
    // at which point the reset interface is called to initiate the reset process
    this.avPlayer.on('error', (err: BusinessError) => {
      if (!this.avPlayer) {
        return;
      }
      Logger.error(TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      this.avPlayer.reset(); // resets the resources and triggers the idle state
    })

    // Subtitles mount callback functions
    this.avPlayer.on('subtitleUpdate', (info: media.SubtitleInfo) => {
      if (!!info) {
        let text = (!info.text) ? '' : info.text;
        this.currentCaption = text;
      } else {
        this.currentCaption = '';
        Logger.error(TAG, 'subtitleUpdate info is null');
      }
    });

    // Listen to the streaming media buffer status and the estimated playback duration of the buffered data
    this.avPlayer.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
      if (infoType === media.BufferingInfoType.BUFFERING_START) {
        this.isLoading = true;
      } else if (infoType === media.BufferingInfoType.BUFFERING_END) {
        this.isLoading = false;
      }
      if (this.durationTime === 0) {
        return;
      }
      if (infoType === media.BufferingInfoType.CACHED_DURATION && this.avPlayer) {
        this.currentBufferTime = Math.max(this.currentBufferTime, this.currentTime + value);
      }
    });
    this.setInterruptCallback();
    this.setStateChangeCallback();
  }

  // [Start RegisterInterruptCallBack]
  private setInterruptCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.on('audioInterrupt', async (interruptEvent: audio.InterruptEvent) => {
      if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
        // For the INTERRUPT_FORCE type: Audio-related processing has been performed by the system, and the
        // application needs to update its own state and make the corresponding adjustments.
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
            // This branch indicates that the system has paused the audio stream (temporarily lost focus).
            this.videoPause();
            break;
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            // This branch indicates that the system has stopped the audio stream (permanently lost focus).
            this.videoPause();
            break;
          case audio.InterruptHint.INTERRUPT_HINT_DUCK:
            // This branch indicates that the system has reduced the audio volume (default to 20% of the normal volume).
            break;
          case audio.InterruptHint.INTERRUPT_HINT_UNDUCK:
            // This branch indicates that the system has restored the audio volume to normal.
            break;
          default:
            break;
        }
      } else if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_SHARE) {
        // For the INTERRUPT_SHARE type: The application can choose to perform related actions or ignore the
        // audio interruption event.
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_RESUME:
            // This branch indicates that the audio stream, which was paused due to temporary loss of focus,
            // can now resume playing.
            this.videoPlay();
            break;
          default:
            break;
        }
      }
    })
  }

  // [End RegisterInterruptCallBack]

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
        // DocsDot
        case 'idle': // This state machine is triggered after the reset interface is successfully invoked.
          break;
        case 'initialized': // This status is reported after the playback source is set on the AVPlayer.
          // Set the display screen. This parameter is not required when the resource to be played is audio-only.
          this.avPlayer.surfaceId = this.surfaceID;
          await this.avPlayer.setPlaybackStrategy({
            // preferredBufferDurationForPlaying: 0.1,
            preferredBufferDuration: 20,
            showFirstFrameOnPrepare: true
          });
          this.avPlayer.prepare();
          break;
        case 'prepared': // This state machine is reported after the prepare interface is successfully invoked.
          this.isReady = true;
          this.durationTime = this.avPlayer.duration;
          this.currentTime = this.avPlayer.currentTime;
          if (this.seekTime) {
            this.avPlayer!.seek(this.seekTime!, media.SeekMode.SEEK_CLOSEST);
          }
          let eventData: emitter.EventData = {
            data: {
              'percent': this.avPlayer.width / this.avPlayer.height
            }
          };
          emitter.emit(CommonConstants.AVPLAYER_PREPARED, eventData);
          if (this.index === 0 || this.langFlag) {
            this.avPlayer.play(); // Invoke the playback interface to start playback.
          }
          break;
        case 'playing': // After the play interface is successfully invoked, the state machine is reported.
          this.isPlaying = true;
          let eventDataTrue: emitter.EventData = {
            data: {
              'flag': true
            }
          };
          let innerEventTrue: emitter.InnerEvent = {
            eventId: 2,
            priority: emitter.EventPriority.HIGH
          };
          emitter.emit(innerEventTrue, eventDataTrue);
          break;
      // DocsDot
        case 'completed': // This state machine is triggered to report when the playback ends.
          this.currentTime = 0;
          this.avPlayer.seek(0);
          this.avPlayer.play();
          let eventDataFalse: emitter.EventData = {
            data: {
              'flag': false
            }
          };
          let innerEvent: emitter.InnerEvent = {
            eventId: 1,
            priority: emitter.EventPriority.HIGH
          };
          emitter.emit(innerEvent, eventDataFalse);
          break;
        // DocsDot
        default:
          break;
        // DocsDot
      }
    });
    // [End loop_playback]
  }

  private updateIsPlay(isPlay: boolean) {
    this.isPlaying = isPlay;
  }

  videoPlay(): void {
    if (this.avPlayer) {
      try {
        if (AppStorage.has('speedIndex')) {
          let speedSelect: number = AppStorage.get('speedIndex') as number;
          switch (speedSelect) {
            case 0:
              this.videoSpeedOne();
              break;
            case 1:
              this.videoSpeedOnePointTwentyFive();
              break;
            case 2:
              this.videoSpeedOnePointSeventyFive();
              break;
            case 3:
              this.videoSpeedTwo();
              break;
            default:
              break;
          }
        }
        this.avPlayer.play();
        this.isPlaying = true;
      } catch (error) {
        Logger.error(TAG, `error code is =${error.code}, videoPlay message is = ${error.message}`);
      }
    }
  }

  videoPause(): void {
    if (this.avPlayer) {
      try {
        this.updateIsPlay(false);
        this.avPlayer.pause();
        this.isPlaying = false;
      } catch (error) {
        Logger.error(TAG, `error code is =${error.code}, videoPause message is = ${error.message}`);
      }
    }
  }

  // Toggle play/pause state
  videoStop(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.stop();
        this.isPlaying = false;
      } catch (error) {
        Logger.error(TAG, `error code is =${error.code}, videoStop message is = ${error.message}`);
      }
    }
  }

  getVideoState(): AVPlayerState {
    let status: AVPlayerState = AVPlayerState.UNDEFINED;
    if (this.avPlayer !== undefined) {
      switch (this.avPlayer!.state) {
        case 'idle':
          status = AVPlayerState.IDLE;
          break;
        case 'initialized':
          status = AVPlayerState.INITIALIZED;
          break;
        case 'prepared':
          status = AVPlayerState.PREPARED;
          break;
        case 'playing':
          status = AVPlayerState.PLAYING;
          break;
        case 'paused':
          status = AVPlayerState.PAUSED;
          break;
        case 'completed':
          status = AVPlayerState.COMPLETED;
          break;
        case 'stopped':
          status = AVPlayerState.STOPPED;
          break;
        case 'released':
          status = AVPlayerState.RELEASED;
          break;
        case 'error':
          status = AVPlayerState.ERROR;
          break;
        default:
          status = AVPlayerState.UNDEFINED;
          break;
      }
    }
    return status;
  }

  videoSeek(seekTime: number): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.seek(seekTime, media.SeekMode.SEEK_CLOSEST);
      } catch (error) {
        Logger.error(TAG, `error code is =${error.code}, videoSeek message is = ${error.message}`);
      }
    }
  }

  async videoRelease(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.release((err) => {
      if (!err) {
        Logger.info(TAG, 'videoRelease release success');
      } else {
        Logger.error(TAG, `videoRelease release filed, error message is = ${err.message}`);
      }
    });
  }

  async videoMuted(isMuted: boolean): Promise<void> {
    if (this.avPlayer) {
      try {
        await this.avPlayer!.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, isMuted)
      } catch (err) {
        Logger.info(TAG, `videoMuted failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // [Start video_speed_fun]

  // [Start video_speed_1.0X_fun]
  videoSpeedOne(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_00_X);
      } catch (err) {
        Logger.info(TAG, `videoSpeed_1_00 failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // [End video_speed_1.0X_fun]

  videoSpeedOnePointTwentyFive(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_25_X);
      } catch (err) {
        Logger.info(TAG, `videoSpeed_1_25 failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  videoSpeedOnePointSeventyFive(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_75_X);
      } catch (err) {
        Logger.info(TAG, `videoSpeed_1_75 failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // [Start video_speed_2.0X_fun]
  videoSpeedTwo(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_2_00_X);
      } catch (err) {
        Logger.info(TAG, `videoSpeed_2_0 failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // [End video_speed_2.0X_fun]
  // [End video_speed_fun]

  async languageChange(languageSelect: number = 0): Promise<void> {
    if (this.avPlayer) {
      try {
        if (this.curSource && this.curSource.caption) {
          if (this.curSource.caption.slice(0, 2) === 'cn' && languageSelect === 0 ||
            this.curSource.caption.slice(0, 2) === 'en' && languageSelect === 1) {
            this.langFlag = false;
            return;
          } else {
            this.curSource.caption = this.curSource.caption.replace(/^../, languageSelect === 0 ? 'cn' : 'en');
            this.curSource.seekTime = this.avPlayer.currentTime;
            await this.avPlayer.reset();
            this.initAVPlayer(this.avPlayer, this.curSource, this.surfaceID)
            this.langFlag = true;
          }
        }
      } catch (err) {
        Logger.error(TAG,
          `languageChange failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }
}