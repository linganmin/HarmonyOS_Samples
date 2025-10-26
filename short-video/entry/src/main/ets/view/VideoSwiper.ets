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

import { CommonConstants as Const } from '../common/CommonConstants';
import { Side } from './Side';
import { VideoDes } from './Side';
import { BasicDataSource } from '../model/BasicDataSource';
import { VideoData } from '../model/DataModel';
import { curves } from '@kit.ArkUI';

let videoIndex: number = 0;
const uiContext: UIContext | undefined = AppStorage.get('uiContext');

@Component
export struct VideoSwiper {
  private swiperController: SwiperController = new SwiperController();
  controller: VideoController = new VideoController();
  @State playBoo: boolean = true;
  @State index: number = 0;
  private data: VideoNew = new VideoNew();
  videoData: Array<VideoData> = [
    {
      video: $r("app.media.short_video1"),
      name: this.ResourceToString($r("app.string.name_one")),
      description: this.ResourceToString($r("app.string.description_one")),
      time: '2024-1-3 14:52',
      controller: this.controller,
      auto: true,
      head: $r('app.media.photo33'),
      likeCount: '1234',
      commentCount: '2234',
      favoriteCount: '3234',
      shareCount: '4234',
      hotspot: this.ResourceToString($r("app.string.hotspot_one")),
      play: true,
      index: 0
    },
    {
      video: $r("app.media.short_video2"),
      name: this.ResourceToString($r("app.string.name_two")),
      description: this.ResourceToString($r("app.string.description_two")),
      time: '2024-1-2 10:52',
      controller: this.controller,
      auto: true,
      head: $r('app.media.photo35'),
      likeCount: '7890',
      commentCount: '8890',
      favoriteCount: '9990',
      shareCount: '9991',
      hotspot: this.ResourceToString($r("app.string.hotspot_two")),
      play: true,
      index: 1
    },
    {
      video: $r("app.media.short_video3"),
      name: this.ResourceToString($r("app.string.name_three")),
      description: this.ResourceToString($r("app.string.description_three")),
      time: '2024-1-2 16:03',
      controller: this.controller,
      auto: true,
      head: $r('app.media.photo37'),
      likeCount: '4567',
      commentCount: '5567',
      favoriteCount: '6667',
      shareCount: '7667',
      hotspot: this.ResourceToString($r("app.string.hotspot_three")),
      play: true,
      index: 2
    }
  ]

  onPageShow() {
    this.data.getData(this.index).controller.start();
  }

  onPageHide() {
    this.data.getData(this.index).controller.pause();
  }

  aboutToAppear() {
    if (videoIndex) {
      this.index = videoIndex;
    }
    for (let i = 0; i < this.videoData.length; i++) {
      this.data.pushData(this.videoData[i]);
    }
  }

