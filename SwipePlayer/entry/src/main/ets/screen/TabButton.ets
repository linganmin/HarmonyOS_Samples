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
export struct TabButton {
  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
      Text(TabConstant.getTab(this.getUIContext())[0])
        .fontColor(CommonConstant.CUSTOM_FONT_COLOR)
        .textAlign(TextAlign.Center)
        .fontWeight(CommonConstant.CUSTOM_FONT_WEIGHT);
      Text(TabConstant.getTab(this.getUIContext())[1])
        .fontColor(CommonConstant.CUSTOM_FONT_COLOR)
        .textAlign(TextAlign.Center)
        .opacity(CommonConstant.TEXT_OPACITY);
      Column() {
        Image(TabConstant.TAB_ICON)
          .width(TabConstant.TAB_ICON_WIDTH);
      };

      Text(TabConstant.getTab(this.getUIContext())[3])
        .fontColor(CommonConstant.CUSTOM_FONT_COLOR)
        .textAlign(TextAlign.Center)
        .opacity(CommonConstant.TEXT_OPACITY);
      Text(TabConstant.getTab(this.getUIContext())[4])
        .fontColor(CommonConstant.CUSTOM_FONT_COLOR)
        .textAlign(TextAlign.Center)
        .opacity(CommonConstant.TEXT_OPACITY);
    };
  }
}