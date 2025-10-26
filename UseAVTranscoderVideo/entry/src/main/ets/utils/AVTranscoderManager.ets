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
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs} from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export interface avConfigCommon {
  resolution: string,
  codeRate: number
}

export interface outputPathCommon {
  outputFilePath: string
}

export class AVTranscoderManager {
  private avTranscoder: media.AVTranscoder | undefined = undefined;
  private context: Context | undefined;
  private currentProgress: number = 0;
  private isSupport: boolean = canIUse('SystemCapability.Multimedia.Media.AVTranscoder');
  outputFilePath: string = '';

  constructor(context: Context | undefined) {
    if (context != undefined) {
      this.context = context;
    }
  }

  private avConfig: media.AVTranscoderConfig = {
    fileFormat: media.ContainerFormatType.CFT_MPEG_4, // The encapsulation format of the output video currently only supports MP4.
    videoBitrate: 200000, // Video code rate.
    videoCodec: media.CodecMimeType.VIDEO_AVC, // Video encoding format
    videoFrameWidth: 1920, // Resolution width [240-3840]
    videoFrameHeight: 1080, // High resolution [240-2160]
  }

  // Set conversion parameters
  setAVConfig(params: avConfigCommon) {
    const resolutionList: string[] = params.resolution.split('x');
    this.avConfig.videoFrameWidth = Number(resolutionList[0]);
    this.avConfig.videoFrameHeight = Number(resolutionList[1]);
    this.avConfig.videoBitrate = params.codeRate;
  }

  // Register avTranscoder callback function
  setAVTranscoderCallback() {
    if (this.avTranscoder) {
      // Transcoding to complete the callback function
      this.avTranscoder.on('complete', async () => {
        hilog.info(0x0000, 'testTag', 'AVTranscoder is completed');
        await this.releaseTranscoderProcess();
      })
      // Error report callback function
      this.avTranscoder.on('error', (err: BusinessError) => {
        hilog.error(0x0000, 'testTag', `AVTranscoder failed, code is ${err.code}, message is ${err.message}`);
      })
      // Progress report callback function
      this.avTranscoder.on('progressUpdate', (progress: number) => {
        hilog.info(0x0000, 'testTag', `AVTranscoder progressUpdate = ${progress}`);
        this.currentProgress = progress;
        this.context?.eventHub.emit('myEvent', progress);
      })
    }
  }

  // Start the process for transcoding
  async startTranscoderProcess() {
    if (this.isSupport) {
      if (this.avTranscoder) {
        try {
          await this.avTranscoder.release();
        } catch (err) {
          hilog.error(0x0000, 'testTag', `release failed, code is ${err.code}, message is ${err.message}`);
        }
        this.avTranscoder = undefined;
      };
      // 1. Create a transcoding instance.
      try {
        this.avTranscoder = await media.createAVTranscoder();
      } catch (err) {
        hilog.error(0x0000, 'testTag', `createAVTranscoder failed, code is ${err.code}, message is ${err.message}`);
      }
      this.setAVTranscoderCallback();
      // 2. Get the transcoding source file fd and the target file fd to avTranscoder; refer to the FilePicker document.
      if (this.context) {
        try {
          // To obtain the input file fd, video_sample.mp4 is a provisioning resource in the rawfile directory,
          // which needs to be replaced by the developer according to the actual situation.
          let fileDescriptor = await this.context.resourceManager.getRawFd('video_sample.mp4');
          this.avTranscoder!.fdSrc = fileDescriptor;
        } catch (error) {
          hilog.error(0x0000, 'testTag', 'Failed to get the file descriptor, please check the resource and path.');
        }
        let outputFilePath = this.context.filesDir + '/output.mp4';
        try {
          let file = fs.openSync(outputFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
          this.avTranscoder!.fdDst = file.fd;
          this.outputFilePath = outputFilePath;
          this.currentProgress = 0;
        } catch (err) {
          hilog.error(0x0000, 'testTag', `openSync failed, code is ${err.code}, message is ${err.message}`);
        }
      }
      try {
        // 3. Configure transcoding parameters to complete the preparation.
        await this.avTranscoder!.prepare(this.avConfig);
        // 4. Start transcoding.
        await this.avTranscoder!.start();
      } catch (err) {
        hilog.error(0x0000, 'testTag', `prepare or start failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // Pause the process for transcoding.
  async pauseTranscoderProcess() {
    if (this.isSupport && this.avTranscoder) {
      try {
        // Call pause only after the start returns.
        await this.avTranscoder.pause();
      } catch (err) {
        hilog.error(0x0000, 'testTag', `pause failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // Restore the corresponding transcoding process.
  async resumeTranscoderProcess() {
    if (this.isSupport && this.avTranscoder) {
      try {
        // It is reasonable to call resume only after the call is returned.
        await this.avTranscoder.resume();
      } catch (err) {
        hilog.error(0x0000, 'testTag', `resume failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // Release the transcoding process.
  async releaseTranscoderProcess() {
    if (this.isSupport && this.avTranscoder) {
      try {
        // 1. Release the transcoding instance.
        await this.avTranscoder.release();
        this.avTranscoder = undefined;
        // 2. Turn off the transcoding target file fd.
        fs.closeSync(this.avTranscoder!.fdDst);
      } catch (err) {
        hilog.error(0x0000, 'testTag', `release failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }

  // Get the current progress
  getCurrentProgress(): number {
    hilog.info(0x0000, 'testTag', `getCurrentProgress = ${this.currentProgress}`);
    return this.currentProgress;
  }
}