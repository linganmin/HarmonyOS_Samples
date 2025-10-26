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

import { common } from '@kit.AbilityKit';
import { AVVolumePanel } from '@kit.AudioKit';
import { ScreenUtil } from '../common/util/ScreenUtil';

@Component
export struct VideoView {
  @StorageLink('context') context: common.UIAbilityContext | undefined = undefined;
  @Consume('pageInfo') pageInfo: NavPathStack;
  @State @Watch('changePlayState') isPlaying: boolean = true;
  @State isFullScreen: boolean = false;
  @State isChangingVolume: boolean = false;
  @State currentTime: number = 0;
  @State currentStringTime: string = '00:00';
  @State volume: number = 5;
  private videoController: VideoController = new VideoController();
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Vertical });

  aboutToAppear(): void {
    this.changePlayState();
  }

  changePlayState() {
    ScreenUtil.changeScreenState(this.context, this.isPlaying);
  }

  @Styles
  imageBackground() {
    .width(28)
    .height(28)
    .backgroundColor('#33FFFFFF')
    .borderRadius('50%')
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.End }) {
        Column() {
          Text($r('app.string.HarmonyOS'))
            .fontSize('19fp')
            .fontWeight(700)
            .margin({ bottom: 9 })

          Video({
            src: $rawfile('video.mp4'),
            controller: this.videoController
          })
            .autoPlay(true)
            .objectFit(ImageFit.Contain)
            .loop(true)
            .height('60%')
            .width(this.isFullScreen ? '100%' : '80%')
            .controls(false)
            .onUpdate((event) => {
              this.currentTime = event.time;
              this.currentStringTime = '00:' + this.currentTime.toString().padStart(2, '0');
            })

          Row() {
            Row() {
              Image(this.isPlaying ? $r('app.media.ic_video_play') : $r('app.media.ic_video_pause'))
                .height(20)
            }
            .onClick(() => {
              if (this.isPlaying) {
                this.videoController.pause();
              } else {
                this.videoController.start();
              }
              this.isPlaying = !this.isPlaying;
            })
            .justifyContent(FlexAlign.Center)
            .imageBackground()

            Column() {
              Row() {
                Text(this.currentStringTime)
                  .fontSize('9fp')
                  .margin({ left: 3 })

                Text('00:10')
                  .fontSize('9fp')
                  .margin({ right: 3 })
              }
              .width('100%')
              .height('70%')
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Top)

              Slider({
                min: 0,
                value: this.currentTime,
                max: 10
              })
                .width('100%')
                .height('30%')
                .onChange((value: number) => {
                  this.currentTime = Number.parseInt(value.toString());
                  this.videoController.setCurrentTime(this.currentTime, SeekMode.PreviousKeyframe);
                })
            }
            .layoutWeight(1)
            .width('60%')
            .height('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Image(this.isFullScreen ? $r('app.media.reduce') : $r('app.media.enlarge'))
                .height(20)
            }
            .onClick(() => {
              this.isFullScreen = !this.isFullScreen;
            })
            .justifyContent(FlexAlign.Center)
            .imageBackground()
          }
          .width('70%')
          .height('10%')
          .margin({ top: 6 })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)

          Row() {
            Image($r('app.media.back'))
              .height(24)
          }
          .onClick(() => {
            this.pageInfo.pop();
          })
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .margin({ top: 3 })
          .imageBackground()
        }
        .width('100%')
        .margin({
          top: 17,
          bottom: 6
        })

        AVVolumePanel({ volumeLevel: this.volume })
          .width(0)
          .height(0)

        Progress({
          value: this.volume,
          total: 15,
          type: ProgressType.Capsule
        })
          .visibility(this.isChangingVolume ? Visibility.Visible : Visibility.None)
          .width('5%')
          .height('40%')
          .color(Color.White)
          .backgroundColor('#ff838282')
          .rotate({ angle: 180 })
          .margin({ right: '10%' })
      }
      .gesture(
        PanGesture(this.panOption)
          .onActionStart(() => {
            this.isChangingVolume = true;
          })
          .onActionUpdate((event: GestureEvent) => {
            if (!event) {
              return;
            }
            let offset: number = event.offsetY / ScreenUtil.getDeviceHeight();
            if (offset > 0) {
              if (this.volume - offset < 0) {
                this.volume = 0;
              } else {
                this.volume -= offset;
              }
            } else {
              if (this.volume - offset > 15) {
                this.volume = 15;
              } else {
                this.volume -= offset;
              }
            }
          })
          .onActionEnd(() => {
            this.isChangingVolume = false;
          })
      )
    }
    .width('100%')
    .height('100%')
    .borderRadius('50%')
    .hideTitleBar(true)
    .backgroundColor(Color.Black)
  }
}

@Builder
export function videoViewBuilder() {
  VideoView()
}