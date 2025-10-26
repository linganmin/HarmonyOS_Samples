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

@Component
export struct CAVScreenCaptureToStream {
  @Consume('pageInfos') pageInfos: NavPathStack;
  private file: fs.File | null = null;
  private tmpFileNameThree: string = '';
  private filepath: string = '';
  @State videoSrc: string = AppStorage.get('videoSrcThree') as string;
  private controller: VideoController = new VideoController();
  private displayInfo: display.Display = AppStorage.get('displayInfo') as display.Display;
  @State isPlayFlag: boolean = false;
  @StorageLink('fileNameThree') fileName: string = '';
  @State currentTime: number = 0
  @State durationTime: number = 0
  @State isStart: boolean = true;

  StopCallback() {
    AppStorage.setOrCreate('isRecordThree', false);
    AppStorage.setOrCreate('fileNameThree', AppStorage.get('tmpFileNameThree'));
  }

  // [Start create_file_fd2]
  // 获取保存文件信息并调用Native方法
  async createVideoFd(): Promise<void> {
    // 拼接文件路径
    this.tmpFileNameThree = systemDateTime.getTime(true) + '.mp4';
    // [StartExclude create_file_fd2]
    AppStorage.setOrCreate('tmpFileNameThree', this.tmpFileNameThree);
    // [EndExclude create_file_fd2]
    this.filepath = this.getUIContext().getHostContext()?.filesDir + '/' + this.tmpFileNameThree;
    hilog.info(0xFF00, CommonConstants.LOG_TAG, 'filepath uri: %{public}s', this.filepath);
    try {
      // 获取文件信息
      this.file = fs.openSync(this.filepath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);

      // [StartExclude create_file_fd2]
      avScreenCapture.setStopCallbackToStream(this.StopCallback);
      // [EndExclude create_file_fd2]

      // 调用native方法开启录制并传递fd、宽高
      avScreenCapture.startScreenCaptureToStream(this.file.fd, this.displayInfo.width, this.displayInfo.height)

      // [StartExclude create_file_fd2]
      this.videoSrc = 'file://' + this.filepath;
      AppStorage.setOrCreate('videoSrcThree', this.videoSrc);
      // [EndExclude create_file_fd2]
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `startScreenCaptureToStream fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  // [End create_file_fd2]

  // [Start release_fd2]
  async releaseFD() {
    if (this.file?.fd != undefined && this.file.fd?.valueOf() > 0) {
      // 关闭文件
      try {
        fs.close(this.file.fd);
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'testTag', `close fail. code = ${err.code}, message = ${err.message}`);
      }
    }
  }

  // [End release_fd2]

  build() {
    NavDestination() {
      Row() {
        Column() {
          // Video area
          Column() {
            if (this.isPlayFlag) {
              Stack() {
                Video({ src: this.videoSrc, controller: this.controller })
                  .width('100%')
                  .height('100%')
                  .autoPlay(true)
                  .controls(false)
                  .objectFit(1)
                  .zIndex(0)
                  .onPrepared((event) => {
                    if (event) {
                      this.durationTime = event.duration
                      console.info(this.durationTime.toString());
                    }
                  })
                  .onUpdate((event) => {
                    if (event) {
                      this.currentTime = event.time
                    }
                  })
                  .onFinish(() => {
                    this.isStart = !this.isStart;
                  })
                  .transition(TransitionEffect.OPACITY.animation({ duration: 1000, curve: Curve.Sharp }))

                Row() {
                  Image(this.isStart ? $r('app.media.pause') : $r('app.media.play'))
                    .width(18)
                    .height(18)
                    .onClick(() => {
                      if (this.isStart) {
                        this.controller.pause();
                        this.isStart = !this.isStart;
                      } else {
                        this.controller.start();
                        this.isStart = !this.isStart;
                      }
                    })

                  Text(formatVideoTime(this.currentTime))
                    .fontColor(Color.White)
                    .fontSize(12)
                    .margin({ left: '12vp' })
                  Slider({
                    value: this.currentTime,
                    min: 0,
                    max: this.durationTime
                  })
                    .onChange((value: number, mode: SliderChangeMode) => {
                      // Set the video playback progress to jump to the value
                      this.controller.setCurrentTime(value);
                    })
                    .layoutWeight(1)
                  Text(formatVideoTime(this.durationTime))
                    .fontColor(Color.White)
                    .fontSize(12)
                }
                .padding({ left: '16vp', right: '16vp' })
                .zIndex(1)
                .height(43)
                .width('100%')
              }
              .alignContent(Alignment.Bottom)
              .width('100%')
              .layoutWeight(1)

            } else {
              if (this.fileName != '') {
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
                  Button($r('app.string.Play_button'))
                    .fontSize(14)
                    .width(120)
                    .margin({ top: '14vp' })
                    .onClick(() => {
                      this.isPlayFlag = true;
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
          }
          .backgroundColor($r('app.color.background_color'))
          .width('100%')
          .layoutWeight(1)

          Column() {
            Button('Start Screen Recording')
              .width('100%')
              .margin({ top: '24vp' })
              .onClick(() => {
                if (!AppStorage.get('isRecordThree')) {
                  this.isPlayFlag = false;
                  this.createVideoFd();
                  AppStorage.setOrCreate('isRecordThree', true);
                }
              })

            Button('Stop Screen Recording')
              .width('100%')
              .margin({ top: '12vp' })
              .onClick(() => {
                if (AppStorage.get('isRecordThree')) {
                  avScreenCapture.stopScreenCaptureToStream();
                  this.releaseFD();
                  AppStorage.setOrCreate('isRecordThree', false);
                  this.fileName = this.tmpFileNameThree;
                }
              })
          }
          .justifyContent(FlexAlign.End)
          .padding({ left: '16vp', right: '16vp', bottom: '16vp' })
          .width('100%')
        }
        .width('100%')
      }
      .height('100%')
    }
    .title($r('app.string.Subtitle3_desc'))
  }
}
