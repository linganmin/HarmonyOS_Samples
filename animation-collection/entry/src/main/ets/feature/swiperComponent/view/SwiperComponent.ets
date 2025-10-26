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

import { SwiperData } from '../../../viewmodel/SwiperData';
import Constants from '../../../common/Constants';
import { SwiperConstants } from '../common/Constants';

@Component
export struct SwiperComponent {
  @Consume('NavPathStack') pageInfos: NavPathStack;
  @State currentIndex: number = SwiperConstants.COMMON_ZERO;
  @State swiperInterval: number = SwiperConstants.COMMON_ZERO;
  @State swiperData: SwiperData[] = [
    new SwiperData($r('app.media.page_turning'), Constants.NavDestinationData[0].detail,
      Constants.NavDestinationData[0]),
    new SwiperData($r('app.media.expand_title'), Constants.NavDestinationData[1].detail,
      Constants.NavDestinationData[1]),
    new SwiperData($r('app.media.shopping'), Constants.NavDestinationData[2].detail, Constants.NavDestinationData[2]),
  ];
  private halfCount: number = Math.floor(3 / 2);
  private manualSlidingDuration: number = SwiperConstants.MANUAL_SLIDING_DURATION;
  private automaticSlidingDuration: number = SwiperConstants.AUTOMATIC_SLIDING_DURATION;
  private automaticSwitchTime: number = SwiperConstants.AUTOMATIC_SWITCH_TIME;

  aboutToAppear(): void {
    this.currentIndex = this.halfCount;
    this.swiperInterval = setInterval(() => {
      this.startAnimation(true, this.manualSlidingDuration);
    }, this.automaticSwitchTime);
  }

  getImgCoefficients(index: number): number {
    // Calculating the left and right positions of an image.
    const coefficient: number = this.currentIndex - index;
    const tempCoefficient: number = Math.abs(coefficient);
    if (tempCoefficient <= this.halfCount) {
      return coefficient;
    }
    const dataLength: number = this.swiperData.length;
    // Determine whether the image is located at the left or right level.
    let tempOffset: number = dataLength - tempCoefficient;
    if (tempOffset <= this.halfCount) {
      if (coefficient > SwiperConstants.COMMON_ZERO) {
        return -tempOffset;
      }
      return tempOffset;
    }
    return SwiperConstants.COMMON_ZERO;
  }

  getOffSetX(index: number): number {
    const offsetIndex: number = this.getImgCoefficients(index);
    const tempOffset: number = Math.abs(offsetIndex);
    let offsetX: number = SwiperConstants.COMMON_ZERO;
    if (tempOffset === SwiperConstants.TEMP_OFFSET) {
      // Determine the left and right offsets based on the image level coefficient.
      offsetX = SwiperConstants.OFFSET_X * offsetIndex;
    }
    return offsetX;
  }

  startAnimation(isLeft: boolean, duration: number): void {
    this.getUIContext().animateTo({
      duration: duration
    }, () => {
      const dataLength: number = this.swiperData.length;
      const tempIndex: number = isLeft ? this.currentIndex + SwiperConstants.TEMP_OFFSET :
        this.currentIndex - SwiperConstants.TEMP_OFFSET + dataLength;
      this.currentIndex = tempIndex % dataLength;
    })
  }

  aboutToDisappear() {
    clearInterval();
  }

  build() {
    Column() {
      Stack() {
        ForEach(this.swiperData, (item: SwiperData, index: number) => {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(item.imageSrc)
              .objectFit(ImageFit.Cover)
              .width($r('app.string.full_size'))
              .height($r('app.string.full_size'))
              .borderRadius($r('app.string.main_page_top_borderRadius'))
            // Carousel Bottom Mask
            Stack() {
              Column() {
              }
              .width($r('app.string.full_size'))
              .height($r('app.string.full_size'))
              .backgroundColor(Color.Black)
              .opacity(SwiperConstants.OPACITY)
              .borderRadius({
                bottomLeft: $r('app.string.main_page_top_borderRadius'),
                bottomRight: $r('app.string.main_page_top_borderRadius')
              })

              Text(item.name)
                .width($r('app.string.full_size'))
                .height($r('app.string.full_size'))
                .fontSize($r('app.string.search_history_font_size2'))
                .fontColor(Color.White)
                .textAlign(TextAlign.Start)
                .padding($r('app.string.main_page_padding5'))
            }
            .height($r('app.string.bottom_title_height'))
          }
          .shadow(ShadowStyle.OUTER_DEFAULT_SM)
          .backgroundColor(Color.White)
          .borderRadius($r('app.string.main_page_top_borderRadius'))
          .offset({ x: this.getOffSetX(index) })
          .blur(index !== this.currentIndex ? SwiperConstants.BLUR_RADIUS : SwiperConstants.NOT_BLURRING)
          .zIndex(index !== this.currentIndex && this.getImgCoefficients(index) === 0 ?
            SwiperConstants.NOT_BLURRING : SwiperConstants.Z_INDEX_VALUE - Math.abs(this.getImgCoefficients(index)))
          .width($r('app.string.swiper_stack_width'))
          .height(index !== this.currentIndex ? $r('app.string.swiper_stack_height1') :
            $r('app.string.swiper_stack_height2'))
          .onClick(() => {
            this.pageInfos.pushPathByName(item.routerInfo.name, '');
          })
        })
      }
      .onVisibleAreaChange(SwiperConstants.VISIBLE_AREA_CHANGE, (isVisible: boolean, currentRatio: number) => {
        clearInterval(this.swiperInterval);
        if (isVisible && currentRatio >= SwiperConstants.VISIBLE_PARAMETER_ONE) {
          this.swiperInterval = setInterval(() => {
            this.startAnimation(true, this.manualSlidingDuration);
          }, this.automaticSwitchTime)
        }
        if (!isVisible && currentRatio <= SwiperConstants.VISIBLE_PARAMETER_ZERO) {
          clearInterval(this.swiperInterval);
        }
      })
      .height($r('app.string.main_page_swiper_height'))
      .width($r('app.string.full_size'))
      .gesture(
        PanGesture({ direction: PanDirection.Horizontal })
          .onActionStart((event: GestureEvent) => {
            clearInterval(this.swiperInterval);
            this.startAnimation(event.offsetX < SwiperConstants.COMMON_ZERO, this.automaticSlidingDuration);
          })
          .onActionEnd(() => {
            this.swiperInterval = setInterval(() => {
              this.startAnimation(true, this.manualSlidingDuration);
            }, this.automaticSwitchTime);
          })
      )
      .alignContent(Alignment.Center)
      .padding({
        left: $r('app.string.main_page_padding2'),
        right: $r('app.string.main_page_padding2'),
        top: $r('app.string.main_page_padding2')
      })

      Row({ space: SwiperConstants.SPACE }) {
        ForEach(this.swiperData, (_dataItem: SwiperData, index: number) => {
          Ellipse(index !== this.currentIndex ? {
            width: SwiperConstants.COMMON_SIZE,
            height: SwiperConstants.COMMON_SIZE
          } : {
            width: SwiperConstants.ELLIPSE_WIDTH,
            height: SwiperConstants.COMMON_SIZE
          })
            .fill(index !== this.currentIndex ? Color.Black : Color.Red)
            .fillOpacity(SwiperConstants.FILL_OPACITY)
        }, (item: SwiperData) => JSON.stringify(item))
      }
      .margin({ top: $r('app.string.main_page_padding2') })
    }
    .width($r('app.string.full_size'))
  }
}