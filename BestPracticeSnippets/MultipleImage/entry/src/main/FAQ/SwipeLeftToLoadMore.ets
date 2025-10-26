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

/**
 * 常见问题:Swiper如何实现左滑加载更多效果
 */

// [Start SwipeLeftToLoadMore]
@Entry
@Component
struct MySwiper {
  private swiperController: SwiperController = new SwiperController();
  private ind: number = 1;
  @State list: number[] = [];

  aboutToAppear(): void {
    for (let i = 0; i <= 3; i++) {
      this.list.push(this.ind);
      this.ind += 1;
    }
  }

  build() {
    Column({ space: 5 }) {
      Swiper(this.swiperController) {
        ForEach(this.list, (item: string) => {
          Text(item.toString())
            .width('90%')
            .height(160)
            .backgroundColor(0xAFEEEE)
            .textAlign(TextAlign.Center)
            .fontSize(30)
        }, (item: string) => item)
      }
      .cachedCount(2)
      .index(1)
      .autoPlay(false)
      .interval(4000)
      .loop(false)
      .indicatorInteractive(true)
      .duration(1000)
      .itemSpace(0)
      .curve(Curve.Linear)
      .onGestureSwipe((index: number, extraInfo: SwiperAnimationEvent) => {
        if (index === this.list.length - 1) {
          if (extraInfo.currentOffset < -50) {
            this.getUIContext().getPromptAction().showToast({ message: '< -50' });
            for (let i = 4; i <= 6; i++) {
              this.list.push(this.ind);
              this.ind += 1;
            }
          }
        }
      })
    }
    .width('100%')
    .margin({ top: 5 })
  }
}

// [Start SwipeLeftToLoadMore]