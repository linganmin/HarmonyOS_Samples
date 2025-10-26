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
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../utils/Logger';
import { SizeChangeListener } from '../utils/SizeChangeInterface';
import { resourceManager } from '@kit.LocalizationKit';

const TAG: string = 'AVPlayerDemo';

export class AVPlayerDemo {
  private count: number = 0;
  private surfaceID: string = ''; // surfaceID用于播放画面显示，具体的值需要通过XComponent接口获取，相关文档链接见上面XComponent创建方法
  private isSeek: boolean = true; // 用于区分模式是否支持seek操作
  private fileSize: number = -1;
  private fd: number = 0;
  private avPlayer: media.AVPlayer | undefined = undefined
  private UIContext: UIContext

  constructor(uiContext: UIContext) {
    this.UIContext = uiContext
  }

  // 注册avplayer回调函数
  setAVPlayerCallback(avPlayer: media.AVPlayer, callback: SizeChangeListener) {
    // startRenderFrame首帧渲染回调函数
    Logger.debug(TAG, 'setAVPlayerCallback ... ')
    avPlayer.on('startRenderFrame', () => {
      Logger.info(TAG, `AVPlayer start render frame`);
    })
    // seek操作结果回调函数
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      Logger.info(TAG, `AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    })
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用reset接口触发重置流程
    avPlayer.on('error', (err: BusinessError) => {
      Logger.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      avPlayer.reset() // 调用reset重置资源，触发idle状态
        .catch((err: BusinessError) => {
          Logger.error(`avPlayer reset failed, code=${err.code}, message=${err.message}`)
        })
    })
    // 状态机变化回调函数
    avPlayer.on('stateChange', async (state: string, _reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          Logger.info(TAG, 'AVPlayer state idle called.');
          avPlayer.release() // 调用release接口销毁实例对象
            .catch((err: BusinessError) => {
              Logger.error(`avPlayer release failed, code=${err.code}, message=${err.message}`)
            })
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          Logger.info(TAG, 'AVPlayer state initialized called.');
          // 设置显示画面，当播放的资源为纯音频时无需设置
          Logger.debug(TAG, 'surfaceID ' + this.surfaceID)
          avPlayer.surfaceId = this.surfaceID;

          avPlayer.prepare()
            .catch((err: BusinessError) => {
              Logger.error(`avPlayer prepare failed, code=${err.code}, message=${err.message}`)
            })
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          Logger.info(TAG, 'AVPlayer state prepared called.');
          avPlayer.play() // 调用播放接口开始播放
            .catch((err: BusinessError) => {
              Logger.error(`avPlayer play failed, code=${err.code}, message=${err.message}`)
            })
          Logger.warn(TAG, ' avPlayer surface size ' + avPlayer.width + ' ' + avPlayer.height)
          callback.onChange(avPlayer.width, avPlayer.height)

          break;
        case 'playing': // play成功调用后触发该状态机上报
          Logger.info(TAG, 'AVPlayer state playing called.');
          if (this.count !== 0) {
            if (this.isSeek) {
              Logger.info(TAG, 'AVPlayer start to seek.');
              avPlayer.seek(avPlayer.duration); //seek到视频末尾
            } else {
              // 当播放模式不支持seek操作时继续播放到结尾
              Logger.info(TAG, 'AVPlayer wait to play end.');
            }
          } else {
            avPlayer.pause() // 调用暂停接口暂停播放
              .catch((err: BusinessError) => {
                Logger.error(`avPlayer pause failed, code=${err.code}, message=${err.message}`)
              })
          }
          this.count++;
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          Logger.info(TAG, 'AVPlayer state paused called.');
          avPlayer.play() // 再次播放接口开始播放
            .catch((err: BusinessError) => {
              Logger.error(`avPlayer play failed, code=${err.code}, message=${err.message}`)
            })
          break;
        case 'completed': // 播放结束后触发该状态机上报
          Logger.info(TAG, 'AVPlayer state completed called.');
          avPlayer.stop() //调用播放结束接口
            .catch((err: BusinessError) => {
              Logger.error(`avPlayer stop failed, code=${err.code}, message=${err.message}`)
            })
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          Logger.info(TAG, 'AVPlayer state stopped called.');
          avPlayer.reset() // 调用reset接口初始化avplayer状态
            .catch((err: BusinessError) => {
              Logger.error(`avPlayer reset failed, code=${err.code}, message=${err.message}`)
            })
          break;
        case 'released':
          Logger.info(TAG, 'AVPlayer state released called.');
          break;
        default:
          Logger.info(TAG, 'AVPlayer state unknown called.');
          break;
      }
    })
  }

  private callback: SizeChangeListener = {
    onChange: (_width: number, _height: number): void => {

    }
  }

  setCallBack(callback: SizeChangeListener) {
    this.callback = callback;
  }

  // 以下demo为使用fs文件系统打开沙箱地址获取媒体文件地址并通过url属性进行播放示例
  async avPlayerUrlDemo(surfaceId: string, filePath: string, callBack: SizeChangeListener) {
    Logger.debug(TAG, 'avPlayerUrlDemo ..... surface id ' + surfaceId);
    this.surfaceID = surfaceId;
    // 创建avPlayer实例对象
    // this.avPlayer = await media.createAVPlayer();
    await media.createAVPlayer()
      .then((data: media.AVPlayer) => {
        this.avPlayer = data;
        // 创建状态机变化回调函数
        this.setAVPlayerCallback(data, callBack);
      })
      .catch((err: BusinessError) => {
        Logger.error(`createAVPlayer failed, code=${err.code}, message=${err.message}`)
      })
    let fdPath = 'fd://';
    // 通过UIAbilityContext获取沙箱地址filesDir，以Stage模型为例
    // 打开相应的资源文件地址获取fd，并为url赋值触发initialized状态机上报
    await fileIo.open(filePath, fileIo.OpenMode.READ_ONLY)
      .then((data: fileIo.File) => {
        // let pathDir = context.filesDir +''+'VID_20240805_094821.mp4';
        // Logger.debug(TAG,pathDir)
        fdPath = fdPath + '' + data.fd;
        this.isSeek = true; // 支持seek操作
        this.avPlayer!.url = fdPath;
      })
      .catch((err: BusinessError) => {
        Logger.error(`fileIo open failed, code=${err.code}, message=${err.message}`)
      })
  }

  // 以下demo为使用资源管理接口获取打包在HAP内的媒体资源文件并通过fdSrc属性进行播放示例
  async avPlayerFdSrcDemo() {
    // 创建avPlayer实例对象
    // this.avPlayer = await media.createAVPlayer();
    await media.createAVPlayer()
      .then((data: media.AVPlayer) => {
        this.avPlayer = data;
        // 创建状态机变化回调函数
        this.setAVPlayerCallback(data, this.callback);
      })
      .catch((err: BusinessError) => {
        Logger.error(`createAVPlayer failed, code=${err.code}, message=${err.message}`)
      })
    // 通过UIAbilityContext的resourceManager成员的getRawFd接口获取媒体资源播放地址
    // 返回类型为{fd,offset,length},fd为HAP包fd地址，offset为媒体资源偏移量，length为播放长度
    let context = this.UIContext.getHostContext() as common.UIAbilityContext;
    await context.resourceManager.getRawFd('H264_AAC.mp4')
      .then((data: resourceManager.RawFileDescriptor) => {
        let avFileDescriptor: media.AVFileDescriptor = { fd: data.fd, offset: data.offset, length: data.length };
        this.isSeek = true; // 支持seek操作
        // 为fdSrc赋值触发initialized状态机上报
        this.avPlayer!.fdSrc = avFileDescriptor;
      })
      .catch((err: BusinessError) => {
        Logger.error(`setPreferredOrientation failed, code=${err.code}, message=${err.message}`)
      })
  }

  // 以下demo为使用fs文件系VideoPage.ets统打开沙箱地址获取媒体文件地址并通过dataSrc属性进行播放(seek模式)示例
  async avPlayerDataSrcSeekDemo() {
    // 创建avPlayer实例对象
    // let avPlayer: media.AVPlayer = await media.createAVPlayer();
    await media.createAVPlayer()
      .then((avPlayer: media.AVPlayer) => {
        this.avPlayer = avPlayer;
        // 创建状态机变化回调函数
        this.setAVPlayerCallback(avPlayer, this.callback);
      })
      .catch((err: BusinessError) => {
        Logger.error(`createAVPlayer failed, code=${err.code}, message=${err.message}`)
      })
    // dataSrc播放模式的的播放源地址，当播放为Seek模式时fileSize为播放文件的具体大小，下面会对fileSize赋值
    let src: media.AVDataSrcDescriptor = {
      fileSize: -1,
      callback: (buf: ArrayBuffer, length: number, pos: number | undefined) => {
        let num = 0;
        if (buf == undefined || length == undefined || pos == undefined) {
          return -1;
        }
        try {
          num = fileIo.readSync(this.fd, buf, { offset: pos, length: length });
        } catch (error) {
          let err = error as BusinessError;
          Logger.error(`fileIo  failed, code=${err.code}, message=${err.message}`);
        }
        if (num > 0 && (this.fileSize >= pos)) {
          return num;
        }
        return -1;
      }
    }
    let context = this.UIContext.getHostContext() as common.UIAbilityContext;
    // 通过UIAbilityContext获取沙箱地址filesDir，以Stage模型为例
    let pathDir = context.filesDir;
    let path = pathDir + '/H264_AAC.mp4';
    await fileIo.open(path)
      .then((file: fileIo.File) => {
        this.fd = file.fd;
      })
      .catch((err: BusinessError) => {
        Logger.error(`fileIo open failed, code=${err.code}, message=${err.message}`)
      })
    try {
      // 获取播放文件的大小
      this.fileSize = fileIo.statSync(path).size;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(`setColorMode failed, code=${err.code}, message=${err.message}`);
    }
    src.fileSize = this.fileSize;
    this.isSeek = true; // 支持seek操作
    this.avPlayer!.dataSrc = src;
  }

  // 以下demo为使用fs文件系统打开沙箱地址获取媒体文件地址并通过dataSrc属性进行播放(No seek模式)示例
  async avPlayerDataSrcNoSeekDemo(surfaceId: string, filePath: string) {
    this.surfaceID = surfaceId
    // 创建状态机变化回调函数

    // let file = await fileIo.open(filePath, fileIo.OpenMode.READ_ONLY);
    await fileIo.open(filePath, fileIo.OpenMode.READ_ONLY)
      .then((file: fileIo.File) => {
        if (!file) {
          Logger.error(TAG, 'player inputFile is null');
        }
        try {
          let inputFileState = fileIo.statSync(file.fd);
          if (inputFileState.size <= 0) {
            Logger.error(TAG, 'player inputFile size is 0');
          }
          Logger.info(TAG, 'inputFileState size ' + inputFileState.size);
        } catch (error) {
          let err = error as BusinessError;
          Logger.error(`setColorMode failed, code=${err.code}, message=${err.message}`);
        }
        this.fd = file.fd;
      })
      .catch((err: BusinessError) => {
        Logger.error(`setPreferredOrientation failed, code=${err.code}, message=${err.message}`)
      })
    Logger.debug(TAG, 'fd --- ' + this.fd);
    let src: media.AVDataSrcDescriptor = {
      fileSize: -1,
      callback: (buf: ArrayBuffer, length: number, pos: number | undefined) => {
        let num = 0;
        if (buf == undefined || length == undefined || pos == undefined) {
          return -1;
        }
        try {
          num = fileIo.readSync(this.fd, buf, { offset: pos, length: length });
        } catch (error) {
          let err = error as BusinessError;
          Logger.warn(`setColorMode failed, code=${err.code}, message=${err.message}`);
        }
        if (num > 0 && (this.fileSize >= pos)) {
          return num;
        }
        return -1;
      }
    }
    try {
      // 创建avPlayer实例对象
      this.avPlayer = await media.createAVPlayer();
      this.setAVPlayerCallback(this.avPlayer, this.callback);
    } catch (error) {
      let err = error as BusinessError;
      Logger.warn(`createAVPlayer failed, code=${err.code}, message=${err.message}`);
    }
    try {
      // 获取播放文件的大小
      this.fileSize = fileIo.statSync(filePath).size;
    } catch (error) {
      let err = error as BusinessError;
      Logger.warn(`createAVPlayer failed, code=${err.code}, message=${err.message}`);
    }
    src.fileSize = this.fileSize;
    this.isSeek = true; // 支持seek操作
    this.avPlayer!.dataSrc = src;
  }

  // 以下demo为通过url设置网络地址来实现播放直播码流的demo
  async avPlayerLiveDemo() {
    try {
      // 创建avPlayer实例对象
      let avPlayer: media.AVPlayer = await media.createAVPlayer();
      // 创建状态机变化回调函数
      this.setAVPlayerCallback(avPlayer, this.callback);
      this.isSeek = false; // 不支持seek操作
      avPlayer.url = 'http://xxx.xxx.xxx.xxx:xx/xx/index.m3u8'; // 播放hls网络直播码流
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(`createAVPlayer failed, code=${err.code}, message=${err.message}`);
    }
  }

  // 以下demo为通过setMediaSource设置自定义头域及媒体播放优选参数实现初始播放参数设置
  async preDownloadDemo() {
    try {
      // 创建avPlayer实例对象
      let avPlayer: media.AVPlayer = await media.createAVPlayer();
      let mediaSource: media.MediaSource =
        media.createMediaSourceWithUrl('http://xxx', { 'User-Agent': 'User-Agent-Value' });
      let playbackStrategy: media.PlaybackStrategy = {
        preferredWidth: 1,
        preferredHeight: 2,
        preferredBufferDuration: 3,
        preferredHdr: false
      };
      // 设置媒体来源和播放策略
      avPlayer.setMediaSource(mediaSource, playbackStrategy)
        .catch((err: BusinessError) => {
          Logger.error(`setMediaSource failed, code=${err.code}, message=${err.message}`)
        })
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(`createAVPlayer or createMediaSourceWithUrl failed, code=${err.code}, message=${err.message}`);
    }
  }
}