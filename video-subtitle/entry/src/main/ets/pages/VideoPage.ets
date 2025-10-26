/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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
import { util } from '@kit.ArkTS';
import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Caption, CaptionFont, registerMyFont } from '../model/ViewModel';
import { VideoPlayer } from '../view/VideoPlayerComponent';
import { AvPlayer } from '../view/AvPlayerComponent';
import { CaptionFontComponent } from '../view/CaptionFontComponent';
import { Logger } from '../utils/Logger';

const LOG_TAG = 'VIDEO_PAGE';

@Component
export struct VideoPage {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @Prop isVideo: boolean = true;
  @Prop currentWindow: window.Window | null = null;
  @State isPlaying: boolean = false;
  @State currentTime: number = 0;
  @State duration: number = 0;
  @State sliderTime: number = 0;
  @State showControls: boolean = false;
  @State videoWidth: number = 0;
  @State videoHeight: number = 0;
  @State currentCaption: Caption | null = null;
  @State windowWidth: number = 300;
  @State windowHeight: number = 200;
  @State captionFont: CaptionFont = {
    family: 'Sans',
    size: 14,
    color: Color.White
  };
  @State isShowCaptionConfig: boolean = false;

  private formatTime(seconds: number): string {
    let hours = Math.floor(seconds / 3600);
    let minus = Math.floor(seconds / 60);
    let secs = Math.floor(seconds % 60);
    return util.format('%s:%s:%s', hours.toString().padStart(2, '0'), minus.toString().padStart(2, '0'),
      secs.toString().padStart(2, '0'));
  }

  aboutToAppear(): void {
    try {
      this.windowHeight = display.getDefaultDisplaySync().height;
    } catch (error) {
      Logger.error(LOG_TAG, `getDefaultDisplaySync fail, error is: ${JSON.stringify(error as BusinessError)}`);
    }
    registerMyFont(this.getUIContext());
  }

  closeCaptionSetting(captionFont: CaptionFont | null) {
    this.isPlaying = true;
    this.isShowCaptionConfig = false;
    if (captionFont) {
      this.captionFont = captionFont;
    }
  }

  build() {
    NavDestination() {
      Column() {
        Stack() {
          Column() {
            if (this.isVideo) {
              VideoPlayer({
                isPlaying: this.isPlaying,
                currentTime: this.currentTime,
                duration: this.duration,
                currentCaption: this.currentCaption,
                sliderTime: this.sliderTime
              })
            } else {
              AvPlayer({
                isPlaying: this.isPlaying,
                currentTime: this.currentTime,
                duration: this.duration,
                currentCaption: this.currentCaption,
                sliderTime: this.sliderTime
              })
            }
          }
          .onClick(() => {
            this.showControls = !this.showControls;
          })
          .width('100%')
          .height('100%')

          if (this.showControls) {
            Column() {
              Row({ space: 8 }) {
                Button() {
                  Image($r('app.media.chevron_left'))
                    .width(16)
                    .height(16)
                    .align(Alignment.Center)
                }
                .backgroundColor('rgba(255, 255, 255, 0.1)')
                .width(40)
                .height(40)
                .onClick(() => {
                  this.pageStack.pop();
                })


                Column() {
                  Text('Test.mp4')
                    .fontSize(20)
                    .fontWeight(700)
                    .fontColor(Color.White)
                }
              }
              .width('100%')
            }
            .position({ x: 24 })
            .padding({ top: 16, bottom: 16 })
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0.3)', 0.0179], ['rgba(0,0,0,0)', 1]]
            })
          }

          Column() {
            Text(this.currentCaption?.text || '')
              .fontColor(this.captionFont.color)
              .fontSize(this.captionFont.size)
              .fontFamily(this.captionFont.family)
          }
          .width('100%')
          .position({ bottom: 40 })

          if (this.showControls) {
            Column({ space: 8 }) {
              Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                Column() {
                  Text(this.formatTime(this.currentTime))
                    .fontColor(Color.White)
                    .fontSize(14)
                }
                .margin({ right: 16 })
                .flexShrink(0)

                Column() {
                  Slider({
                    value: this.currentTime,
                    min: 0,
                    max: this.duration,
                    step: 1,
                    style: SliderStyle.OutSet
                  })
                    .trackThickness(6)
                    .blockSize({
                      width: 16,
                      height: 16
                    })
                    .trackColor('rgba(255, 255, 255, 0.4)')
                    .onChange((value: number) => {
                      this.sliderTime = value;
                    })
                }

                Column() {
                  Text(this.formatTime(this.duration))
                    .fontColor(Color.White)
                    .fontSize(14)
                }
                .margin({ left: 16 })
                .flexShrink(0)

              }
              .margin({ left: 24, right: 24 })

              Row() {
                Row({ space: 32 }) {
                  Button() {
                    Image(this.isPlaying ? $r('app.media.pause') : $r('app.media.play'))
                      .width(24)
                      .height(24)
                  }
                  .onClick(() => this.isPlaying = !this.isPlaying)
                  .backgroundColor(Color.Transparent)

                  Button() {
                    Image($r('app.media.character_viewfinder'))
                      .width(24)
                      .height(24)
                  }
                  .onClick(() => {
                    this.isPlaying = false;
                    this.isShowCaptionConfig = true;
                  })
                  .backgroundColor(Color.Transparent)
                }
              }
              .width('100%')
              .padding({ left: 24, right: 24 })
            }
            .width('100%')
            .position({ bottom: 0 })
            .padding({ bottom: 16 })
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0.0179], ['rgba(0,0,0,0.3)', 1]]
            })
          }

          if (this.isShowCaptionConfig) {
            CaptionFontComponent({
              captionFont: this.captionFont,
              close: (captionFont: CaptionFont | null) => {
                this.closeCaptionSetting(captionFont);
              }
            })
          }

        }
        .height('100%')
        .width('100%')
      }
      .width('100%')
      .height(`${this.windowHeight}px`)
    }
    .hideTitleBar(true)
    .mode(NavDestinationMode.STANDARD)
    .onShown(async () => {
      this.isPlaying = true;
      await this.currentWindow?.setWindowSystemBarEnable([]);
    })
    .onHidden(() => {
      this.isPlaying = false;
    })

  }
}