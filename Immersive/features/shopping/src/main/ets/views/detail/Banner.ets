/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { Breakpoint } from 'commons';
import { BANNER_IMAGES, BANNER_SMALL_IMAGES } from '../../constants/Detail';

@Component
export struct Banner {
  @StorageProp('breakpoint') breakpoint: Breakpoint = 'sm';
  @State currentSwiperIndex: number = 0;
  private swiperController: SwiperController = new SwiperController();

  getDataByBp<T>(data: Record<string, T>): T {
    return data[this.breakpoint];
  }

  build() {
    Column() {
      // [Start configure_swiper_clip_property]
      // features/shopping/src/main/ets/views/detail/Banner.ets
      Swiper(this.swiperController) {
        ForEach(BANNER_IMAGES, (image: Resource) => {
          Image(image)
            .width('100%')
            .height('100%')
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        }, (image: Resource) => JSON.stringify(image))
      }
      .clip(false)
      // [End configure_swiper_clip_property]
      .aspectRatio(this.getDataByBp({ 'sm': 1.2, 'md': 2.2 }))
      .indicator(false)
      .nextMargin(this.getDataByBp({ 'sm': 0, 'md': 175 }))
      .prevMargin(this.getDataByBp({ 'sm': 0, 'md': 175 }))
      .onChange((index: number) => {
        this.currentSwiperIndex = index;
      })
      Row() {
        Text(`${this.currentSwiperIndex + 1}/${BANNER_IMAGES.length}`)
          .width(36)
          .height(16)
          .fontSize(10)
          .fontColor(Color.White)
          .borderRadius(8)
          .backgroundColor('#66000000')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding(12)
      .justifyContent(FlexAlign.End)
      Row() {
        List({ space: 10 }) {
          ForEach(BANNER_SMALL_IMAGES, (image: Resource, index) => {
            ListItem() {
              Image(image)
                .width(36)
                .height(36)
                .borderRadius(8)
                .borderWidth(this.currentSwiperIndex === index ? 1 : 0)
                .onClick(() => {
                  this.swiperController.changeIndex(index)
                })
            }
          }, (image: Resource) => JSON.stringify(image))
        }
        .padding({ left: 16, bottom: 12 })
        .scrollBar(BarState.Off)
        .listDirection(Axis.Horizontal)
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
  }
}
