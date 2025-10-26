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
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { Controller } from '../model/SongData';

const TAG = 'AudioPlayerController';

@Observed
export class AudioPlayerController implements Controller {
  @Track state: string = 'default';
  @Track durationTime: number = 0;
  @Track currentTime: number = 0;
  @Track volume: number = 0.5;
  private avPlayer: media.AVPlayer;
  private stateChangeListeners: Array<(newState: string, oldState: string) => void> = [];
  private positionChangeListeners: Array<(newPosition: number) => void> = [];
  private fd?: number;
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');

  private constructor(avPlayer: media.AVPlayer) {
    this.avPlayer = avPlayer;
  }

  /**
   * Creates and initializes an AVPlayerController instance.
   * @param resource The music resource URL or file path.
   * @returns Promise<AVPlayerController> Initialized player controller instance.
   */
  static async create(resource: string) {
    media.createAVPlayer().then(async (avPlayer:  media.AVPlayer) => {
      let avPlayerController = new AudioPlayerController(avPlayer);
      AppStorage.setOrCreate<AudioPlayerController>('avPlayerController', avPlayerController);
      await avPlayerController.avPlayerLocal(resource);
      avPlayerController.setAVPlayerCallback();
    }).catch(() => {
      hilog.error(0x0000, TAG, 'createAudioPlayer failed.');
    });
  }

  /**
   * Sets up AVPlayer event listeners and state change handlers.
   * Handles time updates, duration changes, speed adjustments, volume changes, errors and state transitions.
   */
  setAVPlayerCallback() {
    this.avPlayer.on('timeUpdate', (currentTime: number) => {
      this.currentTime = currentTime;
    });
    this.avPlayer.on('durationUpdate', (duration: number) => {
      this.durationTime = duration;
    });
    this.avPlayer.on('error', (err: BusinessError) => {
      hilog.error(0x0000, TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      this.avPlayer.reset();
    });
    this.avPlayer.on('volumeChange', (vol: number) => {
      this.volume = vol;
      hilog.info(0x0000, TAG, `AVPlayer volumeChange succeeded, seek time is ${vol}`);
    })
    // State machine change callback function
    this.avPlayer.on('stateChange', async (state: string) => {
      this.stateChangeListeners.forEach(listener => listener(state, this.state));
      this.state = state;
      switch (state) {
        case 'idle':
          hilog.info(0x0000, TAG, 'AVPlayer state idle called.');
          break;
      // Automatically call prepare after initialization.
        case 'initialized':
          hilog.info(0x0000, TAG, 'AVPlayer state initialized called.');
          this.avPlayer.prepare();
          break;
      // Automatically start playing after the prepare call succeeds.
        case 'prepared':
          hilog.info(0x0000, TAG, 'AVPlayer state prepared called.');
          this.setAVPlayerVolume(this.volume);
          break;
        case 'playing':
          hilog.info(0x0000, TAG, 'AVPlayer state playing called.');
          break;
        case 'paused':
          hilog.info(0x0000, TAG, 'AVPlayer state paused called.');
          break;
        case 'completed':
          hilog.info(0x0000, TAG, 'AVPlayer state completed called.');
          this.avPlayer.stop();
          break;
        case 'stopped':
          hilog.info(0x0000, TAG, 'AVPlayer state stopped called.');
          break;
        case 'released':
          hilog.info(0x0000, TAG, 'AVPlayer state released called.');
          break;
        default:
          hilog.info(0x0000, TAG, 'AVPlayer state unknown called.');
          break;
      }
    });
  }

  /**
   * Configures AVPlayer for local file playback.
   * @param fileName The name/path of the local media file.
   */
  async avPlayerLocal(fileName: string) {
    try {
      if (this.fd) {
        fs.closeSync(this.fd);
        this.fd = undefined;
      }
      let fdPath = 'fd://';
      let pathDir = this.context?.filesDir;
      let path = pathDir + '/' + fileName;
      let file = await fs.open(path);
      fdPath = fdPath + '' + file.fd;
      this.fd = file.fd;
      this.avPlayer.url = fdPath;
      this.avPlayer.prepare();
    } catch (err) {
      hilog.error(0x0000, TAG, `fileIO failed Cause: error is ${JSON.stringify(err)}`);
    }
  }

  /**
   * Sets the volume level for AVPlayer.
   * @param volume The volume level to set.
   */
  setAVPlayerVolume(volume: number) {
    const validStopStates = ['prepared', 'paused', 'completed', 'playing'];
    if (validStopStates.includes(this.state)) {
      this.avPlayer.setVolume(volume);
      return;
    } else {
      hilog.error(0x0000, TAG, `setAudioPlayer Volume error,this state is ${this.state}`);
    }
  }

  /**
   * Seeks to specified position in current media.
   * @param timeMs Target position in milliseconds.
   */
  async seek(timeMs: number) {
    const validSeekStates = ['prepared', 'playing', 'paused', 'completed'];
    if (!validSeekStates.includes(this.state)) {
      hilog.error(0x0000, TAG, `setAudioPlayer Seek error,this state is ${this.state} time is ${timeMs}`);
      return;
    }
    this.avPlayer.seek(timeMs);
    this.positionChangeListeners.forEach(listener => listener(timeMs));
  }

  async setPlaying() {
    const validPlayingStates = ['prepared', 'paused', 'completed'];
    if (validPlayingStates.includes(this.state)) {
      try {
        await this.avPlayer.play();
      } catch (error) {
        hilog.error(0x0000, TAG, `avPlayer play failed, the error is: ${JSON.stringify(error)}`);
      }
      return;
    } else {
      hilog.error(0x0000, TAG, `setAudioPlayer Playing error,this state is ${this.state}`);
    }
  }

  async setPause() {
    if (this.state === 'playing') {
      try {
        await this.avPlayer.pause();
      } catch (error) {
        hilog.error(0x0000, TAG, `avPlayer pause failed, the error is: ${JSON.stringify(error)}`);
      }
      return;
    }
  }

  async setStop() {
    const validStopStates = ['prepared', 'paused', 'completed', 'playing'];
    if (validStopStates.includes(this.state)) {
      try {
        await this.avPlayer.stop();
      } catch (error) {
        hilog.error(0x0000, TAG, `avPlayer stop failed, the error is: ${JSON.stringify(error)}`);
      }
      return;
    } else {
      hilog.error(0x0000, TAG, `setAudioPlayer Stop  error,this state is ${this.state}`);
    }
  }

  /**
   * Registers a callback for player state changes.
   * @param listener Callback function receiving new and old state values.
   */
  onStateChange(listener: (newState: string, oldState: string) => void): void {
    this.stateChangeListeners.push(listener);
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
        hilog.error(0x0000, TAG, `closeSync fail, the error is:${JSON.stringify(error)}`);
      }
      this.fd = undefined;
    }
    this.avPlayer.off('timeUpdate');
    this.avPlayer.off('durationUpdate');
    this.avPlayer.off('speedDone');
    this.avPlayer.off('error');
    this.avPlayer.off('volumeChange');
    this.avPlayer.off('stateChange');
    try {
      await this.avPlayer.release();
    } catch (error) {
      hilog.error(0x0000, TAG, `avPlayer release failed, the error is: ${JSON.stringify(error)}`);
    }
    AppStorage.setOrCreate<AudioPlayerController>('avPlayerController', undefined);
  }
}