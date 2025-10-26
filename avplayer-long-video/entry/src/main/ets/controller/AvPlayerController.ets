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
import { avSession } from '@kit.AVSessionKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { AVPlayerState, CommonConstants, VideoDataType } from '../common/constants/CommonConstants';
import { VideoData } from '../model/VideoData';
import { AvSessionController } from './AvSessionController';
import Logger from '../common/utils/Logger';

const TAG = '[AvPlayerController]';
const CASE_ZERO = 0;
const CASE_ONE = 1;
const CASE_TWO = 2;
const CASE_THREE = 3;

@Observed
export class AvPlayerController {
  @Track surfaceID: string = '';
  @Track isPlaying: boolean = false; // Whether the video is playing
  @Track isReady: boolean = false;
  @Track currentTime: number = 0;
  @Track currentBufferTime: number = 0;
  @Track isLoading: boolean = false;
  @Track duration: number = 0; // Current play time
  @Track durationTime: number = 0; // Video duration
  @Track currentCaption: string = '';
  private avPlayer?: media.AVPlayer;
  private curSource?: VideoData;
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  private avSessionController: AvSessionController = AvSessionController.getInstance();
  private seekTime?: number; // Video jump play time
  private isMuted: boolean | undefined = undefined;
  private speedSelect: number = 0;
  private isSwitchLanguage: boolean = false;

