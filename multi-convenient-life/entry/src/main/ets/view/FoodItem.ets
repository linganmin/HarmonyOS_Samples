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
import { CommonConstants } from '../constants/CommonConstants';

import { FoodData } from '../viewmodel/FoodListViewModel';

@Component
export struct FoodItem {
  @Consume('ifShowSides') ifShowSides: boolean;
  @Prop foodData: FoodData;
  @Prop chooseIndex: number;
  listIndex: number = 0;

  @Styles
  orangeText(){
    .backgroundColor('#1aed6f21')
    .padding($r('app.float.orange_padding'))
    .borderRadius($r('app.float.orange_border'))
  }

  build() {
    Row() {
      Image(this.foodData.getImage())
        .width($r('app.float.food_data_image'))
        .aspectRatio(1)
      Column() {
        Row() {
          Text(this.foodData.getName())
            .fontWeight(CommonConstants.FONT_WEIGHT_700)
            .fontSize($r('app.float.food_data_font'))
          Blank()
          Text($r('app.string.booked_text'))
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .fontColor('#ED6F21')
            .fontSize($r('app.float.filtering_font'))
            .orangeText()
            .visibility(this.foodData.getReservation() ? Visibility.Visible : Visibility.None)
            .margin({
              right: $r('app.float.filtering_margin_right')
            })
          Text($r('app.string.takeaway_text'))
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .fontColor('#ED6F21')
            .fontSize($r('app.float.filtering_font'))
            .orangeText()
        }
        .width(CommonConstants.FULL_PERCENT)
        .margin({
          bottom: $r('app.float.food_data_bottom')
        })

        Row() {
          Rating({ rating: this.foodData.getRating(), indicator: true })
            .height($r('app.float.rating_height'))
            .margin({
              right: $r('app.float.rating_margin_right')
            })
          Text(this.foodData.getRating().toFixed(1))
            .fontWeight(CommonConstants.FONT_WEIGHT_700)
            .fontColor('#ED6F21')
            .fontSize($r('app.float.reviews_font'))
            .margin({
              right: $r('app.float.filtering_margin_right')
            })
          Text(CommonConstants.CURRENCY_SYMBOL + this.foodData.getPricePerPerson() + CommonConstants.CURRENCY_UNIT)
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .fontSize($r('app.float.delivery_font'))
            .textAlign(TextAlign.Center)
        }
        .alignItems(VerticalAlign.Center)
        .width(CommonConstants.FULL_PERCENT)
        .margin({
          bottom: $r('app.float.food_margin_bottom')
        })

        Row() {
          Text(this.foodData.getLocation())
            .fontWeight(CommonConstants.FONT_WEIGHT_500)
            .fontColor($r('app.color.sixty_black'))
            .fontSize($r('app.float.delivery_font'))
          Blank()
          Text(this.foodData.getDistance())
            .fontWeight(CommonConstants.FONT_WEIGHT_500)
            .fontSize($r('app.float.delivery_font'))
        }
        .width(CommonConstants.FULL_PERCENT)
        .margin({
          bottom: $r('app.float.text_margin_bottom')
        })

        Row() {
          ForEach(this.foodData.getRankings(), (item: string) => {
            Text(item)
              .fontWeight(CommonConstants.FONT_WEIGHT_400)
              .fontColor($r('app.color.filtering_font'))
              .fontSize($r('app.float.filtering_font'))
              .orangeText()
              .margin({
                right: $r('app.float.filtering_margin_right')
              })
          })
        }
        .width(CommonConstants.FULL_PERCENT)
        .margin({
          bottom: $r('app.float.text_margin_bottom')
        })

        Row() {
          Text($r('app.string.preference_flag'))
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .fontColor($r('app.color.filtering_font'))
            .fontSize($r('app.float.filtering_font'))
            .orangeText()
            .margin({
              right: $r('app.float.flag_margin_right')
            })
          Text(CommonConstants.CURRENCY_SYMBOL + this.foodData.getPrice())
            .fontWeight(CommonConstants.FONT_WEIGHT_500)
            .fontColor($r('app.color.filtering_font'))
            .fontSize($r('app.float.delivery_font'))
            .margin({
              right: $r('app.float.symbol_margin_right')
            })
          Text(CommonConstants.CURRENCY_SYMBOL + ' ' + this.foodData.getOriginalPrice())
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .fontColor($r('app.color.forty_black'))
            .fontSize($r('app.float.filtering_font'))
            .decoration({ type: TextDecorationType.LineThrough })
          Text(this.foodData.getRecommended())
            .fontWeight(CommonConstants.FONT_WEIGHT_500)
            .fontSize($r('app.float.filtering_font'))
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({
              overflow: TextOverflow.Ellipsis
            })
        }
        .width(CommonConstants.FULL_PERCENT)
      }
      .padding({
        left: $r('app.float.twelves_padding')
      })
      .layoutWeight(1)
    }
    .alignItems(VerticalAlign.Top)
    .width(CommonConstants.FULL_PERCENT)
    .padding($r('app.float.twelves_padding'))
    .borderRadius($r('app.float.dish_border'))
    .backgroundColor(this.listIndex === this.chooseIndex && this.ifShowSides ?
    $r('app.color.food_background') : $r('app.color.three_black'))
  }
}