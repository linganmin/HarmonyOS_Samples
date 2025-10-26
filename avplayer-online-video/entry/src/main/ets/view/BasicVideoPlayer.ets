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

import { display } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { AvPlayerController } from '../controller/AvPlayerController';
import { VideoOperate } from '../components/VideoOperate';
import { ExitVideo } from '../components/ExitVideo';
import { SetVolume } from '../components/SetVolume'
import { TimeUtil } from '../common/utils/TimeUtils';
import { GlobalContext } from '../common/utils/GlobalContext';
import { CommonConstants } from '../common/constants/CommonConstants';
import { VideoData } from '../model/VideoData';
import { BulletCommentView } from '../components/BulletCommentView';
import { BulletComment } from '../model/BulletCommentModel';
import { PiPWindowController } from '../controller/PipWindowController';
import { SetBrightness } from '../components/SetBirghness';

const SURFACE_WIDTH = 0.9; // Surface width ratio
const SURFACE_HEIGHT = 1.78; // Surface height ratio
const TIMEOUT = 0; // Timer ID
const SET_TIME_OUT = 8000; // Interval: 8s
const SET_VOLUME_TIME_OUT = 5000 // VolumeTimer: 5s
const TAG = '[BasicVideoPlayer]';

@Component
export struct BasicVideoPlayer {
  @Consume('systemStatusAreaHeight') systemStatusAreaHeight: number;
  @Prop videoData: VideoData;
  @State isSwiping: boolean = false;
  @State isClickScreen: boolean = false;
  @State @Watch('onIsFullScreenChange') isFullScreen: boolean = false;
  @State surfaceW: number = 0;
  @State surfaceH: number = 0;
  @State volume: number = 5;
  @State volumeVisible: boolean = false
  @State show: boolean = false; // Indicates whether the videoPanel component is displayed.
  @State percent: number = 0;
  @State windowWidth: number = 300;
  @State windowHeight: number = 300;
  @State isCalcWHFinished: boolean = false;
  @State bulletComments: BulletComment[] = []; //bullet comments storage array
  @State showBulletComment: boolean = true; //whether to show bullet comments
  @State brightnessVisible: boolean = false; //whether to show slider/image
  @State screenBrightness: number = 0; //screen luminance
  private screenHeight: number = 0; //screen height
  @Link avPlayerController: AvPlayerController;
  private uiAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private windowClass = this.uiAbilityContext.windowStage.getMainWindowSync();
  private surfaceId: string = '';
  private timeout: number = 0; // Timer ID
  private volumeTimeout: number = 0; // VolumeTimer ID
  private xComponentController: XComponentController = new XComponentController();
  private pipWindowController: PiPWindowController =
    new PiPWindowController(this.avPlayerController, this.xComponentController); //the instance of picture in picture

  onIsFullScreenChange() {
    if (this.isFullScreen) {
      this.screenHeight = this.windowClass.getWindowProperties().windowRect.width;
    } else {
      this.screenHeight = this.windowClass.getWindowProperties().windowRect.height;
    }
  }

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
    this.windowWidth = display.getDefaultDisplaySync().width;
    this.windowHeight = display.getDefaultDisplaySync().height;
    this.surfaceW = (GlobalContext.getContext().getObject('windowWidth') as number) * SURFACE_WIDTH;
    this.surfaceH = this.surfaceW / SURFACE_HEIGHT;
    this.avPlayerController.isPlaying = true;

    this.screenHeight = this.windowClass.getWindowProperties().windowRect.height;

    // listen rotation
    display.on('change', async () => {
      let rotation = await display.getDefaultDisplaySync().rotation;
      if (rotation === 0 || rotation === 2) {
        this.isFullScreen = false;
      } else {
        this.isFullScreen = true;
      }
    });

    emitter.on(CommonConstants.AVPLAYER_PREPARED, (res) => {
      if (res.data) {
        this.percent = res.data.percent;
        this.setVideoWH();
        this.isCalcWHFinished = true;
      }
    });
    emitter.on(CommonConstants.innerEventTrue, (res) => {
      if (res.data) {
        this.avPlayerController.isPlaying = res.data.flag;
      }
    });
    emitter.on(CommonConstants.innerEventFalse, (res) => {
      if (res.data) {
        this.avPlayerController.isPlaying = res.data.flag;
      }
    });
    emitter.on(CommonConstants.innerEventWH, (res) => {
      if (res.data) {
        this.windowWidth = res.data.width;
        this.windowHeight = res.data.height;
        this.setVideoWH();
      }
    });
    if (!this.avPlayerController.isPlaying) {
      this.clearTimer();
    }