  build() {
    Column() {
      Swiper(this.swiperController) {
        LazyForEach(this.data, (item: VideoData, index: number) => {
          Stack({ alignContent: Alignment.Center }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Stack({ alignContent: Alignment.BottomEnd }) {
                Video({
                  src: item.video,
                  controller: item.controller
                })
                  .width(Const.FULL_SIZE)
                  .height(Const.FULL_SIZE)
                  .objectFit(ImageFit.Contain)
                  .loop(true)
                  .autoPlay(item.auto)
                  .controls(false)
                  .onPrepared((err) => {
                    item.controller.start();
                  })
                  .onStart(() => {
                    item.play = true;
                    this.playBoo = this.data.getData(this.index).play;
                  })
                  .onPause(() => {
                    item.play = false;
                    this.playBoo = this.data.getData(this.index).play;
                  })
                  .onClick(() => {
                    if (item.play) {
                      item.controller.pause();
                    } else {
                      item.controller.start();
                    }
                  })
                  .onVisibleAreaChange([0.0, 1.0], (isVisisble: boolean, currentRatio: number) => {
                    if (isVisisble && currentRatio >= 1.0) {
                      item.controller.start();
                    }
                  })
                Side({
                  head: item.head,
                  likeCount: item.likeCount,
                  commentCount: item.commentCount,
                  favoriteCount: item.favoriteCount,
                  shareCount: item.shareCount,
                  index: item.index
                })
              }.width(Const.FULL_SIZE).height(Const.FULL_SIZE).padding($r('app.integer.stack_padding'))

              VideoDes({ name: item.name, description: item.description, hotspot: item.hotspot, time: item.time })
                .margin({ bottom: $r('app.integer.video_des_margin_bottom') })
              Row() {
                Row() {
                  Image($r('app.media.ic_public_upgrade_filled'))
                    .height($r('app.integer.upgrade_icon_size'))
                    .width($r('app.integer.upgrade_icon_size'))
                  Text($r('app.string.upgrade_hot'))
                    .fontSize($r('app.integer.upgrade_text_font_size'))
                    .fontColor($r('app.color.up_color'))
                  Text(' · ' + item.hotspot)
                    .fontSize($r('app.integer.mus_font_size'))
                    .maxLines(1)
                    .width(item.hotspot.length * 12)
                    .fontColor(Color.White)
                    .height($r('app.integer.mus_height'))
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .layoutWeight(1)
                }
                .width(Const.ROW_WIDTH)

                Row() {
                  Divider()
                    .vertical(true)
                    .color(Color.White)
                    .strokeWidth(1)
                    .height($r('app.integer.upgrade_text_font_size'))
                    .margin({ left: $r('app.integer.upgrade_margin'), right: $r('app.integer.upgrade_margin') })
                  Text($r('app.string.online_people'))
                    .fontSize($r('app.integer.mus_font_size'))
                    .fontColor(Color.White)
                  Image($r('app.media.ic_arrow_right'))
                    .width($r('app.integer.upgrade_text_font_size'))
                }
                .layoutWeight(1)
                .justifyContent(FlexAlign.End)
              }
              .width(Const.FULL_SIZE)
              .height($r('app.integer.upgrade_height'))
              .backgroundColor(Color.Gray)
              .opacity($r('app.float.fabulous_opacity'))
              .padding({ left: $r('app.integer.upgrade_padding'), right: $r('app.integer.upgrade_padding') })
              .justifyContent(FlexAlign.Start)

            }.width(Const.FULL_SIZE).height(Const.FULL_SIZE).padding(0)

            if (!this.playBoo) {
              Image($r('app.media.pau'))
                .height($r('app.integer.play_icon_size'))
                .width($r('app.integer.play_icon_size'))
                .onClick(() => {
                  item.controller.start();
                  item.play = true;
                  this.playBoo = true;
                })
            }
          }.width(Const.FULL_SIZE).height(Const.FULL_SIZE).padding($r('app.integer.stack_padding'))
        }, (item: VideoData) => JSON.stringify(item))
      }
      .index(videoIndex)
      .width(Const.FULL_SIZE)
      .height(Const.FULL_SIZE)
      .autoPlay(false)
      .indicator(false)
      .loop(true)
      .duration(Const.DURATION)
      .cachedCount(0)
      .vertical(true)
      .itemSpace(0)
      .curve(curves.interpolatingSpring(-1, 1, 328, 34))
      .onChange((index) => {
        this.index = index;
        this.playBoo = true;
        videoIndex = index;
      })
    }
    .width(Const.FULL_SIZE)
    .height(Const.FULL_SIZE)
  }

  ResourceToString(resource:Resource):string{
    return uiContext!.getHostContext()!.resourceManager.getStringSync(resource)
  }
}

class VideoNew extends BasicDataSource {
  videoNew: Array<VideoData> = [];

  public totalCount(): number {
    return this.videoNew.length;
  }

  public getData(index: number): VideoData {
    return this.videoNew[index];
  }

  public addData(index: number, data: VideoData): void {
    this.videoNew.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: VideoData): void {
    this.videoNew.push(data);
    this.notifyDataAdd(this.videoNew.length - 1);
  }
}
