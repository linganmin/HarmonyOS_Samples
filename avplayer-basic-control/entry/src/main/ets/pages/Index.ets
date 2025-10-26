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

import { connection } from '@kit.NetworkKit';
import { display } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { media } from '@kit.MediaKit';
import { AvPlayerController } from '../controller/AvPlayerController';
import { VideoOperate } from '../views/VideoOperate';
import { SetVolume } from '../views/SetVolume'
import { timeConvert } from '../common/utils/TimeUtils';
import { GlobalContext } from '../common/utils/GlobalContext';
import { VideoDataType, CommonConstants } from '../common/constants/CommonConstants';
import { VideoData } from '../model/VideoData';

const PROPORTION = 0.99; // Screen Percentage
const SURFACE_WIDTH = 0.9; // Surface width ratio
const SURFACE_HEIGHT = 1.78; // Surface height ratio
const TIMEOUT = 0; // Timer ID
const SET_TIME_OUT = 8000; // Interval: 8s
const SET_INTERVAL = 100;
const SET_VOLUME_TIME_OUT = 5000 // VolumeTimer: 5s
const TAG = '[Index]';
const CASE_ZERO = 0;
const CASE_THREE = 3;

@Entry
@Component
struct Index {
  @State avPlayerController: AvPlayerController = new AvPlayerController()
  @State isSwiping: boolean = false;
  @State isClickScreen: boolean = false;
  @State flag: boolean = true; // Pause Playback
  @State XComponentFlag: boolean = false;
  @State speedList: Resource[] =
    [$r('app.string.video_speed_1_0X'), $r('app.string.video_speed_1_25X'), $r('app.string.video_speed_1_75X'),
      $r('app.string.video_speed_2_0X')];
  @State @Watch('onSpeedSelectUpdate') speedSelect: number = 0;
  @State durationTime: number = 0;
  @State currentTime: number = 0;
  @State surfaceW: number = 0;
  @State surfaceH: number = 0;
  @State @Watch('onVolumeUpdate') volume: number = 5;
  @State volumeVisible: boolean = false
  @State show: boolean = false; // Indicates whether the videoPanel component is displayed.
  @State percent: number = 0;
  @State windowWidth: number = 300;
  @State windowHeight: number = 300;
  @State isCalcWHFinished: boolean = false;
  @Provide videoScaleType: number = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT;
  @Provide speedName: Resource = $r('app.string.video_speed_1_0X');
  @Provide speedIndex: number = 0;
  @Provide isMuted: boolean = false;
  @Provide currentLanguageType: number = 0;
  private surfaceId: string = '';
  private timeout: number = 0; // Timer ID
  private volumeTimeout: number = 0; // VolumeTimer ID
  private xComponentController: XComponentController = new XComponentController();

  setTimer(): void {
    let that = this;
    this.timeout = setTimeout(() => {
      that.isClickScreen = false; // Hide the operation panel
    }, SET_TIME_OUT); // Hide in 8 seconds
  }

  clearTimer(): void {
    if (this.timeout !== TIMEOUT) {
      clearTimeout(this.timeout);
      this.timeout = TIMEOUT;
    }
  }

  setVolumeTimer(): void {
    this.volumeTimeout = setTimeout(() => {
      this.volumeVisible = false
    }, SET_VOLUME_TIME_OUT)
  }

  clearVolumeTimer(): void {
    if (this.volumeTimeout !== TIMEOUT) {
      clearTimeout(this.volumeTimeout);
      this.volumeTimeout = TIMEOUT;
    }
  }

  aboutToAppear() {
    try {
      this.windowWidth = display.getDefaultDisplaySync().width;
      this.windowHeight = display.getDefaultDisplaySync().height;
    } catch (err) {
      hilog.error(CommonConstants.LOG_DOMAIN, TAG,
        `getDefaultDisplaySync failed, code is ${err.code}, message is ${err.message}`);
    }
    this.surfaceW = (GlobalContext.getContext().getObject('windowWidth') as number) * SURFACE_WIDTH;
    this.surfaceH = this.surfaceW / SURFACE_HEIGHT;
    this.flag = true;
    AppStorage.setOrCreate('avPlayerController', this.avPlayerController);
    emitter.on(CommonConstants.AVPLAYER_PREPARED, (res) => {
      if (res.data) {
        this.percent = res.data.percent;
        this.setVideoWH();
        this.isCalcWHFinished = true;
        this.durationTime = this.avPlayerController.durationTime;
        setInterval(() => { // Update the current time.
          if (!this.isSwiping) {
            this.currentTime = this.avPlayerController.currentTime;
          }
        }, SET_INTERVAL);
      }
    });
  }

  aboutToDisappear() {
    this.avPlayerController.videoRelease();
    emitter.off(CommonConstants.innerEventFalse.eventId);
  }

  onPageHide() {
    this.avPlayerController.videoPause();
    this.flag = false;
  }

  onPageShow() {
    emitter.on(CommonConstants.innerEventTrue, (res) => {
      if (res.data) {
        this.flag = res.data.flag;
        this.XComponentFlag = res.data.flag;
      }
    });
    emitter.on(CommonConstants.innerEventFalse, (res) => {
      if (res.data) {
        this.flag = res.data.flag;
      }
    });
    emitter.on(CommonConstants.innerEventWH, (res) => {
      if (res.data) {
        this.windowWidth = res.data.width;
        this.windowHeight = res.data.height;
        this.setVideoWH();
      }
    });
    if (this.flag === false) {
      this.clearTimer();
    }
  }

