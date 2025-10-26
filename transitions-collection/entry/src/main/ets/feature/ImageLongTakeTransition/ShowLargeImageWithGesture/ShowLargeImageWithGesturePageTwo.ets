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

import { matrix4 } from '@kit.ArkUI';
import { PhotoItem } from './MyComponent';

@Builder
export function ShowLargeImageWithGesturePageTwoBuilder() {
  ShowLargeImageWithGesturePageTwo();
}

@Component
struct ShowLargeImageWithGesturePageTwo {
  @State selectedIndex: number = 0;
  @State scaleRatio: number = 1;
  @State positionX: number = 0;
  @State positionY: number = 0;
  @State scaleX: number = 1;
  @State scaleY: number = 1;
  @State translateX: number = 0;
  @State translateY: number = 0;
  @State imageMatrix: matrix4.Matrix4Transit = matrix4.identity();
  private pageInfo: NavPathStack = new NavPathStack();
  private swiperController: SwiperController = new SwiperController();
  private imageRatioData: number[] = [2772 / 2080, 1706 / 1280, 3648 / 2736, 3648 / 2736, 1280 / 720,
    1280 / 1706, 2772 / 2080, 2081 / 2775, 2772 / 2080];

  aboutToAppear(): void {
    for (let i = 0; i < 9; i++) {
      this.bigImageData[i] = i;
    }
  }

  private onIndexChange: (index: number) => void = (_index: number) => {
  }
  private backToFirstPage: () => void = () => {
    this.getUIContext().animateTo({
      duration: 300,
      curve: Curve.EaseIn,
    }, () => {
      this.onFirstPageShow();
      this.pageInfo.pop(false);
    })
  }
  private onFirstPageShow: () => void = () => {};
  private bigImageData: number[] = [];

  build() {
    NavDestination() {
      Swiper(this.swiperController) {
        ForEach(this.bigImageData, (item: number) => {
          PhotoItem({
            imageWidth: 1260,
            imageHeight: 1260 / this.imageRatioData[item],
            imageUrl: 'app.media.img_' + JSON.stringify(item % 9),
            backToFirstPage: this.backToFirstPage
          })
        }, (item: string) => item)
      }
      .transition(TransitionEffect.opacity(0.99))
      .width('100%')
      .height('100%')
      .clip(false)
      .index(this.selectedIndex)
      .onChange((index: number) => {
        this.selectedIndex = index;
        this.onIndexChange(index);
      })
      .onAnimationStart((_: number, targetIndex: number) => {
        this.onIndexChange(targetIndex);
      })
      .indicator(false)
    }
    .width('100%')
    .height('100%')
    .mode(NavDestinationMode.DIALOG)
    .expandSafeArea([SafeAreaType.SYSTEM])
    .onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack;
      let param = context.pathInfo?.param as Record<string, Object>;
      if (param === undefined) {
        return;
      }
      this.selectedIndex = param['selectedIndex'] as number;
      this.onIndexChange = param['onIndexChange'] as (index: number) => void;
      this.onFirstPageShow = param['onBackToFirstPage'] as () => void;
    })
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.backToFirstPage();
      return true;
    })
    .transition(TransitionEffect.opacity(0.99))
  }
}