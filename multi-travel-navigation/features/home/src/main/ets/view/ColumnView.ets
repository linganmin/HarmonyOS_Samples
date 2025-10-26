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

@Component
export struct ColumnView {
  @Link columnHeight: number;

  build() {
    Column() {
      Column() {
        Row() {
          Text($r('app.string.frequent_locations'))
            .fontSize($r('app.float.add_font_size'))
            .fontColor($r('app.color.black'))

          Row() {
            Text($r('app.string.all'))
              .fontSize($r('app.float.tip_font_size'))
              .padding({ right: $r('app.float.text_space') })
            Image($r('app.media.ic_public_arrow_right'))
              .width($r('app.float.arrow_right_size'))
          }
        }
        .width(Common.FULL_WIDTH)
        .padding({
          left: $r('app.float.side_space'),
          right: $r('app.float.side_space')
        })
        .justifyContent(FlexAlign.SpaceBetween)
        .visibility(this.columnHeight <= Common.HEIGHT_MIDDLE ? Visibility.None : Visibility.Visible)
        .layoutWeight(1)

        Row() {
          Row() {
            Image($r('app.media.add_home'))
              .width($r('app.float.image_width'))
            Text($r('app.string.add_home'))
              .fontSize($r('app.float.add_font_size'))
              .fontColor($r('app.color.font_add_color'))
              .padding({ left: $r('app.float.add_text_space') })
          }

          Row() {
            Image($r('app.media.comp'))
              .width($r('app.float.image_width'))
            Text($r('app.string.add_comp'))
              .fontSize($r('app.float.add_font_size'))
              .fontColor($r('app.color.font_add_color'))
              .padding({ left: $r('app.float.add_text_space') })
          }
        }
        .width(Common.FULL_WIDTH)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          left: $r('app.float.side_space'),
          right: $r('app.float.side_space')
        })
        .layoutWeight(1)

        Row() {
          Image($r('app.media.address'))
            .width($r('app.float.image_width'))
          Text($r('app.string.add_address'))
            .fontSize($r('app.float.add_font_size'))
            .fontColor($r('app.color.font_add_color'))
            .padding({ left: $r('app.float.add_text_space') })
        }
        .padding({ left: $r('app.float.side_space') })
        .width(Common.FULL_WIDTH)
      }
      .height(this.columnHeight <= Common.HEIGHT_MIDDLE ?
        $r('app.float.column_height_part') : $r('app.float.column_height_full'))
      .padding({ bottom: $r('app.float.side_padding') })
      .margin({ top: $r('app.float.side_distance') })
      .borderRadius($r('app.float.border_radius'))
      .shadow({
        radius: $r('app.float.shadow_radius'),
        color: $r('app.color.blur')
      })

      Column() {
        Row() {
          Text($r('app.string.recommend_location'))
            .fontSize($r('app.float.tip_font_size'))
            .fontColor($r('app.color.font_recommend_color'))
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

        Row() {
          Column() {
            Row() {
              Text($r('app.string.recommend'))
                .padding({ right: $r('app.float.text_space') })
                .fontSize($r('app.float.large_font_size'))
                .fontColor($r('app.color.black'))
              Image($r('app.media.arrow'))
                .width($r('app.float.arrow_image_size'))
            }
            .padding({ bottom: $r('app.float.text_space') })

            Text($r('app.string.direction_desc'))
              .fontColor($r('app.color.font_add_color'))
              .fontSize($r('app.float.tip_font_size'))
          }
          .alignItems(HorizontalAlign.Start)
          .width(HomeConstants.TEXT_WIDTH)

          Button($r('app.string.goto'))
            .height($r('app.float.button_height'))
            .width($r('app.float.button_width'))
        }
        .padding({
          left: $r('app.float.side_space'),
          right: $r('app.float.side_space')
        })
        .justifyContent(FlexAlign.SpaceBetween)
        .width(Common.FULL_WIDTH)
      }
      .padding({
        top: $r('app.float.side_distance'),
        bottom: $r('app.float.side_distance')
      })
      .margin({ top: $r('app.float.side_distance') })
      .borderRadius($r('app.float.border_radius'))
      .shadow({
        radius: $r('app.float.shadow_radius'),
        color: $r('app.color.blur')
      })
    }
  }
}