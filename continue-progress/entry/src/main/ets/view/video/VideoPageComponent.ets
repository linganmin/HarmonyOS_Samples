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

import { media } from '@kit.MediaKit';
import { connection } from '@kit.NetworkKit';
import { display, promptAction } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import avPlayManage from '../../viewmodel/video/AvPlayManager';
import { VideoOperate } from './VideoOperate';
import { ExitVideo } from './ExitVideo';
import { timeConvert } from '../../utils/TimeUtils';
import { GlobalContext } from '../../utils/GlobalContext';
import { hilog } from '@kit.PerformanceAnalysisKit';

const PROPORTION = 0.99; // Screen Percentage
const SURFACEW = 0.9; // Surface width ratio
const SURFACEH = 1.78; // Surface height ratio
const TIMEOUT = 0; // Timer ID
const SET_TIME_OUT = 8000; // Interval: 8s
const SET_INTERVAL = 100;

class innerInfo {
  eventId: number = 0
  priority: emitter.EventPriority = 0
}

let innerEventFalse: innerInfo = {
  eventId: 1,
  priority: emitter.EventPriority.HIGH
};

let innerEventTrue: innerInfo = {
  eventId: 2,
  priority: emitter.EventPriority.HIGH
};

let innerEventWH: innerInfo = {
  eventId: 3,
  priority: emitter.EventPriority.HIGH
};

@Entry
@Component
struct VideoPageComponent {
  @StorageLink('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @StorageLink('flag') flag: boolean = true; // Pause Playback
  @StorageLink('currentTime') currentTime: number = 0;
  @StorageLink('show') show: boolean = false; // Indicates whether the videoPanel component is displayed.
  @StorageLink('videoSelect') videoSelect: number = 0;
  @StorageLink('videoState') @Watch('continueChange') videoState: string = '';
  @StorageLink('videoName') videoName: Resource = $r('app.string.video_res_1');
  @StorageLink('videoIndex') videoIndex: number = 0;
  @StorageLink('continue') @Watch('continueChange') continue: boolean = false;
  @StorageLink('bottomHeight') bottomHeight: number = 0;
  @StorageLink('topHeight') topHeight: number = 0;
  @StorageLink('windowWidth') windowWidth: number = 0;
  @StorageLink('windowHeight') windowHeight: number = 0;
  @StorageLink('continueEntry') continueEntry: boolean = false;
  @StorageLink('currentPage') currentPage: string = '';
  @State avPlayManage: avPlayManage = new avPlayManage();
  @State isSwiping: boolean = false;
  @State isClickScreen: boolean = false;
  @State XComponentFlag: boolean = false;
  @StorageLink('speedSelect') speedSelect: number = 0;
  @State videoListSelect: number = 0;
  @State durationTime: number = 0;
  @State surfaceW: number = 0;
  @State surfaceH: number = 0;
  @State percent: number = 0;
  @State isCalcWHFinished: boolean = false;
  private videoNameList: string[] = ['test1.mp4', 'test2.mp4']
  private surfaceId: string = '';
  private timeout: number = 0; // Timer ID
  private xComponentController: XComponentController = new XComponentController();

  continueChange() {
    if (this.videoState === 'playing' && this.continue) {
      this.avPlayManage.videoSeek(this.currentTime);
      AppStorage.set('continue', false);
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

  aboutToAppear() {
    this.windowWidth = display.getDefaultDisplaySync().width;
    this.windowHeight = display.getDefaultDisplaySync().height;
    this.surfaceW = (GlobalContext.getContext().getObject('windowWidth') as number) * SURFACEW;
    this.surfaceH = this.surfaceW / SURFACEH;
    this.flag = true;
    AppStorage.setOrCreate('avPlayManage', this.avPlayManage);
  }

  aboutToDisappear() {
    this.avPlayManage.videoRelease();
    emitter.off(innerEventFalse.eventId);
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

  async isInternet(): Promise<boolean> {
    if (connection.getAllNetsSync().length <= 0) {
      this.toast();
      return false
    }
    return true;
  }

  async toast() {
    this.getUIContext().getPromptAction().showToast({
      message: $r('app.string.video_warn'),
      duration: 2000,
    });
  }

  @Builder
  CoverXComponent() {
    XComponent({
      // Loading the video container
      id: 'xComponent',
      type: XComponentType.SURFACE,
      controller: this.xComponentController
    })
      .visibility(this.XComponentFlag ? Visibility.Visible : Visibility.Hidden)
      .onLoad(() => {
        this.surfaceId = this.xComponentController.getXComponentSurfaceId();
        this.avPlayManage.initPlayer(this.surfaceId, this.videoNameList[this.videoIndex], this.continue,
          this.currentTime,
          (avPlayer: media.AVPlayer) => {
            this.percent = avPlayer.width / avPlayer.height;
            this.setVideoWH();
            this.isCalcWHFinished = true;
            this.durationTime = this.avPlayManage.getDurationTime();
            this.clearTimer();
            if (!this.flag) {
              this.avPlayManage.videoPause()
            }
          })

      })
      .height(this.isCalcWHFinished ? `${this.surfaceH}px` : '100%')
      .width(this.isCalcWHFinished ? `${this.surfaceW}px` : '100%')
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          this.CoverXComponent()
        }
        .id('Video')
        .justifyContent(FlexAlign.Center)

        Text()
          .height(`${this.surfaceH}px`)
          .width(`${this.surfaceW}px`)
          .margin({ top: $r('app.float.size_80') })
          .backgroundColor(Color.Black)
          .opacity($r('app.float.size_zero_five'))
          .visibility(this.isSwiping ? Visibility.Visible : Visibility.Hidden)

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
        .margin({ top: $r('app.float.size_80') })
        .visibility(this.isSwiping ? Visibility.Visible : Visibility.Hidden)

        Column() {
          Row() {
            ExitVideo({
              avPlayManage: $avPlayManage,
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)

          Blank()

          Column() {
            // Progress bar
            VideoOperate({
              avPlayManage: $avPlayManage,
              durationTime: $durationTime,
              isSwiping: $isSwiping,
              XComponentFlag: $XComponentFlag
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
      .backgroundColor(Color.Black)
      .height('100%')
      .width('100%')
      .padding({
        top: this.topHeight,
        bottom: this.bottomHeight === 0 ? 16 : this.bottomHeight
      })
    }
    .hideTitleBar(true)
    .onAppear(() => {
      let index = AppStorage.get('videoIndex') as number;
      if (!index) {
        AppStorage.setOrCreate('videoIndex', 0);
      }
    })
    .onShown(() => {
      emitter.on(innerEventTrue, (res) => {
        if (res.data) {
          this.flag = res.data.flag;
          this.XComponentFlag = res.data.flag;
        }
      });
      emitter.on(innerEventFalse, (res) => {
        if (res.data) {
          this.flag = res.data.flag;
        }
      });
      emitter.on(innerEventWH, (res) => {
        if (res.data) {
          this.windowWidth = res.data.width;
          this.windowHeight = res.data.height;
          this.setVideoWH();
        }
      });

      if (!this.flag) {
        this.clearTimer();
      }
      hilog.info(0x000, 'progress', 'onShown currentPage ' + this.currentPage);
    })
    .onHidden(() => {
      this.avPlayManage.videoPause();
      this.flag = false;
    })
  }
}

@Builder
export function VideoPageComponentBuilder() {
  VideoPageComponent()
}