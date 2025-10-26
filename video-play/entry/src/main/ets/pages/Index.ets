/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import { common } from '@kit.AbilityKit';
import { display } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import avPlayManage from '../videomanager/AvPlayManager';
import { VideoOperate } from '../components/VideoOperate';
import { ExitVideo } from '../components/ExitVideo';
import { timeConvert } from '../utils/TimeUtils';
import { GlobalContext } from '../utils/GlobalContext';

const PROPORTION = 0.99; // Screen Percentage
const SURFACEW = 0.9; // Surface width ratio
const SURFACEH = 1.78; // Surface height ratio
const TIMEOUT = 0; // Timer ID
const SET_TIME_OUT = 8000; // Interval: 8s
const SET_INTERVAL = 100;
const TAG = 'Index';

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
struct Index {
  @State avPlayManage: avPlayManage = new avPlayManage();
  @State isSwiping: boolean = false;
  @State isClickScreen: boolean = false;
  @State flag: boolean = true; // Pause Playback
  @State XComponentFlag: boolean = false;
  @State speedSelect: number = 0;
  @State videoListSelect: number = 0;
  @State durationTime: number = 0;
  @State currentTime: number = 0;
  @State surfaceW: number = 0;
  @State surfaceH: number = 0;
  @State show: boolean = false; // Indicates whether the videoPanel component is displayed.
  @State videoSelect: number = 0;
  @State percent: number = 0;
  @State windowWidth: number = 300;
  @State windowHeight: number = 300;
  @State isCalcWHFinished: boolean = false;
  @State videoList: Resource[] =
    [$r('app.string.video_res_1'), $r('app.string.video_res_2'), $r('app.string.video_res_3')];
  @State videoNameList: string[] = ['video_res_1', 'video_res_2', 'video_res_3'];
  @StorageLink('videoName') videoName: Resource = $r('app.string.video_res_1');
  @StorageLink('videoIndex') videoIndex: number = 0;
  private surfaceId: string = '';
  private timeout: number = 0; // Timer ID
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

  aboutToAppear() {
    try {
      this.windowWidth = display.getDefaultDisplaySync().width;
      this.windowHeight = display.getDefaultDisplaySync().height;
      this.surfaceW = (GlobalContext.getContext().getObject('windowWidth') as number) * SURFACEW;
      this.surfaceH = this.surfaceW / SURFACEH;
      this.flag = true;
      AppStorage.setOrCreate('avPlayManage', this.avPlayManage);
    } catch (error) {
      hilog.error(0x0000, TAG, `aboutToAppear catch error, code: ${error.code}, message: ${error.message}`);
    }

  }

  aboutToDisappear() {
    this.avPlayManage.videoRelease();
    emitter.off(innerEventFalse.eventId);
  }

  onPageHide() {
    this.avPlayManage.videoPause();
    this.flag = false;
  }

  onPageShow() {
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

    if (this.flag == false) {
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

  async isInternet(): Promise<boolean> {
    try {
      if (connection.getAllNetsSync().length <= 0) {
        this.toast();
        return false;
      }
      return true;
    } catch (error) {
      hilog.error(0x0000, TAG, `getAllNetsSync catch error, code: ${error.code}, message: ${error.message}`);
      return false;
    }
  }

  async toast() {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: $r('app.string.video_warn'),
        duration: 2000,
      });
    } catch (error) {
      hilog.error(0x0000, TAG, `showToast catch error, code: ${error.code}, message: ${error.message}`);
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
      .visibility(this.XComponentFlag ? Visibility.Visible : Visibility.Hidden)
      .onLoad(() => {
        this.surfaceId = this.xComponentController.getXComponentSurfaceId();
        this.avPlayManage.initPlayer(this.surfaceId, (avPlayer: media.AVPlayer) => {
          this.percent = avPlayer.width / avPlayer.height;
          this.setVideoWH();
          this.isCalcWHFinished = true;
          this.durationTime = this.avPlayManage.getDurationTime();
          setInterval(() => { // Update the current time.
            if (!this.isSwiping) {
              this.currentTime = this.avPlayManage.getCurrentTime();
            }
          }, SET_INTERVAL);
        })
      })
      .height(this.isCalcWHFinished ? `${this.surfaceH}px` : '100%')
      .width(this.isCalcWHFinished ? `${this.surfaceW}px` : '100%')
  }

