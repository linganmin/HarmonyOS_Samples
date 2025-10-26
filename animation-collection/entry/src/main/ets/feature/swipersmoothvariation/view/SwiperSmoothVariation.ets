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

import { CommonConstants as Const, GridItemInfo } from '../common/CommonConstants';

@Component
struct ViewItem {
  item: GridItemInfo = {
    name: $r('app.string.name_page_one'),
    image: $r('app.media.taxi'),
    prompt: $r('app.string.first_prompt')
  };

  build() {
    Column() {
      Stack() {
        Image(this.item.image)
          .height($r('app.float.app_side_length'))
          .width($r('app.float.app_side_length'))
        Text(this.item.prompt)
          .fontColor($r('app.color.color_white'))
          .fontSize($r('app.float.badge_font_size'))
          .backgroundColor($r('app.color.badge_color'))
          .borderRadius({
            topLeft: $r('app.float.text_border_radius'),
            topRight: $r('app.float.text_border_radius'),
            bottomRight: $r('app.float.text_border_radius')
          })
          .textAlign(TextAlign.Center)
          .width($r('app.integer.item_width'))
          .height($r('app.integer.item_height'))
          .margin({
            top: $r('app.integer.margin_top'),
            left: $r('app.integer.margin_left')
          })
          .visibility(this.item.prompt !== undefined ? Visibility.Visible : Visibility.None)
      }
      .width(Const.FULL_PERCENT)

      Text(this.item.name)
        .margin({ top: $r('app.float.item_text_offset') })
        .fontSize($r('app.float.small_font_size'))
    }
  }
}

/**
 * The page height changes smoothly with the swiper height.
 * Slide the swiper. The page height smoothly changes with the swiper height.
 * Effect: When the heights of different swiper pages change, the heights of the pages below also change smoothly.
 */
@Component
struct SwiperSmoothVariation {
  @State swiperDistance: number = 0;
  private gridScroller: Scroller = new Scroller();

  @Builder
  GridBuilderFunction(page: GridItemInfo[], height: number, template: string) {
    Column() {
      Grid(this.gridScroller) {
        ForEach(page, (item: GridItemInfo) => {
          GridItem() {
            ViewItem({ item: item })
          }
          .width(Const.FULL_PERCENT)
          .height(height)
          .width($r('app.float.scroll_width'))
        }, (item: GridItemInfo, index: number) => index + JSON.stringify(item))
      }
      .height(height)
      .width($r('app.string.width_full'))
      .borderRadius($r('app.integer.swiper_border_radius'))
      .edgeEffect(EdgeEffect.None)
      .columnsTemplate(Const.COLUMN_TEMPLATE)
      .rowsTemplate(template)

      if (page === Const.DATA_PAGE_ONE) {
        Column()
          .margin({ top: this.swiperDistance })
          .height($r('app.float.blank_height'))
          .width($r('app.float.scroll_width'))
      } else {
        Column()
          .margin(height == Const.GRID_SINGLE_HEIGHT ?
            { top: Const.SWIPER_OFFSET + Const.GRID_SINGLE_HEIGHT + this.swiperDistance } :
            { top: Const.SWIPER_OFFSET + this.swiperDistance })
          .height($r('app.float.blank_height'))
          .width($r('app.float.scroll_width'))
      }
    }
    .margin(page === Const.DATA_PAGE_ONE ? { top: $r('app.float.swiper_offset') } : 0)
  }

