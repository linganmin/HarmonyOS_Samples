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

import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { AVPlayerController } from '../controller/AVPlayerController';
import { MultiStatusButton } from '../view/MultiStatusButton';
import player from 'libplayer.so';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = '[Transcode]';

enum VideoStatus {
  NO_VIDEO = 0, // No videos
  SELECTED_VIDEOS = 1, // Selected videos
  OPTIMIZE_VIDEOS = 2 // Optimize videos
}

@Builder
export function TranscodeBuilder() {
  Transcode();
}

@Component
struct Transcode {
  @State viewState: number = VideoStatus.NO_VIDEO;
  @State selectFilePath: string | undefined = undefined;
  @State colorSpaceIsShow: boolean = false;
  @State targetType: string = '';
  @State isHDRVivid: boolean = false; // video type
  @State pixelMap: image.PixelMap | undefined = undefined;
  @State avPlayerController: AVPlayerController = new AVPlayerController();
  private XComponentSurfaceId: string = '';
  private XComponentController: XComponentController = new XComponentController();
  private isProcessing: boolean = false;
  private targetColorSpace: number = 0; //color space
  private targetMetaData: number = 0; //Metadata Type

  preload() {
    try {
      let inputFile = fileIo.openSync(this.selectFilePath, fileIo.OpenMode.READ_ONLY);
      let inputFileState = fileIo.statSync(inputFile.fd);
      let info: string = player.preload(inputFile.fd, inputFileState.size);
      fileIo.close(inputFile).catch((error: BusinessError) => {
        hilog.error(0x0000, TAG, `file close fail, error code is =${error.code}, message is = ${error.message}`);
      });
      hilog.info(0x0000, TAG, `Video info: ${info}}`);
      let arr: string[] = info.split('@');
      let msg = arr[0] + ' ' + arr[1];
      if (msg.includes('HDRVivid ')) {
        this.isHDRVivid = true;
      } else {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.video_processing_not_support'),
          duration: 2000
        });
        this.isHDRVivid = false;
      }
    } catch (error) {
      hilog.error(0x0000, TAG, `preload fail, error code is =${error.code}, message is = ${error.message}`);
    }
  }

  async processVideo(option: number): Promise<void> {
    this.avPlayerController.videoPause();
    try {
      this.viewState = VideoStatus.SELECTED_VIDEOS;
      let inputFile = fileIo.openSync(this.selectFilePath, fileIo.OpenMode.READ_ONLY);
      let inputFileState = fileIo.statSync(inputFile.fd);
      this.isProcessing = true;
      player.playNative(inputFile.fd, 0, inputFileState.size, 1, -1, this.targetColorSpace,
        this.targetMetaData, option, (ret: number) => {
          fileIo.close(inputFile).catch((error: BusinessError) => {
            hilog.error(0x0000, TAG, `file close fail, error code is =${error.code}, message is = ${error.message}`);
          });
          if (ret && ret === 5) {
            this.getUIContext().getPromptAction().showToast({ message: $r('app.string.video_processing_not_support') });
          } else {
            hilog.info(0x0000, TAG, 'The video transcoding ' + this.targetType + ' succeed');
          }
          this.isProcessing = false;
          this.viewState = VideoStatus.OPTIMIZE_VIDEOS;
        });
    } catch (error) {
      hilog.error(0x0000, TAG, `processVideo fail, error code is =${error.code}, message is = ${error.message}`);
    }
  }

  aboutToDisappear(): void {
    player.destroy();
    this.XComponentSurfaceId = '';
    this.avPlayerController.videoRelease();
  }

  @Builder
  ColorSpaceMenu() {
    Column() {
      MultiStatusButton({ text: 'SDR-BT709', status: this.isHDRVivid ? 1 : 0 })
        .onClick(() => {
          this.colorSpaceIsShow = false;
          this.targetType = 'SDR BT709';
          this.targetColorSpace = 8; //OH_COLORSPACE_BT709_LIMIT
          this.targetMetaData = -1; //OH_VIDEO_NONE
          this.processVideo(1);
        })
      MultiStatusButton({ text: 'HDR-HLG', status: this.isHDRVivid ? 1 : 0 })
        .onClick(() => {
          this.colorSpaceIsShow = false;
          this.targetType = 'HDRVivid HLG';
          this.targetColorSpace = 9; //OH_COLORSPACE_BT2020_HLG_LIMIT
          this.targetMetaData = 0; //OH_VIDEO_HDR_HLG
          this.processVideo(1);
        })
    }
    .margin({
      left: 16,
      right: 16,
      bottom: 30
    })
  }

  selectFile() {
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select({
      MIMEType: photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE,
      maxSelectNumber: 1
    })
      .then(async (photoSelectResult) => {
        this.selectFilePath = photoSelectResult.photoUris[0];
        this.preload();
        if (this.selectFilePath === undefined) {
          try {
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.alert'),
              duration: 2000,
              bottom: 280
            });
          } catch (error) {
            hilog.error(0x0000, TAG, `showToast fail, error code is =${error.code}, message is = ${error.message}`);
          }
        } else {
          this.viewState = VideoStatus.OPTIMIZE_VIDEOS;
          await this.avPlayerController.initAVPlayer(this.XComponentSurfaceId, this.selectFilePath);
          this.avPlayerController.isPlaying = false;
          hilog.info(0x0000, TAG, 'documentViewPicker.select to file succeed and URI is:' + this.selectFilePath);
        }
      })
      .catch((error: BusinessError) => {
        hilog.error(0x0000, TAG,
          `photoPicker select fail, error code is =${error.code}, message is = ${error.message}`);
      })
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text(this.viewState === VideoStatus.OPTIMIZE_VIDEOS ? $r('app.string.original_video') :
            $r('app.string.Optimize_video'))
            .fontWeight(700)
            .fontSize(18)
            .margin({
              left: 16,
              bottom: 5
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Stack({ alignContent: Alignment.Center }) {
          Text() {
            SymbolSpan($r('sys.symbol.ohos_folder_badge_plus'))
              .fontWeight(FontWeight.Normal)
              .fontSize(40)
            Span($r('app.string.video_processing_before_are'))
          }
          .fontSize(14)
          .fontColor($r('app.color.video_processing_after_area_hint_font_color'))
          .textAlign(TextAlign.Center)
          .backgroundColor($r('app.color.video_processing_after_area_bg_color'))
          .width('100%')
          .height('100%')
          .visibility(this.viewState === VideoStatus.NO_VIDEO ? Visibility.Visible : Visibility.Hidden)

          XComponent({
            id: 'dstPlayer',
            type: XComponentType.SURFACE,
            controller: this.XComponentController,
            libraryname: 'player'
          })
            .width('100%')
            .height('100%')
            .visibility(this.viewState === VideoStatus.SELECTED_VIDEOS ? Visibility.Visible : Visibility.Hidden)

          XComponent({
            type: XComponentType.SURFACE,
            controller: this.XComponentController,
          })
            .width('100%')
            .height('100%')
            .visibility(this.viewState === VideoStatus.OPTIMIZE_VIDEOS ? Visibility.Visible : Visibility.Hidden)
            .onLoad(() => {
              this.XComponentSurfaceId = this.XComponentController.getXComponentSurfaceId();
            })
          if (!this.avPlayerController.isPlaying && this.viewState === VideoStatus.OPTIMIZE_VIDEOS) {
            Image($r('app.media.icon_pause'))
              .size({ width: 50, height: 50 })
          }
        }
        .onClick(() => {
          if (this.viewState === VideoStatus.NO_VIDEO) {
            this.selectFile();
          } else {
            this.avPlayerController.isPlaying === true ? this.avPlayerController.videoPause() :
              this.avPlayerController.videoPlay()
          }

        })
        .width('100%')
        .layoutWeight(1)

        Button($r('app.string.AVCodec_transcode'))
          .enabled(this.isHDRVivid)
          .width('100%')
          .constraintSize({ maxWidth: '100%' })
          .margin({
            left: 16,
            top: 12,
            right: 16
          })
          .fontWeight(500)
          .backgroundColor($r('app.color.button_bg_color'))
          .fontColor($r('app.color.button_text_color'))
          .onClick(() => {
            try {
              if (this.isProcessing) {
                this.getUIContext()
                  .getPromptAction()
                  .showToast({ message: $r('app.string.video_is_processing_try_later') });
                return;
              }
              if (this.selectFilePath === undefined) {
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.alert'),
                  duration: 2000,
                  bottom: 280
                })
              } else {
                this.targetType = 'SDR BT709';
                this.targetColorSpace = 8;
                this.processVideo(2);
              }
            } catch (error) {
              hilog.error(0x0000, TAG, `showToast fail, error code is =${error.code}, message is = ${error.message}`);
            }
          })
        Button($r('app.string.color_space_conversion'))
          .width('100%')
          .constraintSize({ maxWidth: '100%' })
          .margin({
            left: 16,
            top: 12,
            right: 16
          })
          .fontWeight(500)
          .backgroundColor($r('app.color.button_bg_color'))
          .fontColor($r('app.color.button_text_color'))
          .bindSheet($$this.colorSpaceIsShow, this.ColorSpaceMenu(), {
            detents: [SheetSize.FIT_CONTENT],
            backgroundColor: Color.White,
            blurStyle: BlurStyle.NONE,
            showClose: true,
            title: { title: $r('app.string.color_space_list') }
          })
          .onClick(() => {
            try {
              if (this.isProcessing) {
                this.getUIContext()
                  .getPromptAction()
                  .showToast({ message: $r('app.string.video_is_processing_try_later') });
                return;
              }
              if (this.selectFilePath === undefined) {
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.alert'),
                  duration: 2000,
                  bottom: 280
                })
              } else {
                this.colorSpaceIsShow = true;
              }
            } catch (error) {
              hilog.error(0x0000, TAG, `showToast fail, error code is =${error.code}, message is = ${error.message}`);
            }
          })
        Row() {
          Button($r('app.string.video_select_file'))
            .layoutWeight(1)
            .backgroundColor($r('app.color.button_bg_color'))
            .fontColor($r('app.color.button_text_color'))
            .fontWeight(500)
            .margin({ right: 6 })
            .enabled(this.viewState !== VideoStatus.NO_VIDEO ? true : false)
            .onClick(() => {
              this.selectFile();
            })
        }
        .justifyContent(FlexAlign.Center)
        .margin({
          left: 16,
          top: 12,
          right: 16
        })
      }
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .margin({
        bottom: '12vp'
      })
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}