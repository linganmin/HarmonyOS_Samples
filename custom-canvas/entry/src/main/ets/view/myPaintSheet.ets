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

import { CommonConstants } from '../common/CommonConstants';
import { IBrush } from '../viewmodel/IBrush';
import NormalBrush from '../viewmodel/IBrush';
import Paint from '../viewmodel/Paint';

@Component
export struct myPaintSheet {
  @Link isMarker: boolean;
  @Link alpha: number;
  @Link percent: string;
  @Link color: string;
  @Link thicknessesValue: number;
  @Link strokeWidth: number;
  @Consume mPaint: Paint;
  @Consume mBrush: IBrush;

  ToggleThicknessColor() {
    this.mPaint = new Paint(CommonConstants.ZERO, CommonConstants.COLOR_STRING, CommonConstants.ONE);
    this.mPaint.setStrokeWidth(this.strokeWidth);
    this.mPaint.setColor(this.color);
    this.mPaint.setGlobalAlpha(this.alpha);
    this.mBrush = new NormalBrush();
  }

  build() {
    Column() {
      Column() {
        Text($r('app.string.brash'))
          .textAlign(TextAlign.Start)
          .fontSize($r('app.float.font_size'))
          .fontColor($r('sys.color.mask_secondary'))
          .margin({ bottom: $r('app.float.margin_bottom') })
        Row() {
          Column() {
            Stack() {
              Text()
                .width($r('app.float.back_width'))
                .height($r('app.float.back_width'))
                .backgroundColor(this.isMarker ? $r('app.color.paint_color') : $r('app.color.theme_color'))
                .borderRadius($r('app.float.border_radius'))
              Image(this.isMarker ? $r('app.media.Ballpoint') : $r('app.media.Ballpoint_active'))
                .width($r('app.float.image_width'))
                .height($r('app.float.image_width'))
              Button({ type: ButtonType.Normal })
                .width($r('app.float.back_width'))
                .height($r('app.float.back_width'))
                .borderRadius($r('app.float.border_radius'))
                .backgroundColor(Color.Transparent)
                .onClick(() => {
                  this.isMarker = false;
                  this.alpha = 1;
                  this.percent = '100';
                  this.ToggleThicknessColor();
                })
            }

            Text($r('app.string.ballpoint'))
              .fontSize($r('app.float.font_size'))
              .fontColor(this.isMarker ? $r('sys.color.mask_secondary') : $r('app.color.theme_color'))
              .margin({ top: $r('app.float.margin_top') })
          }
          .width($r('app.float.brash_width'))
          .height($r('app.float.brash_height'))

          Column() {
            Stack() {
              Text()
                .width($r('app.float.back_width'))
                .height($r('app.float.back_width'))
                .backgroundColor(this.isMarker ? $r('app.color.theme_color') : $r('app.color.paint_color'))
                .borderRadius($r('app.float.border_radius'))
              Image(this.isMarker ? $r('app.media.marker_active') : $r('app.media.marker'))
                .width($r('app.float.image_width'))
                .height($r('app.float.image_width'))
              Button({ type: ButtonType.Normal })
                .width($r('app.float.back_width'))
                .height($r('app.float.back_width'))
                .borderRadius($r('app.float.border_radius'))
                .backgroundColor(Color.Transparent)
                .onClick(() => {
                  this.isMarker = true;
                  this.alpha = 0.5;
                  this.percent = '50';
                  this.ToggleThicknessColor();
                })
            }

            Text($r('app.string.marker'))
              .fontSize($r('app.float.font_size'))
              .fontColor(this.isMarker ? $r('app.color.theme_color') : $r('sys.color.mask_secondary'))
              .margin({ top: $r('app.float.margin_top') })
          }
          .width($r('app.float.brash_width'))
          .height($r('app.float.brash_height'))

          Column() {
            Stack() {
              Text()
                .width($r('app.float.back_width'))
                .height($r('app.float.back_width'))
                .backgroundColor($r('app.color.paint_color'))
                .borderRadius($r('app.float.border_radius'))
              Image($r('app.media.pencils'))
                .width($r('app.float.image_width'))
                .height($r('app.float.image_width'))
            }

            Text($r('app.string.pencil'))
              .fontSize($r('app.float.font_size'))
              .fontColor($r('sys.color.mask_secondary'))
              .margin({ top: $r('app.float.margin_top') })
          }
          .width($r('app.float.brash_width'))
          .height($r('app.float.brash_height'))

          Column() {
            Stack() {
              Text()
                .width($r('app.float.back_width'))
                .height($r('app.float.back_width'))
                .backgroundColor($r('app.color.paint_color'))
                .borderRadius($r('app.float.border_radius'))
              Image($r('app.media.fountain'))
                .width($r('app.float.image_width'))
                .height($r('app.float.image_width'))
            }

            Text($r('app.string.fountain_pen'))
              .fontSize($r('app.float.font_size'))
              .fontColor($r('sys.color.mask_secondary'))
              .margin({ top: $r('app.float.margin_top') })
          }
          .width($r('app.float.brash_width'))
          .height($r('app.float.brash_height'))

          Column() {
            Stack() {
              Text()
                .width($r('app.float.back_width'))
                .height($r('app.float.back_width'))
                .backgroundColor($r('app.color.paint_color'))
                .borderRadius($r('app.float.border_radius'))
              Image($r('app.media.laser'))
                .width($r('app.float.image_width'))
                .height($r('app.float.image_width'))
            }

            Text($r('app.string.laser_pointer'))
              .fontSize($r('app.float.font_size'))
              .fontColor($r('sys.color.mask_secondary'))
              .margin({ top: $r('app.float.margin_top') })
          }
          .width($r('app.float.brash_width'))
          .height($r('app.float.brash_height'))
        }
        .padding({
          left: $r('app.float.margin_top'),
          right: $r('app.float.margin_top')
        })
        .width(CommonConstants.ONE_HUNDRED_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .padding({
        left: $r('app.float.padding_left'),
        right: $r('app.float.padding_left'),
        top: $r('app.float.margin_bottom')
      })
      .alignItems(HorizontalAlign.Start)
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .margin({ bottom: $r('app.float.title_bottom') })

      Column() {
        Text($r('app.string.color'))
          .textAlign(TextAlign.Start)
          .fontSize($r('app.float.font_size'))
          .fontColor($r('sys.color.mask_secondary'))
          .margin({ bottom: $r('app.float.margin_bottom') })
        Row() {
          ForEach(CommonConstants.COLOR_ARR, (item: string) => {
            Text()
              .width($r('app.float.image_width'))
              .height($r('app.float.image_width'))
              .borderRadius($r('app.float.border_radius_m'))
              .backgroundColor(item)
              .onClick(() => {
                this.color = item;
                this.ToggleThicknessColor();
              })
          }, (item: string) => JSON.stringify(item))
        }
        .padding({
          left: $r('app.float.margin_top'),
          right: $r('app.float.margin_top')
        })
        .justifyContent(FlexAlign.SpaceBetween)
        .width(CommonConstants.ONE_HUNDRED_PERCENT)
      }
      .padding({
        left: $r('app.float.padding_left'),
        right: $r('app.float.padding_left')
      })
      .alignItems(HorizontalAlign.Start)
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .margin({ bottom: $r('app.float.margin_bottom') })

      Column() {
        Text($r('app.string.opacity'))
          .textAlign(TextAlign.Start)
          .fontSize($r('app.float.font_size'))
          .fontColor($r('sys.color.mask_secondary'))
          .margin({ bottom: $r('app.float.margin_top') })
        Row() {
          Stack() {
            Slider({
              style: SliderStyle.InSet,
              value: this.alpha * CommonConstants.ONE_HUNDRED
            })
              .height($r('app.float.brash_width'))
              .width($r('app.float.slider_width'))
              .selectedColor(Color.Transparent)
              .minResponsiveDistance(CommonConstants.ONE)
              .trackColor(new LinearGradient([
                { color: $r('app.color.linear_start'), offset: CommonConstants.ZERO },
                { color: $r('app.color.linear_end'), offset: CommonConstants.ONE }
              ]))
              .onChange((value: number) => {
                if (this.isMarker) {
                  this.alpha = value / 100;
                  this.percent = value.toFixed(0);
                  this.ToggleThicknessColor();
                }
              })
            if (!this.isMarker) {
              Row()
                .backgroundColor(Color.Transparent)
                .width($r('app.float.slider_width'))
                .height($r('app.float.brash_width'))
            }
          }

          Text(this.percent + CommonConstants.SIGN)
            .width($r('app.float.number'))
            .height($r('app.float.image_width'))
            .fontSize($r('app.float.font_size_l'))
            .borderRadius($r('app.float.border_radius_m'))
            .textAlign(TextAlign.Center)
            .backgroundColor($r('app.color.number_color'))
        }
        .padding({
          left: $r('app.float.margin_top'),
          right: $r('app.float.margin_top')
        })
        .justifyContent(FlexAlign.SpaceBetween)
        .width(CommonConstants.ONE_HUNDRED_PERCENT)
      }
      .padding({
        left: $r('app.float.padding_left'),
        right: $r('app.float.padding_left')
      })
      .alignItems(HorizontalAlign.Start)
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .margin({ bottom: $r('app.float.margin_bottom') })

      Column() {
        Text($r('app.string.thicknesses'))
          .textAlign(TextAlign.Start)
          .fontSize($r('app.float.font_size'))
          .fontColor($r('sys.color.mask_secondary'))
          .margin({ bottom: $r('app.float.margin_bottom') })
        Row() {
          Image($r('app.media.minuses'))
            .width($r('app.float.image_width'))
            .height($r('app.float.image_width'))
            .onClick(() => {
              this.thicknessesValue -= 1;
              this.strokeWidth = this.thicknessesValue;
              this.ToggleThicknessColor();
            })
          Slider({
            value: this.thicknessesValue,
            min: CommonConstants.THREE,
            max: CommonConstants.TWENTY_ONE
          })
            .width($r('app.float.slider_width'))
            .minResponsiveDistance(CommonConstants.ONE)
            .onChange((value: number, _mode: SliderChangeMode) => {
              this.thicknessesValue = value;
              this.strokeWidth = value;
              this.ToggleThicknessColor();
            })
          Image($r('app.media.add'))
            .width($r('app.float.image_width'))
            .height($r('app.float.image_width'))
            .onClick(() => {
              this.thicknessesValue += 1;
              this.strokeWidth = this.thicknessesValue;
              this.ToggleThicknessColor();
            })
        }
        .padding({
          left: $r('app.float.margin_bottom'),
          right: $r('app.float.margin_bottom')
        })
        .justifyContent(FlexAlign.SpaceBetween)
        .width(CommonConstants.ONE_HUNDRED_PERCENT)
      }
      .padding({
        left: $r('app.float.padding_left'),
        right: $r('app.float.padding_left')
      })
      .alignItems(HorizontalAlign.Start)
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
    }
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .height(CommonConstants.ONE_HUNDRED_PERCENT)
  }
}