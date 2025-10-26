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
import { audio } from '@kit.AudioKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { CommonConstants, VideoDataType } from '../common/constants/CommonConstants';
import { VideoData } from '../model/VideoData';

const TAG = '[AvPlayerController]';
const CASE_ZERO = 0;
const CASE_ONE = 1;
const CASE_TWO = 2;
const CASE_THREE = 3;

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
  private seekTime?: number;
  private isMuted: boolean | undefined = undefined;
  private speedSelect: number = 0;
  private windowScaleSelect: number = 0;
  private index: number = 0;

  // [Start create_instance]
  // Create an AVPlayer instance
  public async initAVPlayer(source: VideoData, surfaceId: string, avPlayer?: media.AVPlayer) {
    if (!this.context) {
      hilog.info(CommonConstants.LOG_DOMAIN, TAG, `initPlayer failed context not set`);
      return
    }
    this.curSource = source;
    if (source.seekTime) {
      this.seekTime = source.seekTime;
    }
    if (source.isMuted) {
      this.isMuted = source.isMuted;
    }
    if (source.index) {
      this.index = source.index;
    }
    if (!this.curSource) {
      return;
    }
    this.surfaceID = surfaceId;

    try {
      // Creates the avPlayer instance object.
      this.avPlayer = avPlayer ? avPlayer : await media.createAVPlayer()
      // Creates a callback function for state machine changes.
      this.setAVPlayerCallback();

      if (!this.context) {
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, `initPlayer failed context not set`);
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
      // [Start AddCaption]
      if (this.curSource.caption) {
        let fileDescriptorSub = await this.context.resourceManager.getRawFd(this.curSource.caption);
        this.avPlayer.addSubtitleFromFd(fileDescriptorSub.fd, fileDescriptorSub.offset, fileDescriptorSub.length)
          .catch((err: BusinessError) => {
            hilog.error(CommonConstants.LOG_DOMAIN, TAG,
              `addSubtitleFromFd failed, code is ${err.code}, message is ${err.message}`);
          });
      }
      // [End AddCaption]
    } catch (err) {
      hilog.error(CommonConstants.LOG_DOMAIN, TAG,
        `initPlayer failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  // [End create_instance]

  private setAVPlayerCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer!.on('error', (err: BusinessError) => {
      hilog.error(CommonConstants.LOG_DOMAIN, TAG, `AVPlayer error, code is ${err.code}, message is ${err.message}`);
      this.avPlayer!.reset().catch((err: BusinessError) => {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `reset failed, code is ${err.code}, message is ${err.message}`);
      });
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
      hilog.error(CommonConstants.LOG_DOMAIN, TAG,
        `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      this.avPlayer.reset().catch((err: BusinessError) => {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `reset failed, code is ${err.code}, message is ${err.message}`);
      });
    })
    this.subtitleUpdateFunction();
    this.setStateChangeCallback();
  }

  private setStateChangeCallback() {
    if (!this.avPlayer) {
      return;
    }
    // [Start loop_playback]
    // Callback function for state machine changes
    this.avPlayer.on('stateChange', async (state) => {
      if (!this.avPlayer) {
        return;
      }
      switch (state) {
        // [StartExclude loop_playback]
        case 'idle': // This state machine is triggered after the reset interface is successfully invoked.
          hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'setAVPlayerCallback AVPlayer state idle called.');
          break;
        case 'initialized': // This status is reported after the playback source is set on the AVPlayer.
          // Set the display screen. This parameter is not required when the resource to be played is audio-only.
          this.avPlayer.surfaceId = this.surfaceID;
          this.avPlayer.prepare().catch((err: BusinessError) => {
            hilog.error(CommonConstants.LOG_DOMAIN, TAG,
              `prepare failed, code is ${err.code}, message is ${err.message}`);
          });
          break;
        // [EndExclude loop_playback]
        case 'prepared': // This state machine is reported after the prepare interface is successfully invoked.
          this.isReady = true;
          this.avPlayer.loop = true
          // [StartExclude loop_playback]
          this.durationTime = this.avPlayer.duration;
          this.currentTime = this.avPlayer.currentTime;
          this.avPlayer.audioInterruptMode = audio.InterruptMode.SHARE_MODE;
          if (this.seekTime) {
            this.avPlayer!.seek(this.seekTime!, media.SeekMode.SEEK_CLOSEST);
          }
          let eventData: emitter.EventData = {
            data: {
              'percent': this.avPlayer.width / this.avPlayer.height
            }
          };
          emitter.emit(CommonConstants.AVPLAYER_PREPARED, eventData);
          if (this.isMuted) {
            try {
              await this.avPlayer!.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, this.isMuted!)
            } catch (err) {
              hilog.error(CommonConstants.LOG_DOMAIN, TAG,
                `setMediaMuted failed, code is ${err.code}, message is ${err.message}`);
            }
          }
          this.setWindowScale();
          if (this.index === 0) {
            this.avPlayer.play().catch((err: BusinessError) => {
              hilog.error(CommonConstants.LOG_DOMAIN, TAG,
                `play failed, code is ${err.code}, message is ${err.message}`);
            });
          }
          this.setVideoSpeed();
          // [EndExclude loop_playback]
          break;
        // [StartExclude loop_playback]
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
        case 'completed': // This state machine is triggered to report when the playback ends.
          this.currentTime = 0;
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
        default:
          hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'setAVPlayerCallback AVPlayer state unknown called.');
          break;
        // [EndExclude loop_playback]
      }
    });
    // [End loop_playback]
  }

  private setWindowScale() {
    switch (this.windowScaleSelect) {
      case CASE_ZERO:
        this.videoScaleFit();
        break;
      case CASE_ONE:
        this.videoScaleFitCrop();
        break;
      default:
        break;
    }
  }

  private setVideoSpeed() {
    switch (this.speedSelect) {
      case CASE_ZERO:
        this.videoSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_00_X);
        break;
      case CASE_ONE:
        this.videoSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_25_X);
        break;
      case CASE_TWO:
        this.videoSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_75_X);
        break;
      case CASE_THREE:
        this.videoSpeed(media.PlaybackSpeed.SPEED_FORWARD_2_00_X);
        break;
      default:
        break;
    }
  }

  videoPlay(): void {
    if (this.avPlayer) {
      this.avPlayer.play().catch((err: BusinessError) => {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `play failed, code is ${err.code}, message is ${err.message}`);
      });
      this.isPlaying = true;
    }
  }

  videoPause(): void {
    if (this.avPlayer) {
      this.avPlayer.pause().catch((err: BusinessError) => {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `addSubtitleFromFd failed, code is ${err.code}, message is ${err.message}`);
      });
      this.isPlaying = false;
    }
  }

  // Toggle play/pause state
  videoStop(): void {
    if (this.avPlayer) {
      this.avPlayer.stop().catch((err: BusinessError) => {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `videoPause failed, code is ${err.code}, message is ${err.message}`);
      });
      this.isPlaying = false;
    }
  }

  // [Start video_muted_fun]
  /**
   * Video muted
   * @param isMuted
   * @returns
   */
  async videoMuted(isMuted: boolean): Promise<void> {
    if (this.avPlayer) {
      try {
        this.isMuted = isMuted;
        await this.avPlayer!.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, isMuted)
      } catch (err) {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `videoMuted failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // [End video_muted_fun]

  // [Start video_speed_fun]
  videoSpeed(speed: number): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(speed);
      } catch (err) {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `videoSpeed failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // [End video_speed_fun]

  videoSeek(seekTime: number): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.seek(seekTime, media.SeekMode.SEEK_CLOSEST);
      } catch (err) {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `videoSeek failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  async videoReset(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    try {
      await this.avPlayer.reset();
    } catch (err) {
      hilog.error(CommonConstants.LOG_DOMAIN, TAG, `videoReset failed, code is ${err.code}, message is ${err.message}`);
    }

  }

  async videoRelease(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.release((err) => {
      if (err === null) {
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'videoRelease release success');
      } else {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `videoRelease release filed,  code is ${err.code}, message is ${err.message}`);
      }
    });
  }

  getDurationTime(): number {
    return this.durationTime;
  }

  getCurrentTime(): number {
    return this.currentTime;
  }

  // [Start window_scale_fun]
  /**
   * Set window scale mode
   */
  videoScaleFit(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT
      } catch (err) {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `videoScaleType_0 failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  videoScaleFitCrop(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT_CROP
      } catch (err) {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `videoScaleType_1 failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // [End window_scale_fun]
  subtitleUpdateFunction(): void {
    if (this.avPlayer) {
      try {
        // [Start RegisterCaptionCallBack]
        this.avPlayer.on('subtitleUpdate', (info: media.SubtitleInfo) => {
          if (info) {
            let text = (!info.text) ? '' : info.text;
            this.currentCaption = text; //update current caption content
          } else {
            this.currentCaption = '';
            hilog.error(CommonConstants.LOG_DOMAIN, TAG, 'subtitleUpdate info is null');
          }
        });
        // [End RegisterCaptionCallBack]
      } catch (err) {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `subtitleUpdateFunction failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // [Start languageSwitch]
  async languageChange(languageSelect: number = 0): Promise<void> {
    if (this.avPlayer) {
      try {
        if (this.curSource && this.curSource.caption) {
          this.curSource.caption = languageSelect === 0 ? 'captions.srt' : 'en_captions.srt'
          this.curSource.seekTime = this.avPlayer.currentTime;
          await this.avPlayer.reset();
          this.initAVPlayer(this.curSource, this.surfaceID, this.avPlayer);
        }
      } catch (err) {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `languageChange failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // [End languageSwitch]
}