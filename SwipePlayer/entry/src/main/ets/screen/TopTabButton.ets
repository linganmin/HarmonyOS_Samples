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
import { TabConstant } from '../constant/TabConstants';

@Component
export struct TopTabButton {
  build() {
    Flex({ justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center }) {
      Row()
        .width(CommonConstant.TWENTY_PERCENT_WIDTH)
        .height(CommonConstant.FULL_PERCENT_HEIGHT);
      Row() {
        Text(TabConstant.getTopTab(this.getUIContext())[0])
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .fontSize(TabConstant.TOP_TAB_FONT_SIZE[0])
          .opacity(CommonConstant.TEXT_OPACITY)
          .margin({ right: TabConstant.TAB_MARGIN_OR_PADDING[0] });
        Text(TabConstant.getTopTab(this.getUIContext())[1])
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .fontSize(TabConstant.TOP_TAB_FONT_SIZE[1]);
      }
      .width(CommonConstant.SIXTY_PERCENT_WIDTH)
      .height(CommonConstant.FULL_PERCENT_HEIGHT)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center);

      Row() {
        Image(CommonConstant.SEARCH_ICON)
          .width(CommonConstant.SEARCH_ICON_WIDTH);
      }
      .padding({ right: TabConstant.TAB_MARGIN_OR_PADDING[1] })
      .width(CommonConstant.TWENTY_PERCENT_WIDTH)
      .height(CommonConstant.FULL_PERCENT_HEIGHT)
      .justifyContent(FlexAlign.End);
    }
    .height(CommonConstant.TEN_PERCENT_HEIGHT);
  }
}