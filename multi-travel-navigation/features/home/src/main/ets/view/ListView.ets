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

import { Common } from '@ohos/commons/Index';
import { HomeConstants } from '../constants/HomeConstants';
import { AttractionModel } from '../viewmodel/AttractionModel';

@Component
export struct ListView {
  build() {
    Column() {
      Row() {
        Text($r('app.string.discount_attraction'))
          .fontSize($r('app.float.attraction_text_size'))
          .fontColor($r('app.color.black'))
        Image($r('app.media.close'))
          .height($r('app.float.close_image_size'))
          .width($r('app.float.close_image_size'))
      }
      .width(Common.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: $r('app.float.side_space'),
        right: $r('app.float.side_space'),
        bottom: $r('app.float.text_space')
      })

      List() {
        ForEach(HomeConstants.DISCOUNT_ATTRACTIONS, (item: AttractionModel) => {
          ListItem() {
            Column({ space: HomeConstants.LIST_ITEM_SPACE }) {
              Image(item.icon)
                .height($r('app.float.attraction_icon_height'))
                .width($r('app.float.attraction_icon_width'))
                .borderRadius($r('app.float.list_item_border_radius'))
              Text(item.name)
                .fontSize($r('app.float.attraction_text_size'))
                .fontColor($r('app.color.black'))
            }
            .padding({ right: $r('app.float.side_distance') })
          }
        }, (item: AttractionModel) => JSON.stringify(item))
        ForEach(HomeConstants.DISCOUNT_ATTRACTIONS, (item: AttractionModel) => {
          ListItem() {
            Column({ space: HomeConstants.LIST_ITEM_SPACE }) {
              Image(item.icon)
                .height($r('app.float.attraction_icon_height'))
                .width($r('app.float.attraction_icon_width'))
                .borderRadius($r('app.float.list_item_border_radius'))
              Text(item.name)
                .fontSize($r('app.float.attraction_text_size'))
                .fontColor($r('app.color.black'))
            }
            .padding({ right: $r('app.float.side_distance') })
          }
        }, (item: AttractionModel) => JSON.stringify(item))
      }
      .scrollBar(BarState.Off)
      .height($r('app.float.list_height'))
      .padding({
        top: $r('app.float.add_text_space'),
        left: $r('app.float.side_space'),
        bottom: $r('app.float.side_padding')
      })
      .listDirection(Axis.Horizontal)

      Row() {
        Text($r('app.string.have_more'))
          .fontSize($r('app.float.tip_font_size'))
          .fontColor($r('app.color.have_more_color'))
          .padding({ right: $r('app.float.text_space') })
        Image($r('app.media.ic_public_arrow_right'))
          .width($r('app.float.arrow_right_size'))
      }
    }
    .hitTestBehavior(HitTestMode.None)
    .padding({
      top: $r('app.float.side_distance'),
      bottom: $r('app.float.add_text_space')
    })
    .margin({ top: $r('app.float.side_distance') })
    .borderRadius($r('app.float.border_radius'))
    .shadow({
      radius: $r('app.float.shadow_radius'),
      color: $r('app.color.blur')
    })
  }
}