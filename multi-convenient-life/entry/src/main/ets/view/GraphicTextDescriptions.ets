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

import { BreakpointConstants } from '../constants/BreakpointConstants';
import { CommonConstants } from '../constants/CommonConstants';
import { BreakpointType } from '../utils/BreakpointType';

@Component
export struct GraphicTextDescriptions {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @Consume('showSideBar') showSideBar: boolean;
  private tagList: ResourceStr[] = [$r('app.string.seagulls'), $r('app.string.bay_seagull'),
    $r('app.string.seabird_park_symbol')];
  private descriptions: string = CommonConstants.GRAPHIC_DESCRIPTIONS;

  build() {
    Column() {
      Text($r('app.string.plants_language'))
        .textAlign(TextAlign.Start)
        .fontSize($r('app.float.plants_language_font'))
        .fontWeight(CommonConstants.FONT_WEIGHT_700)
        .width(CommonConstants.FULL_PERCENT)
        .margin({
          bottom: $r('app.float.twelves_padding')
        })
      Text(this.descriptions)
        .width(CommonConstants.FULL_PERCENT)
        .textAlign(TextAlign.Start)
        .fontSize($r('app.float.tabs_font'))
        .lineHeight($r('app.float.line_height'))
        .fontWeight(CommonConstants.FONT_WEIGHT_400)
      Row() {
        ForEach(this.tagList, ((item: ResourceStr) => {
          Text(item)
            .fontSize($r('app.float.tabs_font'))
            .fontColor($r('app.color.tag_color'))
            .lineHeight($r('app.float.line_height'))
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .margin({
              right: $r('app.float.price_margin_right')
            })
        }))
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        top: $r('app.float.price_margin_right')
      })
      .justifyContent(FlexAlign.Start)

      Row() {
        Image($r('app.media.slt_img'))
          .width($r('app.float.graphic_slt_width'))
          .aspectRatio(1)
          .borderRadius($r('app.float.add_cart_border'))
          .margin({
            right: $r('app.float.tabs_margin_right')
          })
        Row() {
          Column() {
            Text($r('app.string.seabird_park'))
              .fontSize($r('app.float.tabs_font'))
              .fontWeight(CommonConstants.FONT_WEIGHT_700)
            Text($r('app.string.metro_station'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontSize($r('app.float.delivery_font'))
              .fontColor($r('app.color.sixty_black'))
            Text($r('app.string.city_park'))
              .fontSize($r('app.float.filtering_font'))
              .fontColor($r('app.color.city_park_font'))
              .backgroundColor('#1aed6f21')
              .padding({
                top: $r('app.float.orange_padding'),
                bottom: $r('app.float.orange_padding'),
                left: $r('app.float.tabs_padding_tb'),
                right: $r('app.float.tabs_padding_tb')
              })
          }
          .height($r('app.float.graphic_slt_width'))
          .layoutWeight(1)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(HorizontalAlign.Start)

          Row() {
            Image($r('app.media.v2_ic_public_collect'))
              .width($r('app.float.common_image'))
              .aspectRatio(1)
            Text($r('app.string.people_number'))
              .fontSize($r('app.float.delivery_font'))
          }
        }
        .layoutWeight(1)
        .onClick(() => {
          this.showSideBar = true;
        })
      }
      .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
      .width(CommonConstants.FULL_PERCENT)
      .borderRadius($r('app.float.five_radius'))
      .backgroundColor(Color.White)
      .padding({
        top: $r('app.float.seven_padding'),
        left: $r('app.float.eight_padding'),
        right: $r('app.float.twelves_padding'),
        bottom: $r('app.float.eight_padding')
      })
      .margin({
        top: $r('app.float.price_margin_right'),
        bottom: $r('app.float.margin_twelves')
      })

      Text($r('app.string.data_text'))
        .fontSize($r('app.float.filtering_font'))
        .fontColor($r('app.color.forty_black'))
        .width(CommonConstants.FULL_PERCENT)
        .textAlign(TextAlign.Start)
      Column() {
        Divider()
          .vertical(false)
          .color($r('app.color.five_white'))
          .width(CommonConstants.FULL_PERCENT)
          .margin({
            bottom: $r('app.float.margin_small')
          })
        Text($r('app.string.total_reviews'))
          .fontSize($r('app.float.tabs_font'))
          .fontColor($r('app.color.forty_black'))
          .width(CommonConstants.FULL_PERCENT)
          .textAlign(TextAlign.Start)
          .margin({
            bottom: $r('app.float.margin_small')
          })
        Row() {
          Image($r('app.media.tx2_img'))
            .width($r('app.float.tx2_width'))
            .aspectRatio(1)
            .margin({
              right: $r('app.float.back_image_right')
            })
          Column() {
            Text($r('app.string.candy_pocket'))
              .fontColor($r('app.color.forty_black'))
              .fontSize($r('app.float.delivery_font'))
              .margin({
                bottom: $r('app.float.sanger_bottom')
              })
            Text($r('app.string.seagull_much'))
              .fontSize($r('app.float.delivery_font'))
          }
          .alignItems(HorizontalAlign.Start)
          .padding({
            top: $r('app.float.text_margin_bottom')
          })
          .layoutWeight(1)

          Column() {
            Image($r('app.media.v2_ic_public_favor'))
              .width($r('app.float.more_width'))
              .aspectRatio(1)
              .margin({
                bottom: $r('app.float.flag_margin_right')
              })
            Text($r('app.string.two_number'))
              .fontColor($r('app.color.forty_black'))
              .fontSize($r('app.float.filtering_font'))
          }
        }
        .width(CommonConstants.FULL_PERCENT)
        .margin({
          bottom: $r('app.float.margin_small')
        })

        Divider()
          .vertical(false)
          .color($r('app.color.five_white'))
          .width(CommonConstants.FULL_PERCENT)
          .margin({
            bottom: $r('app.float.margin_small')
          })
      }
      .padding({
        top: $r('app.float.margin_small')
      })
    }
    .padding({
      right: new BreakpointType($r('app.float.padding_small'), $r('app.float.common_padding'),
        $r('app.float.padding_large')).getValue(this.currentBreakpoint),
      left: new BreakpointType($r('app.float.padding_small'), $r('app.float.common_padding'),
        $r('app.float.zero')).getValue(this.currentBreakpoint)
    })
    .width(CommonConstants.FULL_PERCENT)
  }
}