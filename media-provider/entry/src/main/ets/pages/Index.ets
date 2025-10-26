/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { avSession } from '@kit.AVSessionKit';
import MediaData from '../model/MediaData';
import Logger from '../common/utils/Logger';
import { ProviderFeature } from '../viewmodel/ProviderManager';
import Constants from '../common/constants/Constants';

const TAG = 'Index';

@Entry
@Component
struct Index {
  @StorageLink('SeekPosition') seekPosition: number = 0;
  @StorageLink('CurrentLoopMode') currentLoopMode: avSession.LoopMode.LOOP_MODE_SEQUENCE = 0;
  @StorageLink('IsPlaying') isPlaying: boolean = false;
  @StorageLink('isFavorMap') isFavorMap: Map<String, boolean> | null = null;
  @StorageLink('CurrentPlayItem') currentPlayItem: avSession.AVQueueItem | null = null;
  @StorageLink('CurrentAVMetadata') currentAVMetadata: avSession.AVMetadata | null = null;
  @StorageLink('CurrentImage') currentImage: PixelMap | null = null;
  @State isProgressSliding: Boolean = false;
  private providerFeature: ProviderFeature | undefined = undefined;
  private sliderTimer?: number;

  async aboutToAppear() {
    this.providerFeature = await ProviderFeature.getInstance();
  }

  aboutToDisappear() {
    this.providerFeature!.unInit();
  }

  onPageHide() {
    // The application page is returned to the background, and a long-time task keep-alive playback is applied for.
    this.providerFeature!.startContinuousTask();
  }

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
          Row() {
            Image($r('app.media.ic_down'))
              .width($r('app.float.icon_width'))
              .height($r('app.float.icon_height'))
          }
          .width(Constants.PERCENT_FULL)
          .height($r('app.float.icon_area_height'))
          .margin({ top: $r('app.float.icon_area_marin_top') })
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Bottom)

          Image(this.currentImage ? this.currentImage : '')
            .width(Constants.PERCENT_FULL)
            .margin({ top: $r('app.float.image_margin_top') })
            .id('CurrentImage')

          Row() {
            Text(this.currentAVMetadata!.title ? this.currentAVMetadata!.title : 'No title')
              .width(Constants.PERCENT_FULL)
              .fontSize($r('app.float.music_title_font_size'))
              .fontColor($r('app.color.music_title_font_color'))
              .fontWeight(FontWeight.Bold)
              .id('Title')
          }
          .height($r('app.float.title_area_height'))
          .alignItems(VerticalAlign.Bottom)

          Text(this.currentAVMetadata!.artist ? this.currentAVMetadata!.artist : 'No artist')
            .width(Constants.PERCENT_FULL)
            .height($r('app.float.artist_height'))
            .margin({ top: $r('app.float.artist_margin_top') })
            .fontSize($r('app.float.artist_margin_font_size'))
            .fontColor($r('app.color.music_title_font_color'))
            .id('Artist')

          Blank()

          Flex({
            direction: FlexDirection.Row,
            alignItems: ItemAlign.Start,
            alignContent: FlexAlign.Center,
            justifyContent: FlexAlign.Center
          }) {
            Slider({
              value: this.seekPosition,
              min: 0,
              max: Constants.ONE_HUNDRED,
              style: SliderStyle.OutSet
            })
              .trackThickness($r('app.float.slider_track_thickness_normal'))
              .blockColor(Color.White)
              .trackColor($r('app.color.slider_track_color'))
              .selectedColor($r('app.color.slider_selected_color'))
              .showSteps(false)
              .showTips(false)
              .onChange((value: number, mode: SliderChangeMode) => {
                Logger.info(TAG, 'value:' + value + 'mode:' + mode.toString())
                if (mode === SliderChangeMode.End) {
                  this.providerFeature!.seek(value);
                }
              })
              .onTouch((event: TouchEvent) => {
                Logger.info(TAG, 'progress touch: ' + event.type)
                if (event.type === TouchType.Up) {
                  this.sliderTimer = setTimeout(() => {
                    this.isProgressSliding = false;
                  }, Constants.SLIDER_CHANGE_DURATION);
                } else {
                  clearTimeout(this.sliderTimer);
                  this.isProgressSliding = true;
                }
              })
          }
          .height($r('app.float.slider_area_height'))

          Flex({
            direction: FlexDirection.Row,
            alignItems: ItemAlign.Center,
            alignContent: FlexAlign.Center,
            justifyContent: FlexAlign.SpaceBetween
          }) {
            Button({ stateEffect: true }) {
              Image(this.isFavorMap!.get(this.currentAVMetadata!.assetId) ? $r('app.media.ic_public_favor_filled') :
                $r('app.media.ic_public_favor'))
            }
            .width($r('app.float.normal_button_width'))
            .aspectRatio(1)
            .backgroundColor(Color.Transparent)
            .id('Favorite')
            .onClick(async () => {
              await this.providerFeature!.toggleFavorite();
            })

            Button({ stateEffect: true }) {
              Image($r('app.media.ic_previous'))
            }
            .width($r('app.float.normal_button_width'))
            .aspectRatio(1)
            .backgroundColor(Color.Transparent)
            .id('Previous')
            .onClick(async () => {
              this.providerFeature!.previous();
            })

            Button({ stateEffect: true }) {
              Image(this.isPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
            }
            .height($r('app.float.play_button_height'))
            .aspectRatio(1)
            .backgroundColor(Color.Transparent)
            .id('PlayOrPause')
            .onClick(async () => {
              if (!this.isPlaying) {
                await this.providerFeature!.play();
              } else {
                await this.providerFeature!.pause();
              }
            })

            Button({ stateEffect: true }) {
              Image($r('app.media.ic_next'))
            }
            .width($r('app.float.normal_button_width'))
            .aspectRatio(1)
            .backgroundColor(Color.Transparent)
            .id('Next')
            .onClick(async () => {
              this.providerFeature!.next();
            })

            Button({ stateEffect: true }) {
              Image(MediaData.loopModeList[this.currentLoopMode!])
            }
            .width($r('app.float.normal_button_width'))
            .aspectRatio(1)
            .backgroundColor(Color.Transparent)
            .id('LoopMode')
            .onClick(async () => {
              this.providerFeature!.loopMode();
            })
          }
          .width(Constants.PERCENT_FULL)
          .height($r('app.float.play_button_height'))
          .margin({
            left: $r('app.float.button_row_margin_left'),
            right: $r('app.float.button_row_margin_left'),
            top: $r('app.float.button_row_margin_top'),
            bottom: $r('app.float.button_row_margin_bottom')
          })
        }
        .height(Constants.PERCENT_FULL)
        .width(Constants.PERCENT_FULL)
      }
      .margin({
        left: $r('app.float.page_margin_left'),
        right: $r('app.float.page_margin_left')
      })
    }
    .width(Constants.PERCENT_FULL)
    .height(Constants.PERCENT_FULL)
    .backgroundImage($r('app.media.ic_background'))
    .backgroundImageSize(ImageSize.Cover)
  }
}