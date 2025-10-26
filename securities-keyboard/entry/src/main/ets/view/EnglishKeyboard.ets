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

import { keySourceListData, KeySourceListType } from '../model/MenuData';
import { DeleteKey } from './DeleteKey';
import { EnglishKeyItem } from './EnglishKeyItem';
import { ShiftKey } from './ShiftKey';
import CommonConstants from '../common/constants/CommonConstants';

@Component
export struct EnglishKeyboard {
  @State upper: boolean = false;

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(keySourceListData.slice(0, 10), (item: KeySourceListType) => {
          EnglishKeyItem({
            keyValue: item,
            upper: $upper
          })
            .margin({
              right: $r('app.float.comm_margin_two'),
              left: $r('app.float.comm_margin_two')
            })
        }, (item: KeySourceListType) => item.content as string)
      }
      .width(CommonConstants.PERCENTAGE_MAX)
      .margin({ top: $r('app.float.comm_margin_twelve'), bottom: $r('app.float.comm_margin_six') })

      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(keySourceListData.slice(10, 19), (item: KeySourceListType) => {
          EnglishKeyItem({
            keyValue: item,
            upper: $upper
          })
            .margin({
              right: $r('app.float.comm_margin_two'),
              left: $r('app.float.comm_margin_two')
            })
        }, (item: KeySourceListType) => item.content as string)
      }
      .width(CommonConstants.NINETY_PERCENT_WIDTH)
      .margin({ top: $r('app.float.comm_margin_six'), bottom: $r('app.float.comm_margin_six') })

      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        ShiftKey({
          upper: $upper
        })
          .margin({
            right: $r('app.float.comm_margin_five'),
            left: $r('app.float.comm_margin_two')
          })
        ForEach(keySourceListData.slice(19, 26), (item: KeySourceListType) => {
          EnglishKeyItem({
            keyValue: item,
            upper: $upper
          })
            .margin({
              right: $r('app.float.comm_margin_two'),
              left: $r('app.float.comm_margin_two')
            })
        }, (item: KeySourceListType) => item.content as string)
        DeleteKey().margin({ left: $r('app.float.comm_margin_five') })
      }
      .width(CommonConstants.PERCENTAGE_MAX)
      .margin({ top: $r('app.float.comm_margin_six'), bottom: $r('app.float.comm_margin_six') })

      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        EnglishKeyItem({
          keyValue: keySourceListData.slice(26)[0],
          upper: $upper,
          color: $r('app.color.state_styles_normal')
        })
          .margin({
            right: $r('app.float.comm_margin_two'),
            left: $r('app.float.comm_margin_two')
          })
          .layoutWeight(CommonConstants.LAYOUT_WEIGHT_ONE)
        EnglishKeyItem({
          keyValue: keySourceListData.slice(27)[0],
          upper: $upper
        })
          .margin({
            right: $r('app.float.comm_margin_five'),
            left: $r('app.float.comm_margin_five')
          })
          .layoutWeight(CommonConstants.LAYOUT_WEIGHT_TWO)
        EnglishKeyItem({
          keyValue: keySourceListData.slice(28)[0],
          upper: $upper,
          color: $r('app.color.search_background_normal')
        })
          .margin({
            right: $r('app.float.comm_margin_two'),
            left: $r('app.float.comm_margin_two')
          })
          .layoutWeight(CommonConstants.LAYOUT_WEIGHT_ONE)
      }
      .width(CommonConstants.PERCENTAGE_MAX)
      .margin({ top: $r('app.float.comm_margin_six'), bottom: $r('app.float.comm_margin_six') })
    }
    .height($r('app.float.keyboard_height'))
    .padding({ top: $r('app.float.comm_margin_three'), bottom: $r('app.float.comm_margin_ten') })
    .backgroundColor($r('app.color.keyboard_background_color'))
  }
}