  // Create an AVPlayer instance
  public async initAVPlayer(avPlayer: media.AVPlayer, source: VideoData, surfaceId: string) {
    if (!this.context) {
      Logger.error(TAG, 'initPlayer failed context not set');
      return
    }
    this.curSource = source;
    if (source.seekTime) {
      this.seekTime = source.seekTime;
    }
    if (source.isMuted) {
      this.isMuted = source.isMuted;
    }
    if (!this.curSource) {
      return;
    }
    this.surfaceID = surfaceId;
    try {
      // Creates the avPlayer instance object.
      this.avPlayer = avPlayer;
      // Creates a callback function for state machine changes.
      this.setAVPlayerCallback();
      // Create avSession callback function
      this.setAvSessionListener();
      if (!this.context) {
        Logger.error(TAG, 'initPlayer failed context not set');
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
        case VideoDataType.RAW_M3U8FILE:
          let m3u8Fd = await this.context.resourceManager.getRawFd(this.curSource.videoSrc);
          let fdUrl = 'fd://' + m3u8Fd.fd + '?offset=' + m3u8Fd.offset + '&size=' + m3u8Fd.length;
          let mediaSource = media.createMediaSourceWithUrl(fdUrl);
          mediaSource.setMimeType(media.AVMimeTypes.APPLICATION_M3U8);
          let playbackStrategy: media.PlaybackStrategy = { preferredBufferDuration: 20, showFirstFrameOnPrepare: true };
          await this.avPlayer.setMediaSource(mediaSource, playbackStrategy);
          break;
        case VideoDataType.RAW_MP4FILE:
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
            Logger.error(TAG, `addSubtitleFromFd failed. Code:${err.code}, message:${err.message}`);
          });
      }
      // [End AddCaption]
    } catch (exception) {
      Logger.error(TAG, `initPlayer initPlayer failed, code is ${exception.code}, message is ${exception.message}`);
    }
  }

  private setAVPlayerCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer!.on('error', (err: BusinessError) => {
      Logger.error(`AVPlayer error, code is ${err.code}, message is ${err.message}`);
      this.avPlayer!.reset().catch((err: BusinessError) => {
        Logger.error(TAG, `reset failed. Code:${err.code}, message:${err.message}`);
      });
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
      // resets the resources and triggers the idle state
      this.avPlayer.reset().catch((err: BusinessError) => {
        Logger.error(TAG, `reset failed. Code:${err.code}, message:${err.message}`);
      });
    })
    this.setInterruptCallback()
    this.setStateChangeCallback();
    this.setOutputDeviceChangeCallback();
    this.subtitleUpdateFunction();
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
          // This branch indicates that the system has paused the audio stream (temporarily lost focus).
          case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
          // This branch indicates that the system has stopped the audio stream (permanently lost focus).
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            this.isPlaying = false;
            this.updateIsPlay();
            break;
          // This branch indicates that the system has reduced the audio volume (default to 20% of the normal volume).
          case audio.InterruptHint.INTERRUPT_HINT_DUCK:
          // This branch indicates that the system has restored the audio volume to normal.
          case audio.InterruptHint.INTERRUPT_HINT_UNDUCK:
            break;
          default:
            break;
        }
      } else if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_SHARE) {
        // For the INTERRUPT_SHARE type: The application can choose to perform related actions or ignore the
        // audio interruption event.
        switch (interruptEvent.hintType) {
          // This branch indicates that the audio stream, which was paused due to temporary loss of focus,
          // can resume playing.
          case audio.InterruptHint.INTERRUPT_HINT_RESUME:
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
    // Callback function for state machine changes
    this.avPlayer.on('stateChange', async (state) => {
      if (!this.avPlayer) {
        return;
      }
      switch (state) {
        case 'idle': // This state machine is triggered after the reset interface is successfully invoked.
          Logger.info(TAG, 'setAVPlayerCallback AVPlayer state idle called.');
          break;
        // [Start SetShowFirstFrameStrategy]
        case 'initialized': // This status is reported after the playback source is set on the AVPlayer.
          Logger.info(TAG, 'setAVPlayerCallback AVPlayerState initialized called.');
          // Set the display screen. This parameter is not required when the resource to be played is audio-only.
          this.avPlayer.surfaceId = this.surfaceID;

          try {
            await this.avPlayer.setPlaybackStrategy({
              preferredBufferDuration: 20,
              showFirstFrameOnPrepare: true
            });
          } catch (exception) {
            Logger.error(TAG,
              `setPlaybackStrategy failed. Cause code: ${exception.code}, message: ${exception.message}`);
          }
          this.avPlayer.prepare().catch((err: BusinessError) => {
            Logger.error(TAG, `prepare failed. Code:${err.code}, message:${err.message}`);
          });
          break;
        // [End SetShowFirstFrameStrategy]
        case 'prepared': // This state machine is reported after the prepare interface is successfully invoked.
          Logger.info(TAG, 'setAVPlayerCallback AVPlayer state prepared called.');
          this.isReady = true;
          this.durationTime = this.avPlayer.duration;
          this.currentTime = this.avPlayer.currentTime;
          this.avPlayer.audioInterruptMode = audio.InterruptMode.SHARE_MODE;
          if (this.seekTime) {
            this.avPlayer!.seek(this.seekTime!, media.SeekMode.SEEK_CLOSEST);
          }
          if (this.isMuted) {
            try {
              await this.avPlayer!.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, this.isMuted!)
            } catch (exception) {
              Logger.error(TAG, `setMediaMuted failed. Cause code: ${exception.code}, message: ${exception.message}`);
            }
          }
          this.setVideoSpeed();
          if (this.isSwitchLanguage) {
            this.videoPlay();
          }
          break;
        case 'playing': // After the play interface is successfully invoked, the state machine is reported.
          Logger.info(TAG, 'setAVPlayerCallback AVPlayer state playing called.');
          this.isPlaying = true;
          this.updateIsPlay();
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
          Logger.info(TAG, 'setAVPlayerCallback AVPlayer state completed called.');
          this.currentTime = 0;
          this.videoPlay();
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
          Logger.info(TAG, 'setAVPlayerCallback AVPlayer state unknown called.');
          break;
      }
    });
  }

  private setOutputDeviceChangeCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.on('audioOutputDeviceChangeWithInfo', (data: audio.AudioStreamDeviceChangeInfo) => {
      if (data.changeReason === audio.AudioStreamDeviceChangeReason.REASON_OLD_DEVICE_UNAVAILABLE) {
        this.videoPause();
      } else if (data.changeReason === audio.AudioStreamDeviceChangeReason.REASON_NEW_DEVICE_AVAILABLE) {
        Logger.info(TAG, `Device connect: ${data.changeReason}`);
      }
    });
  }

  // [Start SetAvSessionListener]
  // Set background control monitor the callback events
  public async setAvSessionListener() {
    if (!this.avSessionController) {
      return;
    }
    try {
      this.avSessionController.getAvSession()?.on('play', () => this.sessionPlayCallback());
      this.avSessionController.getAvSession()?.on('pause', () => this.sessionPauseCallback());
      this.avSessionController.getAvSession()?.on('seek', (seekTime: number) => this.sessionSeekCallback(seekTime));
      this.avSessionController.getAvSession()?.on('setLoopMode', (mode: avSession.LoopMode) => {
        Logger.info(`on setLoopMode: ${mode}`)
      });
      this.avSessionController.getAvSession()?.on('playPrevious', () => {
        this.sessionPlayPreviousCallback();
      });
      this.avSessionController.getAvSession()?.on('playNext', () => {
        this.sessionPlayNextCallback();
      });
    } catch (exception) {
      Logger.error(TAG,
        `Invoke setAvSessionListener failed, code is ${exception.code}, message is ${exception.message}`);
    }
  }

  // [End SetAvSessionListener]

  // [Start UpdateIsPlay]
  // Report the video state to background control
  private updateIsPlay() {
    this.avSessionController.setAvSessionPlayState({
      state: this.isPlaying ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
        avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: this.currentTime,
        updateTime: new Date().getTime()
      },
      duration: this.currentTime
    });
  }

  // [End UpdateIsPlay]

  private isCurAvSession(): boolean {
    let curAvMetadata = this.avSessionController.getAvSessionMetadata();
    if (!curAvMetadata) {
      Logger.error(TAG, 'playVideo failed, AvMetadata is undefined');
    }
    if (curAvMetadata?.assetId === `${this.curSource?.index}`) {
      return true;
    }
    return false;
  }

  private sessionPlayCallback() {
    if (this.isCurAvSession()) {
      this.videoPlay();
    }
  }

  private sessionPauseCallback() {
    if (this.isCurAvSession()) {
      this.videoPause();
    }
  }

  private sessionSeekCallback(seekTime: number) {
    if (this.isCurAvSession()) {
      this.videoSeek(seekTime);
    }
  }

  private sessionPlayPreviousCallback() {
    if (this.isCurAvSession()) {
      emitter.emit(CommonConstants.PLAY_PREVIOUS_EVENT_ID);
      if (this.curSource?.index == 0) {
        this.updateIsPlay();
      }
    }
  }

  private sessionPlayNextCallback() {
    if (this.isCurAvSession()) {
      emitter.emit(CommonConstants.PLAY_NEXT_EVENT_ID);
      if (this.curSource?.index == 2) {
        this.updateIsPlay();
      }
    }
  }

  async videoMuted(isMuted: boolean): Promise<void> {
    if (this.avPlayer) {
      try {
        this.isMuted = isMuted;
        await this.avPlayer!.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, isMuted)
      } catch (exception) {
        Logger.error(TAG, `videoMuted failed, code is ${exception.code}, message is ${exception.message}`);
      }
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
      } catch (exception) {
        Logger.error(TAG, `set speed 1 failed, code is ${exception.code}, message is ${exception.message}`);
      }
    }
  }

  videoSpeedOnePointTwentyFive(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_25_X);
      } catch (exception) {
        Logger.error(TAG, `set speed 1_25 failed, code is ${exception.code}, message is ${exception.message}`);
      }
    }
  }

  videoSpeedOnePointSeventyFive(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_75_X);
      } catch (exception) {
        Logger.error(TAG, `set speed 1_75 failed, code is ${exception.code}, message is ${exception.message}`);
      }
    }
  }

  videoSpeedTwo(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_2_00_X);
      } catch (exception) {
        Logger.error(TAG, `set speed 2_0 failed, code is ${exception.code}, message is ${exception.message}`);
      }
    }
  }

  videoPlay(): void {
    if (this.avPlayer) {
      if (this.curSource) {
        this.avSessionController.setAVMetadata(this.curSource, this.duration);
      }
      this.avPlayer.play().catch((err: BusinessError) => {
        Logger.error(TAG, `play failed, Code:${err.code}, message:${err.message}`);
      });
      this.isPlaying = true;
      this.updateIsPlay();
    }
  }

  videoPause(): void {
    if (this.avPlayer) {
      this.avPlayer.pause().catch((err: BusinessError) => {
        Logger.error(TAG, `pause failed, Code:${err.code}, message:${err.message}`);
      });
      this.isPlaying = false;
      this.updateIsPlay();
    }
  }

  videoStop(): void {
    if (this.avPlayer) {
      this.avPlayer.stop().catch((err: BusinessError) => {
        Logger.error(TAG, `stop failed, Code:${err.code}, message:${err.message}`);
      });
      this.isPlaying = false;
      this.updateIsPlay();
    }
  }

  videoSeek(seekTime: number): void {
    if (this.avPlayer) {
      try {
        this.currentTime = seekTime;
        this.isPlaying = true;
        this.updateIsPlay();
        this.avPlayer.seek(seekTime, media.SeekMode.SEEK_CLOSEST);
      } catch (exception) {
        Logger.error(TAG, `videoSeek failed, code is ${exception.code}, message is ${exception.message}`);
      }
    }
  }

  async videoReset(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    await this.avPlayer.reset().catch((err: BusinessError) => {
      Logger.error(TAG,
        `reset failed, Code:${err.code}, message:${err.message}`);
    });
  }

  async videoRelease(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.release((err) => {
      if (err == null) {
        Logger.info(TAG, 'videoRelease release success');
      } else {
        Logger.error(TAG, `videoRelease release filed,error message is = ${err.message}`);
      }
    });
  }

  subtitleUpdateFunction(): void {
    try {
      if (this.avPlayer) {
        // [Start RegisterCaptionCallBack]
        this.avPlayer.on('subtitleUpdate', (info: media.SubtitleInfo) => {
          if (info) {
            let text = (!info.text) ? '' : info.text;
            let startTime = (!info.startTime) ? 0 : info.startTime;
            let duration = (!info.duration) ? 0 : info.duration;
            this.currentCaption = text; // Update current caption content
            Logger.info(TAG,
              `subtitleUpdate info: text:${text}, startTime:${startTime}, duration:${duration}`);
          } else {
            this.currentCaption = '';
            Logger.error(TAG, 'subtitleUpdate info is null');
          }
        });
        // [End RegisterCaptionCallBack]
      }
    } catch (err) {
      Logger.error(TAG,
        `subtitleUpdateFunction failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  async languageChange(languageSelect: number = 0): Promise<void> {
    if (this.avPlayer) {
      try {
        if (this.curSource && this.curSource.caption) {
          this.curSource.caption = languageSelect === 0 ? 'captions.srt' : 'en_captions.srt'
          this.curSource.seekTime = this.avPlayer.currentTime;
          await this.avPlayer.reset();
          await this.avSessionController.unregisterSessionListener();
          this.initAVPlayer(this.avPlayer, this.curSource, this.surfaceID);
          this.isSwitchLanguage = true;
        }
      } catch (err) {
        Logger.error(TAG,
          `languageChange failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  getDurationTime(): number {
    return this.durationTime;
  }

  getCurrentTime(): number {
    return this.currentTime;
  }
}