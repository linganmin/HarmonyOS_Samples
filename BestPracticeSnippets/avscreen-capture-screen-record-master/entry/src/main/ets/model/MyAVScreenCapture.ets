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
import { media } from '@kit.MediaKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { systemDateTime, BusinessError } from '@kit.BasicServicesKit';
import { display } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants } from '../common/constants/CommonConstants';

// Perform screen recording using the ArkTS method.
export class MyAVScreenCapture {
  private static instance: MyAVScreenCapture;
  private screenCapture?: media.AVScreenCaptureRecorder;
  private path: string = '';
  private fileName: string = '';
  private file: fs.File | null = null;
  private displayInfo: display.Display = AppStorage.get('displayInfo') as display.Display;

  // 开始屏幕录制
  public async startRecording(filesDir: string) {
    // [Start create_record]
    // 获取fd
    this.updateFileFd(filesDir);
    // 实例化对象
    try {
      this.screenCapture = await media.createAVScreenCaptureRecorder();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag',
        `createAVScreenCaptureRecorder fail. code = ${err.code}, message = ${err.message}`);
    }
    if (this.screenCapture != undefined) {
      hilog.info(0xFF00, CommonConstants.LOG_TAG, 'ScreenCapture has been created successfully.');
    } else {
      hilog.info(0xFF00, CommonConstants.LOG_TAG, 'ScreenCapture creation failed.');
      return;
    }

    // 监听屏幕捕获的状态更改
    this.screenCapture?.on('stateChange', async (infoType: media.AVScreenCaptureStateCode) => {
      switch (infoType) {
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_STARTED:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, '录屏成功开始后会收到的回调.');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_CANCELED:
          this.screenCapture?.release();
          this.screenCapture = undefined;
          hilog.info(0xFF00, CommonConstants.LOG_TAG, '不允许使用录屏功能.');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_STOPPED_BY_USER:
          this.screenCapture?.release();
          this.screenCapture = undefined;
          AppStorage.setOrCreate('isRecordOne', false);
          AppStorage.setOrCreate('fileNameOne', this.fileName);
          hilog.info(0xFF00, CommonConstants.LOG_TAG,
            '通过屏幕录制胶囊结束屏幕录制，底层录制停止');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_INTERRUPTED_BY_OTHER:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, '屏幕录制因其他中断而停止');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_STOPPED_BY_CALL:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, '屏幕录制被电话打断');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_MIC_UNAVAILABLE:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, '录屏麦克风不可用');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_MIC_MUTED_BY_USER:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, '录屏麦克风被用户静音');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_MIC_UNMUTED_BY_USER:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, '录屏麦克风被用户取消静音');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_ENTER_PRIVATE_SCENE:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, '录屏进入隐私场景');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_EXIT_PRIVATE_SCENE:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, '录屏退出隐私场景');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_STOPPED_BY_USER_SWITCHES:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, '用户账号切换，底层录制会停止');
          break;
        default:
          break;
      }
    })

    // 监听异常
    this.screenCapture?.on('error', (err) => {
      hilog.info(0xFF00, CommonConstants.LOG_TAG, 'Handle exception cases.');
    })
    // [End create_record]

    // [Start set_config]
    // 配置屏幕录制参数
    let captureConfig: media.AVScreenCaptureRecordConfig = {
      // 开发者可以根据自己的需要设置宽度和高度
      frameWidth: this.displayInfo.width,
      frameHeight: this.displayInfo.height,
      // 用于写入文件的文件描述符（fd）
      fd: (this.file as fs.File).fd,
      // 可选参数及其默认值
      videoBitrate: 10000000,
      audioSampleRate: 48000,
      audioChannelCount: 2,
      audioBitrate: 96000,
      displayId: 0,
    };
    // [End set_config]
    try {
      // [Start init_config]
      await this.screenCapture?.init(captureConfig);
      // [End init_config]

      // [Start start_record]
      await this.screenCapture?.startRecording();
      // [End start_record]
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `start fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  // [Start stop_record]
  // 停止录屏
  public async stopRecording() {
    if (this.screenCapture == undefined) {
      hilog.info(0xFF00, CommonConstants.LOG_TAG, 'ScreenCapture exception.');
      return;
    }

    try {
      await this.screenCapture?.stopRecording();

      // 调用release()方法来销毁实例并释放资源
      await this.screenCapture?.release();

      // 关闭文件
      fs.close((this.file as fs.File).fd);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `stop fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  // [End stop_record]

  // [Start get_file_fd]
  public updateFileFd(filesDir: string) {
    // 获取文件fd
    this.fileName = systemDateTime.getTime(true).toString() + '.mp4';
    this.path = filesDir + '/' + this.fileName;
    try {
      this.file = fs.openSync(this.path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `openSync fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  // [End get_file_fd]

  public getPath(): string {
    return this.path;
  }


  public getFileName(): string {
    return this.fileName;
  }

  private constructor() {
  };

  public static getInstance(): MyAVScreenCapture {
    if (!MyAVScreenCapture.instance) {
      MyAVScreenCapture.instance = new MyAVScreenCapture();
    }
    return MyAVScreenCapture.instance;
  }
}
