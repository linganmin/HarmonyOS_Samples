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
import { ReceiveMoneyServiceCardItem } from '../viewmodel/ReceiveMoneyCardViewModel';

@Component
export struct CashFlowCenterCard {
  @Prop cashFlowCenterItem: ReceiveMoneyServiceCardItem;

  build() {
    Row() {
      Image(this.cashFlowCenterItem.getImage())
        .width($r('app.float.receive_money_service_card_image_width'))
        .height($r('app.float.receive_money_service_card_image_height'))
        .margin({ right: Constants.CONTENT_SPACE[6] })
        .objectFit(ImageFit.Contain)

      Row() {
        Text(this.cashFlowCenterItem.getText())
          .fontFamily($r('app.string.medium_font_family'))
          .fontSize($r('app.float.middle_font_size'))
          .fontColor(Color.Black)
          .textAlign(TextAlign.Start)
          .lineHeight($r('app.float.receive_money_service_card_text_line_height'))
          .fontWeight(Constants.FONT_WEIGHT[1])

        Row() {
          if (this.cashFlowCenterItem.getBrief()) {
            Text(this.cashFlowCenterItem.getBrief())
              .opacity(Constants.OPACITY)
              .fontFamily($r('app.string.normal_font_family'))
              .fontSize($r('app.float.smaller_font_size'))
              .fontColor(Color.Black)
              .textAlign(TextAlign.End)
              .lineHeight($r('app.float.brief_line_height'))
              .fontWeight(Constants.FONT_WEIGHT[0])
              .margin({ right: $r('app.float.brief_margin_right') })
          }
          Image($r('app.media.right_arrow'))
            .width($r('app.float.right_arrow_width'))
            .height($r('app.float.right_arrow_height'))
        }
      }
      .layoutWeight(Constants.LAYOUT_WEIGHT)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
    .width(Constants.FULL_WIDTH)
    .height($r('app.float.receive_money_bottom_card_height'))
    .padding({ left: Constants.CONTENT_SPACE[2], right: Constants.CONTENT_SPACE[2] })
  }
}