  setVideoWH(): void {
    if (this.percent >= 1) { // Horizontal video
      this.surfaceW = Math.round(this.windowWidth * PROPORTION);
      this.surfaceH = Math.round(this.surfaceW / this.percent);
    } else { // Vertical video
      this.surfaceH = Math.round(this.windowHeight * PROPORTION);
      this.surfaceW = Math.round(this.surfaceH * this.percent);
    }
  }

  onSpeedSelectUpdate() {
    this.speedName = this.speedList[this.speedSelect]
    this.speedIndex = this.speedSelect
  }

  onVolumeUpdate() {
    this.isMuted = this.volume <= 0.0
    this.avPlayerController.videoMuted(this.volume <= 0.0);
  }

  async isInternet(): Promise<boolean> {
    try {
      if (connection.getAllNetsSync().length <= 0) {
        this.toast();
        return false
      }
    } catch (err) {
      hilog.error(CommonConstants.LOG_DOMAIN, TAG,
        `getAllNetsSync failed, code is ${err.code}, message is ${err.message}`);
    }
    return true;
  }

  async toast() {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: $r('app.string.video_warn'),
        duration: 2000,
      });
    } catch (err) {
      hilog.error(CommonConstants.LOG_DOMAIN, TAG,
        `showToast failed, code is ${err.code}, message is ${err.message}`);
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
      .onLoad(() => {
        this.surfaceId = this.xComponentController.getXComponentSurfaceId();
        let source: VideoData = {
          type: VideoDataType.RAW_FILE,
          videoSrc: 'test1.mp4',
          name: $r('app.string.local_video'),
          description: '',
          caption: 'captions.srt',
          index: 0
        }
        this.avPlayerController.initAVPlayer(source, this.surfaceId);
      })
      .height(this.videoScaleType === 0 ? (this.isCalcWHFinished ? `${this.surfaceH}px` : '100%') : null)
      .width(this.videoScaleType === 0 ? (this.isCalcWHFinished ? `${this.surfaceW}px` : '100%') : null)
  }

  build() {
    Stack() {
      SetVolume({ volume: this.volume, volumeVisible: this.volumeVisible })

      Column() {
        // [Start currentCaptionText]
        Stack({ alignContent: Alignment.Center }) {
          Text(this.avPlayerController.currentCaption)
            .fontColor(Color.White)
            .fontSize($r('app.float.size_20'))
            .fontFamily('Sans')
        }
        .width('100%')
        .position({ x: $r('app.float.size_zero'), y: $r('app.float.size_216') })
        .zIndex(1)

        // [End currentCaptionText]

        this.CoverXComponent()
      }
      // [Start pan_gesture]
      .gesture(
        PanGesture({ direction: PanDirection.Vertical })
          .onActionStart(() => {
          })
          .onActionUpdate((event: GestureEvent) => {
            this.volumeVisible = true;
            let curVolume = this.volume - this.getUIContext().vp2px(event.offsetY) / this.windowHeight;
            curVolume = curVolume >= 15.0 ? 15.0 : curVolume;
            curVolume = curVolume <= 0.0 ? 0.0 : curVolume;
            this.volume = curVolume;
          })
          .onActionEnd(() => {
            this.setVolumeTimer();
          })
      )
      // [End pan_gesture]
      .align(Alignment.TopStart)
      .margin({ top: $r('app.float.size_80') })
      .id('Video')
      .justifyContent(FlexAlign.Center)

      Row() {
        Text(timeConvert(this.currentTime))
          .fontSize($r('app.float.size_24'))
          .opacity($r('app.float.size_1'))
          .fontColor($r('app.color.slider_selected'))
        Text('/' + timeConvert(this.durationTime))
          .fontSize($r('app.float.size_24'))
          .opacity($r('app.float.size_1'))
          .fontColor(Color.White)
      }
      .height($r('app.float.size_50'))
      .backgroundColor('#90000000')
      .borderRadius(10)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .margin({ top: $r('app.float.size_80') })
      .padding({ left: $r('app.float.size_15'), right: $r('app.float.size_15') })
      .visibility(this.isSwiping ? Visibility.Visible : Visibility.Hidden)

      Column() {
        Blank()
        Column() {
          // Progress bar
          VideoOperate({
            flag: this.flag,
            avPlayerController: this.avPlayerController,
            currentTime: this.currentTime,
            durationTime: this.durationTime,
            isSwiping: this.isSwiping,
            XComponentFlag: this.XComponentFlag
          })
            .width('100%')
        }
        .justifyContent(FlexAlign.Center)
      }
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.isClickScreen = true;
          this.clearTimer();
        } else if (event.type === TouchType.Up) {
          this.setTimer();
        } else if (event.type === TouchType.Move) {
          this.isClickScreen = true;
          this.clearTimer();
        }
      })
      .visibility(this.isClickScreen ? Visibility.Visible : Visibility.Hidden)
      .width('100%')
      .height('100%')
    }
    .onClick(() => {
      this.isClickScreen = !this.isClickScreen;
      if (this.isClickScreen) {
        this.setTimer();
      } else {
        this.clearTimer();
      }
    })
    // [Start long_press_gesture]
    .gesture(
      LongPressGesture({ repeat: true })
        .onAction(() => {
          this.speedSelect = CASE_THREE
          this.avPlayerController.videoSpeed(media.PlaybackSpeed.SPEED_FORWARD_2_00_X);
        })
        .onActionEnd(() => {
          this.speedSelect = CASE_ZERO
          this.avPlayerController.videoSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_00_X);
        })
    )
    // [End long_press_gesture]
    .backgroundColor(Color.Black)
    .height('100%')
    .width('100%')
    .padding({ top: '36vp' })
  }
}