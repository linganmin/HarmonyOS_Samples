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
import { MusicPlayMode, SECOND_BUFFER_WALK, Options, SILENT_ID } from '../songdatacontroller/PlayerData';
import { SongItem } from '../songdatacontroller/SongData';
import { BackgroundUtil } from './BackgroundUtil';
import { MediaTools } from './MediaTools';
import { Logger } from './Logger';
import { PreferencesUtil } from './PreferencesUtil';

const TAG = 'AudioRendererController';

export class AudioRendererController {
  public audioRenderer?: audio.AudioRenderer;
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  private songItemBuilder: SongItemBuilder = new SongItemBuilder();
  private playMode: MusicPlayMode = MusicPlayMode.ORDER;
  private isFirst: boolean = true;
  private musicIndex: number = 0;
  private songList: SongItem[] = [];
  private initOffset: number = 0;
  private currentOffset: number = 0;
  private bufferRead: number = 0;
  private bufferNeedRead: number = 0;
  private songRawFileDescriptor: resourceManager.RawFileDescriptor | undefined = undefined;
  private curMs: number = 0;
  private avSessionController: AVSessionController | undefined = undefined;

  constructor() {
    let list: SongItem[] | undefined = AppStorage.get('songList');
    if (list) {
      this.songList = list;
    }
    this.songItemBuilder = new SongItemBuilder();
    this.initAudioRenderer();
  }

  public static getInstance(): AudioRendererController {
    let audioRendererController: AudioRendererController | undefined = AppStorage.get('audioRendererController');
    if (!audioRendererController) {
      audioRendererController = new AudioRendererController();
      AppStorage.setOrCreate<AudioRendererController>('audioRendererController', audioRendererController);
    }
    return audioRendererController;
  }

  private initAudioRenderer() {
    let audioStreamInfo: audio.AudioStreamInfo = {
      samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000,
      channels: audio.AudioChannel.CHANNEL_2,
      sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
      encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
    };

    let audioRendererInfo: audio.AudioRendererInfo = {
      usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
      rendererFlags: 0
    };

    let audioRendererOptions: audio.AudioRendererOptions = {
      streamInfo: audioStreamInfo,
      rendererInfo: audioRendererInfo
    };

    audio.createAudioRenderer(audioRendererOptions, (err, data) => {
      if (err) {
        Logger.error(TAG, `Invoke createAudioRenderer failed, code is ${err.code}, message is ${err.message}`);
        return;
      } else {
        Logger.info(TAG, 'Invoke createAudioRenderer succeeded.');
        this.audioRenderer = data;
        this.setAudioRendererCallbacks();
      }
    });
  }

