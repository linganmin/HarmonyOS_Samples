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

import Constants from '../commom/Constants';
import CommentModel from '../model/CommentModel';
import CommentViewModel from '../viewmodel/CommentViewModel';

@ComponentV2
export default struct VideoCommentView {
  private readonly LIST_CACHE_COUNT: number = 2;
  private comments: CommentViewModel = new CommentViewModel();

  aboutToAppear(): void {
    this.comments.getCommentRawFile();
  }

  build() {
    Column() {
      Text($r('app.string.all_comment'))
        .fontSize(16)
        .fontWeight(500)
        .lineHeight(21)
        .textAlign(TextAlign.Start)

      Column() {
        List() {
          LazyForEach(this.comments, (item: CommentModel) => {
            ListItem() {
              CommentListItem({
                item: item
              })
            }
          }, (item: CommentModel) => item.id)
        }
        .cachedCount(this.LIST_CACHE_COUNT)
        .width(Constants.FULL_PERCENT)
        .height(Constants.FULL_PERCENT)
        .scrollBar(BarState.Off)
        .divider({
          strokeWidth: 1,
          color: '#0D000000'
        })
      }
      .width(Constants.FULL_PERCENT)
      .margin({ top: 14 })
    }
    .width(Constants.FULL_PERCENT)
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16, top: 25 })
  }
}

@ComponentV2
export struct CommentListItem {
  @Param @Require item: CommentModel;

  build() {
    Column() {
      Row() {
        Image($r(this.item.avatar))
          .width(36)
          .height(36)
          .borderRadius(18)
        Text(this.item.userName)
          .fontSize(16)
          .fontWeight(500)
          .lineHeight(21)
          .textAlign(TextAlign.Start)
          .margin({ left: 16 })
      }
      .justifyContent(FlexAlign.Start)
      .width(Constants.FULL_PERCENT)
      .height(56)

      Row() {
        Text(this.item.comment)
          .fontSize(14)
          .fontWeight(500)
          .lineHeight(19)
          .fontColor($r('sys.color.mask_secondary'))
          .textAlign(TextAlign.JUSTIFY)
          .width(288)
      }
      .margin({ left: 52, top: 4 })
      .justifyContent(FlexAlign.Start)
      .width(Constants.FULL_PERCENT)

      Image($r(this.item.image))
        .width(288)
        .height(155)
        .borderRadius(12)
        .margin({ left: 52, top: 16 })

      Row() {
        Text(this.item.date)
          .fontSize(12)
          .fontWeight(400)
          .lineHeight(16)
          .textAlign(TextAlign.Start)
          .fontColor($r('sys.color.mask_secondary'))
          .margin({ right: 142 })

        SymbolGlyph($r('sys.symbol.ellipsis_message'))
          .fontSize(16)
          .margin({ right: 24 })
        SymbolGlyph($r('sys.symbol.hand_thumbsup'))
          .fontSize(16)
          .margin({ right: 24 })
        SymbolGlyph($r('sys.symbol.share'))
          .fontSize(16)
      }
      .margin({ top: 16 , bottom: 16})
      .justifyContent(FlexAlign.End)
      .width(Constants.FULL_PERCENT)
    }
    .alignItems(HorizontalAlign.Start)
    .width(Constants.FULL_PERCENT)
  }
}