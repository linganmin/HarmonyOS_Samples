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
import avScreenCapture from 'libentry.so';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError, systemDateTime } from '@kit.BasicServicesKit';
import { display } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { formatVideoTime } from '../common/utils/TimeUtils';
import { CommonConstants } from '../common/constants/CommonConstants';
import PlayerParam from '../model/PlayerParam';

@Component
export struct CAVScreenCaptureToFile {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State videoSrc: string = AppStorage.get('videoSrcTwo') as string;
  @StorageLink('fileNameTwo') fileName: string = '';
  @StorageProp("isRecordTwo") isRecordTwo: boolean = false;

  private fileFd: number | null = null;
  private tmpFileNameTwo: string = AppStorage.get('tmpFileNameTwo') as string;;
  private filepath: string = '';
  private displayInfo: display.Display = AppStorage.get('displayInfo') as display.Display;

  StopCallback() {
    AppStorage.setOrCreate('isRecordTwo', false);
    AppStorage.setOrCreate('fileNameTwo', AppStorage.get('tmpFileNameTwo'));
  }

  // Create a file descriptor (FD) corresponding to the saved screen recording file.
  async createVideoFd(): Promise<void> {
    this.tmpFileNameTwo = systemDateTime.getTime(true) + '.mp4';
    AppStorage.setOrCreate('tmpFileNameTwo', this.tmpFileNameTwo);
    this.filepath = this.getUIContext().getHostContext()?.filesDir + '/' + this.tmpFileNameTwo;
    hilog.info(0xFF00, CommonConstants.LOG_TAG, 'filepath uri: %{public}s', this.filepath);

    await fs.open(this.filepath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE).then((file) => {
      this.fileFd = file.fd;

    }).catch((err: BusinessError) => {
      hilog.info(0xFF00, CommonConstants.LOG_TAG,
        'open file failed with error message: %{public}s, error code: %{public}d',
        err.message, err.code);
    })

    avScreenCapture.setStopCallbackToFile(this.StopCallback);
    avScreenCapture.startScreenCaptureToFile(this.fileFd, this.displayInfo.width, this.displayInfo.height)
    this.videoSrc = 'file://' + this.filepath;
    AppStorage.setOrCreate('videoSrcTwo', this.videoSrc);
  }

  async releaseFD() {
    if (this.fileFd != undefined && this.fileFd?.valueOf() > 0) {
      try {
        // Close the file descriptor (fd).
        fs.close(this.fileFd);
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'testTag', `close fail. code = ${err.code}, message = ${err.message}`);
      }
    }
  }

  @Builder
  navTitleBuilder() {
    Row() {
      Text($r('app.string.Subtitle2_desc'))
        .fontSize($r('app.float.subtitle_font_size'))
        .fontWeight(FontWeight.Bold)
        .margin({ left: 10 })
      Button() {
        if (!this.isRecordTwo) {
          SymbolGlyph($r('sys.symbol.play_video'))
            .fontSize(24)
        } else {
          Image($r('app.media.dot_video'))
            .height(24)
            .width(24)
        }
      }
      .height(40)
      .width(40)
      .padding(8)
      .backgroundColor(this.isRecordTwo
        ? $r('app.color.record_button_background_active_color')
        : $r('app.color.record_button_background_inactive_color'))
      .margin({ right: 15 })
      .onClick(() => {
        if (!this.isRecordTwo) {
          this.createVideoFd();
          AppStorage.setOrCreate('isRecordTwo', true);
        } else {
          avScreenCapture.stopScreenCaptureToFile();
          AppStorage.setOrCreate('isRecordTwo', false);
          this.fileName = this.tmpFileNameTwo;
        }
      })
    }
    .height('100%')
    .width('85%')
    .justifyContent(FlexAlign.SpaceBetween)

  }

  build() {
    NavDestination() {
      Row() {
        Column() {
          // Video area
          Column() {
            if (this.isRecordTwo) {
              Text($r('app.string.Recording_text_desc'))
                .width('100%')
                .layoutWeight(1)
                .fontSize(16)
                .textAlign(TextAlign.Center)
            } else if (this.fileName != '') {
              Column() {
                Image($r('app.media.image'))
                  .width(48)
                  .height(48)
                Text($r('app.string.Text_desc'))
                  .width('100%')
                  .fontSize(16)
                  .margin({ top: '17vp' })
                  .textAlign(TextAlign.Center)
                Text(this.fileName)
                  .width('100%')
                  .height(22)
                  .fontSize(12)
                  .margin({ top: '6vp' })
                  .textAlign(TextAlign.Center)
                SymbolGlyph($r('sys.symbol.play_circle_fill'))
                  .fontColor([$r('app.color.player_button_color')])
                  .fontSize(40)
                  .margin({ top: '14vp' })
                  .onClick(() => {
                    let param: PlayerParam = {
                      videoSrc: this.videoSrc,
                      fileName: this.fileName
                    } as PlayerParam;
                    this.pageInfos.pushPathByName('Player', param);
                  })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
              .layoutWeight(1)
            } else {
              Text($r('app.string.Initial_text_desc'))
                .width('100%')
                .layoutWeight(1)
                .fontSize(16)
                .textAlign(TextAlign.Center)
            }
          }
          .backgroundColor($r('app.color.background_color'))
          .width('100%')
          .layoutWeight(1)

        }
        .width('100%')
      }
      .height('104%')
    }
    .title(this.navTitleBuilder())
  }
}
