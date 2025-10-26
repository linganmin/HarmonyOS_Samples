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

import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import { ImageUtils } from '../common/ImageUtils';
import { MyDataSource } from '../common/MyDataSource';
import { SwiperData } from '../model/SwiperData';

const IMAGE_URL = 'https://gitee.com/harmonyos_samples/SwiperPerformance/raw/master/image/photo.jpg';

@Reusable
@Component
struct ImageItem {
  @ObjectLink swiperData: SwiperData;
  @State item: string = '';

  build() {
    Image(this.swiperData.pixelMap ?? this.item)
      .width('100%')
      .aspectRatio(1)
  }
}

// [Start PreloadSwiperItem_start]
@Reusable
@Component
struct PreloadSwiperItem {
  // [StartExclude PreloadSwiperItem_start]
  @ObjectLink swiperData: SwiperData;
  private gridDataSource = new MyDataSource<string>();
  // [EndExclude PreloadSwiperItem_start]

  aboutToAppear(): void {
    hiTraceMeter.startTrace('preloadData', 1);
    // [StartExclude PreloadSwiperItem_start]
    if (this.swiperData.urls.length < 50) {
      this.swiperData.urls = [];
      for (let i = 0; i < 50; i++) {
        this.swiperData.urls.push(IMAGE_URL);
      }
    }
    // [EndExclude PreloadSwiperItem_start]
    if (!this.swiperData.pixelMap) {
      ImageUtils.getPixelMap(IMAGE_URL, (pixelMap: PixelMap) => {
        this.swiperData.pixelMap = pixelMap;
      });
    }
    // [StartExclude PreloadSwiperItem_start]
    this.gridDataSource.pushArrayData(this.swiperData.urls);
    // [EndExclude PreloadSwiperItem_start]
  }

  onDidBuild(): void {
    hiTraceMeter.finishTrace('preloadData', 1);
  }

  build() {
    Grid() {
      LazyForEach(this.gridDataSource, (item: string) => {
        GridItem() {
          ImageItem({ item: item, swiperData: this.swiperData })
        }
      }, (item: string): string => item.toString())
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    // [StartExclude PreloadSwiperItem_start]
    .rowsGap(2)
    .columnsGap(2)
    .height('100%')
    .width('100%')
    // [EndExclude PreloadSwiperItem_start]
  }
}
// [End PreloadSwiperItem_start]

@Component
export struct PreloadDataSwiper {
  private swiperDataSource = new MyDataSource<SwiperData>();

  aboutToAppear(): void {
    for (let i = 0; i < 20; i++) {
      let swiperData = new SwiperData();
      swiperData.index = i;
      this.swiperDataSource.pushData(swiperData);
    }
  }

  build() {
    NavDestination() {
      Column() {
        // [Start LazyForEach1_start]
        Swiper() {
          LazyForEach(this.swiperDataSource, (item: SwiperData) => {
            PreloadSwiperItem({ swiperData: item })
          }, (item: SwiperData) => item.index.toString())
        }
        .cachedCount(1)
        // [StartExclude LazyForEach1_start]
        .indicator(true)
        .height('100%')
        .width('100%')
        .indicator(
          Indicator.digit()
            .bottom(16)
        )
        // [EndExclude LazyForEach1_start]
        .onAnimationStart((index: number, targetIndex: number) => {
          if (targetIndex < this.swiperDataSource.totalCount() - 2) {
            let swiperData = this.swiperDataSource.getData(targetIndex + 2);
            if (swiperData.pixelMap) {
              return;
            } else {
              // Simulation data download
              ImageUtils.getPixelMap(IMAGE_URL, (pixelMap: PixelMap) => {
                swiperData.pixelMap = pixelMap;
              });
            }
          }
        })
        // [End LazyForEach1_start]
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.background_secondary'))
      .height('100%')
      .width('100%')
    }
    .title($r('app.string.title_picture'))
    .backgroundColor($r('sys.color.background_secondary'))
    .height('100%')
    .width('100%')
    .padding({
      top: AppStorage.get<number>('statusBarHeight') ?? 0,
      bottom: 0
    })
  }
}