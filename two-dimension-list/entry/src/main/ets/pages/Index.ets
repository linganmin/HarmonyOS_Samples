/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { CommonConstants as Common } from '../common/CommonConstants';
import { GoodsNameListDataSource, MessageListDataSource } from '../model/ListDataSource';
import { MessageItem } from '../model/MessageList';
import { TitleItem, TitleList } from '../model/TitleList';

@Entry
@Component
struct Index {
  goodsNameData: GoodsNameListDataSource = new GoodsNameListDataSource();
  messageData: MessageListDataSource = new MessageListDataSource();
  titles: Array<TitleItem> = TitleList;
  goodsScroller = new Scroller();
  verticalScroller = new Scroller();

  @Builder
  messageBuilder(index: number, content: string) {
    Column() {
      Text(content)
        .fontSize($r('app.float.content_font_size'))
        .margin({
          top: $r('app.float.text_margin_top'),
          left: $r('app.float.text_margin_left')
        })
        .width($r('app.float.text_width'))
        .height($r('app.float.text_height'))
    }
    .height($r('app.float.text_column_height'))
    .width($r('app.float.text_column_width'))
    .backgroundColor(index % 2 === 0 ? $r('app.color.list_item_background') : $r('app.color.start_window_background'))
  }

  @Builder
  titleBuilder() {
    Row({ space: Common.SPACE }) {
      ForEach(this.titles, (item: TitleItem) => {
        Text(item.content)
          .fontSize($r('app.float.title_list_size'))
          .fontColor($r('app.color.name_color'))
          .width(Common.CONTENT_WIDTH)
          .textAlign(TextAlign.Center)
      }, (item: TitleItem) => JSON.stringify(item))
    }
    .width(Common.CONTENT_ROW_WIDTH)
    .height($r('app.float.name_height'))
    .backgroundColor($r('app.color.start_window_background'))
  }

  @Builder
  listItemBuilder(messageItem: MessageItem) {
    Row({ space: Common.SPACE }) {
      Row({ space: Common.SPACE }) {
        Text(messageItem.price)
          .fontColor($r('app.color.price_color'))
          .buildText()

        Text(messageItem.type)
          .buildText()

        Text(messageItem.param)
          .buildText()
      }

      Image(messageItem.icon)
        .height($r('app.float.picture_size'))
        .width($r('app.float.picture_size'))
    }
    .width(Common.CONTENT_ROW_WIDTH)
    .height($r('app.float.text_column_height'))
    .backgroundColor(messageItem.id % 2 === 1 ?
    $r('app.color.list_item_background') : $r('app.color.start_window_background'))
  }

  @Builder
  listBuilder() {
    List({ scroller: this.verticalScroller }) {
      ListItemGroup({ header: this.titleBuilder() }) {
        LazyForEach(this.messageData, (item: MessageItem) => {
          ListItem() {
            this.listItemBuilder(item)
          }
        })
      }
    }
    .sticky(StickyStyle.Header)
    .edgeEffect(EdgeEffect.None)
    .onScrollFrameBegin((offset: number) => {
      this.goodsScroller.scrollBy(0, offset);
      return { offsetRemain: 0 };
    })
  }

  build() {
    Column() {
      Text($r('app.string.title'))
        .fontSize($r('app.float.title_font_size'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
        .width($r('app.float.title_width'))
        .height($r('app.float.title_height'))
        .margin({
          top: $r('app.float.title_margin_top')
        })

      Row() {
        Column() {
          Text($r('app.string.name_title'))
            .fontSize($r('app.float.title_list_size'))
            .fontColor($r('app.color.name_color'))
            .height($r('app.float.name_height'))
            .width($r('app.float.name_width'))
            .margin({ left: $r('app.float.text_margin_left') })

          Scroll(this.goodsScroller) {
            List() {
              LazyForEach(this.goodsNameData, (item: string) => {
                ListItem() {
                  this.messageBuilder(this.goodsNameData.getIndex(item), item)
                }
              })
            }
          }
          .scrollBar(BarState.Off)
          .onDidScroll(() => {
            this.verticalScroller.scrollTo({ xOffset: 0, yOffset: this.goodsScroller.currentOffset().yOffset });
          })
          .layoutWeight(Common.LAYOUT_WEIGHT)
        }
        .width($r('app.float.column_width'))

        Column() {
          Scroll() {
            this.listBuilder()
          }
          .scrollBar(BarState.Off)
          .width(Common.SCROLL_WIDTH)
          .scrollable(ScrollDirection.Horizontal)
        }
        .width(Common.SCROLL_WIDTH)
      }
      .height($r('app.float.row_height'))
      .layoutWeight(Common.LAYOUT_WEIGHT)
    }
  }
}

@Extend(Text)
function buildText() {
  .fontSize($r('app.float.content_font_size'))
  .textAlign(TextAlign.Center)
  .width(Common.CONTENT_WIDTH)
}