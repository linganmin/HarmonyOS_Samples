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
import { fileIo as fs } from '@kit.CoreFileKit';
import { media } from '@kit.MediaKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CacheListener } from '@ohos/video-cache';
import GlobalProxyServer from '../model/GlobalProxyServer';

const ORIGIN_URL: string = 'http://<您的电脑IP地址>/video';
const TAG: string = 'AVPlayManager';

export default class AvPlayManager {
  private static instance: AvPlayManager | null = null;
  private avPlayer: media.AVPlayer = {} as media.AVPlayer;
  private surfaceID: string = '';

  public static getInstance(): AvPlayManager {
    if (!AvPlayManager.instance) {
      AvPlayManager.instance = new AvPlayManager();
    }
    return AvPlayManager.instance;
  }

  /**
   * Init player.
   * @param context
   * @param surfaceId
   * @param callback
   * @returns
   */
  async initPlayer(context: common.UIAbilityContext, surfaceId: string,
    callback: (avPlayer: media.AVPlayer) => void): Promise<void> {
    hilog.info(0x0000, TAG, `initPlayer==initCamera surfaceId== ${surfaceId}`);
    this.surfaceID = surfaceId;
    try {
      this.avPlayer = await media.createAVPlayer();
      await this.setAVPlayerCallback(callback);
      this.cacheAndPlayVideo(context);
    } catch (err) {
      hilog.error(0x0000, TAG, `initPlayer initPlayer err：${JSON.stringify(err)}`);
    }
  }

  /**
   * Set callback.
   * @param callback
   * @returns
   */
  async setAVPlayerCallback(callback: (avPlayer: media.AVPlayer) => void): Promise<void> {
    hilog.info(0x0000, TAG, `setAVPlayerCallback start`);
    if (this.avPlayer === null) {
      hilog.info(0x0000, TAG, 'avPlayer has not init');
      return;
    }
    this.avPlayer.on('seekDone', (seekDoneTime) => {
      hilog.info(0x0000, TAG, `AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    })
    this.avPlayer.on('error', (err) => {
      hilog.error(0x0000, TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      this.avPlayer.reset();
    })
    this.avPlayer.on('stateChange', async (state, reason) => {
      switch (state) {
        case 'idle':
          hilog.info(0x0000, TAG, 'AVPlayer state idle called.');
          this.videoRelease();
          break;
        case 'initialized':
          hilog.info(0x0000, TAG, 'AVPlayer state initialized called.');
          if (this.surfaceID) {
            this.avPlayer.surfaceId = this.surfaceID;
            hilog.info(0x0000, TAG, `setAVPlayerCallback this.avPlayer.surfaceId = ${this.avPlayer.surfaceId}`);
            this.avPlayer.prepare();
          }
          break;
        case 'prepared':
          hilog.info(0x0000, TAG, 'AVPlayer state prepared called.');
          callback(this.avPlayer);
          hilog.info(0x0000, TAG, 'AVPlayer state prepared duration.' + this.avPlayer.duration);
          this.avPlayer.play();
          break;
        case 'playing':
          hilog.info(0x0000, TAG, 'AVPlayer state playing called.');
          AppStorage.setOrCreate('playStatus', 'playing');
          break;
        case 'paused':
          hilog.info(0x0000, TAG, 'AVPlayer state paused called.');
          break;
        case 'completed':
          hilog.info(0x0000, TAG, 'AVPlayer state completed called.');
          AppStorage.setOrCreate('playStatus', 'completed');
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
    })
  }

  /**
   * Cache and play video.
   * @param context
   * @returns
   */
  async cacheAndPlayVideo(context: common.UIAbilityContext): Promise<void> {
    try {
      hilog.info(0x0000, TAG, `cacheAndPlayVideo start`);

      class MyCacheListener implements CacheListener {
        onCacheAvailable(cacheFilePath: string, url: string, percentsAvailable: number): void {
          AppStorage.setOrCreate('currentCachePercent', percentsAvailable);
        }
      }

      GlobalProxyServer?.getInstance()?.getServer()?.registerCacheListener(new MyCacheListener(), ORIGIN_URL);
      let proxyUrl: string | undefined = await GlobalProxyServer?.getInstance()?.getServer()?.getProxyUrl(ORIGIN_URL);
      if (proxyUrl?.startsWith(context.cacheDir)) {
        const file = fs.openSync(proxyUrl, fs.OpenMode.READ_ONLY);
        proxyUrl = `fd://${file.fd}`;
      }
      hilog.info(0x0000, TAG, `proxyUrl ${proxyUrl}`);
      this.avPlayer.url = proxyUrl;
    } catch (error) {
      hilog.error(0x0000, TAG, `cacheAndPlayVideo catch error, code: ${error.code}, message: ${error.message}`);
    }
  }

  /**
   * Play video.
   */
  videoPlay(): void {
    hilog.info(0x0000, TAG, `videoPlay start`);
    if (this.avPlayer !== null) {
      try {
        this.avPlayer.play();
      } catch (err) {
        hilog.error(0x0000, TAG, `videoPlay = ${JSON.stringify(err)}`);
      }
    }
  }

  /**
   * Pause video.
   */
  videoPause(): void {
    hilog.info(0x0000, TAG, `videoPause start`);
    if (this.avPlayer !== null) {
      try {
        this.avPlayer.pause();
      } catch (err) {
        hilog.info(0x0000, TAG, `videoPause== ${JSON.stringify(err)}`);
      }
    }
  }

  /**
   * Release video.
   */
  videoRelease(): void {
    hilog.info(0x0000, TAG, `videoRelease start`);
    if (this.avPlayer !== null) {
      try {
        this.avPlayer.release();
      } catch (err) {
        hilog.info(0x0000, TAG, `videoRelease== ${JSON.stringify(err)}`);
      }
    }
  }
}

