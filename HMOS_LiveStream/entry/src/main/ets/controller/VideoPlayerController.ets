/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { audio } from '@kit.AudioKit';
import { avSession } from '@kit.AVSessionKit';
import Logger from '../common/utils/Logger';

const TAG = '[AVPlayerController]';

@Observed
export class VideoPlayerController {
  @Track state: string = 'default';
  @Track durationTime: number = 0;
  @Track currentTime: number = 0;
  @Track volume: number = 0.5;
  @Track width: number = 1920;
  @Track height: number = 1080;
  private avPlayer: media.AVPlayer;
  private surfaceID: string;
  private stateChangeListeners: Array<(newState: string, oldState: string) => void> = [];
  private positionChangeListeners: Array<(newPosition: number) => void> = [];
  private interruptListeners: Array<(playState: avSession.AVPlaybackState) => void> = [];
  private fd?: number;

  private constructor(avPlayer: media.AVPlayer, surfaceID: string) {
    this.surfaceID = surfaceID;
    this.avPlayer = avPlayer;
  }

  /**
   * Creates and initializes an AVPlayerController instance.
   * @param surfaceID The surface ID for video rendering.
   * @param videoType The type of video source ('network' or 'local').
   * @param resource The video resource URL or file path.
   * @returns Promise<AVPlayerController> Initialized player controller instance.
   */
  static async create(surfaceID: string, resource: string) {
    let avPlayer: media.AVPlayer | undefined;
    try {
      avPlayer = await media.createAVPlayer();
    } catch (err) {
      let message = 'Unknown error';
      if (err instanceof Error) {
        message = err.message;
      }
      Logger.error(TAG, `Create AVPlayer failed: ${message}.`);
      return;
    }


    let avPlayerController = new VideoPlayerController(avPlayer, surfaceID);
    avPlayerController.avPlayerLocal(resource);
    return avPlayerController;
  }

  /**
   * Sets up AVPlayer event listeners and state change handlers.
   * Handles time updates, duration changes, speed adjustments, volume changes, errors and state transitions.
   */
  setAVPlayerCallback() {
    this.avPlayer.on('timeUpdate', (currentTime: number) => {
      this.currentTime = currentTime;
    })
    this.avPlayer.on('durationUpdate', (duration: number) => {
      this.durationTime = duration;
    })
    this.avPlayer.on('error', (err: BusinessError) => {
      Logger.error(TAG, `Invoke avPlayer failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      this.avPlayer.reset().catch((err: BusinessError) => {
        Logger.error(TAG, `avPlayer reset failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      });
    });
    this.avPlayer.on('volumeChange', (vol: number) => {
      this.volume = vol;
      Logger.info(TAG, `AVPlayer volumeChange succeeded, seek time is ${vol}.`);
    })
    // State machine change callback function
    this.avPlayer.on('stateChange', async (state: string, _: media.StateChangeReason) => {
      this.stateChangeListeners.forEach(listener => listener(state, this.state));
      this.state = state;
      switch (state) {
        case 'idle':
          Logger.info(TAG, 'AVPlayer state idle called.');
          break;
        // Automatically call prepare after initialization.
        case 'initialized':
          Logger.info(TAG, 'AVPlayer state initialized called.');
          this.avPlayer.surfaceId = this.surfaceID;
          this.avPlayer.prepare().catch((err: BusinessError) => {
            Logger.error(TAG, `avPlayer prepare failed, errCode = ${err.code}, errMessage = ${err.message}.`);
          });
          break;
        // Automatically start playing after the prepare call succeeds.
        case 'prepared':
          Logger.info(TAG, 'AVPlayer state prepared called.');
          this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT_CROP
          try {
            this.setAVPlayerVolume(this.volume);
          } catch (error) {
            let err = error as BusinessError;
            Logger.error(TAG, `setAVPlayerVolume failed, errCode = ${err.code}, errMessage = ${err.message}.`);
          }
          this.getVideoSize();
          this.getVideoDuration();
          this.avPlayer.play().catch((err: BusinessError) => {
            Logger.error(TAG, `avPlayer play failed, errCode = ${err.code}, errMessage = ${err.message}.`);
          });
          break;
        case 'playing':
          Logger.info(TAG, 'AVPlayer state playing called.');
          break;
        case 'paused':
          Logger.info(TAG, 'AVPlayer state paused called.');
          break;
        case 'completed':
          Logger.info(TAG, 'AVPlayer state completed called.');
          this.avPlayer.stop().catch((err: BusinessError) => {
            Logger.error(TAG, `avPlayer stop failed, errCode = ${err.code}, errMessage = ${err.message}.`);
          });
          break;
        case 'stopped':
          Logger.info(TAG, 'AVPlayer state stopped called.');
          this.avPlayer.reset().catch((err: BusinessError) => {
            Logger.error(TAG, `avPlayer reset failed, errCode = ${err.code}, errMessage = ${err.message}.`);
          });
          break;
        case 'released':
          Logger.info(TAG, 'AVPlayer state released called.');
          break;
        default:
          Logger.info(TAG, 'AVPlayer state unknown called.');
          break;
      }
    });

