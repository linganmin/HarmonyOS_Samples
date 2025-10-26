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

import { MediaService } from '../utils/MediaService';

@Component
export struct PlayerControlArea {
  @StorageLink('isPlay') isPlay: boolean = false;
  @StorageLink('currentTime') currentTime: string = '00:00';
  @StorageLink('totalTime') totalTime: string = '00:00';
  @StorageLink('progress') value: number = 0;
  @StorageLink('progressMax') max: number = 0;

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_public_list_cycled'))
          .controlImageBuilder()
          .width(24)
        Image($r('app.media.ic_sequence'))
          .controlImageBuilder()
          .width(24)
        Image($r('app.media.ic_ring'))
          .controlImageBuilder()
          .width(24)
        Image($r('app.media.ic_more'))
          .controlImageBuilder()
          .width(24)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Column() {
        Slider({
          min: 0,
          max: this.max,
          step: 1,
          value: this.value
        })
          .blockColor($r('app.color.slider_block'))
          .selectedColor($r('app.color.slider_select'))
          .trackColor($r('app.color.slider_track'))
          .blockSize({
            width: $r('app.float.slider_block'),
            height: $r('app.float.slider_block')
          })
          .onChange((value: number, mode: SliderChangeMode) => {
            if (mode === SliderChangeMode.End || mode === SliderChangeMode.Begin) {
              MediaService.getInstance().seek(value);
            }
          })
          .height($r('app.float.slider_height'))
          .margin({
            left: -4,
            right: -4
          })

        Row() {
          Text(this.currentTime)
            .fontColor($r('app.color.play_text_color'))
            .fontSize($r('app.float.singer_title_sm'))
            .lineHeight('14vp')
          Text(this.totalTime)
            .fontColor($r('app.color.play_text_color'))
            .fontSize($r('app.float.singer_title_sm'))
            .lineHeight('14vp')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .hitTestBehavior(HitTestMode.None)
      .margin({
        top: $r('app.float.slider_margin_top'),
        bottom: 16
      })

      Row() {
        Image($r('app.media.ic_public_forward'))
          .controlImageBuilder()
          .width(32)
          .onClick(() => {
            MediaService.getInstance().playPrevious();
          })
        Image(this.isPlay ? $r('app.media.ic_public_pause') : $r('app.media.ic_public_play'))
          .controlImageBuilder()
          .width(72)
          .onClick(() => {
            this.isPlay ? MediaService.getInstance().pause() : MediaService.getInstance().play();
          })
        Image($r('app.media.ic_public_next'))
          .controlImageBuilder()
          .width(32)
          .onClick(() => {
            MediaService.getInstance().playNext();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: $r('app.float.control_padding'),
        right: $r('app.float.control_padding')
      })
    }
  }
}

@Extend(Image)
function controlImageBuilder() {
  .aspectRatio(1)
  .opacity(0.86)
  .objectFit(ImageFit.Contain)
}
