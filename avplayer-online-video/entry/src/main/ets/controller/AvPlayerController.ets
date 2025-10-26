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
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { VideoData } from '../model/VideoData';
import { AVPlayerState, CommonConstants, VideoDataType } from '../common/constants/CommonConstants';

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

  // [Start online_url_2]
  // [Start online_url_1]
  // [Start cache_bar_1]
  // [Start set_source_1]
  // [Start set_source_2]
  // [Start set_strategy_1]
  // Create an AVPlayer instance
  public async initAVPlayer(source: VideoData, surfaceId: string) {
    // [StartExclude online_url_2]
    // [StartExclude online_url_1]
    // [StartExclude set_strategy_1]
    // [StartExclude cache_bar_1]
    // [StartExclude set_source_1]
    // [StartExclude set_source_2]
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
    hilog.info(CommonConstants.LOG_DOMAIN, TAG, `initPlayer == this.curSource : ${JSON.stringify(this.curSource)}`);
    if (!this.curSource) {
      return;
    }
    hilog.info(CommonConstants.LOG_DOMAIN, TAG, `initPlayer == initCamera surfaceId == ${surfaceId}`);
    this.surfaceID = surfaceId;
    hilog.info(CommonConstants.LOG_DOMAIN, TAG, `initPlayer == this.surfaceID surfaceId == ${this.surfaceID}`);

    // [EndExclude set_source_2]
    // [EndExclude set_source_1]
    // [EndExclude cache_bar_1]
    // [EndExclude online_url_1]
    // [EndExclude set_strategy_1]
    // [EndExclude online_url_2]
    try {
      // [StartExclude set_source_2]
      hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'initPlayer videoPlay avPlayerDemo');
      // Creates the avPlayer instance object.
      this.avPlayer = await media.createAVPlayer();
      // [StartExclude online_url_1]
      // Creates a callback function for state machine changes.
      this.setAVPlayerCallback();
      hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'initPlayer videoPlay setAVPlayerCallback');

      if (!this.context) {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG, `initPlayer failed context not set`);
        return
      }
      // [EndExclude set_source_2]
      switch (this.curSource.type) {
        // [StartExclude online_url_2]
        // [StartExclude set_strategy_1]
        // [StartExclude cache_bar_1]
        // [StartExclude set_source_1]
        // [StartExclude set_source_2]
        case VideoDataType.RAW_FILE:
          let fileDescriptor = await this.context.resourceManager.getRawFd(this.curSource.videoSrc);
          this.avPlayer.fdSrc = fileDescriptor;
          hilog.info(CommonConstants.LOG_DOMAIN, TAG,
            `initPlayer videoPlay src = ${JSON.stringify(this.avPlayer.fdSrc)}`);
          break;
        // [EndExclude online_url_2]
        // [EndExclude set_strategy_1]
        // [EndExclude cache_bar_1]
        // Set online video source by url
        case VideoDataType.URL:
          this.avPlayer.url = this.curSource.videoSrc;
          hilog.info(CommonConstants.LOG_DOMAIN, TAG,
            `initPlayer videoPlay url = ${JSON.stringify(this.avPlayer.url)}`);
          break;
        // [StartExclude set_strategy_1]
        // [StartExclude cache_bar_1]
        // [EndExclude set_source_1]
        // [EndExclude set_source_2]
        // Set the mediaSource by url with playbackStrategy
        case VideoDataType.RAW_M3U8_FILE:
          let m3u8Fd = await this.context.resourceManager.getRawFd(this.curSource.videoSrc);
          let fdUrl = 'fd://' + m3u8Fd.fd + '?offset=' + m3u8Fd.offset + '&size=' + m3u8Fd.length;
          // create mediaSource by the URL instead of an assigned URL
          let mediaSource = media.createMediaSourceWithUrl(fdUrl);
          mediaSource.setMimeType(media.AVMimeTypes.APPLICATION_M3U8);
          // [StartExclude set_source_1]
          // create PlaybackStrategy
          let playbackStrategy: media.PlaybackStrategy = { preferredBufferDuration: 20, showFirstFrameOnPrepare: true };
          await this.avPlayer.setMediaSource(mediaSource, playbackStrategy);
          hilog.info(CommonConstants.LOG_DOMAIN, TAG, `initPlayer videoPlay fdUrl = ${JSON.stringify(fdUrl)}`);
          break;
        // [StartExclude set_source_2]
        // Set local video source by url
        case VideoDataType.RAW_MP4_FILE:
          let mp4Fd = await this.context.resourceManager.getRawFd(this.curSource.videoSrc);
          let mp4FdUrl = 'fd://' + mp4Fd.fd;
          this.avPlayer.url = mp4FdUrl;
          hilog.info(CommonConstants.LOG_DOMAIN, TAG, `initPlayer videoPlay fdUrl = ${JSON.stringify(mp4FdUrl)}`);
          break;

        default:
          hilog.error(CommonConstants.LOG_DOMAIN, TAG, `initPlayer failed VideoDataType is invalid`);
          break;
        // [EndExclude set_strategy_1]
        // [EndExclude cache_bar_1]
        // [EndExclude set_source_1]
        // [EndExclude set_source_2]
      }
      await this.setCaption();
      // [EndExclude online_url_1]
    } catch (err) {
      hilog.error(CommonConstants.LOG_DOMAIN, TAG,
        `initPlayer initPlayer, code is ${err.code}, message is ${err.message}`);
    }

  }
  // [End online_url_1]
  // [End online_url_2]
  // [End set_strategy_1]
  // [End cache_bar_1]
  // [End set_source_1]
  // [End set_source_2]

  private async setCaption(){
    // [Start AddCaption]
    if (this.curSource?.caption && this.context?.resourceManager && this.avPlayer) {
      let fileDescriptorSub = await this.context.resourceManager.getRawFd(this.curSource.caption);
      this.avPlayer.addSubtitleFromFd(fileDescriptorSub.fd, fileDescriptorSub.offset, fileDescriptorSub.length);
      hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'initPlayer videoPlay addSubtitleFromFd');
    }
    // [Start AddCaption]
  }
  // [Start cache_bar_2]
  // [Start cache_bar_3]
  private setAVPlayerCallback() {
    // [StartExclude cache_bar_2]
    // [StartExclude cache_bar_3]
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer!.on('error', (err: BusinessError) => {
      hilog.error(CommonConstants.LOG_DOMAIN, TAG, `AVPlayer error, code is ${err.code}, message is ${err.message}`);
      this.avPlayer!.reset();
    });
    // Listening function for reporting time
    this.avPlayer!.on('startRenderFrame', () => {
      hilog.info(CommonConstants.LOG_DOMAIN, TAG, `AVPlayer start render frame`);
      AppStorage.setOrCreate('StartRender', true);
    });
    this.avPlayer!.on('durationUpdate', (time: number) => {
      this.duration = time;
      hilog.info(CommonConstants.LOG_DOMAIN, TAG, `AVPlayer duration update: ${time}`);
      AppStorage.setOrCreate('DurationTime', time);
    });
    // [EndExclude cache_bar_2]
    this.avPlayer.on('timeUpdate', (time: number) => {
      this.currentTime = time;
      AppStorage.setOrCreate('CurrentTime', time);
      hilog.info(CommonConstants.LOG_DOMAIN, TAG,
        `setAVPlayerCallback timeUpdate success,and new time is = ${this.currentTime}`);
    });
    // [StartExclude cache_bar_2]

    // The error callback function is triggered when an error occurs during avPlayer operations,
    // at which point the reset interface is called to initiate the reset process
    this.avPlayer.on('error', (err: BusinessError) => {
      if (!this.avPlayer) {
        return;
      }
      hilog.error(CommonConstants.LOG_DOMAIN, TAG,
        `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      this.avPlayer.reset(); // resets the resources and triggers the idle state
    })

    // Subtitles mount callback functions
    this.avPlayer.on('subtitleUpdate', (info: media.SubtitleInfo) => {
      if (!!info) {
        let text = (!info.text) ? '' : info.text;
        let startTime = (!info.startTime) ? 0 : info.startTime;
        let duration = (!info.duration) ? 0 : info.duration;
        this.currentCaption = text;
        hilog.info(CommonConstants.LOG_DOMAIN, TAG,
          'subtitleUpdate info:' + ` text:${text},startTime:${startTime},duration:${duration}`);
      } else {
        this.currentCaption = '';
        hilog.error(CommonConstants.LOG_DOMAIN, TAG, 'subtitleUpdate info is null');
      }
    });
    // [EndExclude cache_bar_3]
    // Listen to the streaming media buffer status and the estimated playback duration of the buffered data
    this.avPlayer.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
      hilog.info(CommonConstants.LOG_DOMAIN, TAG,
        `BufferedProgressBar bufferingUpdate, infoType is ${infoType}, value is ${value}.`);
      // [StartExclude cache_bar_3]
      if (infoType === media.BufferingInfoType.BUFFERING_START) {
        this.isLoading = true;
      } else if (infoType === media.BufferingInfoType.BUFFERING_END) {
        this.isLoading = false;
      }

      if (this.durationTime === 0) {
        return;
      }
      // [EndExclude cache_bar_3]
      if (infoType === media.BufferingInfoType.CACHED_DURATION && this.avPlayer) {
        this.currentBufferTime = Math.max(this.currentBufferTime, this.currentTime + value);
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, `currentBufferTime: ${this.currentBufferTime}`)
      }
    });

    // [StartExclude cache_bar_3]
    // [Start RegisterCaptionCallBack]
    this.avPlayer.on('subtitleUpdate', (info: media.SubtitleInfo) => {
      if (!!info) {
        let text = (!info.text) ? '' : info.text;
        let startTime = (!info.startTime) ? 0 : info.startTime;
        let duration = (!info.duration) ? 0 : info.duration;
        this.currentCaption = text; //update current caption content
        hilog.info(CommonConstants.LOG_DOMAIN, TAG,
          `subtitleUpdate info: text:${text},startTime:${startTime},duration:${duration}`);
      } else {
        this.currentCaption = '';
        hilog.error(CommonConstants.LOG_DOMAIN, TAG, 'subtitleUpdate info is null');
      }
    });
    // [End RegisterCaptionCallBack]

    this.setInterruptCallback()
    this.setStateChangeCallback();
    this.setOutputDeviceChangeCallback();
    // [EndExclude cache_bar_2]
    // [EndExclude cache_bar_3]
  }
  // [End cache_bar_2]
  // [End cache_bar_3]

  private setInterruptCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.on('audioInterrupt', async (interruptEvent: audio.InterruptEvent) => {
      // When an audio interruption event occurs, the `audioRenderer` receives the `interruptEvent` callback. Here,
      // handle it based on its content:
      // 1. Optional: Read the type of `interruptEvent.forceType` to determine if the system has already enforced
      // the corresponding action.
      //    Note: Under the default focus strategy, `INTERRUPT_HINT_RESUME` is of type `INTERRUPT_SHARE`, while all
      //    other hint types are of `INTERRUPT_FORCE`.Therefore, checking `forceType` may not be necessary.
      // 2. Required: Read the type of `interruptEvent.hintType` and perform the corresponding handling.
      if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
        // For the INTERRUPT_FORCE type: Audio-related processing has been performed by the system, and the
        // application needs to update its own state and make the corresponding adjustments.
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
            // This branch indicates that the system has paused the audio stream (temporarily lost focus).
            // To maintain consistency in state, the application should switch to the audio paused state.
            // Temporarily lost focus: After other audio streams release the audio focus, this audio stream
            // will receive a corresponding resume audio interruption event, at which point it can resume
            // playback on its own.
            this.updateIsPlay(false);
            break;
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            // This branch indicates that the system has stopped the audio stream (permanently lost focus).
            // To maintain consistency in state, the application should switch to the audio paused state.
            // Permanently lost focus: No further audio interruption events will be received. To resume
            // playback, user intervention is required.
            this.updateIsPlay(false);
            break;
          case audio.InterruptHint.INTERRUPT_HINT_DUCK:
            // This branch indicates that the system has reduced the audio volume (default to 20% of the normal volume).
            // To maintain consistency in state, the application should switch to the reduced volume playback state.
            // If the application does not accept reduced volume playback, it can choose an alternative handling method
            // here, such as pausing playback.
            break;
          case audio.InterruptHint.INTERRUPT_HINT_UNDUCK:
            // This branch indicates that the system has restored the audio volume to normal. To maintain
            // consistency in state, the application should switch to the normal volume playback state.
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
            // can now resume playing. It is recommended that the application resumes playback and switches
            // to the audio playback state.
            // If the application does not want to resume playback at this point, it can ignore this audio
            // interruption event and take no action.
            // Resume playback by explicitly calling `start()` here, and record the result of the `start()`
            // call in a flag variable `started`.
            this.videoPlay();
            break;
          default:
            break;
        }
      }
    })
  }

  private setStateChangeCallback() {
    if (!this.avPlayer) {
      return;
    }
    // [Start set_strategy_2]
    // Callback function for state machine changes
    this.avPlayer.on('stateChange', async (state) => {
      if (!this.avPlayer) {
        return;
      }
      switch (state) {
        // [StartExclude set_strategy_2]
        case 'idle': // This state machine is triggered after the reset interface is successfully invoked.
          this.avPlayer.release();
          hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'setAVPlayerCallback AVPlayer state idle called.');
          break;
        // [EndExclude set_strategy_2]
        case 'initialized': // This status is reported after the playback source is set on the AVPlayer.
          hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'setAVPlayerCallback AVPlayerState initialized called.');
          // Set the display screen. This parameter is not required when the resource to be played is audio-only.
          this.avPlayer.surfaceId = this.surfaceID;
          hilog.info(CommonConstants.LOG_DOMAIN, TAG,
            `setAVPlayerCallback this.avPlayer.surfaceId = ${this.avPlayer.surfaceId}`);
          await this.avPlayer.setPlaybackStrategy({
            preferredBufferDurationForPlaying: 0.3,
            preferredBufferDuration: 20,
            showFirstFrameOnPrepare: true
          });
          this.avPlayer.prepare();
          break;
        // [StartExclude set_strategy_2]
        case 'prepared': // This state machine is reported after the prepare interface is successfully invoked.
          hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'setAVPlayerCallback AVPlayer state prepared called.');
          this.isReady = true;
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
            await this.avPlayer!.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, this.isMuted!)
          }

          this.setWindowScale();

          if (this.index === 0) {
            this.avPlayer.play(); // Invoke the playback interface to start playback.
          }

          this.setVideoSpeed();

          break;
        case 'playing': // After the play interface is successfully invoked, the state machine is reported.
          hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'setAVPlayerCallback AVPlayer state playing called.');
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
          hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'setAVPlayerCallback AVPlayer state completed called.');
          this.currentTime = 0;
          this.avPlayer.seek(0)
          await this.avPlayer.play()
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
        // [EndExclude set_strategy_2]
      }
    });
    // [End set_strategy_2]
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
        this.videoSpeedOne();
        break;
      case CASE_ONE:
        this.videoSpeedOnePointTwentyFive();
        break;
      case CASE_TWO:
        this.videoSpeedOnePointSeventyFive();
        break;
      case CASE_THREE:
        this.videoSpeedTwo();
        break;
      default:
        break;
    }
  }

  // [End mode_volume]

  private setOutputDeviceChangeCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.on('audioOutputDeviceChangeWithInfo', (data: audio.AudioStreamDeviceChangeInfo) => {
      if (data.changeReason === audio.AudioStreamDeviceChangeReason.REASON_OLD_DEVICE_UNAVAILABLE) {
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, `Device break: ${data.changeReason}`);
        this.videoPause();
      } else if (data.changeReason === audio.AudioStreamDeviceChangeReason.REASON_NEW_DEVICE_AVAILABLE) {
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, `Device connect: ${data.changeReason}`);
      }
    });
  }

  private updateIsPlay(isPlay: boolean) {
    this.isPlaying = isPlay;
  }

  videoPlay(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.play();
        this.isPlaying = true;
      } catch (err) {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `videoPlay failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  videoPause(): void {
    if (this.avPlayer) {
      try {
        this.updateIsPlay(false);
        this.avPlayer.pause();
        this.isPlaying = false;
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'videoPause');
      } catch (err) {
        hilog.info(CommonConstants.LOG_DOMAIN, TAG,
          `videoPause failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // Toggle play/pause state
  videoStop(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.stop();
        this.isPlaying = false;
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'videoPause');
      } catch (err) {
        hilog.info(CommonConstants.LOG_DOMAIN, TAG,
          `videoPause failed, code is ${err.code}, message is ${err.message}`);
      }
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
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'videoMuted');
      } catch (err) {
        hilog.info(CommonConstants.LOG_DOMAIN, TAG,
          `videoMuted failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // [End video_muted_fun]

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

  // [Start video_speed_fun]

  // [Start video_speed_1.0X_fun]
  videoSpeedOne(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_00_X);
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'videoSpeed_1_00');
      } catch (err) {
        hilog.info(CommonConstants.LOG_DOMAIN, TAG,
          `videoSpeed_1_00 failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // [End video_speed_1.0X_fun]

  videoSpeedOnePointTwentyFive(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_25_X);
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'videoSpeed_1_25');
      } catch (err) {
        hilog.info(CommonConstants.LOG_DOMAIN, TAG,
          `videoSpeed_1_25 failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  videoSpeedOnePointSeventyFive(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_75_X);
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'videoSpeed_1_75');
      } catch (err) {
        hilog.info(CommonConstants.LOG_DOMAIN, TAG,
          `videoSpeed_1_75 failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // [Start video_speed_2.0X_fun]
  videoSpeedTwo(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_2_00_X);
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, `videoSpeed_2_0`);
      } catch (err) {
        hilog.info(CommonConstants.LOG_DOMAIN, TAG,
          `videoSpeed_2_0 failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // [End video_speed_2.0X_fun]

  // [End video_speed_fun]

  videoSeek(seekTime: number): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.seek(seekTime, media.SeekMode.SEEK_CLOSEST);
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, `videoSeek== ${seekTime}`);
      } catch (err) {
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, `videoSeek failed, code is ${err.code}, message is ${err.message}`);
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
      hilog.info(CommonConstants.LOG_DOMAIN, TAG,
        `avPlayer.reset failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  async videoRelease(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.release((err) => {
      if (err) {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG, `videoRelease release filed,error message is = ${err.message}`);
      } else {
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'videoRelease release success');
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
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, `videoScaleType_0`);
      } catch (err) {
        hilog.info(CommonConstants.LOG_DOMAIN, TAG,
          `videoScaleType_0 failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  videoScaleFitCrop(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT_CROP
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, `videoScaleType_1`);
      } catch (err) {
        hilog.info(CommonConstants.LOG_DOMAIN, TAG,
          `videoScaleType_1 failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // [End window_scale_fun]

  public setIsPlaying(isPlayer: boolean) {
    this.isPlaying = isPlayer;
  }

  async languageChange(languageSelect: number = 0): Promise<void> {
    if (this.avPlayer) {
      try {
        if (this.curSource && this.curSource.caption) {
          if (!this.context) {
            hilog.info(CommonConstants.LOG_DOMAIN, TAG, `initPlayer failed context not set`);
            return
          }
          this.curSource.caption = languageSelect === 0 ? 'captions.srt' : 'en_captions.srt'

          if (languageSelect === 0) {
            this.curSource.caption = 'captions.srt';
          } else if (languageSelect === 1) {
            this.curSource.caption = 'en_captions.srt';
          }
          this.curSource.seekTime = this.avPlayer.currentTime;
          await this.avPlayer.reset();
          this.initAVPlayer(this.curSource, this.surfaceID);
          hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'language change');
        }
      } catch (err) {
        hilog.error(CommonConstants.LOG_DOMAIN, TAG,
          `languageChange failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }
}