    // Audio InterruptCallback
    this.avPlayer?.on('audioInterrupt', async (interruptInfo: audio.InterruptEvent) => {
      Logger.info(TAG, `audioInterrupt forceType = ${interruptInfo.forceType}, hintType = ${interruptInfo.hintType}.`);
      // Before the interruption, AVPlayer is in the playback state, so the playback status of AVSession Broadcast Control Center is PLAY
      let playbackState: avSession.AVPlaybackState = {
        state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
        loopMode: avSession.LoopMode.LOOP_MODE_SINGLE
      };
      if (interruptInfo.forceType === audio.InterruptForceType.INTERRUPT_SHARE &&
        interruptInfo.hintType === audio.InterruptHint.INTERRUPT_HINT_RESUME) {
        Logger.info(TAG, 'Video resume play.');
        this.avPlayer?.play().catch((err: BusinessError) => {
          Logger.error(TAG, `avPlayer play failed, errCode = ${err.code}, errMessage = ${err.message}.`);
        });
      } else if (interruptInfo.forceType === audio.InterruptForceType.INTERRUPT_FORCE &&
        (interruptInfo.hintType === audio.InterruptHint.INTERRUPT_HINT_PAUSE ||
          interruptInfo.hintType === audio.InterruptHint.INTERRUPT_HINT_STOP)) {
        playbackState.state = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
      }
      Logger.debug(TAG, `audioInterrupt happend state = ${playbackState.state}.`);
      this.interruptListeners.forEach(listener => listener(playbackState));
    })
  }

  getVideoSize() {
    this.width = this.avPlayer.width;
    this.height = this.avPlayer.height;
  }

  getVideoDuration() {
    this.durationTime = this.avPlayer.duration;
  }

  /**
   * Configures AVPlayer for local file playback.
   * @param fileName The name/path of the local media file.
   */
  avPlayerLocal(filePath: string) {
    this.setAVPlayerCallback();
    let fdPath = 'fd://';
    let file: fs.File;
    try {
      file = fs.openSync(filePath);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `open file failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      return;
    }
    fdPath = fdPath + '' + file.fd;
    this.fd = file.fd;
    this.avPlayer.url = fdPath;
  }

  /**
   * Seeks to specified position in current media.
   * @param timeMs Target position in milliseconds.
   * @param mode Seeking mode (e.g., SEEK_PREV_SYNC).
   * @throws Error if player is not in seekable state.
   */
  async avPlayerSeek(timeMs: number, mode: media.SeekMode) {
    const validSeekStates = ['prepared', 'playing', 'paused', 'completed'];
    if (!validSeekStates.includes(this.state)) {
      Logger.error(TAG, `avPlayerSeek error,this state is ${this.state}.`);
      return;
    }
    this.avPlayer.seek(timeMs, mode);
    this.positionChangeListeners.forEach(listener => listener(timeMs));
  }

  async setAVPlayerPlaying() {
    const validPlayingStates = ['prepared', 'paused', 'completed'];
    if (validPlayingStates.includes(this.state)) {
      try {
        await this.avPlayer.play();
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `avPlayer play failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
      return;
    } else {
      Logger.error(TAG, `setAVPlayerPlaying error,this state is ${this.state}.`);
    }
  }

  async setAVPlayerPause() {
    if (this.state === 'playing') {
      try {
        await this.avPlayer.pause();
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `avPlayer pause failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
      return;
    }
  }

  async setAVPlayerStop() {
    const validStopStates = ['prepared', 'paused', 'completed', 'playing'];
    if (validStopStates.includes(this.state)) {
      try {
        await this.avPlayer.stop();
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `avPlayer stop failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
      return;
    } else {
      Logger.error(TAG, `setAVPlayerStop failed, this state is ${this.state}.`);
    }
  }

  /**
   * Sets the volume level for AVPlayer.
   * @param volume The volume level to set.
   * @throws Error if player is not in a valid state (prepared/paused/completed/playing).
   */
  setAVPlayerVolume(volume: number) {
    const validStopStates = ['prepared', 'paused', 'completed', 'playing'];
    if (validStopStates.includes(this.state)) {
      this.avPlayer.setVolume(volume);
      return;
    } else {
      Logger.error(TAG, `setAVPlayerVolume error, this state is ${this.state}.`);
    }
  }

  /**
   * Registers a callback for player state changes.
   * @param listener Callback function receiving new and old state values.
   */
  onStateChange(listener: (newState: string, oldState: string) => void): void {
    this.stateChangeListeners.push(listener);
  }

  onInterrupt(listener: (playState: avSession.AVPlaybackState) => void): void {
    this.interruptListeners.push(listener);
  }

  /**
   * Registers a callback for playback position changes.
   * @param listener Callback function receiving the new position in milliseconds.
   */
  onPositionChange(listener: (newPosition: number) => void): void {
    this.positionChangeListeners.push(listener);
  }

  offStateChange(listener: (newState: string, oldState: string) => void): void {
    this.stateChangeListeners = this.stateChangeListeners.filter(l => l !== listener);
  }

  offPositionChange(listener: (newPosition: number) => void): void {
    this.positionChangeListeners = this.positionChangeListeners.filter(l => l !== listener);
  }

  /**
   * Releases player resources and removes all event listeners.
   * Closes file descriptor if currently playing a file.
   */
  async releasePlayer() {
    if (this.fd) {
      try {
        fs.closeSync(this.fd);
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `close player failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
      this.fd = undefined;
    }
    this.avPlayer.off('timeUpdate');
    this.avPlayer.off('durationUpdate');
    this.avPlayer.off('error');
    this.avPlayer.off('volumeChange');
    this.avPlayer.off('stateChange');
    try {
      await this.avPlayer.release();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `avPlayer release failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }
}
