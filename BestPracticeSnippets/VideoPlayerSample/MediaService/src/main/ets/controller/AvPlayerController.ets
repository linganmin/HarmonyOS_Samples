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
import { resourceManager } from '@kit.LocalizationKit';
import { AVPlayerState, CommonConstants } from '../common/CommonConstants';
import { secondToTime } from '../utils/CommUtils'
import { VideoData } from '../model/VideoData';
import { AvSessionController } from './AvSessionController';
import Logger from '../utils/Logger';

const TAG: string = '[AvPlayerController]';

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

  constructor(curSource: VideoData) {
    this.curSource = curSource;
    this.avSessionController = AvSessionController.getInstance();
  }

  public initAVPlayer(): void {
    media.createAVPlayer().then((player: media.AVPlayer) => {
      if (player !== null) {
        this.avPlayer = player;
        if (this.curSource.video) {
          try {
            let fileDescriptor: resourceManager.RawFileDescriptor | undefined =
              this.context?.resourceManager.getRawFdSync(this.curSource.video);
            if (fileDescriptor) {
              let avFileDescriptor: media.AVFileDescriptor =
                { fd: fileDescriptor.fd, offset: fileDescriptor.offset, length: fileDescriptor.length };
              this.avPlayer.fdSrc = avFileDescriptor;
            }
          } catch (err) {
            Logger.error(TAG, `createAVPlayer failed, err.code:${err.code}, err.message:${err.message}`);
          }
        } else {
          this.avPlayer.url = this.curSource.url;
        }
        this.setAVPlayerCallback(this.avPlayer);
        if (this.curIndex === this.curSource.index) {
          this.avSessionController.setAVMetadata(this.curSource, 0);
        }
        this.setAvSessionListener();
        Logger.info(TAG, 'createAVPlayer success:' + ` this.curIndex:${this.curIndex}`);
      } else {
        Logger.error(TAG, 'createAVPlayer fail');
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `AVPlayer catchCallback, err.code:${err.code}, err.message:${err.message}`);
    });
  }

  private setAVPlayerCallback(avPlayer: media.AVPlayer): void {
    if (!this.avPlayer) {
      return;
    }

    const uiContext: UIContext | undefined = AppStorage.get('uiContext');
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
      avPlayer.reset().catch((err: BusinessError) => {
        Logger.error(TAG, `avPlayer reset failed, code is ${err.code}, message is ${err.message}`);
      }); // resets the resources and triggers the idle state
    })
    this.setInterruptCallback()
    this.setStateChangeCallback(avPlayer);
    this.setOutputDeviceChangeCallback();
  }

  // [Start listener1]
  public async setAvSessionListener(): Promise<void> {
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
    } catch (err) {
      Logger.error(TAG, `setAvSessionListener failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  // [End listener1]

  // [Start set_back1]
  private setInterruptCallback(): void {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.on('audioInterrupt', async (interruptEvent: audio.InterruptEvent) => {
      if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
        // INTERRUPT_FORCE: The audio-related processing has been executed by the system, so the application needs to update its status and make corresponding adjustments.
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
            // This branch indicates that the system has paused the audio stream (temporarily lost focus). In order to keep the state consistent, the application needs to switch to the audio paused state.
            // Temporary loss of focus: after other audio streams release the audio focus, this audio stream will receive the audio interruption event corresponding to resume, and then it can continue playing by itself.
            /**
             * Update play status
             * @param isPlay is it playing
             * @returns void
             */
            this.updateIsPlay(false);
            this.pauseVideo();
            break;
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            // This branch indicates that the system has stopped the audio stream (permanently lost focus). In order to keep the state consistent, the application needs to switch to the audio pause state.
            // Permanent loss of focus: no audio interruption events will be received in the future. If you want to resume playing, you need the user to trigger it actively.
            /**
             * Update play status
             * @param isPlay is it playing
             * @returns void
             */
            this.updateIsPlay(false);
            this.pauseVideo();
            break;
          case audio.InterruptHint.INTERRUPT_HINT_DUCK:
            // This branch means that the system automatically reduces the volume of your video, and the application does not need to deal with it.
            // If the application doesn't accept playing with reduced volume, you can choose other processing methods here, such as active pause.
            break;
          case audio.InterruptHint.INTERRUPT_HINT_UNDUCK:
            // This branch indicates that the system has restored the audio volume to normal, and the application does not need to handle it.
            break;
          default:
            break;
        }
      } else if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_SHARE) {
        // INTERRUPT_SHARE: the application can choose to perform related operations or ignore audio interruption events.
        //
        // INTERRUPT_SHARE: the application can choose to perform related operations or ignore audio interruption events.
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_RESUME:
            // This branch indicates that the audio stream that has been paused after temporarily losing focus can continue to play at this time. It is suggested that the application continue to play and switch to the audio playback state.
            // If the application doesn't want to continue playing at this time, it can ignore this audio interruption event and not handle it.
            // Continue playing, where start () is actively executed, and the execution result of start () is recorded with the identifier variable started.
            this.playVideo();
            break;
          default:
            break;
        }
      }
    })
  }

  // [End set_back1]

  private setStateChangeCallback(avPlayer: media.AVPlayer): void {
    avPlayer.on('stateChange', async (state: string) => {
      switch (state) {
        case 'idle':
          Logger.info(TAG, 'AVPlayer state idle called.' + ` this.curIndex:${this.curIndex}`);
          break;
        case 'initialized':
          Logger.info(TAG, 'AVPlayer state initialized called.' + ` this.curIndex:${this.curIndex}`);
          avPlayer.surfaceId = this.surfaceID;
          avPlayer.prepare().catch((err: BusinessError) => {
            Logger.error(TAG, `avPlayer prepare failed, code is ${err.code}, message is ${err.message}`);
          });
          break;
        case 'prepared':
          Logger.info(TAG, `AVPlayer state prepared called. this.curIndex:${this.curIndex}`);
          this.isReady = true;
          avPlayer.loop = true;
          this.duration = avPlayer.duration;
          this.durationTime = Math.floor(this.duration / CommonConstants.SECOND_TO_MS);
          this.durationStringTime = secondToTime(this.durationTime);
          if (this.curIndex === this.curSource.index) {
            this.playVideo();
          }
          break;
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
          this.isPlaying = false;
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
      }
    })
  }

  private setOutputDeviceChangeCallback(): void {
    if (!this.avPlayer) {
      return;
    }
    // [Start player3]
    this.avPlayer.on('audioOutputDeviceChangeWithInfo', (data: audio.AudioStreamDeviceChangeInfo) => {
      if (data.changeReason === audio.AudioStreamDeviceChangeReason.REASON_NEW_DEVICE_AVAILABLE) {
        Logger.info(TAG, `Device connect: ${data.changeReason}`);
      }
    });
    // [End player3]
    // [Start pause_video]
    this.avPlayer.on('audioOutputDeviceChangeWithInfo', (data: audio.AudioStreamDeviceChangeInfo) => {
      if (data.changeReason === audio.AudioStreamDeviceChangeReason.REASON_OLD_DEVICE_UNAVAILABLE) {
        Logger.info(TAG, `Device connect: ${data.changeReason}`);
        this.pauseVideo();
      }
    });
    // [End pause_video]
  }

  // [Start update_is_play]
  private updateIsPlay(isPlay: boolean): void {
    if (this.curIndex !== this.curSource.index) {
      return;
    }
    this.isPlaying = isPlay;
    this.avSessionController.setAvSessionPlayState({
      state: isPlay ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
      avSession.PlaybackState.PLAYBACK_STATE_PAUSE, //Playback status
      position: {
        // Playback position
        elapsedTime: this.currentTime * 1000, // Elapsed time in milliseconds (ms)
        updateTime: new Date().getTime() // Update time, in ms
      },
      duration: this.duration // The duration of the current media resource
    });
  }

  // [End update_is_play]

  private isCurAvSession(): boolean {
    let curAvMetadata: avSession.AVMetadata | undefined = this.avSessionController.getAvSessionMetadata();
    if (!curAvMetadata) {
      Logger.error(TAG, 'playVideo failed, AvMetadata is undefined');
    }
    if (curAvMetadata?.assetId === `${this.curSource?.index}`) {
      return true;
    }
    return false;
  }

  private sessionPlayCallback(): void {
    if (this.isCurAvSession()) {
      this.playVideo();
    }
  }

  private sessionPauseCallback(): void {
    if (this.isCurAvSession()) {
      this.pauseVideo();
    }
  }

  private sessionStopCallback(): void {
    if (this.isCurAvSession()) {
      this.stopVideo();
    }
  }

  private sessionFastForwardCallback(time?: number): void {
    if (this.isCurAvSession()) {
      if (!time) {
        return;
      }
      if (this.isCurAvSession()) {
        this.seek((this.currentTime + time) * 1000);
      }
    }
  }

  private sessionRewindCallback(time?: number): void {
    if (!time) {
      return;
    }
    if (this.isCurAvSession()) {
      this.seek((this.currentTime - time) * 1000);
    }
  }

  private sessionSeekCallback(seekTime: number): void {
    if (this.isCurAvSession()) {
      this.seek(seekTime);
    }
  }

  public playVideo(): void {
    if (this.avPlayer) {
      if (this.avPlayer.state !== AVPlayerState.PREPARED && this.avPlayer.state !== AVPlayerState.PAUSED &&
        this.avPlayer.state !== AVPlayerState.COMPLETED) {
        return;
      }
      this.avSessionController.setAVMetadata(this.curSource, this.duration);
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
  }

  public pauseVideo(): void {
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
  }

  public stopVideo(): void {
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
          this.avPlayer!.release().catch((err: BusinessError) => {
            Logger.error(TAG, `avPlayer release failed, code is ${err.code}, message is ${err.message}`);
          });
          Logger.info(TAG, `stopVideo success, this.curIndex:${this.curIndex}`);
        }
      });
    } else {
      Logger.info(TAG, `stopVideo avPlayer NULL,  this.curIndex:${this.curIndex}`);
    }
  }

  // Parameter seekTime unit - milliseconds (ms)
  public seek(seekTime: number): void {
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
  }

  public setCurIndex(curIndex: number): void {
    this.curIndex = curIndex;
  }

  public setIsPlaying(isPlayer: boolean): void {
    this.isPlaying = isPlayer;
  }

  public setDurationTime(durationTime: number): void {
    this.durationTime = durationTime;
  }

  public setDurationStringTime(durationStringTime: string): void {
    this.durationStringTime = durationStringTime;
  }

  public setCurrentStringTime(currentStringTime: string): void {
    this.currentStringTime = currentStringTime;
  }

  public setSurfaceID(surfaceID: string): void {
    this.surfaceID = surfaceID;
  }

  public releaseVideo(index: number): void {
    if (this.avPlayer) {
      Logger.info(TAG, `releaseVideo: state:${this.avPlayer.state} this.curIndex:${this.curIndex} this.index:${index}`);
      try {
        this.avPlayer.off('timeUpdate');
        this.avPlayer.off('seekDone');
        this.avPlayer.off('speedDone');
        this.avPlayer.off('error');
        this.avPlayer.off('stateChange');
        this.avPlayer.release().catch((err: BusinessError) => {
          Logger.error(TAG, `avPlayer release failed, code is ${err.code}, message is ${err.message}`);
        });
        this.avSessionController?.unregisterSessionListener();
      } catch (err) {
        Logger.error(TAG, `releaseVideo failed, err.code:${err.code}, err.message:${err.message}`);
      }
    }
  }
}