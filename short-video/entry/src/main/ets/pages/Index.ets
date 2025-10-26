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

import { CommonConstants as Const } from '../common/CommonConstants';
import { TopTabContent } from '../model/DataModel';
import { VideoSwiper } from '../view/VideoSwiper';

@Entry
@Component
export struct ShortVideo {
  @State currentIndex: number = 1;
  scroller: Scroller = new Scroller();
  private topTabListData: TopTabContent = new TopTabContent();

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.currentIndex === 1) {
        VideoSwiper()
          .height(Const.FULL_SIZE)
      }
      Row() {
        Image($r("app.media.search_icon"))
          .width($r('app.integer.search_icon_width'))
          .height($r('app.integer.search_icon_height'))
        List({ scroller: this.scroller }) {
          LazyForEach(this.topTabListData, (item: string, index) => {
            ListItem() {
              Column() {
                Text(item)
                  .fontColor(this.currentIndex === index ? Color.White : $r('app.color.font_color'))
                  .fontSize($r('app.integer.tab_font_size'))
                Divider()
                  .width(this.currentIndex === index ? $r('app.integer.tab_divider_width') : $r('app.integer.tab_divider_width_0'))
                  .strokeWidth(2)
                  .color(this.currentIndex === index ? Color.White : Color.Gray)
                  .margin({
                    top: $r('app.integer.divider_margin_top')
                  })
              }
              .padding({ top: $r('app.integer.tab_padding_top') })
              .width(Const.LIST_ITEM_WIDTH)
            }
          }, (item: string, index) => JSON.stringify(item))
        }
        .listDirection(Axis.Horizontal)
        .height(Const.FULL_SIZE)
        .width(Const.LIST_WIDTH)

        Image($r("app.media.add1"))
          .width($r('app.integer.add_icon_width'))
          .height($r('app.integer.add_icon_width'))
      }
      .height($r('app.integer.tab_list_height'))
      .width(Const.FULL_SIZE)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width(Const.FULL_SIZE)
    .height(Const.FULL_SIZE)
  }
}