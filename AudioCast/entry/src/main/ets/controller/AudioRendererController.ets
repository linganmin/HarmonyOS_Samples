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
import { resourceManager } from '@kit.LocalizationKit';
import { audio } from '@kit.AudioKit';
import { fileIo } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AVSessionController } from './AVSessionController';
import { BackgroundUtil } from '../common/utils/BackgroundUtil';
import { SongItem, MusicPlayMode } from '../model/SongData';
import SongItemBuilder from '../common/utils/SongItemBuilder';
import { MediaTools } from '../common/utils/MediaTools';
import { Options, SecondBufferWalk } from '../common/utils/SecondBufferWalk';
import { Controller } from '../model/SongData';

const TAG = 'AudioRendererController';

export class AudioRendererController implements Controller {
  @Track state: number = 0;
  public audioRenderer?: audio.AudioRenderer;
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  private songItemBuilder: SongItemBuilder = new SongItemBuilder();
  private playMode: MusicPlayMode = MusicPlayMode.ORDER;
  private musicIndex: number = 0;
  private songList: SongItem[] = [];
  private initOffset: number = 0;
  private currentOffset: number = 0;
  private bufferRead: number = 0;
  private bufferNeedRead: number = 0;
  private avSessionController: AVSessionController | undefined = undefined;
  songRawFileDescriptor: resourceManager.RawFileDescriptor | undefined = undefined;
  curMs: number = 0;

  constructor() {
    let list: SongItem[] | undefined = AppStorage.get('songList');
    if (list) {
      this.songList = list;
    }
    this.songItemBuilder = new SongItemBuilder();
  }

  public static getInstance(): AudioRendererController {
    let audioRendererController: AudioRendererController | undefined = AppStorage.get('audioRendererController');
    if (!audioRendererController) {
      audioRendererController = new AudioRendererController();
      AppStorage.setOrCreate<AudioRendererController>('audioRendererController', audioRendererController);
    }
    return audioRendererController;
  }

  public async initAudioRenderer() {
    let audioRendererInfo: audio.AudioRendererInfo = {
      usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
      rendererFlags: 0
    };

    let audioRendererOptions: audio.AudioRendererOptions = {
      streamInfo: {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000,
        channels: audio.AudioChannel.CHANNEL_2,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      },
      rendererInfo: audioRendererInfo
    };
    try {
      let data = await audio.createAudioRenderer(audioRendererOptions);
      hilog.info(0x0000, TAG, 'Invoke createAudioRenderer succeeded.');
      this.audioRenderer = data;
      this.state = audio.AudioState.STATE_PREPARED;
    } catch (error) {
      hilog.error(0x0000, TAG, `Invoke createAudioRenderer failed, error is ${JSON.stringify(error)}`);
    }
  }

  public setAudioRendererCallbacks() {
    if (!this.audioRenderer) {
      hilog.error(0x0000, TAG, 'writeData fail.audioRenderer is undefined');
      return;
    }

    this.setWriteDataCallback();
    this.audioRenderer.on('stateChange', (state: audio.AudioState) => {
      this.state = state;
      switch (state) {
        case audio.AudioState.STATE_PREPARED:
          hilog.info(0x0000, TAG, 'AVPlayer state prepared called.');
          this.play();
          break;
        case audio.AudioState.STATE_STOPPED:
          hilog.info(0x0000, TAG, 'AVPlayer state stopped called.');
          this.setStop();
          break;
        default:
          hilog.info(0x0000, TAG, 'AVPlayer state unknown called.');
          break;
      }
    });
    try {
      this.audioRenderer.on('audioInterrupt', this.interruptCallback);
      this.audioRenderer.on('outputDeviceChangeWithInfo', this.outputDeviceChangeCallback);
    } catch (error) {
      hilog.error(0x0000, TAG, `audioRenderer on event failed, the error is: ${JSON.stringify(error)}`);
    }
  }

  public async setAvSessionCallback() {
    this.avSessionController = AppStorage.get('AVSessionController');
    this.musicIndex = AppStorage.get('selectIndex') || 0;
    await this.loadSongAssent();
  }

