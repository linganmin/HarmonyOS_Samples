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

import { media } from '@kit.MediaKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonConstants as Const } from '../common/CommonConstants';
import Logger from '../../../common/Logger';
import { hilog } from '@kit.PerformanceAnalysisKit';

const context = AppStorage.get('context') as UIContext;

export class AudioRecorderDemo {
  private avRecorder: media.AVRecorder | undefined = undefined;
  public maxAmplitude: number = 0;
  public time: number = 0;
  private avProfile: media.AVRecorderProfile = {
    audioBitrate: Const.AUDIO_BITRATE,
    audioChannels: Const.AUDIO_CHANNELS,
    audioCodec: media.CodecMimeType.AUDIO_AAC,
    audioSampleRate: Const.AUDIO_SAMPLE_RATE,
    fileFormat: media.ContainerFormatType.CFT_MPEG_4
  };
  private avConfig: media.AVRecorderConfig = {
    audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
    profile: this.avProfile,
    url: 'fd://35'
  };

  // 设置录音回调。
  setAudioRecorderCallback(): void {
    try {
      if (this.avRecorder !== undefined) {
        this.avRecorder.on('stateChange', (state: media.AVRecorderState, _: media.StateChangeReason) => {
          Logger.info(`AudioRecorder current state is ${state}`);
        })
        this.avRecorder.on('error', (err: BusinessError) => {
          Logger.error(`AudioRecorder failed, code is ${err.code}, message is ${err.message}`);
        })
      }
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'AudioRecorderDemo',
        `setAudioRecorderCallback failed. error code=${error.code}, message=${error.message}`);
    }
  }

  // 开始录制对应的流程
  async startRecordingProcess(): Promise<void> {
    try {
      if (this.avRecorder !== undefined) {
        await this.avRecorder.release();
        this.avRecorder = undefined;
      }
      // 1.创建录制实例
      this.avRecorder = await media.createAVRecorder();
      this.setAudioRecorderCallback();
      // 2.获取录制文件fd赋予avConfig里的url；参考FilePicker文档
      const path = context.getHostContext()!.filesDir;
      const filepath = path + '/01.mp3';

      const file = fileIo.openSync(filepath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      const fdNumber = file.fd;
      this.avConfig.url = 'fd://' + fdNumber;
      // 3.配置录制参数完成准备工作
      await this.avRecorder.prepare(this.avConfig);
      // 4.开始录制
      await this.avRecorder.start();

      // 通过getAudioCapturerMaxAmplitude接口获取声音振幅大小。
      this.time = setInterval(() => {
        this.avRecorder!.getAudioCapturerMaxAmplitude((_: BusinessError, amplitude: number) => {
          this.maxAmplitude = amplitude;
        });
      }, Const.COLUMN_HEIGHT);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'AudioRecorderDemo',
        `startRecordingProcess failed. error code=${error.code}, message=${error.message}`);
    }
  }

  // 暂停录制对应的流程
  async pauseRecordingProcess(): Promise<void> {
    try {
      // 仅在started状态下调用pause为合理状态切换
      if (this.avRecorder !== undefined && this.avRecorder.state === 'started') {
        await this.avRecorder.pause();
      }
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'AudioRecorderDemo',
        `pauseRecordingProcess failed. error code=${error.code}, message=${error.message}`);
    }
  }

  // 恢复录制对应的流程
  async resumeRecordingProcess(): Promise<void> {
    try {
      // 仅在paused状态下调用resume为合理状态切换
      if (this.avRecorder !== undefined && this.avRecorder.state === 'paused') {
        await this.avRecorder.resume();
      }
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'AudioRecorderDemo',
        `resumeRecordingProcess failed. error code=${error.code}, message=${error.message}`);
    }
  }

  // 停止录制对应的流程
  async stopRecordingProcess(): Promise<void> {
    try {
      if (this.avRecorder !== undefined) {
        // 1. 停止录制，仅在started或者paused状态下调用stop为合理状态切换
        if (this.avRecorder.state === 'started' || this.avRecorder.state === 'paused') {
          await this.avRecorder.stop();
          clearInterval(this.time);
        }
        // 2.重置
        await this.avRecorder.reset();
        // 3.释放录制实例
        await this.avRecorder.release();
        this.avRecorder = undefined;
      }
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'AudioRecorderDemo',
        `stopRecordingProcess failed. error code=${error.code}, message=${error.message}`);
    }
  }
}

