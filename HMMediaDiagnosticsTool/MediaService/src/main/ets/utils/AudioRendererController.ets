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
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';
import { audio } from '@kit.AudioKit';
import { fileIo } from '@kit.CoreFileKit';
import { AVSessionController } from './AVSessionController';
import SongItemBuilder from '../songdatacontroller/SongItemBuilder';
import { LIMIT_BUFFER_WALK, Options, SECOND_BUFFER_WALK } from '../songdatacontroller/PlayerData';
import { SongItem } from '../songdatacontroller/SongData';
import { BackgroundUtil } from './BackgroundUtil';
import { Logger } from './Logger';
import { SONG_LIST } from '../songdatacontroller/SongListData';

const TAG = 'AudioRendererController';

export class AudioRendererController {
  public audioRenderer?: audio.AudioRenderer;
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  private songItemBuilder: SongItemBuilder = new SongItemBuilder();
  private isFirst: boolean = true;
  private musicIndex: number = 0;
  private songList: SongItem[] = SONG_LIST;
  private initOffset: number = 0;
  private currentOffset: number = 0;
  private bufferRead: number = 0;
  private bufferNeedRead: number = 0;
  private bufferLimitRead: number = LIMIT_BUFFER_WALK;
  private songRawFileDescriptor: resourceManager.RawFileDescriptor | undefined = undefined;
  private avSessionController: AVSessionController | undefined = undefined;
  private audioStreamUsage: audio.StreamUsage = audio.StreamUsage.STREAM_USAGE_UNKNOWN;
  private state: audio.AudioState = audio.AudioState.STATE_INVALID;

  constructor(audioStreamUsage: audio.StreamUsage) {
    this.audioStreamUsage = audioStreamUsage;
    this.musicIndex = this.songList.findIndex((songItem: SongItem) => {
      return songItem.type === this.audioStreamUsage;
    });
    Logger.info(TAG, 'audioRendererController generate success' + 'current audioStreamUsage:' + audioStreamUsage);
    this.songItemBuilder = new SongItemBuilder();
  }

  public static generateAudioRendererController(audioStreamUsage: audio.StreamUsage,
    audioRendererControllerMap: Map<audio.StreamUsage, AudioRendererController>) {
    let audioRendererController = new AudioRendererController(audioStreamUsage);
    audioRendererControllerMap.set(audioStreamUsage, audioRendererController);
    AppStorage.setOrCreate<Map<audio.StreamUsage, AudioRendererController>>('audioRendererControllerMap',
      audioRendererControllerMap);
    Logger.info(TAG, 'audioRendererController generate success' + 'current audioStreamUsage:' + audioStreamUsage);
    return audioRendererController;
  }

  public static getInstance(audioStreamUsage: audio.StreamUsage): AudioRendererController {
    let audioRendererControllerMap: Map<audio.StreamUsage, AudioRendererController> | undefined =
      AppStorage.get('audioRendererControllerMap');
    AppStorage.setOrCreate('currentAudioStreamUsage', audioStreamUsage);
    if (!audioRendererControllerMap) {
      audioRendererControllerMap = new Map();
      return AudioRendererController.generateAudioRendererController(audioStreamUsage, audioRendererControllerMap);
    }
    if (audioRendererControllerMap.has(audioStreamUsage)) {
      let audioRendererController = audioRendererControllerMap.get(audioStreamUsage);
      if (!audioRendererController) {
        Logger.error(TAG, 'audioRendererController is error' + 'current audioStreamUsage:' + audioStreamUsage);
        return AudioRendererController.generateAudioRendererController(audioStreamUsage, audioRendererControllerMap);
      }
      Logger.info(TAG, 'audioRendererController is got from map' + 'current audioStreamUsage:' + audioStreamUsage);
      return audioRendererController;
    } else {
      return AudioRendererController.generateAudioRendererController(audioStreamUsage, audioRendererControllerMap);
    }
  }

