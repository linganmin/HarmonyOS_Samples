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

import { CommonConstants as Const } from '../common/CommonConstants';
import { VideoPlayer } from './VideoPlayer';
import { LoadingDialog } from '@kit.ArkUI';
import { VideoDataModel } from '../model/VideoDataModel';
import { fileIo } from '@kit.CoreFileKit';
import transcoding from 'libtranscoding.so';
import { formatVideoTime } from '../common/utils/TimeUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();
  @State currentTime: number = 0;
  @State durationTime: number = 0;
  @State isStart: boolean = true;
  @State isTranscoding: boolean = false;
  isConfig: boolean = false;
  private videoDataModel: VideoDataModel = new VideoDataModel();
  private controller: VideoController = new VideoController();
  customDialogId: number = 0;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      content: $r('app.string.transcoding')
    }),
    autoCancel: false
  });

  @Builder
  PagesMap(name: string) {
    if (name === 'VideoPlayer') {
      NavDestination() {
        VideoPlayer()
      }
      .title($r('app.string.video_player'))
      .backgroundColor('#F1F3F5')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Text($r('app.string.buffer_mode'))
          .width('100%')
          .fontColor('#E6000000')
          .fontSize(26)
          .fontWeight(700)
          .lineHeight(40)
          .textAlign(TextAlign.Start)
          .padding(16)

        Blank()

        Column() {
          Stack() {
            Video({ src: $rawfile('video_sample.mp4'), controller: this.controller })
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
        }
        .backgroundColor('')
        .width('100%')
        .layoutWeight(1)

        Blank()

        Column() {
          Button($r('app.string.config_video'))
            .id('config')
            .onClick(() => {
              this.getUIContext().showTextPickerDialog({
                defaultPickerItemHeight: Const.DEFAULT_PICKER_ITEM_HEIGHT,
                selectedTextStyle: ({
                  font: ({
                    size: Const.SELECTED_TEXT_STYLE_FONT_SIZE
                  })
                }),
                range: Const.RECORDER_INFO,
                canLoop: false,
                alignment: DialogAlignment.Center,
                onAccept: (value: TextPickerResult) => {
                  switch (value.value[0]) {
                    case Const.VIDEO_MIMETYPE[0]: {
                      this.videoDataModel.setCodecFormat(Const.TRUE, Const.MIME_VIDEO_AVC);
                      break;
                    }
                    case Const.VIDEO_MIMETYPE[1]: {
                      this.videoDataModel.setCodecFormat(Const.FALSE, Const.MIME_VIDEO_HEVC);
                      break;
                    }
                    default:
                      break;
                  }

                  switch (value.value[1]) {
                    case Const.VIDEO_RESOLUTION[0]: {
                      this.videoDataModel.setResolution(Const.BITRATE_VIDEO_30M);
                      break;
                    }
                    case Const.VIDEO_RESOLUTION[1]: {
                      this.videoDataModel.setResolution(Const.BITRATE_VIDEO_20M);
                      break;
                    }
                    case Const.VIDEO_RESOLUTION[2]: {
                      this.videoDataModel.setResolution(Const.BITRATE_VIDEO_10M);
                      break;
                    }
                    default:
                      break;
                  }

                  switch (value.value[2]) {
                    case Const.VIDEO_FRAMERATE[0]: {
                      this.videoDataModel.frameRate = Const.FRAMERATE_VIDEO_30FPS;
                      break;
                    }
                    case Const.VIDEO_FRAMERATE[1]: {
                      this.videoDataModel.frameRate = Const.FRAMERATE_VIDEO_60FPS;
                      break;
                    }
                    default:
                      break;
                  }
                }
              });

            })
            .size({
              width: '100%',
              height: 40
            })
            .margin({
              bottom: 16
            })

          Button($r('app.string.start_transcoding'))
            .onClick(() => {
              this.dialogController.open();
              this.transcoding();
            })
            .width('100%')
        }
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .backgroundColor('#F1F3F5')
    .navDestination(this.PagesMap)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  transcoding() {
    try {
      this.getUIContext().getHostContext()?.resourceManager.getRawFd('video_sample.mp4').then((inputDesc) => {
        let outputFile = fileIo.openSync(this.getUIContext().getHostContext()?.cacheDir + '/transcoding.mp4',
          fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        this.isTranscoding = true;
        transcoding.startNative(inputDesc.fd, outputFile.fd, inputDesc.offset, inputDesc.length,
          this.videoDataModel.videoCodecMime, this.videoDataModel.frameRate, this.videoDataModel.bitRate,
          () => {
            this.isTranscoding = false;
            this.dialogController.close();
            this.pageStack.pushPathByName('VideoPlayer', '');
          })
      });
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0xFF00, 'AVCodecBufferMode', `transcoding fail, code = ${err.code}, message = ${err.message}`);
    }
  }
}