    this.pipWindowController.createPipController();
  }

  aboutToDisappear() {
    this.avPlayerController.videoRelease();
    emitter.off(CommonConstants.innerEventFalse.eventId);
    emitter.off(CommonConstants.innerEventTrue.eventId);
    emitter.off(CommonConstants.innerEventFalse.eventId);
    emitter.off(CommonConstants.innerEventWH.eventId);

    display.off('change');

    this.pipWindowController.destroyPipController();
  }

  onPageHide() {
    this.avPlayerController.videoPause();
  }

  setVideoWH(): void {
    if (this.percent >= 1) { // Horizontal video
      this.surfaceW = Math.round(this.windowWidth);
      this.surfaceH = Math.round(this.surfaceW / this.percent);
    } else { // Vertical video
      this.surfaceH = Math.round(this.windowHeight);
      this.surfaceW = Math.round(this.surfaceH * this.percent);
    }
  }

  @BuilderParam
  progressBuilder?: () => void;

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
        this.avPlayerController.initAVPlayer(this.videoData, this.surfaceId);
      })
      .height(this.isCalcWHFinished ? `${this.surfaceH}px` : '100%')
      .width(this.isCalcWHFinished ? `${this.surfaceW}px` : '100%')
  }

  build() {
    Stack() {

      Column() {
        this.CoverXComponent()
      }
      .align(Alignment.TopStart)
      .margin({ top: $r('app.float.size_80') })
      .id('Video')
      .justifyContent(FlexAlign.Center)

      if (this.isFullScreen) {
        Row() {
          SetVolume({ volume: this.volume, volumeVisible: this.volumeVisible }).width('50%')
          SetBrightness({ screenBrightness: this.screenBrightness, visible: this.brightnessVisible }).width('50%')
        }
        .width('100%')
        .height('100%')
      }

      if (this.isFullScreen) {
        BulletCommentView({
          bulletComments: this.bulletComments,
          showBulletComment: this.showBulletComment,
        })
          .width('100%')
          .height(200)
          .position({ x: '0%', y: '5%' })
      }

      Text()
        .height(`${this.surfaceH}px`)
        .width(`${this.surfaceW}px`)
        .margin({ top: $r('app.float.size_80') })
        .backgroundColor(Color.Black)
        .opacity($r('app.float.size_zero_five'))
        .visibility(this.isSwiping ? Visibility.Visible : Visibility.Hidden)

      Row() {
        Text(TimeUtil.millisecondsToTime(this.avPlayerController.currentTime))
          .fontSize($r('app.float.size_24'))
          .opacity($r('app.float.size_1'))
          .fontColor($r('app.color.slider_selected'))
        Text('/' + TimeUtil.millisecondsToTime(this.avPlayerController.durationTime))
          .fontSize($r('app.float.size_24'))
          .opacity($r('app.float.size_1'))
          .fontColor(Color.White)
      }
      .margin({ top: $r('app.float.size_80') })
      .visibility(this.isSwiping ? Visibility.Visible : Visibility.Hidden)

      Column() {
        if (this.isClickScreen) {
          Row() {
            ExitVideo({ videoName: this.videoData.name, isFullScreen: this.isFullScreen })
          }
          .padding({ top: `${this.systemStatusAreaHeight}px` })
          .width('100%')
          .justifyContent(FlexAlign.Start)
        }

        Blank()
        if (this.isFullScreen) {
          Column() {
            Text(this.avPlayerController.currentCaption || '')
              .fontColor(Color.White)
              .fontSize($r('app.float.size_20'))
              .fontFamily('Sans')
          }
          .width('100%')
          .margin({ bottom: 20 })
        }

        if (this.isClickScreen) {
          Column() {
            // Progress bar
            if (this.progressBuilder) {
              VideoOperate({
                avPlayerController: this.avPlayerController,
                isSwiping: this.isSwiping,
                isFullScreen: this.isFullScreen,
                bulletComments: this.bulletComments,
                progressBuilder: this.progressBuilder
              })
                .width('100%')
            } else {
              VideoOperate({
                avPlayerController: this.avPlayerController,
                isSwiping: this.isSwiping,
                isFullScreen: this.isFullScreen,
                bulletComments: this.bulletComments,
              })
                .width('100%')
            }

          }
          .justifyContent(FlexAlign.Center)
        }
      }
      .onTouch((event: TouchEvent) => {
        if (event.type == TouchType.Down || event.type == TouchType.Move) {
          this.isClickScreen = true;
          this.clearTimer();
        } else if (event.type == TouchType.Up) {
          this.setTimer();
        }
      })
      .height('100%')
      .width('100%')
    }
    // [Start SetScreenBrightnessPanGesture]
    .gesture(
      //sliding in the vertical direction
      PanGesture({ direction: PanDirection.Vertical })
        .onActionStart(() => {
        })
        .onActionUpdate((event: GestureEvent) => {
          //the area on the right side of the screen
          if (event.fingerList[0].globalX > (820 / 2)) {
            this.brightnessVisible = true;
            let curBrightness = this.screenBrightness -
              this.getUIContext().vp2px(event.offsetY) / this.screenHeight;
            curBrightness = curBrightness >= 1.0 ? 1.0 : curBrightness;
            curBrightness = curBrightness <= 0.0 ? 0.0 : curBrightness;
            this.screenBrightness = curBrightness;
            hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'this brightness is: ' + this.screenBrightness);

          } else {
            this.brightnessVisible = false;
            let curVolume = this.volume - this.getUIContext().vp2px(event.offsetY) / this.screenHeight;
            curVolume = curVolume >= 15.0 ? 15.0 : curVolume;
            curVolume = curVolume <= 0.0 ? 0.0 : curVolume;
            this.volume = curVolume;
            hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'this volume is: ' + this.volume);
          }
        })
        .onActionEnd(() => {
          setTimeout(() => {
            this.brightnessVisible = false;
          }, 3000)
        })
    )

    // [Start long_press_gesture]
    .gesture(
      LongPressGesture({ repeat: true })
        .onAction(() => {
          this.avPlayerController.videoSpeedTwo();
          AppStorage.setOrCreate('speedName', $r('app.string.video_speed_2_0X'));
          AppStorage.setOrCreate('speedIndex', 3);
        })
        .onActionEnd(() => {
          this.avPlayerController.videoSpeedOne();
          AppStorage.setOrCreate('speedName', $r('app.string.video_speed_1_0X'));
          AppStorage.setOrCreate('speedIndex', 0);
        })
    )
    // [End long_press_gesture]
    .backgroundColor(Color.Black)
    .height('100%')
    .width('100%')
  }
}