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

import { FriendMoment } from '../model/BasicDataSource';
import { ImageText } from './ImageText';
import { Constants } from '../common/Constants';

@Reusable
@Component
export struct OneMoment {
  @Prop moment: FriendMoment;

  build() {
    Column() {
      Row() {
        Image($r(this.moment.avatar))
          .autoResize(false)
          .width($r('app.integer.list_history_user_image_width'))
          .height($r('app.integer.list_history_user_image_height'))
          .borderRadius($r('app.integer.list_history_user_image_border_radius'))
        Column() {
          Text(this.moment.userName)
            .fontSize($r('app.integer.list_history_useName_fontSize'))
            .fontColor($r('app.color.title_font_color'))
            .lineHeight($r('app.integer.list_history_useName_line_height'))
            .fontWeight(FontWeight.Medium)
          Text(this.moment.text)
            .fontSize($r('app.integer.list_history_userText_fontSize'))
            .fontColor($r('app.color.title_font_color'))
            .lineHeight($r('app.integer.list_history_userText_line_height'))
            .opacity($r('app.float.opacity_zero_point_six'))
            .margin({ top: $r('app.integer.list_history_userText_margin_top') })
        }
        .margin({ left: $r('app.integer.list_history_user_col_margin_left') })
        .layoutWeight(Constants.LAYOUT_WEIGHT)
        .alignItems(HorizontalAlign.Start)
      }
      .width(Constants.LAYOUT_MAX)
      .constraintSize({ minHeight: $r('app.integer.list_history_oneMoment_height') })
      .padding({
        left: $r('app.integer.list_history_row_padding_left'),
        right: $r('app.integer.list_history_row_padding_right'),
        top: $r('app.integer.list_history_row_padding_top'),
        bottom: $r('app.integer.list_history_row_padding_bottom')
      })

      Stack() {
        if (this.moment.image) {
          Column() {
            Image($r(this.moment.image))
              .id('singleImage')
              .width($r('app.integer.list_history_single_image_width'))
              .height($r('app.integer.list_history_single_image_height'))
              .borderRadius($r('app.integer.list_history_single_image_radius'))
          }
          .alignItems(HorizontalAlign.Start)
          .width(Constants.LAYOUT_MAX)
          .padding({
            left: $r('app.integer.list_history_image_group_padding_left'),
            right: $r('app.integer.list_history_image_group_padding_right')
          })
        }
      }

      Row() {
        ImageText({
          imageStr: $r('app.media.ic_share'),
          text: $r('app.string.friendMomentsPage_share')
        })
        ImageText({
          imageStr: $r('app.media.ic_thumbSup'),
          text: $r('app.string.friends_circle_likes')
        }).margin({ left: $r('app.integer.list_history_thumb_margin_left') })
        ImageText({
          imageStr: $r('app.media.ic_message'),
          text: $r('app.string.friendMomentsPage_message')
        }).margin({ left: $r('app.integer.list_history_message_margin_left') })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width(Constants.LAYOUT_MAX)
      .margin({
        top: $r('app.integer.list_history_handler_margin_top'),
        bottom: $r('app.integer.list_history_handler_margin_bottom')
      })
      .padding({
        left: $r('app.integer.list_history_handler_padding_left'),
        right: $r('app.integer.list_history_handler_padding_right')
      })
    }
    .width(Constants.LAYOUT_MAX)
  }
}