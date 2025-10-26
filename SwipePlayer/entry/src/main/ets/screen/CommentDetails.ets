/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CommonConstant } from '../constant/CommonConstant';
import { LiveCommentsData } from '../model/CommonModel';

@Component
export struct CommentDetails {
  @Prop liveCommentsData: LiveCommentsData;
  @Prop firstIndex: number;
  @Prop index: number;
  @StorageLink('displayWidth') displayWidth: number = 0;

  build() {
    ListItem() {
      Row() {
        Image(this.liveCommentsData.getAvatar())
          .width(CommonConstant.LIVE_COMMENTS_AVATAR_WIDTH)
          .margin({ left: CommonConstant.LIVE_COMMENTS_LEFT_MARGIN });
        Column() {
          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            Text(this.liveCommentsData.getUserName())
              .fontColor(CommonConstant.LIVE_COMMENTS_FONT_COLOR);
            Row() {
              Text(`${this.liveCommentsData.getLikeNum()}`)
                .fontSize(CommonConstant.LIVE_COMMENTS_LIKE_NUM_FONT_SIZE)
                .fontColor(CommonConstant.LIVE_COMMENTS_FONT_COLOR)
                .margin({ right: CommonConstant.LIVE_COMMENTS_LIKE_NUM_MARGIN_RIGHT[0] });
              Image(this.liveCommentsData.getLikeIcon())
                .width(CommonConstant.LIVE_COMMENTS_LIKE_WIDTH)
                .margin({ bottom: CommonConstant.LIVE_COMMENTS_BOTTOM_MARGIN });
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .margin({ right: CommonConstant.LIVE_COMMENTS_LIKE_NUM_MARGIN_RIGHT[1] });
          };

          Text(this.liveCommentsData.getCommentContent())
            .margin({
              top: CommonConstant.LIVE_COMMENTS_REPLY_MARGIN,
              bottom: CommonConstant.LIVE_COMMENTS_REPLY_MARGIN
            });
          Row() {
            Text(this.liveCommentsData.getDate())
              .fontColor(CommonConstant.LIVE_COMMENTS_FONT_COLOR)
              .fontSize(CommonConstant.LIVE_COMMENTS_REPLY_TEXT_FONTSIZE);
            Text(this.liveCommentsData.getFrom())
              .fontColor(CommonConstant.LIVE_COMMENTS_FONT_COLOR)
              .fontSize(CommonConstant.LIVE_COMMENTS_REPLY_TEXT_FONTSIZE);
            Text(this.firstIndex === this.index ? CommonConstant.LIVE_COMMENTS_REPLY_NUM :
            CommonConstant.LIVE_COMMENTS_REPLY)
              .padding(CommonConstant.LIVE_COMMENTS_LIKE_NUM_MARGIN_RIGHT[0])
              .textAlign(TextAlign.Center)
              .fontSize(CommonConstant.LIVE_COMMENTS_REPLY_TEXT_FONTSIZE)
              .fontColor(this.firstIndex === this.index ? CommonConstant.LIVE_COMMENTS_FONT_COLOR :
              CommonConstant.LIVE_COMMENTS_REPLY_FONT_COLOR)
              .backgroundColor(this.firstIndex === this.index ? CommonConstant.LIVE_COMMENTS_REPLY_BACKGROUND_COLOR :
              Color.Transparent)
              .borderRadius(this.firstIndex === this.index ? CommonConstant.LIVE_COMMENTS_REPLY_BACKGROUND_RADIUS :
                null)
              .fontWeight(this.firstIndex === this.index ? null : CommonConstant.CUSTOM_FONT_WEIGHT);
          };

          if (this.firstIndex === this.index) {
            Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceEvenly }) {
              Text(CommonConstant.LIVE_COMMENTS_REPLY_TEXT[0])
                .margin({
                  top: CommonConstant.LIVE_COMMENTS_REPLY_MARGIN
                });
              Text(CommonConstant.LIVE_COMMENTS_REPLY_TEXT[1])
                .fontColor(CommonConstant.LIVE_COMMENTS_LOOK_REPLY_FONT_COLOR)
                .margin({
                  top: CommonConstant.LIVE_COMMENTS_REPLY_MARGIN,
                  bottom: CommonConstant.LIVE_COMMENTS_REPLY_MARGIN
                });
            }
            .width(this.displayWidth < CommonConstant.PHONE_WIDTH ? CommonConstant.FULL_PERCENT_WIDTH :
            CommonConstant.NINETY_PERCENT_WIDTH)
            .padding({
              left: CommonConstant.LIVE_COMMENTS_PADDING,
              right: CommonConstant.LIVE_COMMENTS_PADDING
            })
            .margin({ top: CommonConstant.LIVE_COMMENTS_REPLY_MARGIN_TOP })
            .backgroundColor(CommonConstant.LIVE_COMMENTS_REPLY_BACKGROUND_COLOR)
            .borderRadius(CommonConstant.LIVE_COMMENTS_REPLY_BACKGROUND_RADIUS);
          }
        }
        .alignItems(HorizontalAlign.Start)
        .width(this.displayWidth < CommonConstant.PHONE_WIDTH ? CommonConstant.EIGHTY_PERCENT_WIDTH :
        CommonConstant.NINETY_PERCENT_WIDTH)
        .margin({
          left: CommonConstant.LIVE_COMMENTS_LEFT_MARGIN,
          bottom: CommonConstant.LIVE_COMMENTS_USERNAME_BOTTOM_MARGIN
        });
      }
      .width(CommonConstant.FULL_PERCENT_WIDTH)
      .alignItems(VerticalAlign.Top);
    }
    .width(CommonConstant.FULL_PERCENT_WIDTH);
  }
}