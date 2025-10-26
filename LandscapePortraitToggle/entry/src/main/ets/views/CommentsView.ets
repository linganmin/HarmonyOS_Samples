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

import { Comment, COMMENT_LIST_DADA } from '../viewmodel/CommentModel';

@Component
export struct CommentsView {
  build() {
    Column() {
      Text($r('app.string.all_comment'))
        .fontSize(16)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(500)
        .height(48)
        .width('100%')

      List({ space: 12 }) {
        ForEach(COMMENT_LIST_DADA, (item: Comment) => {
          CommentItem({ itemData: item })
        }, (item: Comment) => JSON.stringify(item))
      }
      .width('100%')

      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
    }
    .padding({
      left: 16,
      right: 16
    })
    .margin({ top: 12 })
  }
}

@Component
struct CommentItem {
  private itemData: Comment | undefined;

  build() {
    Row() {
      Image(this.itemData?.avatar)
        .height(36)
        .width(36)
        .margin({
          top: 6
        })
      Column() {
        Text(this.itemData?.username)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .height(48)
        Text(this.itemData?.content)
          .fontSize(14)
          .fontColor($r('sys.color.mask_secondary'))
          .lineHeight(24)
          .fontWeight(500)
          .textAlign(TextAlign.JUSTIFY)
          .margin({
            bottom: 30
          })
        Row() {
          Text(this.itemData?.sendTime)
            .fontSize(12)
            .fontColor($r('sys.color.mask_secondary'))
          Blank()
            .layoutWeight(1)
          Image($r('app.media.icon_message'))
            .height(18)
            .width(18)
          Image($r("app.media.icon_good"))
            .height(18)
            .width(18)
            .margin({
              left: 26,
              right: 26
            })
          Image($r('app.media.icon_share'))
            .height(18)
            .width(18)
        }

        Divider()
          .width('100%')
          .margin({ top: 12 })
      }
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 16 })
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}