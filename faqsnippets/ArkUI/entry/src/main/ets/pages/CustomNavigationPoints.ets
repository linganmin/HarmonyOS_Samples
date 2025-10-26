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

// [Start custom_navigation_points]
@Entry
@Component
struct SwiperExample {
  private swiperController: SwiperController = new SwiperController();
  @State arr: string[] = ['1', '2', '3', '4', '5', '6'];
  @State widthLength: number = 0;
  @State heightLength: number = 0;
  @State currentIndex: number = 0;

  build() {
    Column({ space: 5 }) {
      Stack({ alignContent: Alignment.Bottom }) {
        Swiper(this.swiperController) {
          ForEach(this.arr, (item: string) => {
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
        .indicator(false)
        .onChange((index: number) => {
          this.currentIndex = index;
        })

        Row() {
          ForEach(this.arr, (_: string, index: number) => {
            Column()
              .width(this.currentIndex == index ? 15 : 5)
              .height(5)
              .margin(5)
              .backgroundColor(this.currentIndex == index ? Color.Gray : Color.White)
          }, (item: string) => item)
        }
      }
    }
    .width('100%')
    .height('100%')
  }
}

// [End custom_navigation_points]