  @Builder
  listBuilder() {
    Column() {
      RelativeContainer() {
        Text(this.videoList[this.videoSelect])
          .fontColor(Color.White)
          .fontSize($r('app.float.size_18'))
          .fontWeight(FontWeight.Regular)
          .alignRules({
            middle: { anchor: '__container__', align: HorizontalAlign.Center },
            center: { anchor: '__container__', align: VerticalAlign.Center }
          })
          .id('test1')
        Image($r('app.media.ic_video_list_down'))
          .width($r('app.float.size_30'))
          .height($r('app.float.size_20'))
          .alignRules({
            right: { anchor: '__container__', align: HorizontalAlign.End },
            center: { anchor: '__container__', align: VerticalAlign.Center }
          }).id('test2')
      }
      .height($r('app.float.size_20'))
      .width('90%')
      .margin({ top: $r('app.float.size_20'), bottom: $r('app.float.size_20') })

      List() {
        ForEach(this.videoList, (item: Resource, index) => {
          ListItem() {
            Column() {
              Row() {
                Text(item)
                  .fontSize($r('app.float.size_20'))
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Regular)
                  .textAlign(TextAlign.Center)

                Blank()

                if (this.videoSelect === index) {
                  Text($r('app.string.playing'))
                    .fontSize($r('app.float.size_20'))
                    .fontColor(Color.White)
                    .opacity($r('app.float.size_zero_six'))
                    .fontWeight(FontWeight.Regular)
                    .textAlign(TextAlign.Center)
                }
              }
              .width('90%')
            }
            .width('100%')
          }
          .backgroundColor(this.videoSelect === index ? $r('app.color.video_play_selected') : '')
          .width('100%')
          .height($r('app.float.size_64'))
          .onClick(async () => {
            if (index === 2) {
              try {
                if (!await this.isInternet()) {
                  return;
                }
              } catch (err) {
                this.toast();
                return;
              }
            }
            this.videoSelect = index;
            AppStorage.setOrCreate('videoName', this.videoList[this.videoSelect]);
            AppStorage.setOrCreate('videoIndex', this.videoSelect);
            AppStorage.setOrCreate('speedName', $r('app.string.video_speed_1_0X'));
            AppStorage.setOrCreate('speedIndex', 0);
            this.show = false;
            let str: string = (GlobalContext.getContext().getObject('context') as (common.UIAbilityContext))
              .resourceManager.getStringByNameSync(this.videoNameList[this.videoSelect]);
            this.avPlayManage.videoChoose(str);
          })
        })
      }
      .width('100%')
      .height('200vp')
    }
    .onClick(() => {
      this.show = false;
    })
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
          ExitVideo()
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        Blank()

        Column() {
          // Progress bar
          VideoOperate({
            flag: $flag,
            avPlayManage: $avPlayManage,
            currentTime: $currentTime,
            durationTime: $durationTime,
            isSwiping: $isSwiping,
            XComponentFlag: $XComponentFlag
          })
            .width('100%')

          Row() {
            Image($r('app.media.ic_video_view_list'))
              .width($r('app.float.size_32'))
              .height($r('app.float.size_32'))
              .margin({ left: $r('app.float.size_30') })
            Text(this.videoName)
              .fontSize($r('app.float.size_20'))
              .fontColor(Color.White)
              .fontWeight(FontWeight.Regular)
              .margin({ left: $r('app.float.size_10') })
            Blank()
            Column() {
              Image($r('app.media.ic_video_list_up'))
                .width($r('app.float.size_30'))
                .height($r('app.float.size_20'))
                .bindSheet($$this.show, this.listBuilder, {
                  height: SheetSize.FIT_CONTENT,
                  backgroundColor: $r('app.color.video_play'),
                  showClose: false
                })
            }
            .margin({ right: $r('app.float.size_25') })
          }
          .id('Choose')
          .margin({ top: $r('app.float.size_10') })
          .width('100%')
          .height($r('app.float.size_50'))
          .backgroundColor($r('app.color.video_play'))
          .borderRadius({ topLeft: $r('app.float.size_35'), topRight: $r('app.float.size_35') })
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            this.show = !this.show;
            this.videoSelect = this.videoIndex;
          })
        }
        .justifyContent(FlexAlign.Center)
      }
      .onTouch((event: TouchEvent) => {
        if (event.type == TouchType.Down) {
          this.isClickScreen = true;
          this.clearTimer();
        } else if (event.type == TouchType.Up) {
          this.setTimer();
        } else if (event.type == TouchType.Move) {
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
    .padding({ top: '36vp', bottom: '28vp' })
  }
}