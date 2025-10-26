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
export struct PagePaintComponent {
  @State progressNum: number = 0;
  @State pathCommands: string = '';
  @State colorBackgroundFill: string = Constants.COLOR_NORMAL;
  @State bgColor: string = Constants.COLOR_TRANSPARENT;
  private isRunning: boolean = false;
  private timerAdd: number = 0;
  private timerLess: number = 0;

  aboutToAppear(): void {
    this.pathCommands = this.getPathCommands(this.progressNum);
    this.changeColor();
  }

  aboutToDisappear(): void {
    clearInterval(this.timerAdd);
    clearInterval(this.timerLess);
  }

  build() {
    Column() {
      Text($r('app.string.title_name'))
        .fontSize($r('app.integer.ohos_id_text_size_headline7'))
        .textAlign(TextAlign.Start)
        .margin({
          top: $r('app.integer.title_margin_top')
        })
        .fontColor(Constants.COLOR_NORMAL)
        .width(Constants.LAYOUT_MAX_PERCENT)

      Blank()
      Stack() {
        Circle({
          width: Constants.BIG_DIAMETER,
          height: Constants.BIG_DIAMETER
        })
          .fill(Constants.COLOR_TRANSPARENT)
          .stroke(this.colorBackgroundFill)
          .strokeWidth($r('app.integer.outer_circle_stroke_width'))

        Circle({
          width: Constants.DIAMETER,
          height: Constants.DIAMETER
        })
          .fill(this.bgColor)

        Path()
          .width(Constants.DIAMETER)
          .height(Constants.DIAMETER)
          .commands(this.pathCommands)
          .fill(this.colorBackgroundFill)
          .antiAlias(true)
          .stroke(this.colorBackgroundFill)
          .strokeWidth($r('app.integer.path_stroke_width'))

        Row() {
          Text() {
            Span(this.progressNum.toFixed(Constants.ZERO))
              .fontSize($r('app.integer.ohos_id_text_size_headline3'))
            Span(Constants.PERCENTAGE_STR)
              .fontSize($r('app.integer.ohos_id_text_size_sub_title2'))
          }
        }
      }
      .width(Constants.BIG_DIAMETER)
      .height(Constants.BIG_DIAMETER)

      Blank()
      Row() {
        Row() {
          Image($r('app.media.ic_screenshot_line'))
            .width($r('app.integer.progress_percentage_image_size_width'))
            .height($r('app.integer.progress_percentage_image_size_height'))
            .onClick(() => {
              if (this.progressNum <= Constants.ZERO_PROGRESS || this.isRunning) {
                return;
              }
              this.isRunning = true;
              this.timerLess = setInterval(() => {
                this.changeProgressNum(false);
                if (this.progressNum <= Constants.ZERO_PROGRESS) {
                  this.isRunning = false;
                  clearInterval(this.timerLess);
                }
              }, Constants.PROGRESS_CHANGE_INTERVAL)
            })
        }
        .borderRadius($r('app.integer.ohos_id_corner_radius_default_xxl'))
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r("app.color.ohos_id_color_emphasize"))
        .width($r('app.integer.add_less_img_background_size'))
        .height($r('app.integer.add_less_img_background_size'))

        Row() {
          Image($r('app.media.ic_public_add'))
            .width($r('app.integer.progress_percentage_image_size_width'))
            .height($r('app.integer.progress_percentage_image_size_height'))
            .onClick(() => {
              if (this.progressNum >= Constants.FULL_PROGRESS || this.isRunning) {
                return;
              }
              this.isRunning = true;
              this.timerAdd = setInterval(() => {
                this.changeProgressNum(true);
                if (this.progressNum >= Constants.FULL_PROGRESS) {
                  this.isRunning = false;
                  clearInterval(this.timerAdd)
                }
              }, Constants.PROGRESS_CHANGE_INTERVAL)
            })
        }
        .borderRadius($r('app.integer.ohos_id_corner_radius_default_xxl'))
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r("app.color.ohos_id_color_emphasize"))
        .width($r('app.integer.add_less_img_background_size'))
        .height($r('app.integer.add_less_img_background_size'))
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .width((Constants.LAYOUT_MAX_PERCENT))
    }
    .width(Constants.LAYOUT_MAX_PERCENT)
    .height(Constants.LAYOUT_MAX_PERCENT)
    .justifyContent(FlexAlign.Center)
    .padding($r('app.integer.ohos_id_max_padding'))
  }

  getOrdinate(progressPercent: number): number {
    return (Constants.UNIT_ONE - progressPercent) * (Constants.RADIUS_IN_PX + Constants.RADIUS_IN_PX);
  }

  getDistanceSquare(ordinate: number): number {
    return Constants.RADIUS_IN_PX * Constants.RADIUS_IN_PX - (ordinate - Constants.RADIUS_IN_PX) *
      (ordinate - Constants.RADIUS_IN_PX);
  }

  getPathCommands(progressNum: number): string {
    const ordinate: number = this.getOrdinate(progressNum / Constants.PERCENT_RATE);
    const distanceSquare: number = this.getDistanceSquare(ordinate);
    if (distanceSquare >= Constants.ZERO) {
      const distance: number = Math.sqrt(distanceSquare);
      const firstAbscissa: number = Constants.RADIUS_IN_PX - distance;
      const secondAbscissa: number = Constants.RADIUS_IN_PX + distance;
      return this.formatPathCommands(firstAbscissa, secondAbscissa, ordinate, Constants.RADIUS_IN_PX);
    }
    return '';
  }

  formatPathCommands(firstAbscissa: number, secondAbscissa: number, ordinate: number, radius: number): string {
    return `M${firstAbscissa} ${ordinate} A${radius} ${radius} ` +
      `0 ${ordinate > Constants.RADIUS_IN_PX ? 0 : 1} 0 ${secondAbscissa} ${ordinate}` +
      `Q${(firstAbscissa + 3 * secondAbscissa) / 4} ${ordinate + 12.5 * (secondAbscissa - firstAbscissa) / radius}, ` +
      `${(firstAbscissa + secondAbscissa) / 2} ${ordinate} T${firstAbscissa} ${ordinate}`;
  }

  changeProgressNum(isIncrease: boolean) {
    isIncrease ? this.progressNum += Constants.PROGRESS_STEP : this.progressNum -= Constants.PROGRESS_STEP;
    this.changeColor();
    this.pathCommands = this.getPathCommands(this.progressNum);
  }

  changeColor() {
    this.colorBackgroundFill = Constants.OHOS_ID_COLOR_PALETTE4;
    if (this.progressNum === Constants.FULL_PROGRESS) {
      this.bgColor = Constants.OHOS_ID_COLOR_PALETTE4;
    } else {
      this.bgColor = Constants.COLOR_TRANSPARENT;
    }
  }
}

@Builder
export function getPagePaintComponent(name: string): void {
  if (name === 'PagePaintComponent') {
    NavDestination() {
      PagePaintComponent()
    }
  }
}

export const wrappedBuilderPaintComponent: WrappedBuilder<[string, number]> = wrapBuilder(getPagePaintComponent);