  private setWriteDataCallback() {
    if (!this.audioRenderer) {
      hilog.error(0x0000, TAG, 'writeData fail.audioRenderer is undefined');
      return;
    }
    let secondBufferWalk = SecondBufferWalk.getInstance().get();
    let bufferWalk = 0;
    let options: Options | undefined = undefined;
    try {
      this.audioRenderer.on('writeData', (buffer) => {
        if (!this.songRawFileDescriptor) {
          return;
        }
        options = {
          offset: this.currentOffset,
          length: buffer.byteLength
        };
        try {
          fileIo.readSync(this.songRawFileDescriptor.fd, buffer, options);
          this.currentOffset += buffer.byteLength;
          this.bufferRead = this.currentOffset - this.initOffset;
          bufferWalk += buffer.byteLength;
          hilog.info(0x0000, TAG, 'buffer.byteLength+bufferWalk+bufferRead: ' + buffer.byteLength +'%'+ bufferWalk + '%' + this.bufferRead);
          hilog.info(0x0000, TAG,
            `songRawFileDescriptor get successed` + 'bufferRead is ' + this.bufferRead + '///' + 'bufferNeedRead is ' +
            this.bufferNeedRead);
          if (this.bufferRead <= this.bufferNeedRead) {
            if (bufferWalk >= secondBufferWalk) {
              let curMs = MediaTools.getMsFromByteLength(this.bufferRead);
              this.seek(curMs);
              bufferWalk = 0;
            }
          } else {
            bufferWalk = 0;
            let curMs = MediaTools.getMsFromByteLength(this.songRawFileDescriptor.length);
            hilog.info(0x0000, TAG, 'setWriteDataCallback CurMs is ' + curMs);
            this.seek(curMs);
            this.setPlayNext();
          }
        } catch (error) {
          hilog.error(0x0000, TAG, `fileIO readSync fail the error is:${JSON.stringify(error)}`);
        }

        hilog.info(0x0000, TAG, 'writeData is calling. ');
      })
    } catch (error) {
      hilog.error(0x0000, TAG, `audioRenderer on event failed, the error is: ${JSON.stringify(error)}`);
    }
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
            this.setPause();
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
            this.setPlaying();
            break;
          default:
            break;
        }
      }
    }

  private outputDeviceChangeCallback: (deviceChangeInfo: audio.AudioStreamDeviceChangeInfo) => void =
    (deviceChangeInfo: audio.AudioStreamDeviceChangeInfo) => {
      hilog.info(0x0000, TAG, `DeviceInfo id: ${deviceChangeInfo.devices[0].id}`);
      hilog.info(0x0000, TAG, `DeviceInfo name: ${deviceChangeInfo.devices[0].name}`);
      hilog.info(0x0000, TAG, `DeviceInfo address: ${deviceChangeInfo.devices[0].address}`);
      hilog.info(0x0000, TAG,  `Device change reason: ${deviceChangeInfo.changeReason}`);
      if (deviceChangeInfo.changeReason === audio.AudioStreamDeviceChangeReason.REASON_OLD_DEVICE_UNAVAILABLE) {
        hilog.info(0x0000, TAG, `Device change reason: ${deviceChangeInfo.changeReason}`);
        this.setPause();
      }
    }

  async play(musicIndex: number = this.musicIndex) {
    if (!this.audioRenderer) {
      return;
    }
    if (musicIndex >= this.songList.length) {
      hilog.error(0x0000, TAG, `current musicIndex ${musicIndex}`);
      return;
    }
    BackgroundUtil.startContinuousTask(this.context);
    this.updateMusicIndex(musicIndex);
    await this.setStop();
    await this.setPlaying();
  }

  private async loadSongAssent() {
    let songItem = this.songList[this.musicIndex];
    await this.songItemBuilder.build(songItem);
    try {
      this.songRawFileDescriptor = await this.context?.resourceManager.getRawFd(songItem.pcmSrc);
    } catch (error) {
      hilog.error(0x0000, TAG, `getRawFd failed, the error is: ${JSON.stringify(error)}`);
    }
    if (!this.songRawFileDescriptor) {
      hilog.error(0x0000, TAG, `loadSongAssent faile : songRawFileDescriptor get failed`);
      return;
    }
    this.initOffset = this.songRawFileDescriptor.offset;
    this.currentOffset = this.initOffset;
    this.bufferNeedRead = this.songRawFileDescriptor.length;
    this.bufferRead = 0;
    AppStorage.setOrCreate('durationTime', this.getDuration());
  }

  private updateIsPlay(isPlay: boolean) {
    AppStorage.setOrCreate<boolean>('isPlay', isPlay);
    if (!this.avSessionController) {
      return;
    }
    this.avSessionController.setAvSessionState(isPlay);
  }

  private getDuration() {
    if (this.audioRenderer && this.songRawFileDescriptor) {
      return MediaTools.getMsFromByteLength(this.songRawFileDescriptor.length);
    }
    return 0;
  }

  public async setPlaying() {
    if (this.audioRenderer) {
      try {
        await this.audioRenderer.start();
        this.updateIsPlay(true);
        BackgroundUtil.startContinuousTask(this.context);
        hilog.info(0x0000, TAG, 'start success');
      } catch (error) {
        hilog.error(0x0000, TAG, `start failed,audioRenderer is undefined,the error is:${JSON.stringify(error)}`);
      }
    }
  }

  public async setPause() {
    if (this.audioRenderer) {
      try {
        await this.audioRenderer.pause();
        this.updateIsPlay(false);
        hilog.info(0x0000, TAG, 'pause success');
      } catch (error) {
        hilog.error(0x0000, TAG, `pause failed,audioRenderer is undefined,the error is:${JSON.stringify(error)}`);
      }
    }
  }

  public seek(ms: number) {
    this.curMs = ms;
    AppStorage.setOrCreate('currentTime', this.curMs);
    if (!this.avSessionController) {
      return;
    }
    this.avSessionController.setAvSessionPosition(ms);
    this.currentOffset = this.initOffset + MediaTools.getOffsetFromTime(this.curMs);
  }

  public async setPlayNext() {
    let selectIndex = this.musicIndex;
    if (!this.audioRenderer) {
      hilog.error(0x0000, TAG, 'audioRenderer is undefined');
      return;
    }
    await this.setStop();
    await this.initAudioRenderer();
    switch (this.playMode) {
      case MusicPlayMode.SINGLE_CYCLE:
        break;
      case MusicPlayMode.ORDER:
        if (selectIndex === this.songList.length - 1) {
          selectIndex = 0;
        } else {
          selectIndex += 1;
        }
        break;
      case MusicPlayMode.RANDOM:
        this.playRandom();
        break;
      default:
        break;
    }
    this.updateMusicIndex(selectIndex);
  }

  private playRandom() {
    let num = Math.round(Math.random() * (this.songList.length - 1));
    if (this.musicIndex === num) {
      this.playRandom();
    } else {
      this.updateMusicIndex(num);
      this.initAudioRenderer()
      this.play(num);
    }
  }

  public async setStop() {
    if (this.audioRenderer) {
      try {
        await this.audioRenderer.stop();
        this.curMs = 0;
        this.updateIsPlay(false);
        this.audioRenderer.flush();
        AppStorage.setOrCreate('currentTime', 0);
      } catch (e) {
        hilog.error(0x0000, TAG, `stop failed,audioRenderer is undefined`);
      }
    }
  }

  public async release() {
    if (this.audioRenderer && this.context) {
      try {
        await this.audioRenderer.release();
        this.unregisterAudioRendererListener();
        BackgroundUtil.stopContinuousTask(this.context);
        AppStorage.setOrCreate<AudioRendererController>('audioRendererController', undefined);
      } catch (e) {
        hilog.error(0x0000, TAG, `release failed,audioRenderer is undefined`);
      }
    }
  }

  public updateMusicIndex(musicIndex: number) {
    if (this.musicIndex !== musicIndex) {
      this.musicIndex = musicIndex;
      AppStorage.setOrCreate('selectIndex', musicIndex);
    }
    if (!this.avSessionController) {
      return;
    }
    this.avSessionController.setAVMetadata(false);
  }

  async unregisterAudioRendererListener() {
    if (!this.audioRenderer) {
      return;
    }
    try {
      this.audioRenderer.off('stateChange');
      this.audioRenderer.off('writeData');
      this.audioRenderer.off('outputDeviceChangeWithInfo');
      this.audioRenderer.off('audioInterrupt');
    } catch (error) {
      hilog.error(0x0000, TAG, `audioRenderer off event failed, the error is: ${JSON.stringify(error)}`);
    }
  }
}