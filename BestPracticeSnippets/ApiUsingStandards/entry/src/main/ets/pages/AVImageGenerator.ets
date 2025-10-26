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

import { media } from '@kit.MediaKit'
import { image } from '@kit.ImageKit'
import { fileIo as fs, ReadOptions } from '@kit.CoreFileKit';
import { display } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

class AVImageGeneratorClass {
  pixelMap: image.PixelMap[] = [];
  rootPath: string = 'root';
  testFilename: string = 'name';
  diffTime: number[] = [];
  pixelMapWidth: number = 0;
  pixelMapHeight: number = 0;
  seekOption!: media.AVImageQueryOptions;
  pixelLcd: image.PixelMap | undefined = undefined;
  lcdHeight: number = 0;
  videoHeight: number = 0;

  // [Start av_image_generator_class]
  async fetchFrame(): Promise<void> {
    await this.fetchMeta();
    if (canIUse("SystemCapability.Multimedia.Media.AVImageGenerator")) {
      this.pixelMap = new Array;
      let avImageGenerator: media.AVImageGenerator = await media.createAVImageGenerator();
      // raw fd
      avImageGenerator.fdSrc = fs.openSync(this.rootPath + this.testFilename);
      for (let i = 0; i < 6; i++) {
        let pixelMap: image.PixelMap = await avImageGenerator.fetchFrameByTime(this.diffTime[i], this.seekOption,
          { width: this.pixelMapWidth, height: this.pixelMapHeight });
        this.pixelMap.push(pixelMap);
        if (i == 0) {
          this.pixelLcd = pixelMap;
          let rate: number = pixelMap.getImageInfoSync().size.height / pixelMap.getImageInfoSync().size.width;
          this.lcdHeight =
            display.getDefaultDisplaySync().width / 2 / display.getDefaultDisplaySync().densityPixels * rate;
        }
        let imageInfo: image.ImageInfo = pixelMap.getImageInfoSync();
        hilog.info(0x0000, 'testTag',
          `colorFormat ${imageInfo.pixelFormat} width ${imageInfo.size.width} height ${imageInfo.size.height} isHdr ${imageInfo.isHdr}`);
      }
    }
  }

  async fetchMeta(): Promise<void> {
    if (canIUse("SystemCapability.Multimedia.Media.AVMetadataExtractor")) {
      let avMetadataExtractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor();
      let fd: number = fs.openSync(this.rootPath + this.testFilename).fd;
      let fileSize: number = fs.statSync(this.rootPath + this.testFilename).size;
      let dataSrc: media.AVDataSrcDescriptor = {
        fileSize: fileSize,
        callback: (buffer, len, pos) => {
          if (buffer == undefined || len == undefined || pos == undefined) {
            return -1;
          }
          let options: ReadOptions = {
            offset: pos,
            length: len
          }
          let num: number = fs.readSync(fd, buffer, options);
          if (num > 0 && fileSize >= pos) {
            return num;
          }
          return -1;
        }
      }

      avMetadataExtractor.dataSrc = dataSrc;
      let metadata: media.AVMetadata;
      try {
        metadata = await avMetadataExtractor.fetchMetadata();
      } catch (error) {
        hilog.error(0x0000, 'testTag', 'error code ' + error.code);
        return;
      }
      if (metadata.duration) {
        let duration: number = parseInt(metadata.duration) * 1000;
        let pick: number = duration / 5;
        this.diffTime[0] = 0;
        this.diffTime[5] = duration;
        let time: number = pick;
        for (let i = 1; i < 5; i++) {
          this.diffTime[i] = time;
          time += pick;
        }
      }
      if (metadata.videoHeight && metadata.videoWidth) {
        let rate: number = Number(metadata.videoHeight) / Number(metadata.videoWidth);
        if (metadata.videoOrientation && Number(metadata.videoOrientation) % 180) {
          rate = 1 / rate;
        }
        this.videoHeight =
          display.getDefaultDisplaySync().width / 6 / display.getDefaultDisplaySync().densityPixels * rate;
      }
      await avMetadataExtractor.release();
    }
  }

  // [End av_image_generator_class]
}