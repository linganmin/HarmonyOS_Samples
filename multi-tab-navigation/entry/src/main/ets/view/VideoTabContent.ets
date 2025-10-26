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

import { display } from '@kit.ArkUI';
import { Side } from './Side';
import { VideoDes } from './VideoDes';
import { TopView } from './TopView';
import { TabContentConstants } from '../common/TabContentConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct VideoTabContent {
  // Used to record the real-time dragging distance.
  @State offsetX: number = 0;
  // Used to record the distance after dragging.
  @State positionX: number = 0;
  // Used to control the playback status.
  @State isPlay: boolean = false;
  // Used to record the current playback time.
  @State playTime: string = '';
  @State isTouch: boolean = false;
  // Used to record the total duration of a video.
  @State totalTime: number = 0;
  @State isTextButtonVisible: boolean = true;
  private videoController: VideoController = new VideoController();
  // Sets the dragging direction.
  private panOption: PanGestureOptions = new PanGestureOptions({
    direction: PanDirection.Left | PanDirection.Right
  });
  // Obtains the device width.
  private screenW: number = 0;

  aboutToAppear(): void {
    try {
      this.screenW = this.getUIContext().px2vp(display.getDefaultDisplaySync().width);
    } catch (error) {
      hilog.error(0x0000, 'testTag',`getDefaultDisplaySync failed, Code:${error.code}, message:${error.message}`);
    }
  }

  private dragAnimation() {
    this.getUIContext().animateTo({
      duration: TabContentConstants.TAB_TOAST_DURATION,
      curve: Curve.EaseOut
    }, () => {
      this.isTouch = true;
    });
  }

  build() {
    RelativeContainer() {
      Video({
        src: $rawfile('tab_play_video.MP4'),
        currentProgressRate: PlaybackSpeed.Speed_Forward_1_00_X,
        previewUri: $r('app.media.tab_preview'),
        controller: this.videoController
      })
        .height($r('app.string.tab_video_height'))
        .width($r('app.string.tab_full_size'))
        .objectFit(ImageFit.Cover)
        .autoPlay(false)
        .controls(false)
        .onPrepared((event) => {
          if (event !== undefined) {
            this.totalTime = event.duration;
          }
        })
        .onFinish(() => {
          this.isPlay = false;
        })
        .onUpdate((event) => {
          if (event !== undefined) {
            if (!this.isTouch) {
              // The progress bar changes according to the playback progress.
              this.offsetX =
                event.time / this.totalTime * (this.screenW - TabContentConstants.TAB_INTERVAL_NUMBER);
              this.positionX = this.offsetX;
            }
          }
        })
        .id(TabContentConstants.TAB_VIDEO)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_CONTAINER, align: VerticalAlign.Top },
          left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start }
        })
        .onClick(() => {
          if (this.isPlay) {
            this.isPlay = false;
            this.videoController.pause();
          } else {
            this.isPlay = true;
            this.videoController.start();
          }
        })
      // Play button.
      Image($r('app.media.tab_play'))
        .width($r('app.integer.tab_image_width'))
        .height($r('app.integer.tab_image_height'))
        .alignRules({
          top: { anchor: TabContentConstants.TAB_VIDEO, align: VerticalAlign.Top },
          bottom: { anchor: TabContentConstants.TAB_VIDEO, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start },
          right: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.End }
        })
        .id(TabContentConstants.TAB_IMAGE)
        .onClick(() => {
          if (this.isPlay) {
            this.isPlay = false;
            this.videoController.pause();
          } else {
            this.isPlay = true;
            this.videoController.start();
          }
        })
        .visibility(this.isPlay ? Visibility.Hidden : Visibility.Visible)

      // Displaying Video Information.
      VideoDes()
        .alignRules({
          bottom: { anchor: TabContentConstants.TAB_VIDEO, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start }
        })
        .id(TabContentConstants.TAB_VIDEO_DES)
        .margin({ bottom: $r('app.integer.tab_video_des_margin_bottom') })
        .visibility(this.isTouch ? Visibility.Hidden : Visibility.Visible)

      // Display information on the right of the video playback page.
      Side()
        .alignRules({
          top: { anchor: TabContentConstants.TAB_VIDEO, align: VerticalAlign.Center },
          right: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.End }
        })
        .id(TabContentConstants.TAB_SIDE)
        .margin({ top: $r('app.integer.tab_side_margin_top') })
        .visibility(this.isTouch ? Visibility.Hidden : Visibility.Visible)

      TopView()
        .alignRules({
          top: { anchor: TabContentConstants.TAB_VIDEO, align: VerticalAlign.Top },
          left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start }
        })
        .id(TabContentConstants.TAB_TOP_VIEW)

      // Displaying the current time point when the progress bar is dragged.
      Text(TabContentConstants.TAB_PLAYTIME_TEXT + this.playTime)
        .fontSize($r('app.integer.tab_play_time_text_font_size'))
        .width($r('app.integer.tab_play_time_text_width'))
        .height($r('app.integer.tab_play_time_text_height'))
        .textAlign(TextAlign.End)
        .id(TabContentConstants.TAB_PLAYTIME_TEXT_ID)
        .fontColor($r('app.color.tab_play_time_text_color'))
        .alignRules({
          top: { anchor: TabContentConstants.TAB_VIDEO, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Center }
        })
        .visibility(this.isTouch ? Visibility.Visible : Visibility.Hidden)
        .margin({
          left: $r('app.integer.tab_play_time_text_margin'),
          top: $r('app.integer.tab_play_time_text_margin')
        })
      // Displaying the total video duration when the progress bar is dragged.
      Text(TabContentConstants.TAB_TOTAL_TIME_TEXT + this.totalTime)
        .fontSize($r('app.integer.tab_play_time_text_font_size'))
        .width($r('app.integer.tab_play_time_text_width'))
        .height($r('app.integer.tab_play_time_text_height'))
        .textAlign(TextAlign.Start)
        .id(TabContentConstants.TAB_TOTAL_TIME_TEXT_ID)
        .fontColor($r('app.color.tab_total_time_text_color'))
        .alignRules({
          top: { anchor: TabContentConstants.TAB_PLAYTIME_TEXT_ID, align: VerticalAlign.Top },
          left: { anchor: TabContentConstants.TAB_PLAYTIME_TEXT_ID, align: HorizontalAlign.End }
        })
        .visibility(this.isTouch ? Visibility.Visible : Visibility.Hidden)

      RelativeContainer() {
        Text()
          .width(this.screenW - TabContentConstants.TAB_INTERVAL_NUMBER)
          .height(this.isTouch ? $r('app.integer.tab_text1_touch_height') :
            $r('app.integer.tab_text1_height'))
          .borderRadius(this.isTouch ? $r('app.integer.tab_text1_touch_border_radius') :
            $r('app.integer.tab_text1_border_radius'))
          .backgroundColor($r('app.color.tab_text1_background_color'))
          .translate({
            y: this.isTouch ? TabContentConstants.TAB_TEXT_TOUCH_TRANSLATE :
              TabContentConstants.TAB_TEXT_TRANSLATE
          })
          .id(TabContentConstants.TAB_TEXT_ONE_ID)
          .margin({
            top: $r('app.integer.tab_text1_margin_top'),
            left: $r('app.integer.tab_text1_margin_left')
          })
        Text()
          .width(this.offsetX)
          .height(this.isTouch ? $r('app.integer.tab_text1_touch_height') :
            $r('app.integer.tab_text1_height'))
          .borderRadius($r('app.integer.tab_text1_border_radius'))
          .backgroundColor($r('app.color.tab_text2_background_color'))
          .translate({
            y: this.isTouch ? TabContentConstants.TAB_TEXT_TOUCH_TRANSLATE :
              TabContentConstants.TAB_TEXT_TRANSLATE
          })
          .id(TabContentConstants.TAB_TEXT_TWO_ID)
          .alignRules({
            top: { anchor: TabContentConstants.TAB_TEXT_ONE_ID, align: VerticalAlign.Top },
            left: { anchor: TabContentConstants.TAB_TEXT_ONE_ID, align: HorizontalAlign.Start }
          })
        Text()
          .width($r('app.integer.tab_text3_width'))
          .height($r('app.integer.tab_text3_height'))
          .borderRadius($r('app.integer.tab_text3_border_radius'))
          .backgroundColor(Color.White)
          .translate({ x: this.offsetX })
          .visibility(this.isTextButtonVisible ? Visibility.Visible : Visibility.None)
          .id(TabContentConstants.TAB_TEXT_THREE_ID)
          .alignRules({
            top: { anchor: TabContentConstants.TAB_TEXT_ONE_ID, align: VerticalAlign.Top },
            left: { anchor: TabContentConstants.TAB_TEXT_ONE_ID, align: HorizontalAlign.Start }
          })
          .margin({
            top: TabContentConstants.TAB_TEXT_THREE_MARGIN_TOP,
            left: TabContentConstants.TAB_TEXT_THREE_MARGIN_LEFT
          })
      }
      .id(TabContentConstants.TAB_RELATIVE_CONTAINER)
      .alignRules({
        top: { anchor: TabContentConstants.TAB_VIDEO, align: VerticalAlign.Bottom },
        left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start }
      })
      .width(this.screenW)
      .height($r('app.integer.tab_tabBar_height'))
      .gesture(
        PanGesture(this.panOption)
          .onActionStart(() => {
            this.dragAnimation();
            this.isTextButtonVisible = false;
          })
          .onActionUpdate((event: GestureEvent) => {
            let playTime =
              Math.floor(this.offsetX / (this.screenW - TabContentConstants.TAB_INTERVAL_NUMBER) * this.totalTime);
            this.offsetX = this.positionX + event.offsetX;
            if (this.offsetX <= TabContentConstants.TAB_ZERO) {
              this.offsetX = TabContentConstants.TAB_ZERO;
            }
            if (this.offsetX >= this.screenW - TabContentConstants.TAB_INTERVAL_NUMBER) {
              this.offsetX = this.screenW - TabContentConstants.TAB_INTERVAL_NUMBER;
            }
            if (playTime >= TabContentConstants.TAB_TEN) {
              this.playTime = playTime.toString();
            } else {
              this.playTime = TabContentConstants.TAB_TIME_ZERO + playTime.toString();
            }
            this.videoController.setCurrentTime(this.offsetX /
              (this.screenW - TabContentConstants.TAB_INTERVAL_NUMBER) * this.totalTime, SeekMode.Accurate);
          })
          .onActionEnd(() => {
            this.positionX = this.offsetX;
            this.isTextButtonVisible = true;
            this.isTouch = false;
          })
      )
    }
  }
}