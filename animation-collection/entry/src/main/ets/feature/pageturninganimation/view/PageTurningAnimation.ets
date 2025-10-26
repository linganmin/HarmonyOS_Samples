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

import Constants from '../common/Constants';

@Component
struct BookPage {
  @Prop pageNum: number;
  @Prop rotateAngle: number;
  @Prop positionX: string;
  @Prop positionY: string;

  build() {
    Text(`${this.pageNum}`)
      .fontSize($r('app.float.common_font_size'))
      .fontColor(Color.White)
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .backgroundColor($r('app.color.common_color_dark_blue'))
      .width($r('app.string.common_text_width'))
      .height($r('app.string.common_text_height'))
      .borderRadius($r('app.float.common_border_radius'))
      .rotate({
        x: 0,
        y: 1,
        z: 0,
        angle: this.rotateAngle,
        centerX: this.positionX,
        centerY: this.positionY
      })
  }
}

@Component
export struct PageTurningAnimation {
  @State originalAngle: number = 0;
  @State rotateAngleTextA: number = 0;
  @State rotateAngleTextB: number = 0;
  @State pageNumTextA: number = 0;
  @State animatePageNumTextB: number = 1;
  @State pageNumTextC: number = 0;
  @State nextPageNumTextD: number = 0;
  @State leftX: string = Constants.PERCENT_ZERO;
  @State leftY: string = Constants.PERCENT_ZERO;
  @State centerX: string = Constants.PERCENT_HALF;
  @State centerY: string = Constants.PERCENT_HALF;
  private timer: number = 0;

  aboutToAppear(): void {
    this.timer = setInterval(() => {
      this.pageTurningAnimate();
    }, Constants.TIMER_DELAY)
  }

  aboutToDisappear(): void {
    clearInterval(this.timer);
  }

  private pageTurningAnimate() {
    this.getUIContext().animateTo({
      duration: Constants.ANIMATE_DURATION,
      onFinish: () => {
        this.pageNumTextA = this.animatePageNumTextB;
        this.rotateAngleTextA = Constants.ROTATE_ANGLE;
        this.rotateAngleTextB = 0;
        this.animatePageNumTextB = (this.animatePageNumTextB + 1) % Constants.MAX_PAGE_NUMBER;
      }
    }, () => {
      this.rotateAngleTextB = Constants.ROTATE_ANGLE;
      this.nextPageNumTextD = (this.animatePageNumTextB + 1) % Constants.MAX_PAGE_NUMBER;
    })
  }

  build() {
    Stack() {
      Row() {
        BookPage({
          pageNum: this.pageNumTextC,
          rotateAngle: this.originalAngle,
          positionX: this.leftX,
          positionY: this.leftY
        })
        BookPage({
          pageNum: this.nextPageNumTextD,
          rotateAngle: this.originalAngle,
          positionX: this.leftX,
          positionY: this.leftY
        })
      }

      Row() {
        BookPage({
          pageNum: this.pageNumTextA,
          rotateAngle: this.rotateAngleTextA,
          positionX: this.centerX,
          positionY: this.centerY
        })
        BookPage({
          pageNum: this.animatePageNumTextB,
          rotateAngle: this.rotateAngleTextB,
          positionX: this.leftX,
          positionY: this.leftY
        })
      }

      Divider()
        .strokeWidth(5)
        .color(Color.White)
        .height($r('app.string.divider_height'))
        .vertical(true)
    }
    .width($r('app.string.common_stack_width'))
    .height($r('app.string.common_stack_height'))
    .backgroundColor($r('app.color.stack_background_color'))
  }
}

@Builder
export function getPageTurningAnimation(name: string): void {
  if (name === 'PageTurningAnimation') {
    NavDestination() {
      PageTurningAnimation()
    }
  }
}

export const wrappedBuilderTurningAnimation: WrappedBuilder<[string, number]> = wrapBuilder(getPageTurningAnimation);