  private async initAudioRenderer() {
    let audioStreamInfo: audio.AudioStreamInfo = {
      samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000,
      channels: audio.AudioChannel.CHANNEL_2,
      sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
      encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
    };

    let audioRendererInfo: audio.AudioRendererInfo = {
      usage: this.audioStreamUsage,
      rendererFlags: 0
    };

    let audioRendererOptions: audio.AudioRendererOptions = {
      streamInfo: audioStreamInfo,
      rendererInfo: audioRendererInfo
    };
    try {
      this.audioRenderer = await audio.createAudioRenderer(audioRendererOptions);
      this.setAudioRendererCallbacks();
      Logger.info(TAG, 'Invoke createAudioRenderer succeeded.');
    } catch (err) {
      Logger.error(TAG, `Invoke createAudioRenderer failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  private setAudioRendererCallbacks() {
    this.setAvSessionCallback();
    this.setWriteDataCallback();
    this.setInterruptCallback();
    this.setOutputDeviceChangeCallback();
    this.setStateChangeCallback();
  }

  private setStateChangeCallback() {
    if (!this.audioRenderer) {
      Logger.error(TAG, 'writeData fail.audioRenderer is undefined');
      return;
    }
    this.audioRenderer.on('stateChange', (state: audio.AudioState) => {
      this.state = state;
      Logger.info(TAG, 'current state is :' + this.state);

    });
  }

  private setAvSessionCallback() {
    this.avSessionController = AVSessionController.getInstance();
    this.loadSongAssent();
  }

  private setWriteDataCallback() {
    if (!this.audioRenderer) {
      Logger.error(TAG, 'writeData fail.audioRenderer is undefined');
      return;
    }
    let options: Options | undefined = undefined;
    this.audioRenderer.on('writeData', (buffer) => {
      if (!this.songRawFileDescriptor) {
        return;
      }
      options = {
        offset: this.currentOffset,
        length: buffer.byteLength
      };
      fileIo.readSync(this.songRawFileDescriptor.fd, buffer, options);
      this.currentOffset += buffer.byteLength;
      this.bufferRead = this.currentOffset - this.initOffset;
      let currentNeedRead: number = 0;
      if (this.audioStreamUsage === audio.StreamUsage.STREAM_USAGE_MUSIC) {
        currentNeedRead = this.bufferNeedRead;
      } else {
        currentNeedRead = this.bufferNeedRead <= this.bufferLimitRead ? this.bufferNeedRead : this.bufferLimitRead;
      }
      if (this.bufferRead > currentNeedRead) {
        this.stop();
      }
      Logger.info(TAG,
        `songRawFileDescriptor get successed` + 'bufferRead is ' + this.bufferRead + '///' + 'bufferNeedRead is ' +
        this.bufferNeedRead);
    });
  }

  private setInterruptCallback() {
    if (!this.audioRenderer) {
      return;
    }
    this.audioRenderer.on('audioInterrupt', this.interruptCallback);
  }

  private interruptCallback: (interruptEvent: audio.InterruptEvent) => void =
    (interruptEvent: audio.InterruptEvent) => {
      if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
            this.updateIsPlay(false);
            break;
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            this.updateIsPlay(false);
            this.pause();
            break;
          case audio.InterruptHint.INTERRUPT_HINT_DUCK:
            break;
          case audio.InterruptHint.INTERRUPT_HINT_UNDUCK:
            break;
          default:
            break;
        }
      } else if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_SHARE) {
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_RESUME:
            this.start();
            break;
          default:
            break;
        }
      }
    };

  private setOutputDeviceChangeCallback() {
    if (!this.audioRenderer) {
      return;
    }
    this.audioRenderer.on('outputDeviceChangeWithInfo', this.outputDeviceChangeCallback);
  }

  private outputDeviceChangeCallback: (deviceChangeInfo: audio.AudioStreamDeviceChangeInfo) => void =
    (deviceChangeInfo: audio.AudioStreamDeviceChangeInfo) => {
      Logger.info(TAG, `DeviceInfo id: ${deviceChangeInfo.devices[0].id}`);
      Logger.info(TAG, `DeviceInfo name: ${deviceChangeInfo.devices[0].name}`);
      Logger.info(TAG, `DeviceInfo address: ${deviceChangeInfo.devices[0].address}`);
      Logger.info(TAG, `Device change reason: ${deviceChangeInfo.changeReason}`);
      if (deviceChangeInfo.changeReason === audio.AudioStreamDeviceChangeReason.REASON_OLD_DEVICE_UNAVAILABLE) {
        Logger.info(TAG, `Device change reason: ${deviceChangeInfo.changeReason}`);
        this.pause();
      }
    };

  public async setSilentModeAndMixWithOthers(isSupportSilent: boolean = false) {
    if (!this.audioRenderer || !this.context) {
      return;
    }
    this.audioRenderer.setSilentModeAndMixWithOthers(isSupportSilent);
  }

  /**
   * Play music by index.
   *
   * @param musicIndex
   */
  async play() {
    if (!this.audioRenderer) {
      await this.initAudioRenderer();
    }
    if (this.isFirst) {
      this.isFirst = false;
      await this.loadSongAssent();
      await this.start();
    } else {
      await this.start();
    }
  }

  private async loadSongAssent() {
    let curSongItem = this.songList[this.musicIndex];
    await this.songItemBuilder.build(curSongItem);
    this.songRawFileDescriptor = this.songItemBuilder.getRawFileDescriptor();
    if (!this.songRawFileDescriptor) {
      Logger.error(TAG, `loadSongAssent faile : songRawFileDescriptor get failed`);
      return;
    }
    this.initOffset = this.songRawFileDescriptor.offset;
    this.bufferNeedRead = this.songRawFileDescriptor.length;
    if (curSongItem.start && curSongItem.end) {
      this.initOffset += curSongItem.start * SECOND_BUFFER_WALK;
      this.bufferNeedRead = (curSongItem.end - curSongItem.start) * SECOND_BUFFER_WALK;
    }
    this.currentOffset = this.initOffset;
    this.bufferRead = 0;
  }

  /**
   * Get whether the music is played for the first.
   *
   * @returns isFirst
   */
  public getFirst() {
    return this.isFirst;
  }

  public getAudioStreamUsage() {
    return this.audioStreamUsage;
  }

  private updateIsPlay(isPlaying: boolean) {
    AppStorage.setOrCreate<boolean>('isPlaying', isPlaying);
    if (!this.avSessionController) {
      return;
    }
    this.avSessionController.setPlayState(isPlaying);
  }

  /**
   * start music.
   */
  public async start() {
    if (this.audioRenderer) {
      try {
        await this.audioRenderer.start().catch((err: BusinessError) => {
          Logger.error(TAG, `start failed,code is ${err.code},message is ${err.message}}`);
        });
        this.updateIsPlay(true);
        BackgroundUtil.startContinuousTask(this.context);
        Logger.info(TAG, 'start success');
      } catch (error) {
        BackgroundUtil.stopContinuousTask(this.context!);
        Logger.error(TAG, `start failed,audioRenderer is undefined`);
      }
    }
  }

  /**
   * Pause music.
   */
  public async pause() {
    if (this.audioRenderer) {
      try {
        await this.audioRenderer.pause().catch((err: BusinessError) => {
          Logger.error(TAG, `pause failed,code is ${err.code},message is ${err.message}}`);
        });
        this.updateIsPlay(false);
        Logger.info(TAG, 'pause success');
      } catch (error) {
        Logger.error(TAG, `pause failed,audioRenderer is undefined`);
      }
    }
  }

  /**
   * Stop music
   */
  public async stop() {
    if (this.audioRenderer) {
      try {
        await this.audioRenderer.stop().catch((err: BusinessError) => {
          Logger.error(TAG, `stop failed,code is ${err.code},message is ${err.message}}`);
        });
        this.updateIsPlay(false);
        BackgroundUtil.stopContinuousTask(this.context!);
        this.audioRenderer.flush();
        this.isFirst = true;
        Logger.info(TAG, 'stop success');
      } catch (error) {
        Logger.error(TAG, `stop failed,audioRenderer is undefined`);
      }
    }
  }

  public async reset() {
    Logger.info(TAG, 'reset()');
    if (this.audioRenderer) {
      this.isFirst = true;
      this.currentOffset = this.initOffset;
      await this.stop();
      await this.play();
    }
  }

  /**
   * release audioRenderer
   */
  public async release() {
    if (this.audioRenderer && this.context) {
      try {
        await this.audioRenderer.release().catch((err: BusinessError) => {
          Logger.error(TAG, `release failed,code is ${err.code},message is ${err.message}}`);
        });
        this.avSessionController?.unregisterSessionListener();
        let audioRendererControllerMap: Map<audio.StreamUsage, AudioRendererController> | undefined =
          AppStorage.get('audioRendererControllerMap');
        if (!audioRendererControllerMap) {
          return;
        }
        audioRendererControllerMap.delete(this.audioStreamUsage);
        AppStorage.setOrCreate('audioRendererControllerMap', audioRendererControllerMap);
        BackgroundUtil.stopContinuousTask(this.context);
        Logger.info(TAG, 'release success');
      } catch (error) {
        Logger.error(TAG, `release failed,audioRenderer is undefined`);
      }
    }
  }

  public clearAudioRendererMap() {
    AppStorage.delete('audioRendererControllerMap');
  }
}