  private setAudioRendererCallbacks() {
    this.setAvSessionCallback();
    this.setWriteDataCallback();
    this.setInterruptCallback();
    this.setOutputDeviceChangeCallback();
    this.setSilentModeAndMixWithOthersFromPrefer();
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
    let secondBufferWalk = SECOND_BUFFER_WALK;
    let bufferWalk = 0;
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
      bufferWalk += buffer.byteLength;
      Logger.info(TAG,
        `songRawFileDescriptor get successed` + 'bufferRead is ' + this.bufferRead + '///' + 'bufferNeedRead is ' +
        this.bufferNeedRead);
      if (this.bufferRead <= this.bufferNeedRead) {
        if (bufferWalk >= secondBufferWalk) { // 1s seek
          let curMs = MediaTools.getMsFromByteLength(this.bufferRead);
          this.seek(curMs);
          Logger.info(TAG, 'curTime is ' + MediaTools.msToCountdownTime(curMs));
          bufferWalk = 0;
        }
      } else {
        bufferWalk = 0;
        let curMs = MediaTools.getMsFromByteLength(this.songRawFileDescriptor.length);
        Logger.info(TAG, 'setWriteDataCallback CurMs is ' + curMs);
        this.seek(curMs);
        this.playNext();
      }
      Logger.info(TAG, 'writeData is calling. ');
    })
  }

  // [Start set_interrupt_callback]
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
    }

  // [StartExclude set_interrupt_callback]
  // [Start set_output_device_change]
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
    }

  // [End set_output_device_change]
  // [EndExclude set_interrupt_callback]

  private async setSilentModeAndMixWithOthersFromPrefer() {
    if (!this.audioRenderer || !this.context) {
      return;
    }
    let formIds: string[] = await PreferencesUtil.getInstance().getFormIds(this.context);
    let isSupportSilent = false;
    if (formIds.includes(SILENT_ID)) {
      isSupportSilent = true;
    } else {
      isSupportSilent = false;
    }
    AppStorage.setOrCreate('isSilentMode', isSupportSilent);
    this.audioRenderer.setSilentModeAndMixWithOthers(isSupportSilent);
  }

  public async setSilentModeAndMixWithOthers(isSupportSilent: boolean = false) {
    if (!this.audioRenderer || !this.context) {
      return;
    }
    let audioManger = audio.getAudioManager();
    let audioSessionManager: audio.AudioSessionManager = audioManger.getSessionManager();
    let strategy: audio.AudioSessionStrategy = {
      concurrencyMode: audio.AudioConcurrencyMode.CONCURRENCY_PAUSE_OTHERS
    };

    let formIds: string[] = await PreferencesUtil.getInstance().getFormIds(this.context);
    if (isSupportSilent) {
      if (!formIds.includes(SILENT_ID)) {
        await PreferencesUtil.getInstance().addFormId(this.context, SILENT_ID);
      }
      this.audioRenderer.setSilentModeAndMixWithOthers(isSupportSilent);
      // After using AudioSession, the system sends INTERRUPT_INT-REUME to the previously interrupted audio stream.
      audioSessionManager.deactivateAudioSession().then(() => {
        Logger.info(TAG, 'deactivateAudioSession SUCCESS');
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `ERROR: ${err}`);
      });
    } else {
      // AudioSession needs to be activated first, and then unmute.
      audioSessionManager.activateAudioSession(strategy).then(() => {
        Logger.info(TAG, 'activateAudioSession SUCCESS');
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `ERROR: ${err}`);
      });
      if (formIds.includes(SILENT_ID)) {
        await PreferencesUtil.getInstance().removeFormId(this.context, SILENT_ID);
      }
      this.audioRenderer.setSilentModeAndMixWithOthers(isSupportSilent);
    }
    AppStorage.setOrCreate('isSilentMode', isSupportSilent);
  }

  // [End set_interrupt_callback]

  // [Start play_music]
  /**
   * Play music by index.
   *
   * @param musicIndex
   */
  async play(musicIndex: number = this.musicIndex) {
    if (!this.audioRenderer) {
      return;
    }
    if (musicIndex >= this.songList.length) {
      Logger.error(TAG, `current musicIndex ${musicIndex}`);
      return;
    }
    BackgroundUtil.startContinuousTask(this.context);
    this.updateMusicIndex(musicIndex);
    if (this.isFirst) {
      this.isFirst = false;
      await this.loadSongAssent();
      await this.stop();
      await this.start();
    } else {
      await this.stop();
      this.updateIsPlay(false);
      await this.reset();
    }
  }

  // [StartExclude play_music]
  private async loadSongAssent() {
    await this.songItemBuilder.build(this.songList[this.musicIndex]);
    this.songRawFileDescriptor = this.songItemBuilder.getRawFileDescriptor()
    if (!this.songRawFileDescriptor) {
      Logger.error(TAG, `loadSongAssent faile : songRawFileDescriptor get failed`);
      return;
    }
    this.initOffset = this.songRawFileDescriptor.offset;
    this.currentOffset = this.initOffset;
    this.bufferNeedRead = this.songRawFileDescriptor.length;
    this.bufferRead = 0;
    AppStorage.setOrCreate('totalTime', MediaTools.msToCountdownTime(this.getDuration()));
    AppStorage.setOrCreate('totalMsTime', this.getDuration());
    AppStorage.setOrCreate('progressMax', this.getDuration());
  }

  /**
   * Get whether the music is played for the first.
   *
   * @returns isFirst
   */
  public getFirst() {
    return this.isFirst;
  }

  /**
   * Set music play mode.
   *
   * @param playMode
   */
  public setPlayModel(playMode: MusicPlayMode) {
    this.playMode = playMode;
    if (!this.avSessionController) {
      return;
    }
    this.avSessionController.setPlayModeToAVSession();
    Logger.info(TAG, 'setPlayModel mode: ' + this.playMode);
  }

  /**
   * Get music play mode.
   *
   * @returns playMode.
   */
  public getPlayMode(): MusicPlayMode {
    return this.playMode;
  }

  private updateIsPlay(isPlay: boolean) {
    AppStorage.setOrCreate<boolean>('isPlay', isPlay);
    if (!this.avSessionController) {
      return;
    }
    this.avSessionController.setPlayState(isPlay);
  }

  private getDuration() {
    if (this.audioRenderer && this.songRawFileDescriptor) {
      AppStorage.setOrCreate('totalByteLength', this.songRawFileDescriptor.length);
      return MediaTools.getMsFromByteLength(this.songRawFileDescriptor.length);
    }
    return 0;
  }

  // [EndExclude play_music]
  /**
   * start music.
   */
  public async start() {
    if (this.audioRenderer) {
      try {
        await this.audioRenderer.start().catch((err: BusinessError) => {
          Logger.error(TAG, `start failed,code is ${err.code},message is ${err.message}`);
        })
        this.updateIsPlay(true);
        BackgroundUtil.startContinuousTask(this.context);
        Logger.info(TAG, 'start success');
      } catch (e) {
        Logger.error(TAG, `start failed,audioRenderer is undefined`);
      }
    }
  }

  // [End play_music]

  /**
   * Pause music.
   */
  public async pause() {
    if (this.audioRenderer) {
      try {
        await this.audioRenderer.pause().catch((err: BusinessError) => {
          Logger.error(TAG, `pause failed,code is ${err.code},message is ${err.message}`);
        })
        this.updateIsPlay(false);
        Logger.info(TAG, 'pause success');
      } catch (e) {
        Logger.error(TAG, `pause failed,audioRenderer is undefined`);
      }
    }
  }

  /**
   * Seek play music.
   *
   * @param ms.
   */
  public seek(ms: number) {
    this.curMs = ms;
    AppStorage.setOrCreate('progress', this.curMs);
    AppStorage.setOrCreate('currentTime', MediaTools.msToCountdownTime(this.curMs));
    if (!this.avSessionController) {
      return;
    }
    this.avSessionController.setProgressState(ms);
    this.currentOffset = this.initOffset + MediaTools.getOffsetFromTime(this.curMs);
  }

  public async playNext() {
    Logger.info(TAG, 'playNext Index:' + this.musicIndex + ', length-1:' + (this.songList.length - 1));
    if (!this.audioRenderer) {
      Logger.error(TAG, 'audioRenderer is undefined');
      return;
    }
    await this.stop();
    if (this.playMode === MusicPlayMode.SINGLE_CYCLE) {
      this.isFirst = false;
    } else {
      this.isFirst = true;
    }
    switch (this.playMode) {
      case MusicPlayMode.SINGLE_CYCLE:
        this.play(this.musicIndex);
        break;
      case MusicPlayMode.ORDER:
        if (this.musicIndex === this.songList.length - 1) {
          this.musicIndex = 0;
        } else {
          this.musicIndex += 1;
        }
        this.play(this.musicIndex);
        break;
      case MusicPlayMode.RANDOM:
        this.playRandom();
        break;
      default:
        break;
    }
  }

  /**
   * Play previous music.
   */
  public async playPrevious() {
    Logger.info(TAG, 'playPrevious Index:' + this.musicIndex + ', length-1:' + (this.songList.length - 1));
    if (!this.audioRenderer) {
      Logger.error(TAG, 'audioRenderer is undefined');
      return;
    }
    await this.stop();
    if (this.playMode === MusicPlayMode.SINGLE_CYCLE) {
      this.isFirst = false;
    } else {
      this.isFirst = true;
    }
    switch (this.playMode) {
      case MusicPlayMode.SINGLE_CYCLE:
        this.play(this.musicIndex);
        break;
      case MusicPlayMode.ORDER:
        if (this.musicIndex === 0) {
          this.musicIndex = this.songList.length - 1;
        } else {
          this.musicIndex -= 1;
        }
        this.play(this.musicIndex);
        break;
      case MusicPlayMode.RANDOM:
        this.playRandom();
        break;
      default:
        break;
    }
  }

  private playRandom() {
    let num = Math.round(Math.random() * (this.songList.length - 1));
    if (this.musicIndex === num) {
      this.playRandom();
    } else {
      this.updateMusicIndex(num);
      this.play(num);
    }
    Logger.info(TAG, 'play Random:' + this.musicIndex);
  }

  /**
   * Stop music
   */
  public async stop() {
    if (this.audioRenderer) {
      try {
        await this.audioRenderer.stop().catch((err: BusinessError) => {
          Logger.error(TAG, `stop failed,code is ${err.code},message is ${err.message}`);
        })
        this.curMs = 0;
        this.updateIsPlay(false);
        this.audioRenderer.flush();
        AppStorage.setOrCreate('currentTime', "00:00");
        AppStorage.setOrCreate('progress', 0);
        Logger.info(TAG, 'stop success');
      } catch (e) {
        Logger.error(TAG, `stop failed,audioRenderer is undefined`);
      }
    }
  }

  private async reset() {
    Logger.info(TAG, 'reset()');
    if (this.audioRenderer) {
      this.isFirst = true;
      this.play(this.musicIndex);
    }
  }

  /**
   * release audioRenderer
   */
  // [Start release]
  public async release() {
    if (this.audioRenderer && this.context) {
      try {
        await this.audioRenderer.release().catch((err: BusinessError) => {
          Logger.error(TAG, `release failed,code is ${err.code},message is ${err.message}`);
        })
        this.avSessionController?.unregisterSessionListener();
        BackgroundUtil.stopContinuousTask(this.context);
        Logger.info(TAG, 'release success');
      } catch (e) {
        Logger.error(TAG, `release failed,audioRenderer is undefined`);
      }
    }
  }

  // [End release]
  private updateMusicIndex(musicIndex: number) {
    Logger.info(TAG, 'updateMusicIndex ===> ' + musicIndex);
    AppStorage.setOrCreate('selectIndex', musicIndex);
    if (this.musicIndex !== musicIndex) {
      this.musicIndex = musicIndex;
    }
    if (!this.avSessionController) {
      return;
    }
    Logger.info(TAG, 'this.session !== undefined ');
    this.avSessionController.setAVMetadata();
    this.avSessionController.getAndUpdateFavoriteState(this.musicIndex.toString());
  }
}