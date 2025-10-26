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
import { formatVideoTime } from '../common/utils/TimeUtils';
import { MyAVScreenCapture } from '../model/MyAVScreenCapture';
import PlayerParam from '../model/PlayerParam';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct Player {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State currentTime: number = 0
  @State durationTime: number = 0
  @State @Watch('statusBarChange') isStart: boolean = true;
  @State @Watch('statusBarChange') clicked: boolean = false;
  @State private fileName: string = '';
  private videoSrc: string = '';
  private controller: VideoController = new VideoController();
  private hideToolTaskId?: number;
  uiAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private windowClass = this.uiAbilityContext.windowStage.getMainWindowSync();

  statusBarChange() {
    try {
      if (!this.isStart || this.clicked) {
        this.windowClass.setWindowSystemBarEnable(['status']);
      } else {
        this.windowClass.setWindowSystemBarEnable([]);
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `setWindowSystemBarEnable fail. code = ${err.code}, message = ${err.message}`);
    }

  }

  @Builder
  navTitleBuilder() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(24)
      }
      .height(40)
      .width(40)
      .padding(8)
      .backgroundColor($r('app.color.record_button_background_inactive_color'))
      .margin({ left: 10, top: 35 })
      .onClick(() => {
        this.pageInfos.pop()
      })

      Text(this.fileName)
        .fontSize($r('app.float.subtitle_font_size'))
        .fontWeight(FontWeight.Bold)
        .margin({ left: 10, top: 35 })

    }
    .height('100%')
    .width('100%')

  }

  @Builder
  toolbarBuilder() {
    Row() {
      Image(this.isStart ? $r('app.media.pause') : $r('app.media.play'))
        .width(24)
        .height(24)
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
        .margin({ left: 12, right: 5 })
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
        .margin({ left: 5 })
    }
    .padding({ left: 16, right: 16, bottom: 28 })
    .margin({ bottom: 25 })
    .backgroundColor($r('app.color.player_video_toolbar_background_color'))
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    .height('160%')
    .width('100%')
  }

  build() {
    NavDestination() {
      Column() {
        Stack() {
          Video({ src: this.videoSrc, controller: this.controller })
            .width('100%')
            .autoPlay(true)
            .controls(false)
            .objectFit(ImageFit.Contain)
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

        }
        .alignContent(Alignment.Bottom)
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
    }
    .title({ height: 90, builder: this.navTitleBuilder() }, {
      backgroundColor: $r('app.color.player_title_bar_background_color'),
      backgroundBlurStyle: BlurStyle.BACKGROUND_THIN,
      barStyle: BarStyle.STACK,
    })
    .onReady((context: NavDestinationContext) => {
      let param: PlayerParam = context.pathInfo.param as PlayerParam;
      this.videoSrc = param.videoSrc;
      this.fileName = param.fileName;
    })
    .onShown(() => {
      this.windowClass.setWindowLayoutFullScreen(true);
      this.windowClass.setWindowSystemBarEnable([]);
    })
    .onHidden(() => {
      this.windowClass.setWindowLayoutFullScreen(false);
    })
    .hideTitleBar(this.isStart && !this.clicked, true)
    .hideBackButton(true)
    .toolbarConfiguration(this.toolbarBuilder(), {
      backgroundColor: $r('app.color.player_toolbar_background_color'),
      barStyle: BarStyle.STACK,
    })
    .hideToolBar(this.isStart && !this.clicked, true)
    .onClick(() => {
      this.clicked = true;
      if (this.hideToolTaskId) {
        clearTimeout(this.hideToolTaskId)
      }
      this.hideToolTaskId = setTimeout(() => {
        this.clicked = false;
      }, 2000)
    })

  }
}
