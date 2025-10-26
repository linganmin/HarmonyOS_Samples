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

import { display } from '@kit.ArkUI';
import Constants from '../common/Constants';
import CardComponent from '../model/CardViewModel';
import { CardsSource, CardInfo } from '../model/CardModel';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
struct CardSwiperAnimation {
  @State cardsList: CardInfo[] = [];
  @State cardsOffset: number[] = [];
  @State currentSwiperIndex: number = 0;
  private data: CardsSource = new CardsSource([]);
  private displayWidth: number = 0;
  private swiperMargin: number = Constants.SWIPER_MARGIN;

  aboutToAppear(): void {
    try {
      const displayData: display.Display = display.getDefaultDisplaySync();
      this.displayWidth = this.getUIContext().px2vp(displayData.width);
      if (canIUse('SystemCapability.Window.SessionManager')) {
        if ((display.isFoldable() && display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED) ||
          this.displayWidth >= Constants.DEVICE_SIZE) {
          this.displayWidth = this.getUIContext().px2vp(displayData.width) / 2;
        }
      }
      Constants.CARD_TEST_CASE.forEach((item) => {
        this.cardsList.push(item);
        this.cardsOffset.push(0);
      })
      this.data = new CardsSource(this.cardsList);
      this.calculateOffset(0);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'CardSwiperAnimation', `aboutToAppear failed. error code=${error.code}, message=${error.message}`);
    }
  }

  build() {
    Column() {
      Swiper() {
        LazyForEach(this.data, (item: CardInfo, index: number) => {
          CardComponent({
            cardInfo: item,
            cardOffset: this.cardsOffset[index],
            cardIndex: index,
            showingCard: this.currentSwiperIndex
          })
        }, (item: CardInfo) => JSON.stringify(item))
      }
      .index(this.currentSwiperIndex)
      .loop(false)
      .prevMargin(this.swiperMargin)
      .nextMargin(this.swiperMargin)
      .duration(Constants.DURATION)
      .curve(Curve.Friction)
      .onChange((index: number) => {
        this.calculateOffset(index);
        this.currentSwiperIndex = index;
      })
      .onGestureSwipe((index, event) => {
        const currentOffset = event.currentOffset;
        const maxOffset = this.getMaxOffset(index) / 2;
        if (currentOffset < 0) {
          this.cardsOffset[index] = (-currentOffset / this.displayWidth) * maxOffset + maxOffset;
          if (this.isIndexValid(index + 1)) {
            const maxOffset = this.getMaxOffset(index + 1) / 2;
            this.cardsOffset[index + 1] = (-currentOffset / this.displayWidth) * maxOffset;
          }
          if (this.isIndexValid(index - 1)) {
            const maxOffset = this.getMaxOffset(index - 1) / 2;
            this.cardsOffset[index - 1] = (currentOffset / this.displayWidth) * maxOffset + 2 * maxOffset;
          }
        } else if (currentOffset > 0) {
          this.cardsOffset[index] = maxOffset - (currentOffset / this.displayWidth) * maxOffset;
          if (this.isIndexValid(index + 1)) {
            const maxOffset = this.getMaxOffset(index + 1) / 2;
            this.cardsOffset[index + 1] = (currentOffset / this.displayWidth) * maxOffset;
          }
          if (this.isIndexValid(index - 1)) {
            const maxOffset = this.getMaxOffset(index - 1) / 2;
            this.cardsOffset[index - 1] = 2 * maxOffset - (currentOffset / this.displayWidth) * maxOffset;
          }
        }
      })
      .onAnimationStart((_index, targetIndex) => {
        this.calculateOffset(targetIndex);
      })
      .height($r('app.float.card_swiper_swiper_height'))
    }
    .width($r('app.string.card_swiper_full_size'))
    .height($r('app.string.card_swiper_full_size'))
    .justifyContent(FlexAlign.Center)
  }

  calculateOffset(target: number) {
    let left = target - 1;
    let right = target + 1;

    if (this.isIndexValid(left)) {
      this.cardsOffset[left] = this.getMaxOffset(left);
    }
    if (this.isIndexValid(target)) {
      this.cardsOffset[target] = this.getMaxOffset(target) / 2;
    }
    if (this.isIndexValid(right)) {
      this.cardsOffset[right] = 0;
    }
  }

  isIndexValid(index: number): boolean {
    return index >= 0 && index < this.cardsList.length;
  }

  getMaxOffset(index: number): number {
    return this.displayWidth - this.cardsList[index].width - 2 * this.swiperMargin;
  }
}

@Builder
export function getCardsSwiper(name: string): void {
  if (name === 'PageCardsSwiper') {
    NavDestination() {
      CardSwiperAnimation()
    }
  }
}

export const wrappedBuilderCardsSwiper: WrappedBuilder<[string, number]> = wrapBuilder(getCardsSwiper);