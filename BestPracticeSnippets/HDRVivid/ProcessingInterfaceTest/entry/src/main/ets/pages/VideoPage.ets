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

import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { fileIo, picker } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import player from 'libplayer.so';
import Logger from '../utils/Logger';
import { AVPlayerDemo } from '../utils/AVPlayerDemo';
import { SizeChangeListener } from '../utils/SizeChangeInterface';

const TAG: string = 'VideoPage';

class innerInfo {
  eventId: number = 0
  priority: emitter.EventPriority = 0
}

let innerEventWH: innerInfo = {
  eventId: 3,
  priority: emitter.EventPriority.HIGH
};

const PROPORTION = 0.99; // 占屏幕比例

@Entry
@Component
struct VideoPage {
  @State isCalcWHFinished: boolean = false;
  @State surfaceW: number = 0;
  @State surfaceH: number = 0;
  @State myUris: string = '';
  @State myFileNames: string[] = [];
  @State percent: number = 0;
  @State windowWidth: number = 300;
  @State windowHeight: number = 300;
  @State hdrMode: string = 'unknown';
  @State canConvertSDR: boolean = false;
  @State canConvertVividPQ: boolean = false;
  @State canConvertVividHLG: boolean = false;
  @State canConvertHLG: boolean = false;
  @State targetType: string = '';
  targetVal: number = 0;
  targetMetadata: number = 0;
  private callback: SizeChangeListener = {
    onChange: (width: number, height: number): void => {
      Logger.debug(TAG, 'callback ' + width + ' ' + height)
      this.isCalcWHFinished = true
      this.surfaceW = width / 6
      this.surfaceH = height / 6
    }
  }
  avPlayerDemoSrc: AVPlayerDemo = new AVPlayerDemo(this.getUIContext())
  avPlayerDemoDst: AVPlayerDemo = new AVPlayerDemo(this.getUIContext())
  controlSrc: XComponentController = new XComponentController()
  controlDst: XComponentController = new XComponentController()

  preload() {
    try {
      let inputFile = fileIo.openSync(this.myUris, fileIo.OpenMode.READ_ONLY);
      let inputFileState = fileIo.statSync(inputFile.fd);
      let msg: string = player.preload(inputFile.fd, inputFileState.size);
      this.hdrMode = msg;
      if (msg.includes('HDRVivid HLG')) {
        this.canConvertVividPQ = true;
        this.canConvertSDR = true;
      } else if (msg.includes('HDRVivid PQ')) {
        this.canConvertVividHLG = true;
        this.canConvertSDR = true;
      } else if (msg.includes('HDR')) {
        this.canConvertHLG = true;
      } else if (msg.includes('SDR')) {
        this.canConvertSDR = true;
      }
      fileIo.close(inputFile)
        .catch((err: BusinessError) => {
          Logger.error(`fileIo close failed, code=${err.code}, message=${err.message}`)
        })
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(`fileIo openSync or statSync failed, code=${err.code}, message=${err.message}`);
    }
  }

  async callFilePickerSelectImage(): Promise<void> {
    let array: string[];
    try {
      let PhotoSelectOptions: photoAccessHelper.PhotoSelectOptions = {
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE,
        maxSelectNumber: 1
      };
      let photoPicker = new picker.DocumentViewPicker();
      photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult) => {
        // 日志中记录成功信息
        Logger.info(TAG,
          'PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + JSON.stringify(PhotoSelectResult));
        if (PhotoSelectResult !== null && PhotoSelectResult !== undefined) {
          array = PhotoSelectResult;
          this.myUris = array[0];
          this.preload();
        }
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'PhotoViewPicker.select failed with err: ' + err.message);
      });
    } catch (err) {
      Logger.error(TAG, 'PhotoViewPicker failed with err: ' + err);
    }
  }

  setVideoWH(): void {
    if (this.percent >= 1) { // 横向视频
      this.surfaceW = Math.round(this.windowWidth * PROPORTION);
      this.surfaceH = Math.round(this.surfaceW / this.percent);
    } else { // 纵向视频
      this.surfaceH = Math.round(this.windowHeight * PROPORTION);
      this.surfaceW = Math.round(this.surfaceH * this.percent);
    }
  }

  onPageShow(): void {
    Logger.info(TAG, 'ImagePage onPageShow ' + this.myUris[0]);

    emitter.on(innerEventWH, (res) => {
      if (res.data) {
        this.windowWidth = res.data.width;
        this.windowHeight = res.data.height;
        this.setVideoWH();
      }
    });
  }

  play() {
    try {
      let inputFile = fileIo.openSync(this.myUris, fileIo.OpenMode.READ_ONLY);
      let inputFile2 = fileIo.openSync(this.myUris, fileIo.OpenMode.READ_ONLY);
      let inputFileState = fileIo.statSync(inputFile.fd);
      let inputFileState2 = fileIo.statSync(inputFile2.fd);
      player.playNative(inputFile.fd, 0, inputFileState.size, 0, this.targetVal, this.targetMetadata, () => {
        fileIo.close(inputFile)
          .catch((err: BusinessError) => {
            Logger.warn(`fileIo close failed, code=${err.code}, message=${err.message}`)
          })
      })
      player.playNative(inputFile2.fd, 0, inputFileState2.size, 1, this.targetVal, this.targetMetadata, () => {
        fileIo.close(inputFile2)
          .catch((err: BusinessError) => {
            Logger.warn(`fileIo close failed, code=${err.code}, message=${err.message}`)
          })
      })
    } catch (error) {
      let err = error as BusinessError;
      Logger.warn(`fileIo openSync or statSync failed, code=${err.code}, message=${err.message}`);
    }
  }

  @Builder
  ColorSpaceMenu() {
    Menu() {
      MenuItemGroup({ header: 'SDR' }) {
        MenuItem({ content: 'BT709' })
          .enabled(this.canConvertSDR)
          .onClick(() => {
            this.targetType = 'BT709';
            this.targetVal = 8;
            this.targetMetadata = -1;
          })
      }

      MenuItemGroup({ header: 'HDR' }) {
        MenuItem({ content: 'HLG' })
          .enabled(this.canConvertHLG)
          .onClick(() => {
            this.targetType = 'HDR HLG';
            this.targetVal = 9;
            this.targetMetadata = 0;
          })
        MenuItem({ content: 'Vivid-HLG' })
          .enabled(this.canConvertVividHLG)
          .onClick(() => {
            this.targetType = 'Vivid-HLG';
            this.targetVal = 9;
            this.targetMetadata = 2;
          })
        MenuItem({ content: 'Vivid-PQ' })
          .enabled(this.canConvertVividPQ)
          .onClick(() => {
            this.targetType = 'Vivid-PQ';
            this.targetVal = 10;
            this.targetMetadata = 2;
          })
      }
    }
  }

  build() {
    RelativeContainer() {
      Column() {
        Row() {
          Button('选择视频').onClick(() => {
            this.canConvertVividPQ = false;
            this.canConvertSDR = false;
            this.canConvertVividHLG = false;
            this.canConvertHLG = false;
            this.callFilePickerSelectImage()
          }).margin('30px')
          Button('选项')
            .bindMenu(this.ColorSpaceMenu())
          Button('生成').onClick(() => {
            if (this.myUris != '') {
              this.play()
            }
          }).margin('30px')
        }

        Text('视频类型:' + this.hdrMode)
        Text('目标格式:' + this.targetType)
      }
      .height('100%')
      .width('100%')
    }
    .height('100%')
    .width('100%')
  }
}