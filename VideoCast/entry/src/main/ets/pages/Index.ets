/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { avSession } from '@kit.AVSessionKit';
import { VideoSessionController } from '../controller/VideoSessionController';
import { VideoPlayerController } from '../controller/VideoPlayerController';
import { VideoCastController } from '../controller/VideoCastController';
import { VideoPlay } from './VideoPlayPage';

class VideoPlayParam {
  videoType: string;
  videoTime: number = 0;
  videoIndex: number = 0;

  constructor(videoType: string, videoTime?: number, videoIndex?: number) {
    this.videoType = videoType;
    if (videoTime) {
      this.videoTime = videoTime;
    }
    if (videoIndex) {
      this.videoIndex = videoIndex;
    }
  }
}

@Entry
@Component
struct Index {
  @StorageLink('avSessionController') avSessionController ?: VideoSessionController = undefined;
  @StorageLink('castingList') castingList: string[] = [];
  @StorageLink('avPlayerController') avPlayerController?: VideoPlayerController = undefined;
  @StorageLink('avCastController') @Watch('avCastControllerChange') avCastPlayerController?: VideoCastController =
    undefined;
  @Provide remoteControlPathStack: NavPathStack = new NavPathStack();
  @State ifShowBack: boolean = false;
  @State avCastControllerState?: avSession.PlaybackState = avSession.PlaybackState.PLAYBACK_STATE_INITIAL;
  @State videoPlayPathStack: NavPathStack = new NavPathStack();

  // [Start Overlay]
  @Builder
  OverlayNode() {
    // [StartExclude Overlay]
    if (!this.ifShowBack){
      Row() {
        SymbolGlyph($r('sys.symbol.wireless_projection'))
          .fontSize(28)
          .fontColor([Color.White])
      }
      .width(56)
      .height(56)
      .backgroundColor('#0A59F7')
      .borderRadius(28)
      .justifyContent(FlexAlign.Center)
      .offset({
        x: -2,
        y: -66
      })
      .onClick(() => {
        this.ifShowBack = true;
      })
      .visibility(this.remoteControlPathStack.size()===0 && this.castingList.length !== 0 ? Visibility.Visible : Visibility.None)
    }else {
      Column() {
        Row() {
          SymbolGlyph($r('sys.symbol.arrowshape_turn_up_left'))
            .fontSize(28)
            .fontColor([Color.Black])
        }
        .width(48)
        .height(48)
        .backgroundColor('#E8E8E8')
        .borderRadius('50%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          let videoPlayParam = new VideoPlayParam(this.castingList[0], 0, this.avCastPlayerController?.videoIndex);
          this.videoPlayPathStack.replacePath({ name: 'detail', param: videoPlayParam });
          this.remoteControlPathStack.replacePath({ name: 'detail', param: -1 });
        })

        Row() {
          SymbolGlyph($r('sys.symbol.wireless_projection'))
            .fontSize(28)
            .fontColor([Color.White])
        }
        .onClick(() => {
          this.ifShowBack = false;
        })
        .width(56)
        .height(56)
        .backgroundColor('#0A59F7')
        .borderRadius('50%')
        .justifyContent(FlexAlign.Center)

        Row() {
          SymbolGlyph(this.avCastControllerState === avSession.PlaybackState.PLAYBACK_STATE_PLAY ?
          $r('sys.symbol.pause_circle') : $r('sys.symbol.play_circle'))
            .fontSize(28)
            .fontColor([Color.Black])
        }
        .onClick(() => {
          if (this.avCastControllerState === avSession.PlaybackState.PLAYBACK_STATE_PLAY &&
          this.avCastPlayerController) {
            this.avCastPlayerController.setAVCastPause();
          } else if (this.avCastControllerState === avSession.PlaybackState.PLAYBACK_STATE_PAUSE &&
          this.avCastPlayerController) {
            this.avCastPlayerController.setAVCastPlay();
          }
        })
        .width(48)
        .height(48)
        .backgroundColor('#E8E8E8')
        .borderRadius('50%')
        .justifyContent(FlexAlign.Center)
      }
      .backgroundColor('#EFF0F3')
      .borderRadius(30)
      .width(60)
      .height(188)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        top: 8,
        bottom: 8
      })
      .visibility(this.remoteControlPathStack.size()===0 && this.castingList.length !== 0 ? Visibility.Visible : Visibility.None)
    }
    // [EndExclude Overlay]
  }
  // [End Overlay]

  avCastControllerChange() {
    this.avCastControllerState = this.avCastPlayerController?.state;
  }

  @Builder
  PageMap(name: string, param: VideoPlayParam) {
    VideoPlay({ videoType: param.videoType, videoIndex: param.videoIndex })
  }

  build() {
    RelativeContainer() {
      Navigation(this.videoPlayPathStack) {
        Column() {
          Row() {
            Text($r('app.string.title'))
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
          }
          .height(112)
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            bottom: 8
          })
          .alignItems(VerticalAlign.Bottom)

          Column() {
            Text($r('app.string.subtitle'))
              .height(48)
              .fontSize(16)
              .fontWeight(500)
            Row() {
              Image($r('app.media.video_cover_0'))
                .height('100%')
                .width(156)
                .borderRadius(10)
              Column() {
                Text($r('app.string.online_video'))
                  .fontSize(14)
                  .margin({
                    bottom: 2
                  })
                Text($r('app.string.online_video_describe'))
                  .fontSize(12)
                  .fontColor('rgba(0,0,0,0.6)')
              }
              .height('100%')
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Start)
              .layoutWeight(1)
              .padding({
                left: 8
              })
            }
            .onClick(() => {
              let videoPlayParam = new VideoPlayParam('network');
              this.videoPlayPathStack.pushPath({ name: 'detail', param: videoPlayParam });
            })
            .width('100%')
            .height(88)
            .margin({
              bottom: 12
            })

            Row() {
              Image($r('app.media.video_cover_0'))
                .height('100%')
                .width(156)
                .borderRadius(10)
              Column() {
                Text($r('app.string.local_video'))
                  .fontSize(14)
                  .margin({
                    bottom: 2
                  })
                Text($r('app.string.local_video_describe'))
                  .fontSize(12)
                  .fontColor('rgba(0,0,0,0.6)')
              }
              .height('100%')
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Start)
              .layoutWeight(1)
              .padding({
                left: 8
              })
            }
            .onClick(() => {
              let videoPlayParam = new VideoPlayParam('localWork');
              this.videoPlayPathStack.pushPath({ name: 'detail', param: videoPlayParam });
            })
            .width('100%')
            .height(88)
          }
          .alignItems(HorizontalAlign.Start)
          .padding({
            left: 16,
            right: 16,
          })
          .width('100%')
          .layoutWeight(1)
          .backgroundColor(Color.White)
        }
        .onClick(() => {
          this.ifShowBack = false;
        })
      }
      .navBarWidth(this.videoPlayPathStack.size() === 0 ? '100%' : '50%')
      .width('100%')
      .mode(NavigationMode.Auto)
      .navDestination(this.PageMap)
      .hideToolBar(true)
      // [Start OverlayNode]
      .overlay(this.OverlayNode(), {
        align: Alignment.BottomEnd,
        offset: { x: -24,
          y: -136 }
      })
      // [End OverlayNode]
    }
    .width('100%')
    .height('100%')
  }
}