/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import CommonConstants from '../common/constants/CommonConstants';
import { ConsigneeInfo } from '../viewmodel/DataModel';

@Builder
export function ConsigneeInfoItem(item: ConsigneeInfo, checkAvailable?: () => void) {
  Row() {
    Text(item.label)
      .fontSize(16)
      .fontWeight(400)
      .lineHeight(19)
      .textAlign(TextAlign.Start)
      .fontColor($r('app.color.item_label_color'))
      .opacity(0.9)
      .layoutWeight(1)

    TextArea({ placeholder: item.placeholder, text: item.value })
      .type(item.label === CommonConstants.PHONE_LABEL ? TextAreaType.PHONE_NUMBER : TextAreaType.NORMAL)
      .fontSize(16)
      .fontWeight(500)
      .lineHeight(21)
      .padding(0)
      .borderRadius(0)
      .textAlign(TextAlign.End)
      .fontColor($r('app.color.item_label_color'))
      .opacity(0.9)
      .backgroundColor($r('app.color.light_background'))
      .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
      .layoutWeight(2)
      .onChange((value: string) => {
        item.value = value;
        checkAvailable?.();
      })
  }
  .width('100%')
  .constraintSize({ minHeight: 48 })
  .justifyContent(FlexAlign.SpaceBetween)
}