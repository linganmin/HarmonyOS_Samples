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

import { listArr } from '../viewmodel/InitData';
import { CommonConstants } from '../common/constants/CommonConstants';

@Entry
@Component
struct NestedCeiling {
  @State currentIndex: number = 0;
  private scrollerForScroll: Scroller = new Scroller();
  private scrollerForList: Scroller = new Scroller();

  @Builder
  tabBuilder(index: number, name: ResourceStr) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? $r('app.color.active_font_color') : $r('app.color.font_color'))
        .fontSize($r('app.float.middle_font_size'))
        .fontWeight(this.currentIndex === index ? CommonConstants.FONT_WEIGHT_FIVE : CommonConstants.FONT_WEIGHT_FOUR)
        .lineHeight($r('app.float.title_line_height'))
        .margin({
          top: $r('app.float.title_margin_top'),
          bottom: $r('app.float.title_margin_bottom')
        })
      Divider()
        .strokeWidth(CommonConstants.STROKE_WIDTH)
        .width($r('app.float.divider_width'))
        .color($r('app.color.active_font_color'))
        .opacity(this.currentIndex === index ? CommonConstants.FULL_OPACITY : CommonConstants.ZERO_OPACITY)
    }
  }

  @Builder
  listBuilder(listName: ResourceStr, tabName: ResourceStr, index: number) {
    TabContent() {
      List({ space: CommonConstants.LIST_SPACE, scroller: this.scrollerForList }) {
        ForEach(listArr, (item: string) => {
          ListItem() {
            Row() {
              Text(listName)
                .fontSize($r('app.float.middle_font_size'))
                .fontWeight(CommonConstants.FONT_WEIGHT_FIVE)
              Text(item)
                .fontSize($r('app.float.middle_font_size'))
                .fontWeight(CommonConstants.FONT_WEIGHT_FIVE)
            }
            .padding({ left: $r('app.float.list_item_padding') })
            .backgroundColor(Color.White)
            .width(CommonConstants.FULL_WIDTH)
            .height(CommonConstants.FULL_HEIGHT)
            .borderRadius($r('app.float.list_item_radius'))

          }
          .width(CommonConstants.FULL_WIDTH)
          .height($r('app.float.list_item_height'))
        }, (item: string) => JSON.stringify(item))
      }
      .padding({
        left: $r('app.float.list_padding'),
        right: $r('app.float.list_padding')
      })
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
    }
    .tabBar(this.tabBuilder(index, tabName))
  }

  build() {
    Column() {
      Text($r('app.string.title'))
        .fontWeight(FontWeight.Bold)
        .fontSize($r('app.float.big_font_size'))
        .height($r('app.float.list_item_height'))
        .textAlign(TextAlign.Start)
        .width(CommonConstants.FULL_WIDTH)
        .padding({
          left: $r('app.float.discover_left_padding'),
          bottom: $r('app.float.discover_bottom_padding'),
          top: $r('app.float.discover_top_padding')
        })

      Stack({ alignContent: Alignment.Top }) {
        Scroll(this.scrollerForScroll) {
          Column() {
            Image($r("app.media.banner"))
              .width(CommonConstants.FULL_WIDTH)
              .height($r('app.float.image_height'))
              .borderRadius($r('app.float.list_item_radius'))
              .padding({
                left: $r('app.float.list_item_padding'),
                right: $r('app.float.list_item_padding')
              })
            Tabs() {
              this.listBuilder($r('app.string.goods'), $r('app.string.Promotional'), 0)
              this.listBuilder($r('app.string.Itinerary'), $r('app.string.Travel'), 1)
            }
            .barWidth($r('app.float.bar_width'))
            .onAnimationStart((_index: number, targetIndex: number, _event: TabsAnimationEvent) => {
              this.currentIndex = targetIndex;
            })
          }
        }
        .scrollBar(BarState.Off)
        .width(CommonConstants.FULL_WIDTH)
        .height(CommonConstants.FULL_HEIGHT)
      }
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.STACK_HEIGHT)
    }
    .height(CommonConstants.FULL_HEIGHT)
    .backgroundColor($r('app.color.start_window_background'))
  }
}