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

@Component
export struct VideoPlayer {
  @Consume('NavPathStack') pageInfos: NavPathStack;
  @State currentTime: number = 0
  @State durationTime: number = 0
  @State isStart: boolean = true;
  @State transCurrentTime: number = 0
  @State transDurationTime: number = 0
  @State transIsStart: boolean = true;
  @State currentIndex: number = 0;
  @State tabColorOne: string = '#191919';
  @State tabColorTwo: string = '#666666';
  @State backgroundColorOne: string = '#FFFFFF';
  @State backgroundColorTwo: string = '#E5E5E5';
  private tabsController: TabsController = new TabsController();
  private controller: VideoController = new VideoController();
  private transController: VideoController = new VideoController();

  build() {
    Column() {
      Row() {
        Button($r('app.string.before_transcoding'))
          .onClick(() => {
            this.tabsController.changeIndex(1);
            this.currentIndex = 1;
            this.changeIndex();
          })
          .fontColor(this.tabColorTwo)
          .backgroundColor(this.backgroundColorTwo)
          .margin(2)
          .width(80)
        Button($r('app.string.after_transcoding'))
          .onClick(() => {
            this.tabsController.changeIndex(0);
            this.currentIndex = 0;
            this.changeIndex();
          })
          .fontColor(this.tabColorOne)
          .backgroundColor(this.backgroundColorOne)
          .margin(2)
          .width(80)
      }
      .borderRadius(20)
      .backgroundColor('#E5E5E5')
      .margin({ bottom: 16 })
      .width(168)

      Tabs({ index: this.currentIndex, controller: this.tabsController }) {
        TabContent() {
          Column() {
            Stack() {
              Video({
                src: 'file://' + this.getUIContext().getHostContext()?.cacheDir + '/transcoding.mp4',
                controller: this.transController
              })
                .width('100%')
                .height('100%')
                .autoPlay(true)
                .controls(false)
                .objectFit(1)
                .zIndex(0)
                .onPrepared((event) => {
                  if (event) {
                    this.transDurationTime = event.duration
                    console.info(this.transDurationTime.toString());
                  }
                })
                .onUpdate((event) => {
                  if (event) {
                    this.transCurrentTime = event.time
                  }
                })
                .onFinish(() => {
                  this.transIsStart = !this.transIsStart;
                })
                .transition(TransitionEffect.OPACITY.animation({ duration: 1000, curve: Curve.Sharp }))

              Row() {
                Image(this.transIsStart ? $r('app.media.pause') : $r('app.media.play'))
                  .width(18)
                  .height(18)
                  .onClick(() => {
                    if (this.transIsStart) {
                      this.transController.pause();
                      this.transIsStart = !this.transIsStart;
                    } else {
                      this.transController.start();
                      this.transIsStart = !this.transIsStart;
                    }
                  })

                Text(formatVideoTime(this.transCurrentTime))
                  .fontColor(Color.White)
                  .fontSize(12)
                  .margin({ left: '12vp' })
                Slider({
                  value: this.transCurrentTime,
                  min: 0,
                  max: this.transDurationTime
                })
                  .onChange((value: number, mode: SliderChangeMode) => {
                    // Set the video playback progress to jump to the value
                    this.transController.setCurrentTime(value);
                  })
                  .layoutWeight(1)
                Text(formatVideoTime(this.transDurationTime))
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
          .width('100%')
          .layoutWeight(1)
        }

        TabContent() {
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
          .width('100%')
          .layoutWeight(1)
        }
      }
      .barHeight(0)
      .scrollable(false)
      .barMode(BarMode.Fixed)
      .height('80%')

      Blank()

      Column() {
        Button($r('app.string.return'))
          .width('100%')
          .onClick(() => {
            this.pageInfos.popToIndex(-1);
          })
      }
      .margin({ top: '12vp' })
      .justifyContent(FlexAlign.End)
      .padding({ left: 16, right: 16, bottom: 16 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
  }

  changeIndex() {
    this.tabColorOne = this.currentIndex === 0 ? '#191919' : '#666666';
    this.backgroundColorOne = this.currentIndex === 0 ? '#FFFFFF' : '#E5E5E5';
    this.tabColorTwo = this.currentIndex === 1 ? '#191919' : '#666666';
    this.backgroundColorTwo = this.currentIndex === 1 ? '#FFFFFF' : '#E5E5E5';
  }
}
