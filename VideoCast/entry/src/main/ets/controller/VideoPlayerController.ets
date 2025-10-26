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

const TAG = 'AVPlayerController logInfo';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

@Observed
export class VideoPlayerController {
  @Track state: string = 'default';
  @Track durationTime: number = 0;
  @Track currentTime: number = 0;
  @Track volume: number = 0.5;
  @Track speed: number = 1.0;
  private avPlayer: media.AVPlayer;
  private surfaceID: string;
  private stateChangeListeners: Array<(newState: string, oldState: string) => void> = [];
  private speedChangeListeners: Array<(newSpeed: number) => void> = [];
  private positionChangeListeners: Array<(newPosition: number) => void> = [];
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
  static async create(surfaceID: string, videoType: string, resource: string) {
    const avPlayer = await media.createAVPlayer();
    let avPlayerController = new VideoPlayerController(avPlayer, surfaceID);
    if (videoType === 'network') {
      await avPlayerController.avPlayerNetUrl(resource);
    } else {
      await avPlayerController.avPlayerLocal(resource);
    }
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
    this.avPlayer.on('speedDone', (speed: number) => {
      this.speed = speed;
      this.speedChangeListeners.forEach(listener => listener(speed));
    })
    this.avPlayer.on('error', (err: BusinessError) => {
      hilog.error(0x0000, TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      this.avPlayer.reset();
    });
    this.avPlayer.on('volumeChange', (vol: number) => {
      this.volume = vol;
      hilog.info(0x0000, TAG, `AVPlayer volumeChange succeeded, seek time is ${vol}`);
    })
    // State machine change callback function
    this.avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      this.stateChangeListeners.forEach(listener => listener(state, this.state));
      this.state = state;
      switch (state) {
        case 'idle':
          hilog.info(0x0000, TAG, 'AVPlayer state idle called.');
          break;
      // Automatically call prepare after initialization.
        case 'initialized':
          hilog.info(0x0000, TAG, 'AVPlayer state initialized called.');
          this.avPlayer.surfaceId = this.surfaceID;
          this.avPlayer.prepare();
          break;
      // Automatically start playing after the prepare call succeeds.
        case 'prepared':
          hilog.info(0x0000, TAG, 'AVPlayer state prepared called.');
          this.setAVPlayerVolume(this.volume);
          this.avPlayer.play();
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
          this.avPlayer.reset();
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
   * Configures AVPlayer for network URL playback.
   * @param netAddress The network URL of the media resource.
   */
  async avPlayerNetUrl(netAddress: string) {
    this.setAVPlayerCallback();
    this.avPlayer.url = netAddress;
  }

  /**
   * Configures AVPlayer for local file playback.
   * @param fileName The name/path of the local media file.
   */
  async avPlayerLocal(fileName: string) {
    this.setAVPlayerCallback();
    let fdPath = 'fd://';
    let context = uiContext?.getHostContext() as common.UIAbilityContext;
    let pathDir = context.filesDir;
    let path = pathDir + '/' + fileName;
    let file = await fs.open(path);
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
      hilog.error(0x0000, TAG, `avPlayerSeek error,this state is ${this.state}`);
      return;
    }
    this.avPlayer.seek(timeMs, mode);
    this.positionChangeListeners.forEach(listener => listener(timeMs));
  }

  async setAVPlayerPlaying() {
    const validPlayingStates = ['prepared', 'paused', 'completed'];
    if (validPlayingStates.includes(this.state)) {
      await this.avPlayer.play();
      return;
    } else {
      hilog.error(0x0000, TAG, `setAVPlayerPlaying error,this state is ${this.state}`);
    }
  }

  async setAVPlayerPause() {
    if (this.state === 'playing') {
      await this.avPlayer.pause();
      return;
    }
  }

  async setAVPlayerStop() {
    const validStopStates = ['prepared', 'paused', 'completed', 'playing'];
    if (validStopStates.includes(this.state)) {
      await this.avPlayer.stop();
      return;
    } else {
      hilog.error(0x0000, TAG, `setAVPlayerStop  error,this state is ${this.state}`);
    }
  }

  /**
   * Sets playback speed for AVPlayer.
   * @param speed The playback speed to set.
   * @throws Error if player is not in a valid state (prepared/paused/completed/playing).
   */
  setAVPlayerSpeed(speed: media.PlaybackSpeed) {
    const validStopStates = ['prepared', 'paused', 'completed', 'playing'];
    if (validStopStates.includes(this.state)) {
      this.avPlayer.setSpeed(speed);
      return;
    } else {
      hilog.error(0x0000, TAG, `setAVPlayerSpeed  error,this state is ${this.state}`);
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
      hilog.error(0x0000, TAG, `setAVPlayerVolume error,this state is ${this.state}`);
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
   * Registers a callback for playback speed changes.
   * @param listener Callback function receiving the new speed value.
   */
  onSpeedChange(listener: (newSpeed: number) => void): void {
    this.speedChangeListeners.push(listener);
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

  offSpeedChange(listener: (newSpeed: number) => void): void {
    this.speedChangeListeners = this.speedChangeListeners.filter(l => l !== listener);
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
      fs.closeSync(this.fd);
      this.fd = undefined;
    }
    this.avPlayer.off('timeUpdate');
    this.avPlayer.off('durationUpdate');
    this.avPlayer.off('speedDone');
    this.avPlayer.off('error');
    this.avPlayer.off('volumeChange');
    this.avPlayer.off('stateChange');
    await this.avPlayer.release();
  }
}