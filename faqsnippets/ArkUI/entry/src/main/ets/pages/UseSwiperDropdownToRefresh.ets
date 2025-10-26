/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

/*
* FAQ:如何使用Swiper组件实现下拉刷新
*/

// [Start use_swiper_dropdown_to_refresh]
@Entry
@Component
struct SwiperItemLeak {
  @State isStopSwiperSlide: boolean = false;
  @State positionY: number = 0;
  private swiperController: SwiperController = new SwiperController();
  @State curSwiperIndex: number = 0;
  private list: number[] = [];

  aboutToAppear(): void {
    for (let i = 1; i <= 10; i++) {
      this.list.push(i);
    }
  }

  build() {
    Refresh({ refreshing: $$this.isStopSwiperSlide}) {
      Swiper(this.swiperController) {
        ForEach(this.list, (item: number) => {
          Text(item.toString())
            .width('100%')
            .height('100%')
            .backgroundColor(0xAFEEEE * ((item + 1) / 0x0f))
            .textAlign(TextAlign.Center)
            .fontSize(30)
        },(item: number) => JSON.stringify(item))
      }
      .vertical(true)
      .width('100%')
      .height('100%')
      .cachedCount(3)
      .index(0)
      .autoPlay(false)
      .indicator(false)
      .effectMode(EdgeEffect.None)
      .loop(false)
      .duration(100)
      .disableSwipe(this.isStopSwiperSlide)
      .displayCount(1)
      .itemSpace(0)
      .curve(Curve.Linear)
      .backgroundColor(Color.Red)
      .position({ y: this.positionY })
      .onChange((index: number) => {
        this.curSwiperIndex = index;
      })
    }
    .onRefreshing(() => {
      setTimeout(() => {
        this.isStopSwiperSlide = false
      }, 2000)
    })
    .backgroundColor(0x89CFF0)
    .refreshOffset(64)
    .pullToRefresh(true)
    .width('100%')
    .height('100%')
  }
}
// [End use_swiper_dropdown_to_refresh]