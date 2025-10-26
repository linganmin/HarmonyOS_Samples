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

@Entry
@Component
struct SliderVerificationCode {
  @State tipText: string = '';
  @State inSetValueOne: number = 0;
  @State opacityNumber: number = 0;

  getTargetTranslateX() {
    return this.inSetValueOne * Constants.COEFFICIENT;
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.complete'))
          .fontSize($r('app.float.font_size_l'))
          .fontWeight(FontWeight.Medium)
      }
      .height($r('app.float.list_padding_top'))
      .margin({
        bottom: $r('app.float.margin_bottom'),
        top: $r('app.float.margin_bottom')
      })

      Stack() {
        Image($r('app.media.sliderBackground'))
          .width($r('app.float.image_width'))
          .height($r('app.float.image_height'))

        Image($r('app.media.slider'))
          .width($r('app.float.image_width_m'))
          .height($r('app.float.image_height_m'))
          .translate({
            x: this.getTargetTranslateX(),
            y: Constants.NEGATIVE_TWO
          })
      }
      .alignContent(Alignment.Start)

      Stack() {
        Row()
          .width($r('app.float.row_width_l'))
          .height(Constants.ANGLE)
          .backgroundColor($r('app.color.row_background_color'))
          .borderRadius($r('app.float.cursor_height'))
        Text($r('app.string.slide'))
          .fontColor($r('sys.color.mask_tertiary'))

        Row() {
          Slider({
            value: this.inSetValueOne,
            min: Constants.ZERO,
            max: Constants.ONE_HUNDRED,
            style: SliderStyle.InSet
          })
            .width(Constants.THREE_HUNDRED_AND_FORTY)
            .trackColor(Color.Transparent)
            .selectedColor($r('app.color.select_color'))
            .showTips(false)
            .trackThickness(Constants.ANGLE)
            .sliderInteractionMode(SliderInteraction.SLIDE_ONLY)
            .onChange((value: number, mode: SliderChangeMode) => {
              this.inSetValueOne = value;
              if (value === Constants.CHANGE_VALUE && mode.valueOf() === Constants.TWO) {
                this.inSetValueOne = Constants.CHANGE_VALUE;
                this.opacityNumber = Constants.LINE_HEIGHT;
                setTimeout(() => {
                  this.opacityNumber = Constants.ZERO;
                  if (this.inSetValueOne === Constants.CHANGE_VALUE) {
                    this.inSetValueOne = Constants.ZERO;
                  }
                }, Constants.THREE_THOUSAND);
              }
              if (value !== Constants.CHANGE_VALUE && mode.valueOf() === Constants.TWO) {
                this.inSetValueOne = Constants.ZERO;
              }
            })
        }

        Image($r('app.media.button'))
          .fillColor(Color.White)
          .width($r('app.float.button_width'))
          .height($r('app.float.button_width'))
          .margin({ left: $r('app.float.margin_left') })
          .translate({ x: this.getTargetTranslateX() })
          .hitTestBehavior(HitTestMode.Transparent)
      }
      .margin({ top: $r('app.float.padding') })

      Row() {
        Text($r('app.string.change'))
          .fontSize($r('app.float.font_size_min'))
          .fontColor($r('app.color.change_color'))
          .textAlign(TextAlign.Center)
          .margin({ top: $r('app.float.row_margin') })
          .lineHeight($r('app.float.change'))
        Image($r('app.media.img'))
          .width($r('app.float.change'))
          .height($r('app.float.change'))
          .translate({
            y: Constants.TEN,
            x: Constants.ITEM_DIVIDER
          })
          .backgroundColor(Color.White)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      Text($r('app.string.verification_passed'))
        .opacity(this.opacityNumber)
        .fontSize($r('app.float.font_size'))
        .fontColor(Color.Black)
        .height($r('app.float.toast_height'))
        .backgroundColor(Color.White)
        .padding({
          left: $r('app.float.change'),
          right: $r('app.float.change')
        })
        .margin({ top: $r('app.float.toast_margin') })
        .borderRadius($r('app.float.toast_border_radius'))
        .shadow({
          radius: $r('app.float.shadow'),
          type: ShadowType.COLOR,
          color: $r('app.color.shadow')
        })
    }
    .width(Constants.ONE_HUNDRED_PERCENT)
    .height(Constants.ONE_HUNDRED_PERCENT)
  }
}

@Builder
export function getSliderVerification(name: string): void {
  if (name === 'SliderVerification') {
    NavDestination() {
      SliderVerificationCode()
    }
  }
}

export const wrappedBuilderSliderVerification: WrappedBuilder<[string, number]> = wrapBuilder(getSliderVerification);