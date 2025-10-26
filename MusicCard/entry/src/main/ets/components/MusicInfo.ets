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

import { SongItem } from '../viewmodel/SongItem';
import { PlayerControlArea } from './PlayerControlArea';

@Component
export struct MusicInfo {
  @StorageProp('currentSong') currentSong: SongItem = new SongItem();
  @State currentTabIndex: number = 0;

  build() {
    Column() {
      this.CoverInfo()
      this.MusicInfo()
      Blank()
      PlayerControlArea()
    }
    .height('100%')
    .width('100%')
    .clip(false)
    .margin({
      top: $r('app.float.music_component_top'),
      bottom: $r('app.float.music_component_bottom')
    })
    .padding({
      left: $r('app.float.common_padding'),
      right: $r('app.float.common_padding')
    })
  }

  @Builder
  CoverInfo() {
    Row() {
      Image(this.currentSong.label)
        .width('100%')
        .aspectRatio(1)
        .borderRadius($r('app.float.cover_radius_label'))
        .constraintSize({
          maxWidth: 400
        })
        .shadow({
          radius: $r('app.float.shadow_radius'),
          color: $r('app.color.shadow_color'),
          offsetX: 0,
          offsetY: 6
        })
        .margin($r('app.float.lyric_margin_right_sm'))
    }
  }

  @Builder
  MusicInfo() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text($r(this.currentSong.title))
          .fontSize($r('app.float.title_font_play'))
          .fontColor(Color.White)
          .opacity(0.86)
          .fontWeight(FontWeight.Bold)
        Image($r('app.media.ic_public_likes'))
          .width($r('app.float.likes_image'))
          .height($r('app.float.likes_image'))
          .objectFit(ImageFit.Contain)
          .fillColor(Color.White)
          .opacity(0.86)
      }

      Text($r(this.currentSong.singer))
        .textAlign(TextAlign.Start)
        .fontSize($r('app.float.font_fourteen'))
        .fontColor($r('app.color.play_text_color'))
        .margin({ top: $r('app.float.music_text_margin_top') })
        .width('100%')
        .fontWeight(FontWeight.Regular)
    }
    .margin({ top: $r('app.float.music_info_margin_top') })
  }
}