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
import { LivingCommentsViewModel } from '../viewmodel/LivingCommentsViewModel';

@Component
export struct LivingComments {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('windowTop') windowTop: number = 0;
  @StorageLink('windowBottom') windowBottom: number = 0;

  build() {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Image($r('app.media.ic_public_contacts_group_filled'))
              .width($r('app.float.group_width'))
              .aspectRatio(1)
              .margin({
                right: $r('app.float.dish_margin_right')
              })
            Text($r('app.string.viewers_online'))
              .fontSize($r('app.float.tabs_font'))
              .fontColor(Color.White)
          }
          .width(CommonConstants.FULL_PERCENT)

          Column({ space: CommonConstants.COLUMN_SPACE }) {
            this.headerListBuild('1', $r('app.media.tx1_img'), $r('app.string.candy_pocket'), '6',
              $r('app.color.candy_pocket'))
            this.headerListBuild('2', $r('app.media.tx2_img'), $r('app.string.fallout'), '6',
              $r('app.color.city_park_font'))
            this.headerListBuild('3', $r('app.media.tx3_img'), $r('app.string.quiet_years'), '4',
              $r('app.color.quiet_years'))
          }
          .padding({
            top: $r('app.float.thirty_padding'),
            bottom: $r('app.float.thirty_padding')
          })
          .width(CommonConstants.FULL_PERCENT)

          Divider()
            .color($r('app.color.ten_white'))
          Column({ space: CommonConstants.COLUMN_SPACE_LIVING }) {
            ForEach(LivingCommentsViewModel.getLivingCommentsList(), (item: LivingCommentsViewModel) => {
              this.commentsListBuilder(item)
            })
          }
          .width(CommonConstants.FULL_PERCENT)
          .alignItems(HorizontalAlign.Start)
          .padding({
            top: $r('app.float.rating_margin_right')
          })
        }
      }
      .align(Alignment.Top)
      .layoutWeight(1)
      .padding({
        top: $r('app.float.living_padding_top'),
        left: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD ?
        $r('app.float.twelves_padding') : $r('app.float.common_padding'),
        right: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD ?
        $r('app.float.twelves_padding') : $r('app.float.common_padding'),
        bottom: $r('app.float.avatar_margin_bottom')
      })

      Row() {
        Row() {
          Image($r('app.media.v2_ic_public_edit'))
            .width($r('app.float.search_width'))
            .height($r('app.float.search_width'))
            .fillColor('#99ffffff')
          Text($r('app.string.write_review'))
            .fontSize($r('app.float.delivery_font'))
            .fontColor('#99ffffff')
            .fontWeight(CommonConstants.FONT_WEIGHT_400)
            .margin({
              left: $r('app.float.avatar_padding_left')
            })
        }
        .borderRadius($r('app.float.food_border_radius'))
        .height($r('app.float.food_height'))
        .width(CommonConstants.FULL_PERCENT)
        .backgroundColor($r('app.color.ten_white'))
        .padding({
          top: $r('app.float.avatar_margin_bottom'),
          bottom: $r('app.float.avatar_margin_bottom'),
          left: $r('app.float.twelves_padding'),
          right: $r('app.float.twelves_padding')
        })
      }
      .padding({
        top: $r('app.float.eight_padding'),
        left: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD ?
        $r('app.float.twelves_padding') : $r('app.float.common_padding'),
        right: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD ?
        $r('app.float.twelves_padding') : $r('app.float.common_padding'),
        bottom: 8 + this.windowBottom
      })
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('app.color.swiper_choose_background'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.forty_black'))
    .padding({
      top: this.windowTop
    })
  }

  @Builder
  commentsListBuilder(item: LivingCommentsViewModel) {
    Row() {
      if (item.type === 1) {
        Text() {
          Span(item.name)
            .fontColor($r('app.color.forty_white'))
            .fontSize($r('app.float.delivery_font'))
          Span(item.content)
            .fontColor($r('app.color.ninety_white'))
            .fontSize($r('app.float.delivery_font'))
        }
      } else if (item.type === 2) {
        Text() {
          Span(item.name)
            .fontColor($r('app.color.ninety_white'))
            .fontSize($r('app.float.delivery_font'))
            .textBackgroundStyle({
              color: $r('app.color.twenty_black'),
              radius: $r('app.float.text_radius')
            })
            .lineHeight($r('app.float.span_line_height'))
          Span(item.content)
            .fontColor($r('app.color.ninety_white'))
            .fontSize($r('app.float.delivery_font'))
        }
        .lineHeight($r('app.float.span_line_height'))
      } else {
        Text() {
          Span(item.content)
            .fontColor($r('app.color.forty_white'))
            .fontSize($r('app.float.delivery_font'))
        }
      }
    }
    .padding({
      top: $r('app.float.flag_margin_right'),
      left: $r('app.float.tabs_margin_right'),
      right: $r('app.float.swiper_margin_top'),
      bottom: $r('app.float.flag_margin_right')
    })
    .backgroundColor($r('app.color.swiper_choose_background'))
    .borderRadius($r('app.float.text_radius'))
  }

  @Builder
  headerListBuild(index: ResourceStr, avatars: Resource, nicknames: ResourceStr, level: ResourceStr,
    color: ResourceColor) {
    Row() {
      Text(index)
        .fontColor(color)
        .fontSize($r('app.float.reviews_font'))
        .margin({
          right: $r('app.float.rating_margin_right')
        })
        .fontWeight(CommonConstants.FONT_WEIGHT_600);
      Image(avatars)
        .width($r('app.float.padding_header'))
        .aspectRatio(1)
        .margin({
          right: $r('app.float.margin_twelves')
        })
      Text(nicknames)
        .fontColor($r('app.color.ninety_white'))
        .fontSize($r('app.float.reviews_font'))
        .margin({
          right: $r('app.float.margin_twelves')
        })
      Row() {
        Stack() {
          Image($r('app.media.ic_public_love'))
            .width($r('app.float.love_width'))
            .height($r('app.float.love_width'))
          Text(level)
            .fontSize($r('app.float.level_font'))
            .fontColor(Color.White)
            .fontWeight(CommonConstants.FONT_WEIGHT_500)
        }

        Text($r('app.string.hardcore_powder'))
          .fontColor(Color.White)
          .fontSize($r('app.float.filtering_font'))
          .margin({
            left: $r('app.float.tabs_padding_tb')
          })
      }
      .padding({
        left: $r('app.float.pay_price_margin_right'),
        right: $r('app.float.pay_price_margin_right'),
        top: $r('app.float.filtering_padding_tb'),
        bottom: $r('app.float.filtering_padding_tb')
      })
      .backgroundColor(color)
      .borderRadius($r('app.float.nine_padding'))
      .opacity(0.4)
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}