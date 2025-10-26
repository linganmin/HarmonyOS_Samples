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

import { emitter } from '@kit.BasicServicesKit';
import { VideoData } from '../model/VideoData';
import VideoToolBar from './VideoToolBar';
import { AvPlayerController } from '../controller/AvPlayerController';
import { CommonConstants } from '../common/constants/CommonConstants';
import Logger from '../common/utils/Logger';
import { WindowUtil } from '../common/utils/WindowUtil';
import { media } from '@kit.MediaKit';
import { TimeUtil } from '../common/utils/TimeUtils';

const PROPORTION = 0.99; // Screen Percentage
const SURFACE_W = 0.9; // Surface width ratio
const SURFACE_H = 1.78; // Surface height ratio

const TAG = '[VideoPlayer]';

@Component
export struct VideoPlayer {
  @Prop videoData: VideoData;
  @State private surfaceW: number = 0;
  @State private surfaceH: number = 0;
  @State private percent: number = 1;
  @State toolBarBottomMargin: number = 20;
  @Link avPlayerController: AvPlayerController;
  private surfaceId: string = '';
  private componentWidth: number = 300;
  private componentHeight: number = 300;
  public xComponentController: XComponentController = new XComponentController();
  @State showPopup: boolean = false; // Control pop-up display
  private windowUtil: WindowUtil = WindowUtil.getInstance();
  @StorageLink('isFullLandscapeScreen') isFullLandscapeScreen: boolean =
    AppStorage.get('isFullLandscapeScreen') as boolean; //whether the video is played in full screen
  @State screenBrightness: number = 0; //screen luminance
  @State isSliding: boolean = false;
  @BuilderParam
  toolBarBuilder: () => void = this.defaultToolBarBuilder;

  @Builder
  defaultToolBarBuilder() {
    VideoToolBar({ avPlayerController: this.avPlayerController, isSliding: this.isSliding });
  }

  sizeChange() {
    this.setVideoWH();
  }

  aboutToAppear() {
    this.surfaceW = this.componentWidth * SURFACE_W;
    this.surfaceH = this.surfaceW / SURFACE_H;

    emitter.on(CommonConstants.AVPLAYER_PREPARED, (res) => {
      if (res.data) {
        this.percent = res.data.percent;
        this.setVideoWH();
      }
    });
  }

  aboutToDisappear() {
    this.avPlayerController.videoRelease();
    emitter.off(CommonConstants.AVPLAYER_PREPARED.eventId);
  }

  onPageHide(): void {
    this.avPlayerController.videoPause();
  }

  setVideoWH(): void {
    let componentPercent = this.componentWidth / this.componentHeight;

    if (componentPercent <= this.percent) {
      this.surfaceW = Math.round(this.componentWidth * PROPORTION);
      this.surfaceH = Math.round(this.surfaceW / this.percent);
    } else {
      this.surfaceH = Math.round(this.componentHeight * PROPORTION);
      this.surfaceW = Math.round(this.surfaceH * this.percent);
    }
  }

  @Builder
  showFeatureIcon(src: ResourceStr, content?: ResourceStr) {
    Column() {
      Image(src)
        .width(30)
      if (content) {
        Text(content)
          .fontSize(14)
          .lineHeight(19)
          .fontColor(Color.White)
          .margin({ top: 5 })
      }
    }
  }

  @Builder
  CoverXComponent() {
    XComponent({
      // Loading the video container
      id: 'xComponent',
      type: XComponentType.SURFACE,
      controller: this.xComponentController
    })
      .onLoad(async () => {
        this.surfaceId = this.xComponentController.getXComponentSurfaceId();
        // Creates the avPlayer instance object.
        try {
          let avPlayer = await media.createAVPlayer();
          this.avPlayerController.initAVPlayer(avPlayer, this.videoData as VideoData, this.surfaceId);
        } catch (error) {
          Logger.error(TAG, `createAVPlayer err: ${error.message}`);
        }
      })
      .height(this.surfaceH)
      .width(this.surfaceW)
  }

  build() {
    Column() {
      Stack() {
        Column() {
          this.CoverXComponent()
        }
        .height('100%')
        .justifyContent(FlexAlign.Center)

        if (!this.avPlayerController.isPlaying) {
          Image($r('app.media.icon_pause'))
            .size({ width: 50, height: 50 })
        }

        Text()
          .height(this.surfaceH)
          .width(this.surfaceW)
          .backgroundColor("#EFEFEF")
          .opacity(0.5)
          .visibility(this.isSliding ? Visibility.Visible : Visibility.Hidden)

        Row() {
          Text(TimeUtil.millisecondsToTime(this.avPlayerController.currentTime))
            .id("currentTime")
            .fontSize(24)
            .opacity(1)
            .fontColor($r('app.color.default_select_color_show'))
          Text("/" + TimeUtil.millisecondsToTime(this.avPlayerController.durationTime))
            .id("durationTime")
            .fontSize(24)
            .opacity($r('app.float.size_1'))
            .fontColor(Color.White)
        }
        .visibility(this.isSliding ? Visibility.Visible : Visibility.Hidden)

        RelativeContainer() {
          Column({ space: 20 }) {
            Image($r('app.media.menu_icon_user_avatar')).width(44)
            this.showFeatureIcon($r('app.media.menu_icon_like'), '1557')
            this.showFeatureIcon($r('app.media.menu_icon_comment'), '566')
            this.showFeatureIcon($r('app.media.menu_icon_share'), '147')
            Image($r('app.media.menu_icon_music_cover')).width(32)
          }
          .alignRules({
            right: { anchor: '__container__', align: HorizontalAlign.End },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
          })
          .margin({ right: 8, bottom: 90 })
          .visibility(this.isFullLandscapeScreen ? Visibility.None : Visibility.Visible)
        }

        Column() {
          Blank()
          Column() {
            Stack({ alignContent: Alignment.Center }) {
              Text(this.avPlayerController.currentCaption || '')
                .fontColor(Color.White)
                .fontSize($r('app.float.size_20'))
                .fontFamily('Sans')
            }
            .margin({ left: -20 })
            .zIndex(1)
            .width('80%')

            // Progress bar
            this.toolBarBuilder();
          }.margin({ bottom: this.toolBarBottomMargin })
        }.height('100%')
        .justifyContent(FlexAlign.End)

        Button({ type: ButtonType.Circle }) {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .fillColor(Color.White)
            .width($r('app.float.size_25'))
            .height($r('app.float.size_25'))
        }
        .width($r('app.float.size_40'))
        .height($r('app.float.size_40'))
        .backgroundColor($r('app.color.white_opacity_1_color'))
        .position({
          x: $r('app.float.size_25'),
          y: $r('app.float.size_25')
        })
        .onClick(() => {
          this.windowUtil.handleFullScreenExit(false);
        })
        .visibility(this.isFullLandscapeScreen ? Visibility.Visible : Visibility.Hidden)
      }
      .onClick(() => {
        this.avPlayerController.isPlaying === true ? this.avPlayerController.videoPause() :
        this.avPlayerController.videoPlay()
      })

    }
    .backgroundColor(Color.Black)
    .height('auto')
    .width('auto')
    .position({ x: 0, y: 0 })
    .onSizeChange((_oldValue: SizeOptions, newValue: SizeOptions) => {
      this.componentWidth = newValue.width as number;
      this.componentHeight = newValue.height as number;
      this.setVideoWH();
    })
  }
}
