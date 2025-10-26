/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { SourceListType, numberSourceListData } from '../model/MenuData';
import { DeleteKey } from './DeleteKey';
import { NumberKeyItem } from './NumberKeyItem';
import CommonConstants from '../common/constants/CommonConstants';

@Component
export struct NumberKeyboard {
  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(numberSourceListData.slice(0, 4), (item: SourceListType) => {
          NumberKeyItem({
            keyValue: item,
            color: item.isSpecial ? $r('app.color.state_styles_normal') : $r('app.color.font_background_white')
          })
        }, (item: string) => JSON.stringify(item))
      }
      .margin({ right: $r('app.float.comm_margin_five') })

      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(numberSourceListData.slice(4, 8), (item: SourceListType) => {
          NumberKeyItem({
            keyValue: item,
            color: item.isSpecial ? $r('app.color.state_styles_normal') : $r('app.color.font_background_white')
          })
        }, (item: string) => JSON.stringify(item))
      }
      .margin({ right: $r('app.float.comm_margin_five') })

      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(numberSourceListData.slice(8, 12), (item: SourceListType) => {
          NumberKeyItem({
            keyValue: item,
            color: item.isSpecial ? $r('app.color.state_styles_normal') : $r('app.color.font_background_white')
          })
        }, (item: string) => JSON.stringify(item))
      }
      .margin({ right: $r('app.float.comm_margin_five') })

      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(numberSourceListData.slice(12, 16), (item: SourceListType) => {
          NumberKeyItem({
            keyValue: item,
            color: item.isSpecial ? $r('app.color.state_styles_normal') : $r('app.color.font_background_white')
          })
        }, (item: string) => JSON.stringify(item))
      }
      .margin({ right: $r('app.float.comm_margin_five') })

      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
        DeleteKey()
          .layoutWeight(CommonConstants.LAYOUT_WEIGHT_ONE)
          .margin({ bottom: $r('app.float.comm_margin_five'), top: $r('app.float.comm_margin_five') });
        NumberKeyItem({
          keyValue: numberSourceListData.slice(16)[0],
          color: $r('app.color.state_styles_normal')
        })
          .layoutWeight(CommonConstants.LAYOUT_WEIGHT_ONE)
          .margin({ bottom: $r('app.float.comm_margin_ten') })
        NumberKeyItem({
          keyValue: numberSourceListData.slice(17)[0],
          color: $r('app.color.search_background_normal')
        })
          .layoutWeight(CommonConstants.LAYOUT_WEIGHT_TWO)
          .margin({ bottom: $r('app.float.comm_margin_ten') })
      }
    }
    .padding($r('app.float.comm_margin_ten'))
    .height($r('app.float.keyboard_height'))
    .backgroundColor($r('app.color.keyboard_background_color'))
  }
}

