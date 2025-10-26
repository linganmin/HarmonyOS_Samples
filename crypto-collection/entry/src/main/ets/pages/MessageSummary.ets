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

import { SummaryViewModel } from '../viewmodel/SummaryViewModel';
import { SummaryItem } from '../viewmodel/SummaryItem';
import CommonConstants from '../constants/CommonConstants';
import { getResourceString } from '../utils/ResourceString';

@Builder
export function MessageSummaryBuilder() {
  MessageSummary();
}

@Entry
@Component
struct MessageSummary {
  @Consume('pageInfos') pageInfos: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.total_count', SummaryViewModel.getSummaryList().length))
          .fontSize($r('app.float.count_size'))
          .fontWeight(CommonConstants.FONT_WIGHT_500)
          .fontFamily(CommonConstants.FONT_FAMILY_BLACK)
          .fontColor($r('sys.color.mask_secondary'))
          .margin({
            bottom: $r('app.float.count_margin_bottom')
          })
        List() {
          ForEach(SummaryViewModel.getSummaryList(), (item: SummaryItem) => {
            ListItem() {
              Row() {
                Text(item.name)
                  .fontSize($r('app.float.common_font'))
                  .fontWeight(CommonConstants.FONT_WIGHT_500)
                  .fontFamily(CommonConstants.FONT_FAMILY_BLACK)
                Image($r('app.media.ic_public_arrow_right'))
                  .width($r('app.float.arrow_width'))
                  .height($r('app.float.common_image'))
              }
              .width(CommonConstants.FULL_PERCENT)
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .height($r('app.float.list_item_height'))
            .onClick(() => {
              this.pageInfos.pushPathByName('SummaryDetail', item);
            })
          }, (item: SummaryItem, index: number) => index + JSON.stringify(item))
        }
        .backgroundColor(Color.White)
        .borderRadius($r('sys.float.corner_radius_level8'))
        .divider({
          strokeWidth: $r('app.float.stroke_width'),
          color: $r('app.color.five_black')
        })
        .padding({
          left: $r('app.float.small_padding'),
          right: $r('app.float.small_padding')
        })
      }
      .alignItems(HorizontalAlign.Start)
      .padding({
        top: $r('app.float.list_padding'),
        left: $r('app.float.medium_padding'),
        right: $r('app.float.medium_padding')
      })
    }
    .title(getResourceString($r('app.string.message_btn'), this.getUIContext()))
    .backgroundColor($r('app.color.background_page'))
  }
}