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

import { Constants } from '../common/Constants';
import { FriendMoment } from '../model/BasicDataSource';

@Reusable
@Component
export struct OneMoment {
  @ObjectLink moment: FriendMoment;
  private readonly SHARE_INDEX_0: number = 0;
  private readonly SHARE_INDEX_1: number = 1;
  private readonly SHARE_INDEX_2: number = 2;

  build() {
    Column() {
      Row() {
        Image($r(this.moment.avatar))
          .autoResize(false)
          .borderRadius(15)
          .width(30)
          .height(30)
        Column() {
          Text(this.moment.userName)
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .lineHeight(19)
            .fontWeight(FontWeight.Medium)
          Text($r('app.string.two_days_ago'))
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
            .lineHeight(14)
            .opacity(0.6)
        }
        .margin({ left: 8 })
        .alignItems(HorizontalAlign.Start)
      }
      .width(Constants.LAYOUT_MAX)
      .constraintSize({ minHeight: 38 })
      .padding({
        left: 12,
        top: 11,
        bottom: 11
      })

      Stack() {
        if (this.moment.image) {
          Column() {
            Image($r(this.moment.image))
              .id('singleImage')
              .width(Constants.LAYOUT_MAX)
              .height(278)
          }
          .alignItems(HorizontalAlign.Start)
          .width(Constants.LAYOUT_MAX)
          .padding({
            left: 12,
            right: 12
          })
        }
      }

      Row() {
        Text(this.moment.text)
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor(Color.Black)
          .lineHeight(19)
      }
      .width(Constants.LAYOUT_MAX)
      .padding({
        left: 11,
        top: 8
      })

      // Using @Builder, you can reduce the time-consuming creation and rendering of custom components.
      Row() {
        Image($r('app.media.share'))
          .width(24)
          .height(24)
          .autoResize(false)

        Row() {
          interactiveButton({
            imageStr: $r('app.media.heart'),
            text: `${this.moment.share.heart}`
          }, this.SHARE_INDEX_0)
          interactiveButton({
            imageStr: $r('app.media.star'),
            text: `${this.moment.share.star}`
          }, this.SHARE_INDEX_1)
          interactiveButton({
            imageStr: $r('app.media.ellipsis_message'),
            text: `${this.moment.share.message}`
          }, this.SHARE_INDEX_2)
        }
        .justifyContent(FlexAlign.End)
        .layoutWeight(1)
      }
      .width(Constants.LAYOUT_MAX)
      .padding({
        left: 12,
        top: 8,
        bottom: 12,
        right: 29.75
      })
    }
    .backgroundColor(Color.White)
    .width(Constants.LAYOUT_MAX)
    .borderRadius(16)
  }
}

@Builder
export function interactiveButton($$: Temp, index: number) {
  Row() {
    // Use $$ to transfer data by reference so that @Builder can sense data changes and refresh the UI.
    Image($$.imageStr)
      .width(24)
      .height(24)
      .objectFit(ImageFit.Contain)
      .autoResize(false)
    Text($$.text)
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor(Color.Black)
      .lineHeight(16)
      .opacity(0.9)
      .margin({ left: 2 })
  }
  .alignItems(VerticalAlign.Center)
  .margin({ left: index > 0 ? 12 : 0 })
}

class Temp {
  imageStr: ResourceStr = '';
  text: ResourceStr | string = '';
}