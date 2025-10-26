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

import { AVDataSource } from '../model/AVDataSource';
import { VideoData } from '../model/VideoData';
import { SOURCES } from '../model/DataModel';
import { AVPlayerView } from './AVPlayerView';
import { WindowUtil } from '../common/utils/WindowUtil';
import Logger from '../common/utils/Logger';

const TAG = '[Index]';
AppStorage.setOrCreate('isFullLandscapeScreen', false);

@Entry
@Component
struct Index {
  @State curIndex: number = 0;
  @State isPageShow: boolean = false;
  private swiperController: SwiperController = new SwiperController();
  private windowUtil: WindowUtil = WindowUtil.getInstance();
  @StorageLink('isFullLandscapeScreen') isFullLandscapeScreen: boolean = false;

  aboutToAppear(): void {
    this.windowUtil.registerOnWindowSizeChange((size) => {
      if (size.width > size.height) {
        this.isFullLandscapeScreen = true;
      } else {
        this.isFullLandscapeScreen = false;
      }
    });
  }

  onPageShow(): void {
    this.isPageShow = true;
  }

  onPageHide(): void {
    this.isPageShow = false;
  }

  build() {
    Stack() {
      Column() {
        Stack() {
          // [Start Swiper]
          Swiper(this.swiperController) {
            LazyForEach(new AVDataSource(SOURCES), (item: VideoData, index: number) => {
              AVPlayerView({
                curSource: item,
                curIndex: this.curIndex,
                index: index,
                isPageShow: this.isPageShow
              })
            })
          }
          .cachedCount(3)
          .vertical(true)
          .loop(true)
          .curve(Curve.Ease)
          .duration(300)
          .indicator(false)
          .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
            Logger.info(TAG, `onAnimationStart index:${index} , targetIndex: ${targetIndex},extraInfo: ${extraInfo}`);
            this.curIndex = targetIndex;
            // key point: Animation starts updating index
          })

          // [End Swiper]
        }

        // [End Swiper]
      }
      .backgroundColor(Color.Black)
      .height('100%')
    }
  }
}