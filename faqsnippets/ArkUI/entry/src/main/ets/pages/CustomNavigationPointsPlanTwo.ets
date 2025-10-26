/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
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
* FAQ:Swiper如何自定义导航点高度位置
*/

// [Start DotIndicatorDemo]
@Entry
@Component
struct DotIndicatorDemo {
  private indicatorController: IndicatorComponentController = new IndicatorComponentController();
  private swiperController: SwiperController = new SwiperController();
  @State list: string[] = ['1', '2', '3', '4', '5', '6'];

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Swiper(this.swiperController) {
        ForEach(this.list, (item: string) => {
          Text(item)
            .width('90%')
            .height(200)
            .backgroundColor(0xAFEEEE)
            .textAlign(TextAlign.Center)
            .fontSize(30)
        }, (item: string) => item)
      }
      .cachedCount(2)
      .index(0)
      .indicator(this.indicatorController)

      Column() {
        IndicatorComponent(this.indicatorController)
          .style(
            new DotIndicator()
              .itemWidth(10)
              .itemHeight(10)
              .selectedItemWidth(20)
              .selectedItemHeight(10)
              .color(Color.White)
              .selectedColor(Color.Gray)
          )
      }
      .height(25)
      .clip(true)
    }
    .width('100%')
  }
}
// [Start DotIndicatorDemo]