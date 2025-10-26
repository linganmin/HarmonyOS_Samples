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
import { AVPlayerState, CommonConstants, Constants, VideoDataType } from '../common/constants/Constants';

const TAG = 'AvPlayerController';
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

  // [Start create_instance]
  // Create an AVPlayer instance
  public async initAVPlayer(source: VideoData, surfaceId: string) {
    // [StartExclude create_instance]
    if (!this.context) {
      hilog.info(Constants.DOMAIN, TAG, `initPlayer failed context not set`);
      return;
    }
    this.curSource = source;
    if (source.seekTime !== null) {
      this.seekTime = source.seekTime;
    }
    if (source.isMuted) {
      this.isMuted = source.isMuted;
    }
    hilog.info(Constants.DOMAIN, TAG, `initPlayer : ${this.curSource}`);
    if (!this.curSource) {
      return;
    }
    hilog.info(Constants.DOMAIN, TAG, `initPlayer surfaceId : ${surfaceId}`);
    this.surfaceID = surfaceId;
    hilog.info(Constants.DOMAIN, TAG, `initPlayer surfaceId : ${this.surfaceID}`);

    try {
      hilog.info(Constants.DOMAIN, TAG, 'initPlayer videoPlay avPlayerDemo');
      // [EndExclude create_instance]
      // Creates the avPlayer instance object.
      this.avPlayer = await media.createAVPlayer();
      // Creates a callback function for state machine changes.
      this.setAVPlayerCallback();
      // [StartExclude create_instance]
      hilog.info(Constants.DOMAIN, TAG, 'initPlayer videoPlay setAVPlayerCallback');
      if (!this.context) {
        hilog.info(Constants.DOMAIN, TAG, `initPlayer failed context not set`);
        return;
      }
      switch (this.curSource.type) {
        case VideoDataType.RAW_FILE:
          let fileDescriptor = await this.context.resourceManager.getRawFd(this.curSource.videoSrc);
          this.avPlayer.fdSrc = fileDescriptor;
          hilog.info(Constants.DOMAIN, TAG, `initPlayer videoPlay src : ${this.avPlayer.fdSrc}`);
          break;
        case VideoDataType.URL:
          this.avPlayer.url = this.curSource.videoSrc;
          hilog.info(Constants.DOMAIN, TAG, `initPlayer videoPlay url : ${this.avPlayer.url}`);
          break;
        case VideoDataType.RAW_M3U8_FILE:
          let m3u8Fd = await this.context.resourceManager.getRawFd(this.curSource.videoSrc);
          let fdUrl = 'fd://' + m3u8Fd.fd + '?offset=' + m3u8Fd.offset + '&size=' + m3u8Fd.length;
          let mediaSource = media.createMediaSourceWithUrl(fdUrl);
          mediaSource.setMimeType(media.AVMimeTypes.APPLICATION_M3U8);
          let playbackStrategy: media.PlaybackStrategy = { preferredBufferDuration: 20, showFirstFrameOnPrepare: true };
          await this.avPlayer.setMediaSource(mediaSource, playbackStrategy);
          hilog.info(Constants.DOMAIN, TAG, `initPlayer videoPlay fdUrl : ${fdUrl}`);
          break;
        default:
          break;
      }

      if (this.curSource.caption) {
        let fileDescriptorSub = await this.context.resourceManager.getRawFd(this.curSource.caption);
        this.avPlayer.addSubtitleFromFd(fileDescriptorSub.fd, fileDescriptorSub.offset, fileDescriptorSub.length);
        hilog.info(Constants.DOMAIN, TAG, 'initPlayer videoPlay addSubtitleFromFd');
      }
    } catch (error) {
      if (error.code !== null && error.message !== null) {
        hilog.error(Constants.DOMAIN, TAG, `initPlayer: Failed. code: ${error.code} ;message: ${error.message}`);
      }
    }
    // [EndExclude create_instance]
  }

  // [End create_instance]
  private setAVPlayerCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer!.on('error', (error: BusinessError) => {
      hilog.error(Constants.DOMAIN, TAG, `AVPlayer: Failed. code: ${error.code} ;message: ${error.message}`);
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
    this.avPlayer.on('error', (error: BusinessError) => {
      if (!this.avPlayer) {
        return;
      }
      hilog.error(Constants.DOMAIN, TAG, `Invoke avPlayer failed, code is ${error.code}, message is ${error.message}`);
      this.avPlayer.reset(); // resets the resources and triggers the idle state
    })

    // Subtitle mounting callback function
    this.avPlayer.on('subtitleUpdate', (info: media.SubtitleInfo) => {
      if (!!info) {
        let text = (!info.text) ? '' : info.text;
        let startTime = (!info.startTime) ? 0 : info.startTime;
        let duration = (!info.duration) ? 0 : info.duration;
        this.currentCaption = text;
        let eventData: emitter.EventData = {
          data: {
            'currentCaption': text
          }
        };
        emitter.emit(CommonConstants.SUBTITLE_UPDATE, eventData);
        hilog.info(Constants.DOMAIN, TAG, `subtitleUpdate text:${text},startTime:${startTime},duration:${duration}`);
      } else {
        this.currentCaption = '';
        hilog.info(Constants.DOMAIN, TAG, 'subtitleUpdate info is null');
      }
    });

    // Monitor the buffering status, buffering percentage, and estimated playable time of buffered data for streaming media
    this.avPlayer.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
      hilog.info(Constants.DOMAIN, TAG, ` bufferingUpdate, infoType is ${infoType}, value is ${value}.`);
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
        hilog.info(Constants.DOMAIN, TAG, `currentBufferTime: ${this.currentBufferTime}`);
      }
    });
    this.setInterruptCallback()
    this.setStateChangeCallback();
    this.setOutputDeviceChangeCallback();
  }

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
            break;
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            // This branch indicates that the system has stopped the audio stream (permanently lost focus).
            // To maintain consistency in state, the application should switch to the audio paused state.
            // Permanently lost focus: No further audio interruption events will be received. To resume
            // playback, user intervention is required.
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

  // [Start mode_volume]
  private setStateChangeCallback() {
    // [StartExclude mode_volume]
    if (!this.avPlayer) {
      return;
    }
    // [EndExclude mode_volume]
    // Callback function for state machine changes
    this.avPlayer.on('stateChange', async (state) => {
      // [StartExclude mode_volume]
      if (!this.avPlayer) {
        return;
      }
      // [EndExclude mode_volume]
      switch (state) {
        // [StartExclude mode_volume]
        case 'idle': // This state machine is triggered after the reset interface is successfully invoked.
          this.avPlayer.release();
          break;
        case 'initialized': // This status is reported after the playback source is set on the AVPlayer.
          // Set the display screen. This parameter is not required when the resource to be played is audio-only.
          this.avPlayer.surfaceId = this.surfaceID;
          hilog.info(Constants.DOMAIN, TAG, `setAVPlayerCallback surfaceId : ${this.avPlayer.surfaceId}`);
          await this.avPlayer.setPlaybackStrategy({
            preferredBufferDuration: 20,
            showFirstFrameOnPrepare: true
          });
          this.avPlayer.prepare();
          break;
        // [EndExclude mode_volume]
        case 'prepared': // This state machine is reported after the prepare interface is successfully invoked.
          // [StartExclude mode_volume]
          hilog.info(Constants.DOMAIN, TAG, 'setAVPlayerCallback AVPlayer state prepared called.');
          this.durationTime = this.avPlayer.duration;
          this.currentTime = this.avPlayer.currentTime;
          if (this.seekTime) {
            this.avPlayer!.seek(this.seekTime!, media.SeekMode.SEEK_CLOSEST);
          }
          // [EndExclude mode_volume]
          let eventData: emitter.EventData = {
            data: {
              'percent': this.avPlayer.width / this.avPlayer.height
            }
          };
          emitter.emit(CommonConstants.AVPLAYER_PREPARED, eventData);
          // [StartExclude mode_volume]
          if (this.isMuted) {
            await this.avPlayer!.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, this.isMuted!);
          }
          this.setWindowScaleSelect();
          // Invoke the playback interface to start playback.
          this.avPlayer.play();
          this.setSpeedSelect();
          // [EndExclude mode_volume]
          break;
        // [StartExclude mode_volume]
        case 'playing': // After the play interface is successfully invoked, the state machine is reported.
          hilog.info(Constants.DOMAIN, TAG, 'setAVPlayerCallback AVPlayer state playing called.');
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
          hilog.info(Constants.DOMAIN, TAG, 'setAVPlayerCallback AVPlayer state completed called.');
          this.currentTime = 0;
          this.avPlayer.seek(0);
          await this.avPlayer.play();
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
          hilog.info(Constants.DOMAIN, TAG, 'setAVPlayerCallback AVPlayer state unknown called.');
          break;
        // [EndExclude mode_volume]
      }
    });
  }

  // [End mode_volume]

  private setOutputDeviceChangeCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.on('audioOutputDeviceChangeWithInfo', (data: audio.AudioStreamDeviceChangeInfo) => {
      if (data.changeReason === audio.AudioStreamDeviceChangeReason.REASON_OLD_DEVICE_UNAVAILABLE) {
        hilog.info(Constants.DOMAIN, TAG, `Device break: ${data.changeReason}`);
        this.videoPause();
      } else if (data.changeReason === audio.AudioStreamDeviceChangeReason.REASON_NEW_DEVICE_AVAILABLE) {
        hilog.info(Constants.DOMAIN, TAG, `Device connect: ${data.changeReason}`);
      }
    });
  }

  private updateIsPlay(isPlay: boolean) {
    this.isPlaying = isPlay;
  }

  videoPlay(): void {
    if (this.avPlayer && this.avPlayer.state !== 'playing') {
      try {
        this.avPlayer.play();
        this.isPlaying = true;
      } catch (error) {
        if (error.code !== null && error.message !== null) {
          hilog.error(Constants.DOMAIN, TAG, `videoPlay failed, code is ${error.code}, message is ${error.message}`);
        }
      }
    }
  }

  videoPause(): void {
    if (this.avPlayer && this.avPlayer.state !== 'paused') {
      try {
        this.avPlayer.pause();
        this.isPlaying = false;
        hilog.info(Constants.DOMAIN, TAG, 'videoPause');
      } catch (error) {
        if (error.code !== null && error.message !== null) {
          hilog.error(Constants.DOMAIN, TAG, `videoPause failed, code is ${error.code}, message is ${error.message}`);
        }
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
        if (error.code !== null && error.message !== null) {
          hilog.error(Constants.DOMAIN, TAG, `videoStop failed, code is ${error.code}, message is ${error.message}`);
        }
      }
    }
  }

  async videoMuted(isMuted: boolean): Promise<void> {
    if (this.avPlayer) {
      try {
        this.isMuted = isMuted;
        await this.avPlayer!.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, isMuted);
      } catch (error) {
        if (error.code !== null && error.message !== null) {
          hilog.error(Constants.DOMAIN, TAG, `videoMuted failed, code is ${error.code}, message is ${error.message}`);
        }
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

  videoSpeedOne(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_00_X);
      } catch (error) {
        if (error.code !== null && error.message !== null) {
          hilog.error(Constants.DOMAIN, TAG,
            `videoSpeedOne failed, code is ${error.code}, message is ${error.message}`);
        }
      }
    }
  }

  videoSpeedOnePointTwentyFive(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_25_X);
      } catch (error) {
        if (error.code !== null && error.message !== null) {
          hilog.error(Constants.DOMAIN, TAG,
            `videoSpeedOnePointTwentyFive failed, code is ${error.code}, message is ${error.message}`);
        }
      }
    }
  }

  videoSpeedOnePointSeventyFive(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_75_X);
      } catch (error) {
        if (error.code !== null && error.message !== null) {
          hilog.error(Constants.DOMAIN, TAG,
            `videoSpeedOnePointSeventyFive failed, code is ${error.code}, message is ${error.message}`);
        }
      }
    }
  }

  videoSpeedTwo(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_2_00_X);
      } catch (error) {
        if (error.code !== null && error.message !== null) {
          hilog.error(Constants.DOMAIN, TAG,
            `videoSpeedTwo failed, code is ${error.code}, message is ${error.message}`);
        }
      }
    }
  }

  videoSeek(seekTime: number): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.seek(seekTime, media.SeekMode.SEEK_CLOSEST);
      } catch (error) {
        if (error.code !== null && error.message !== null) {
          hilog.error(Constants.DOMAIN, TAG, `videoSeek failed, code is ${error.code}, message is ${error.message}`);
        }
      }
    }
  }

  async videoReset(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    try {
      await this.avPlayer.reset();
    } catch (error) {
      if (error.code !== null && error.message !== null) {
        hilog.error(Constants.DOMAIN, TAG, `videoReset failed, code is ${error.code}, message is ${error.message}`);
      }
    }
  }

  async videoRelease(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.release((error) => {
      if (error.code !== null && error.message !== null) {
        hilog.error(Constants.DOMAIN, TAG, `videoScaleFit failed, code is ${error.code}, message is ${error.message}`);
      }
    });
  }

  getDurationTime(): number {
    return this.durationTime;
  }

  getCurrentTime(): number {
    return this.currentTime;
  }

  videoScaleFit(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT;
      } catch (error) {
        if (error.code !== null && error.message !== null) {
          hilog.error(Constants.DOMAIN, TAG,
            `videoScaleFit failed, code is ${error.code}, message is ${error.message}`);
        }
      }
    }
  }

  videoScaleFitCrop(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT_CROP;
      } catch (error) {
        if (error.code !== null && error.message !== null) {
          hilog.error(Constants.DOMAIN, TAG,
            `videoScaleFitCrop failed, code is ${error.code}, message is ${error.message}`);
        }
      }
    }
  }

  setWindowScaleSelect(): void {
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

  setSpeedSelect(): void {
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
}