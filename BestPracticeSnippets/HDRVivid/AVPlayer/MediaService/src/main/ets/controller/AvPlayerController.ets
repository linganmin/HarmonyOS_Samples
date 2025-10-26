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

import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AVPlayerState, CommonConstants } from '../common/CommonConstants';
import { secondToTime } from '../utils/CommUtils'
import { VideoData } from '../model/VideoData';
import { AvSessionController } from './AvSessionController';
import Logger from '../utils/Logger';

const TAG = '[AvPlayerController]';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');

@Observed
export class AvPlayerController {
  @Track surfaceID: string = '';
  @Track isPlaying: boolean = false;
  @Track isReady: boolean = false;
  @Track currentTime: number = 0;
  @Track durationStringTime: string = '00:00';
  @Track currentStringTime: string = '00:00';
  @Track duration: number = 0;
  @Track durationTime: number = 0;
  private avPlayer?: media.AVPlayer;
  private curIndex: number = 0;
  private curSource: VideoData;
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  private avSessionController: AvSessionController;
  private UIContext: UIContext;
  constructor(curSource: VideoData, uiContext: UIContext) {
    this.curSource = curSource;
    this.avSessionController = AvSessionController.getInstance();
    this.UIContext = uiContext
  }

  // [Start create_instance]
  // Create an AVPlayer instance
  public initAVPlayer() {
    media.createAVPlayer().then((player: media.AVPlayer) => {
      if (player !== null) {
        this.avPlayer = player;
        // this.curSource.video is the local video path, and this.curSource.url is the network video path
        if (this.curSource.video) {
          try {
            let fileDescriptor = this.context?.resourceManager.getRawFdSync(this.curSource.video);
            if (fileDescriptor) {
              let avFileDescriptor: media.AVFileDescriptor =
                { fd: fileDescriptor.fd, offset: fileDescriptor.offset, length: fileDescriptor.length };
              this.avPlayer.fdSrc = avFileDescriptor;
            }
          } catch (error) {
            Logger.error(`getRawFdSync failed, code is ${error.code}, message is ${error.message}`);
          }
        } else {
          this.avPlayer.url = this.curSource.url;
        }
        // [StartExclude create_instance]
        this.setAVPlayerCallback(this.avPlayer);
        if (this.curIndex === this.curSource.index) {
          this.avSessionController.setAVMetadata(this.curSource, 0, this.UIContext);
        }
        this.setAvSessionListener();
        Logger.info(TAG, 'createAVPlayer success:' + ` this.curIndex:${this.curIndex}`);
        // [EndExclude create_instance]
      } else {
        Logger.error(TAG, 'createAVPlayer fail');
      }
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `AVPlayer catchCallback, error message:${error.message}`);
    });
  }
  // [End create_instance]

  private setAVPlayerCallback(avPlayer: media.AVPlayer) {
    if (!this.avPlayer) {
      return;
    }

    avPlayer.on('timeUpdate', (time: number) => {
      if (time > this.currentTime * 1000) {
        uiContext?.animateTo({ duration: 1000, curve: Curve.Linear }, () => {
          this.currentTime = Math.floor(time / 1000);
        });
      } else {
        this.currentTime = Math.floor(time / 1000);
        if (time === 0) {
          this.updateIsPlay(true);
        }
      }
      this.currentStringTime = secondToTime(Math.floor(time / CommonConstants.SECOND_TO_MS));
    })

    // The error callback function is triggered when an error occurs during avPlayer operations,
    // at which point the reset interface is called to initiate the reset process
    avPlayer.on('error', (err: BusinessError) => {
      Logger.error(TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}` +
        `----state:${avPlayer.state} this.curIndex:${this.curIndex}`);
      avPlayer.reset() // resets the resources and triggers the idle state
        .catch((err: BusinessError) => {
          Logger.error(TAG, `avPlayer reset failed, code is ${err.code}, message is ${err.message}`);
        })
    })
    this.setInterruptCallback()
    this.setStateChangeCallback(avPlayer);
    this.setOutputDeviceChangeCallback();
  }

  public async setAvSessionListener() {
    if (!this.avSessionController) {
      return;
    }
    try {
      this.avSessionController.getAvSession()?.on('play', () => this.sessionPlayCallback());
      this.avSessionController.getAvSession()?.on('pause', () => this.sessionPauseCallback());
      this.avSessionController.getAvSession()?.on('stop', () => this.sessionStopCallback());
      this.avSessionController.getAvSession()?.on('fastForward',
        (time?: number) => this.sessionFastForwardCallback(time));
      this.avSessionController.getAvSession()?.on('rewind', (time?: number) => this.sessionRewindCallback(time));
      this.avSessionController.getAvSession()?.on('seek', (seekTime: number) => this.sessionSeekCallback(seekTime));
    } catch (error) {
      Logger.error(`getMediaContent failed, code is ${error.code}, message is ${error.message}`);
    }
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
            this.updateIsPlay(false);
            this.pauseVideo();
            break;
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            // This branch indicates that the system has stopped the audio stream (permanently lost focus).
            // To maintain consistency in state, the application should switch to the audio paused state.
            // Permanently lost focus: No further audio interruption events will be received. To resume
            // playback, user intervention is required.
            this.updateIsPlay(false);
            this.pauseVideo();
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
            this.playVideo();
            break;
          default:
            break;
        }
      }
    })
  }

  // [Start mode_volume]
  private setStateChangeCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('stateChange', async (state: string) => {
      switch (state) {
        // [StartExclude mode_volume]
        case 'idle':
          Logger.info(TAG, 'AVPlayer state idle called.' + ` this.curIndex:${this.curIndex}`);
          break;
      // [EndExclude mode_volume]
        case 'initialized':
          Logger.info(TAG, 'AVPlayer state initialized called.' + ` this.curIndex:${this.curIndex}`);
          avPlayer.surfaceId = this.surfaceID;
          avPlayer.prepare()
            .catch((err: BusinessError) => {
              Logger.error(TAG, `avPlayer prepare failed, code is ${err.code}, message is ${err.message}`);
            })
          break;
        case 'prepared':
          // [StartExclude mode_volume]
          avPlayer.audioInterruptMode = audio.InterruptMode.INDEPENDENT_MODE;
          Logger.info(TAG, `AVPlayer state prepared called. this.curIndex:${this.curIndex}`);
          this.isReady = true;
          avPlayer.loop = true;
          avPlayer.audioInterruptMode = audio.InterruptMode.SHARE_MODE;
          this.duration = avPlayer.duration;
          this.durationTime = Math.floor(this.duration / CommonConstants.SECOND_TO_MS);
          this.durationStringTime = secondToTime(this.durationTime);
          if (this.curIndex === this.curSource.index) {
            this.playVideo();
          }
          // [EndExclude mode_volume]
          break;
      // [StartExclude mode_volume]
        case 'completed':
          Logger.info(TAG,
            'AVPlayer state completed called.' + ` this.curIndex:${this.curIndex}`);
          this.isPlaying = false;
          break;
        case 'playing':
          this.isPlaying = true;
          Logger.info(TAG,
            'AVPlayer state playing called.' + ` this.curIndex:${this.curIndex}`);
          break;
        case 'paused':
          Logger.info(TAG,
            'AVPlayer state paused called.' + ` this.curIndex:${this.curIndex}`);
          break;
        case 'stopped':
          Logger.info(TAG,
            'AVPlayer state stopped called.' + ` this.curIndex:${this.curIndex}`);
          break;
        case 'released':
          Logger.info(TAG,
            'AVPlayer state released called.' + ` this.curIndex:${this.curIndex}`);
          break;
        case 'error':
          Logger.info(TAG,
            'AVPlayer state error called.' + ` this.curIndex:${this.curIndex}`);
          break;
        default:
          Logger.info(TAG,
            'AVPlayer state unknown called.' + ` this.curIndex:${this.curIndex}`);
          break;
        // [EndExclude mode_volume]
      }
    })
  }
  // [End mode_volume]

  private setOutputDeviceChangeCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.on('audioOutputDeviceChangeWithInfo', (data: audio.AudioStreamDeviceChangeInfo) => {
      if (data.changeReason === audio.AudioStreamDeviceChangeReason.REASON_OLD_DEVICE_UNAVAILABLE) {
        Logger.info(TAG, `Device break: ${data.changeReason}`);
        this.pauseVideo();
      } else if (data.changeReason === audio.AudioStreamDeviceChangeReason.REASON_NEW_DEVICE_AVAILABLE) {
        Logger.info(TAG, `Device connect: ${data.changeReason}`);
      }
    });
  }

  private updateIsPlay(isPlay: boolean) {
    if (this.curIndex !== this.curSource.index) {
      return;
    }
    this.isPlaying = isPlay;
    this.avSessionController.setAvSessionPlayState({
      state: isPlay ? avSession.PlaybackState.PLAYBACK_STATE_PLAY : avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: this.currentTime * 1000,
        updateTime: new Date().getTime()
      },
      duration: this.duration
    });
  }

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
      this.playVideo();
    }
  }

  private sessionPauseCallback() {
    if (this.isCurAvSession()) {
      this.pauseVideo();
    }
  }

  private sessionStopCallback() {
    if (this.isCurAvSession()) {
      this.stopVideo();
    }
  }

  private sessionFastForwardCallback(time?: number) {
    if (this.isCurAvSession()) {
      if (!time) {
        return;
      }
      if (this.isCurAvSession()) {
        this.seek((this.currentTime + time) * 1000);
      }
    }
  }

  private sessionRewindCallback(time?: number) {
    if (!time) {
      return;
    }
    if (this.isCurAvSession()) {
      this.seek((this.currentTime - time) * 1000);
    }
  }

  private sessionSeekCallback(seekTime: number) {
    if (this.isCurAvSession()) {
      this.seek(seekTime);
    }
  }

  // [Start set_video]
  public playVideo() {
    // [StartExclude set_video]
    if (this.avPlayer) {
      if (this.avPlayer.state !== AVPlayerState.PREPARED && this.avPlayer.state !== AVPlayerState.PAUSED &&
        this.avPlayer.state !== AVPlayerState.COMPLETED) {
        return;
      }
      this.avSessionController.setAVMetadata(this.curSource, this.duration, this.UIContext);
      //Writing in the avPlayer.play callback can cause a delay in the state change of the playback control center.
      this.updateIsPlay(true);
      Logger.info(TAG, `playVideo: state:${this.avPlayer.state} this.curIndex:${this.curIndex}`);
      this.avPlayer.play((err: BusinessError) => {
        if (err) {
          this.updateIsPlay(false); //If playback fails, revert the state of the playback control center.
          Logger.error(TAG, `playVideo failed, code is ${err.code}, message is ${err.message}`);
        } else {
          Logger.info(TAG, `playVideo success , this.curIndex:${this.curIndex}`);
        }
      });
    } else {
      Logger.info(TAG, `playVideo: avPlayer NULL, this.curIndex:${this.curIndex}`);
    }
    // [EndExclude set_video]
  }

  public pauseVideo() {
    // [StartExclude set_video]
    if (this.avPlayer) {
      Logger.info(TAG, `pauseVideo: state:${this.avPlayer.state} this.curIndex:${this.curIndex}`);
      this.updateIsPlay(false);
      this.avPlayer.pause((err: BusinessError) => {
        if (err) {
          this.updateIsPlay(true);
          Logger.error(TAG,
            `pauseVideo failed, code is ${err.code}, message is ${err.message}, this.curIndex:${this.curIndex}`);
        } else {
          Logger.info(TAG, `pauseVideo success , this.curIndex:${this.curIndex}`);
        }
      });
    } else {
      Logger.info(TAG, `pauseVideo avPlayer NULL,  this.curIndex:${this.curIndex}`);
    }
    // [EndExclude set_video]
  }

  public stopVideo() {
    // [StartExclude set_video]
    if (this.avPlayer) {
      Logger.info(TAG, `stopVideo: state: ${this.avPlayer.state} this.curIndex:${this.curIndex}`);
      if (this.avPlayer.state !== AVPlayerState.PREPARED && this.avPlayer.state !== AVPlayerState.PLAYING &&
        this.avPlayer.state !== AVPlayerState.PAUSED && this.avPlayer.state !== AVPlayerState.COMPLETED) {
        return;
      }
      this.updateIsPlay(false);
      this.avPlayer.stop((err: BusinessError) => {
        if (err) {
          this.updateIsPlay(true);
          Logger.error(TAG, `stopVideo failed, code is ${err.code}, message is ${err.message}`);
        } else {
          this.avPlayer!.release()
            .catch((err: BusinessError) => {
              Logger.error(TAG, `avPlayer release failed, code is ${err.code}, message is ${err.message}`);
            })
          Logger.info(TAG, `stopVideo success, this.curIndex:${this.curIndex}`);
        }
      });
    } else {
      Logger.info(TAG, `stopVideo avPlayer NULL,  this.curIndex:${this.curIndex}`);
    }
    // [EndExclude set_video]
  }

  public seek(seekTime: number) {
    // [StartExclude set_video]
    if (this.avPlayer) {
      seekTime = Math.max(seekTime, 0);
      seekTime = Math.min(seekTime, this.duration);
      if (this.avPlayer.state !== AVPlayerState.PREPARED && this.avPlayer.state !== AVPlayerState.PLAYING &&
        this.avPlayer.state !== AVPlayerState.PAUSED && this.avPlayer.state !== AVPlayerState.COMPLETED) {
        return;
      }
      this.currentTime = seekTime / 1000;
      this.avPlayer.seek(seekTime, media.SeekMode.SEEK_PREV_SYNC);
      this.updateIsPlay(this.isPlaying);
    }
    // [EndExclude set_video]
  }
  // [End set_video]

  public setCurIndex(curIndex: number) {
    this.curIndex = curIndex;
  }

  public setIsPlaying(isPlayer: boolean) {
    this.isPlaying = isPlayer;
  }

  public setDurationTime(durationTime: number) {
    this.durationTime = durationTime;
  }

  public setDurationStringTime(durationStringTime: string) {
    this.durationStringTime = durationStringTime;
  }

  public setCurrentStringTime(currentStringTime: string) {
    this.currentStringTime = currentStringTime;
  }

  public setSurfaceID(surfaceID: string) {
    this.surfaceID = surfaceID;
  }

  // [Start destroy_instance]
  public releaseVideo(index: number) {
    if (this.avPlayer) {
      Logger.info(TAG,
        `releaseVideo: state:${this.avPlayer.state} this.curIndex:${this.curIndex} this.index:${index}`);
      this.avPlayer.off('timeUpdate');
      this.avPlayer.off('seekDone');
      this.avPlayer.off('speedDone');
      this.avPlayer.off('error');
      this.avPlayer.off('stateChange');
      this.avPlayer.release()
        .catch((err: BusinessError) => {
          Logger.error(TAG, `avPlayer release failed, code is ${err.code}, message is ${err.message}`);
        })
      // [StartExclude destroy_instance]
      this.avSessionController?.unregisterSessionListener();
      // [EndExclude destroy_instance]
    }
  }
  // [End destroy_instance]
}