  /**
   * Create a stack component to display the swiper and the lower page (lower column).
   * Create a swiper component to display the sliding effect.
   * When the swiper flicks, the height of the lower page (column) also changes.
   */
  build() {
    Stack() {
      Swiper() {
        Column() {
          Stack() {
            Text($r('app.string.function_tool_bar'))
              .textAlign(TextAlign.Center)
              .margin({ top: $r('app.integer.swiper_margin_small'), left: $r('app.integer.default_padding') })
            this.GridBuilderFunction(Const.DATA_PAGE_ONE, Const.GRID_DOUBLE_HEIGHT, Const.GRID_TEMPLATE)
          }
          .alignContent(Alignment.TopStart)
        }

        this.GridBuilderFunction(Const.DATA_PAGE_TWO, Const.GRID_DOUBLE_HEIGHT, Const.GRID_TEMPLATE)
        this.GridBuilderFunction(Const.DATA_PAGE_THREE, Const.GRID_DOUBLE_HEIGHT, Const.GRID_TEMPLATE)
        this.GridBuilderFunction(Const.DATA_PAGE_FOUR, Const.GRID_SINGLE_HEIGHT, Const.GRID_SINGLE_TEMPLATE)
      }
      .width($r('app.string.width_full'))
      .backgroundColor($r('app.color.color_white'))
      .borderRadius($r('app.integer.swiper_border_radius'))
      .margin({ top: $r('app.float.margin_fifteen') })
      .effectMode(EdgeEffect.None)
      .loop(false)
      .onGestureSwipe((index: number, extraInfo: SwiperAnimationEvent) => {
        this.getUIContext().animateTo({
          duration: Const.DURATION_SWIPER,
          curve: Curve.EaseOut,
          playMode: PlayMode.Normal
        }, () => {
          // The corresponding change of the up and down position is calculated by the distance of the left and right sliding.
          if (index === 0 && extraInfo.currentOffset < 0) {
            this.swiperDistance = extraInfo.currentOffset / Const.SCROLL_WIDTH * Const.SMALL_FONT_SIZE;
          }
          if (index === 1 && extraInfo.currentOffset > 0) {
            this.swiperDistance =
              extraInfo.currentOffset / Const.SCROLL_WIDTH * Const.SMALL_FONT_SIZE - Const.SMALL_FONT_SIZE;
          }
          if (index === 2 && extraInfo.currentOffset < 0) {
            this.swiperDistance =
              extraInfo.currentOffset / Const.SCROLL_WIDTH * Const.GRID_SINGLE_HEIGHT - Const.SMALL_FONT_SIZE;
          }
          if (index === 3 && extraInfo.currentOffset > 0) {
            this.swiperDistance =
              extraInfo.currentOffset / Const.SCROLL_WIDTH * Const.GRID_SINGLE_HEIGHT - Const.SMALL_FONT_SIZE -
              Const.GRID_SINGLE_HEIGHT;
          }
        })
      })
      .onAnimationStart((_: number, targetIndex: number) => {
        // Smoothly changing animation effects.
        this.getUIContext().animateTo({
          duration: Const.DURATION_DOWN_PAGE,
          curve: Curve.EaseOut,
          playMode: PlayMode.Normal
        }, () => {
          if (targetIndex === 0) {
            this.swiperDistance = 0;
          } else if (targetIndex === 1 || targetIndex === 2) {
            this.swiperDistance = -Const.SMALL_FONT_SIZE;
          } else {
            this.swiperDistance = -Const.SMALL_FONT_SIZE - Const.GRID_SINGLE_HEIGHT;
          }
        })
      })
      .indicator(Indicator.dot()
        .color($r('app.color.swiper_unselected_color'))
        .selectedColor($r('app.color.swiper_selected_color'))
      )

      Image($r('app.media.ic_image'))
        .height($r('app.integer.height_1'))
        .borderRadius($r('app.integer.swiper_border_radius'))
        .width($r('app.string.width_full'))
        .offset({ y: this.swiperDistance })
        .margin({ top: $r('app.float.colum_offset_one') })
    }
    .backgroundColor($r('app.color.stack_color'))
    .padding($r('app.integer.default_padding'))
    .alignContent(Alignment.TopStart)
    .height($r('app.string.width_full'))
  }
}

@Builder
export function getPageSwiperSmooth(name: string): void {
  if (name === 'SwiperSmoothVariation') {
    NavDestination() {
      SwiperSmoothVariation();
    }
  }
}

export const wrappedBuilderSwiperSmooth: WrappedBuilder<[string, number]> = wrapBuilder(getPageSwiperSmooth);