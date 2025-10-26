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

import { PlayerLyrics } from './PlayerLyrics';
import { MusicInfo } from './MusicInfo';
import { PlayerTopArea } from './PlayerTopArea';
import { SongItem } from '../viewmodel/SongItem';
import ImageUtils from '../utils/ImageUtils';
import WindowUtils from '../utils/WindowUtils';

@Component
export struct PlayerView {
  @StorageLink('naviIndicatorHeight') naviIndicatorHeight: number = 0;
  @StorageLink('statusBarHeight') statusBarHeight: number = 0;
  @StorageProp('currentSong') @Watch('getImageColor') currentSong: SongItem = new SongItem();
  @State imageColor: string = 'rgba(0, 0, 2, 1.00)';
  @State imageLabel: PixelMap | undefined = undefined;
  @Link isShowPlay: boolean;

  getImageColor() {
    ImageUtils.getImageDealData(this.getUIContext().getHostContext()!, this.currentSong.label).then((data) => {
      this.imageColor = data.imageColor;
      this.imageLabel = data.blurPixelMap;
    })
  }

  aboutToAppear(): void {
    this.getImageColor();
  }

  build() {
    Stack() {
      Image(this.imageLabel)
        .size({ height: '120%' })
        .aspectRatio(1)
        .objectFit(ImageFit.Cover)
        .opacity(0.5)

      Row() {
        Stack({ alignContent: Alignment.TopStart }) {
          Swiper() {
            MusicInfo()
            PlayerLyrics()
          }
          .height('100%')
          .indicator(
            new DotIndicator()
              .top(10)
              .selectedColor($r('app.color.select_swiper'))
              .color($r('app.color.slider_track'))
          )
          .clip(false)
          .loop(false)

          PlayerTopArea({ isShowPlay: this.isShowPlay })
        }
        .height('100%')
      }
      .padding({
        bottom: this.naviIndicatorHeight,
        top: this.statusBarHeight
      })
    }
    .onAppear(() => {
      WindowUtils.setStatusbarContentColor('#FFFFFF');
    })
    .onDisAppear(() => {
      WindowUtils.setStatusbarContentColor('#000000');
    })
    .height('100%')
    .width('100%')
    .backgroundColor(this.imageColor)
  }
}