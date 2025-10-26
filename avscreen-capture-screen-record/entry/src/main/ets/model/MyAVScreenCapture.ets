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
  private captureConfig: media.AVScreenCaptureRecordConfig = {
    // Developers can set the width and height according to their own needs.
    frameWidth: this.displayInfo.width,
    frameHeight: this.displayInfo.height,
    // The file descriptor (FD) for writing to a file.
    fd: 0,
    // Optional parameters and their default values
    videoBitrate: 10000000,
    audioSampleRate: 48000,
    audioChannelCount: 2,
    audioBitrate: 96000,
    displayId: 0,
  };

  // Start Screen Recording
  public async startRecording(filesDir: string) {
    this.updateFileFd(filesDir);

    try {
      this.screenCapture = await media.createAVScreenCaptureRecorder();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `createAVScreenCaptureRecorder fail. code = ${err.code}, message = ${err.message}`);
    }

    if (this.screenCapture != undefined) {
      hilog.info(0xFF00, CommonConstants.LOG_TAG, 'ScreenCapture has been created successfully.');
    } else {
      hilog.info(0xFF00, CommonConstants.LOG_TAG, 'ScreenCapture creation failed.');
      return;
    }

    // Listen for state changes of the screenCapture.
    this.screenCapture?.on('stateChange', async (infoType: media.AVScreenCaptureStateCode) => {
      switch (infoType) {
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_STARTED:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, 'Callback received after screen recording starts successfully.');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_CANCELED:
          this.screenCapture?.release();
          this.screenCapture = undefined;
          hilog.info(0xFF00, CommonConstants.LOG_TAG, 'The screen recording function is not allowed.');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_STOPPED_BY_USER:
          this.screenCapture?.release();
          this.screenCapture = undefined;
          AppStorage.setOrCreate('isRecordOne', false);
          AppStorage.setOrCreate('fileNameOne', this.fileName);
          hilog.info(0xFF00, CommonConstants.LOG_TAG,
            'End screen recording via the screen recording capsule, and the underlying recording stops.');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_INTERRUPTED_BY_OTHER:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, 'Screen recording stopped due to other interruptions.');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_STOPPED_BY_CALL:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, 'Screen recording was interrupted by a call.');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_MIC_UNAVAILABLE:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, 'The screen recording microphone is unavailable.');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_MIC_MUTED_BY_USER:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, 'The screen recording microphone has been muted by the user.');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_MIC_UNMUTED_BY_USER:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, 'The screen recording microphone has been unmuted by the user.');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_ENTER_PRIVATE_SCENE:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, 'Screen recording enters a privacy scenario.');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_EXIT_PRIVATE_SCENE:
          hilog.info(0xFF00, CommonConstants.LOG_TAG, 'Screen recording exits the privacy scenario.');
          break;
        case media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_STOPPED_BY_USER_SWITCHES:
          hilog.info(0xFF00, CommonConstants.LOG_TAG,
            'The user account is switched, and the underlying recording stops.');
          break;
        default:
          break;
      }
    })

    this.screenCapture?.on('error', (err) => {
      hilog.info(0xFF00, CommonConstants.LOG_TAG, 'Handle exception cases.');
    })
    try {
      await this.screenCapture?.init(this.captureConfig);

      await this.screenCapture?.startRecording();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `start fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  // Start Screen Recording.
  public async stopRecording() {
    if (this.screenCapture == undefined) {
      hilog.info(0xFF00, CommonConstants.LOG_TAG, 'ScreenCapture exception.');
      return;
    }

    try {
      await this.screenCapture?.stopRecording();

      // Call the release() method to destroy the instance and release resources.
      await this.screenCapture?.release();

      // Close the file descriptor (fd).
      fs.close((this.file as fs.File).fd);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `stop fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  public updateFileFd(filesDir: string) {
    this.fileName = systemDateTime.getTime(true).toString() + '.mp4';
    this.path = filesDir + '/' + this.fileName;
    try {
      this.file = fs.openSync(this.path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      this.captureConfig.fd = this.file.fd;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `openSync fail. code = ${err.code}, message = ${err.message}`);
    }
  }

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
