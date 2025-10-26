/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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
import { BusinessError } from '@kit.BasicServicesKit';
import { Caption } from '../model/ViewModel';
import { Logger } from '../utils/Logger';
import { display } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';

const LOG_TAG = 'AV_PLAYER';

const PROPORTION = 1;
const SURFACE_W = 1;
const SURFACE_H = 1.78;

@Component
export struct AvPlayer {
  private xComponentController: XComponentController = new XComponentController();
  private avPlayer: media.AVPlayer | null = null;
  private surfaceId: string = '';
  private context: common.UIAbilityContext | undefined = undefined;
  @State fileName: string = 'sample.mp4';
  @State surfaceW: number | null = null;
  @State surfaceH: number | null = null;
  @State windowWidth: number = 300;
  @State windowHeight: number = 200;
  @State subtitle: string = '';
  @Link @Watch('togglePlay') isPlaying: boolean;
  @Link @Watch('sliderChange') sliderTime: number;
  @Link currentTime: number;
  @Link duration: number;
  @Link currentCaption: Caption | null;

  togglePlay() {
    if (this.isPlaying) {
      this.avPlay();
    } else {
      this.avPause();
    }
  }

  sliderChange() {
    if (this.avPlayer) {
      try {
        this.avPlayer.seek(this.sliderTime, 1);
      } catch (error) {
        Logger.error(LOG_TAG, `videoSeek== ${JSON.stringify(error as BusinessError)}`);
      }
    }
  }

  async msleepAsync(ms: number): Promise<boolean> {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve(true);
      }, ms)
    })
  }

  async avSetupVideoAndSubtitle() {
    if (!this.context) {
      Logger.error(LOG_TAG, 'Context is undefined, cannot setup video and subtitle.');
      return;
    }

    if (this.avPlayer) {
      try {
        await this.avPlayer.release();
      } catch (error) {
        Logger.error(LOG_TAG, `AVPlayer release error: ${JSON.stringify(error as BusinessError)}`);
      }
    }

    try {
      const videoFd = await this.context.resourceManager.getRawFd(this.fileName);
      const avFileDescriptor: media.AVFileDescriptor = {
        fd: videoFd.fd,
        offset: videoFd.offset,
        length: videoFd.length
      };

      this.avPlayer = await media.createAVPlayer();
      if (!this.avPlayer) {
        Logger.error(LOG_TAG, 'Failed to create AVPlayer!');
        return;
      }
      await this.setAVPlayerCallback();
      this.avPlayer.fdSrc = avFileDescriptor;

      try {
        const subFd = await this.context.resourceManager.getRawFd('captions.srt');
        await this.avPlayer.addSubtitleFromFd(subFd.fd, subFd.offset, subFd.length);
      } catch (subError) {
        Logger.error(LOG_TAG, `Optional subtitle failed: ${JSON.stringify(subError as BusinessError)}`);
      }
    } catch (error) {
      Logger.error(LOG_TAG, `avSetupVideoAndSubtitle failed: ${JSON.stringify(error as BusinessError)}`);
    }
  }

  async avTurnOffSubtitle() {
    this.avPlayer?.off('subtitleUpdate');
  }

  avPlay(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.play();
      } catch (error) {
        Logger.error(LOG_TAG, `avPlay = ${JSON.stringify(error as BusinessError)}`);
      }
    }
  }

  avPause(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.pause();
      } catch (error) {
        Logger.error(LOG_TAG, `avPause== ${JSON.stringify(error)}`);
      }
    }
  }

  async setAVPlayerCallback(): Promise<void> {
    if (this.avPlayer ===null) {
      Logger.error(LOG_TAG, `avPlayer has not init!`);
      return;
    }
    this.avPlayer.on('error', (err) => {
      Logger.error(LOG_TAG, `setAVPlayerCallback Invoke avPlayer failed ${JSON.stringify(err)}`);
      if (this.avPlayer ===null) {
        Logger.error(LOG_TAG, `avPlayer has not init on error`);
        return;
      }
      this.avPlayer.reset();
    });
    this.avPlayer.on('stateChange', async (state) => {
      if (this.avPlayer ===null) {
        Logger.error(LOG_TAG, `avPlayer has not init on state change`);
        return;
      }
      switch (state) {
        case 'initialized':
          if (this.surfaceId) {
            this.avPlayer.surfaceId = this.surfaceId;
            this.avPlayer.prepare();
          }
          break;
        case 'prepared':
          this.duration = Math.floor(this.avPlayer.duration / 1000);
          this.currentTime = Math.floor(this.avPlayer.currentTime / 1000);
          if (this.isPlaying) {
            this.avPlay();
          }
          this.isPlaying = true;
          this.setVideoWH();
          break;
        case 'completed':
          this.isPlaying = false;
          break;
        case 'released':
          this.isPlaying = false;
          break;
        default:
          break;
      }
    });
    this.avPlayer.on('timeUpdate', (time: number) => {
      this.currentTime = Math.floor(time / 1000);
    });
    this.avPlayer.on('subtitleUpdate', (info: media.SubtitleInfo) => {
      if (!!info) {
        let text = (!info.text) ? '' : info.text;
        let startTime = (!info.startTime) ? 0 : info.startTime;
        let endTime = (!info.duration) ? 0 : info.duration;
        this.currentCaption = { text, startTime, endTime };
      } else {
        this.currentCaption = { text: '', startTime: 0, endTime: 0 }
      }
    });
  }

  aboutToAppear() {
    try {
      this.windowWidth = display.getDefaultDisplaySync().width;
      this.windowHeight = display.getDefaultDisplaySync().height;
      this.surfaceW = this.windowWidth * SURFACE_W;
      this.surfaceH = this.surfaceW / SURFACE_H;
    } catch (error) {
      Logger.error(LOG_TAG, `getDefaultDisplaySync fail, error is: ${JSON.stringify(error as BusinessError)}`);
    }
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  aboutToDisappear() {
    if (this.avPlayer ===null) {
      Logger.error(LOG_TAG, `avPlayer has not init aboutToDisappear`);
      return;
    }
    this.avTurnOffSubtitle();
    this.avPlayer.release((err: BusinessError) => {
      if (err) {
        Logger.error(LOG_TAG,
          ` videoRelease release failed, error message is = ${JSON.stringify(err?.message)}`);
      } else {
        this.currentTime = 0;
        this.duration = 0;
      }
    });
  }

  setVideoWH(): void {
    this.surfaceH = Math.round(this.windowHeight * PROPORTION);
    this.surfaceW = Math.round(this.windowWidth);
  }

  build() {
    Column() {
      XComponent({
        id: 'xComponent',
        type: XComponentType.SURFACE,
        controller: this.xComponentController
      })
        .id('VideoView')
        .onLoad(() => {
          this.surfaceId = this.xComponentController.getXComponentSurfaceId();
          this.avSetupVideoAndSubtitle();
        })
        .height(`${this.surfaceH}px`)
        .width(`${this.surfaceW}px`)
    }
  }
}