// 音频播放
export class AVPlayerDemo {
  count: number = 0;
  // 用于区分模式是否支持seek操作
  isSeek: boolean = true;

  // 注册avplayer回调函数
  setAVPlayerCallback(avPlayer: media.AVPlayer): void {
    // seek操作结果回调函数
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      Logger.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    })
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用 reset接口触发重置流程
    avPlayer.on('error', (err: BusinessError) => {
      Logger.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      // 调用reset重置资源，触发idle状态
      avPlayer.reset().catch((error: BusinessError) => {
        hilog.error(0x0000, 'animation-collection', `reset error. Cause: ${error.code}`);
      });
    })
    // 状态机变化回调函数
    avPlayer.on('stateChange', async (state: string, _: media.StateChangeReason) => {
      switch (state) {
        case 'idle':
          Logger.info('AVPlayer state idle called.');
          avPlayer.release().catch((error: BusinessError) => {
            hilog.error(0x0000, 'animation-collection', `release error. Cause: ${error.code}`);
          });
          break;
        case 'initialized':
          Logger.info('AVPlayer state initialized called.');
          avPlayer.prepare().catch((error: BusinessError) => {
            hilog.error(0x0000, 'animation-collection', `prepare error. Cause: ${error.code}`);
          });
          break;
        case 'prepared':
          Logger.info('AVPlayer state prepared called.');
          avPlayer.play().catch((error: BusinessError) => {
            hilog.error(0x0000, 'animation-collection', `play error. Cause: ${error.code}`);
          });
          break;
        case 'playing':
          Logger.info('AVPlayer state playing called.');
          this.count++;
          break;
        case 'paused':
          Logger.info('AVPlayer state paused called.');
          avPlayer.play().catch((error: BusinessError) => {
            hilog.error(0x0000, 'animation-collection', `play error. Cause: ${error.code}`);
          });
          break;
        case 'completed':
          Logger.info('AVPlayer state completed called.');
          avPlayer.stop().catch((error: BusinessError) => {
            hilog.error(0x0000, 'animation-collection', `stop error. Cause: ${error.code}`);
          });
          break;
        case 'stopped':
          Logger.info('AVPlayer state stopped called.');
          avPlayer.reset().catch((error: BusinessError) => {
            hilog.error(0x0000, 'animation-collection', `reset error. Cause: ${error.code}`);
          });
          break;
        case 'released':
          Logger.info('AVPlayer state released called.');
          break;
        default:
          Logger.info('AVPlayer state unknown called.');
          break;
      }
    })
  }

  // 使用fs文件系统打开沙箱地址获取媒体文件地址并通过url属性进行播放示例
  async avPlayerUrlDemo(): Promise<void> {
    try {
      // 创建avPlayer实例对象
      const avPlayer: media.AVPlayer = await media.createAVPlayer();
      // 创建状态机变化回调函数
      this.setAVPlayerCallback(avPlayer);
      let fdPath = 'fd://';
      // 通过UIAbilityContext获取沙箱地址filesDir
      const pathDir = context.getHostContext()!.filesDir;
      const path = pathDir + '/01.mp3';
      // 打开相应的资源文件地址获取fd，并为url赋值触发initialized状态机上报
      const file = await fileIo.open(path);
      fdPath = fdPath + '' + file.fd;
      this.isSeek = true;
      avPlayer.url = fdPath;
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'AVPlayerDemo', `avPlayerUrlDemo failed. error code=${error.code}, message=${error.message}`);
    }
  }
}
