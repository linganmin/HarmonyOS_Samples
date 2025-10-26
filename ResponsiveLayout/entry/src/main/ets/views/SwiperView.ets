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

import { WidthBreakpointType } from '../utils/WidthBreakpointType';
import { WindowInfo } from '../utils/WindowUtil';

class BannerDataSource implements IDataSource {
  private bannerImgList: Resource[] = [];

  constructor(bannerImgList: Resource[]) {
    this.bannerImgList = bannerImgList;
  }

  totalCount(): number {
    return this.bannerImgList.length;
  }

  getData(index: number): Resource {
    return this.bannerImgList[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
  }

  unregisterDataChangeListener() {
  }
}

@Component
export struct SwiperView {
  @ObjectLink mainWindowInfo: WindowInfo;
  pageInfos: NavPathStack = new NavPathStack();
  bannerArray: Resource[] = [$r('app.media.ic_banner_1'), $r('app.media.ic_banner_2'), $r("app.media.ic_banner_3"),
    $r("app.media.ic_banner_4"), $r('app.media.ic_banner_3')];
  bannerDataSource: BannerDataSource = new BannerDataSource([]);

  aboutToAppear(): void {
    this.bannerDataSource = new BannerDataSource(this.bannerArray);
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_public_back'))
          .width(40)
          .height(40)
          .margin({ right: 12 })
          .onClick(() => {
            this.pageInfos.pop();
          })
        Text($r('app.string.swiper'))
          .fontSize(24)
      }
      .width('100%')
      .margin({ bottom: 12 })
      .padding({
        left: 16,
        right: 16
      })

      // [Start swiper_view]
      Swiper() {
        // [StartExclude swiper_view]
        LazyForEach(this.bannerDataSource, (item: Resource, index: number) => {
          Column() {
            Image(item)
              .objectFit(ImageFit.Fill)
              .borderRadius(24)
              .height('100%')
              .width('100%')
              .focusable(true)
          }
          .width('100%')
          // The width and height vary with the container assembly and the aspect ratio remains unchanged.
          .aspectRatio(1.6)
          .padding({
            left: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ? 8 : 0,
            right: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ? 8 : 0
          })
        }, (item: Resource, index: number) => index + JSON.stringify(item))
        // [EndExclude swiper_view]
      }
      .displayCount(new WidthBreakpointType(1, 2, 3).getValue(this.mainWindowInfo.widthBp))
      // Setting the navigation point Style of the swiper.
      .indicator(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ? Indicator.dot()
        .itemWidth(6)
        .itemHeight(6)
        .selectedItemWidth(12)
        .selectedItemHeight(6)
        .color('#4DFFFFFF')
        .selectedColor(Color.White) : false
      )
      // The sizes of the front and rear banners on the MD and LG devices are different.
      .prevMargin(new WidthBreakpointType(0, 12, 64).getValue(this.mainWindowInfo.widthBp))
      .nextMargin(new WidthBreakpointType(0, 12, 64).getValue(this.mainWindowInfo.widthBp))
      // [End swiper_view]
      // Interval between banner images
      .itemSpace(12)
      .loop(true)
      .width('100%')
      .effectMode(EdgeEffect.None)
    }
    .width('100%')
    .height('100%')
    .padding({
      top: this.getUIContext().px2vp(this.mainWindowInfo.AvoidSystem?.topRect.height) + 12,
      bottom: this.getUIContext().px2vp(this.mainWindowInfo.AvoidNavigationIndicator?.bottomRect.height)
    })
  }
}