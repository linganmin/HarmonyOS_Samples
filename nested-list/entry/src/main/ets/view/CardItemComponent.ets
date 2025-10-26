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

import { CommonConstants } from '../constants/CommonConstants';
import { CardItem } from '../viewmodel/CardItem';
import { ClassifyModel } from '../viewmodel/ClassifyModel';

@Component
export struct CardItemComponent {
  classifyModel: ClassifyModel = new ClassifyModel(0, '', []);

  build() {
    Column() {
      Column() {
        Text(this.classifyModel.classifyName)
          .fontSize($r('app.float.title_font_size'))
          .fontColor($r('app.color.service_color'))
          .fontWeight(CommonConstants.FONT_WEIGHT_500)
          .fontFamily($r('app.string.common_font_family'))
          .lineHeight($r('app.float.common_line_height'))
          .margin({
            left: $r('app.float.common_margin_left'),
            top: $r('app.float.item_margin_bottom')
          })
      }

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.classifyModel.courseList, (item: CardItem, index: number) => {
          Column() {
            Image(item.icon)
              .width($r('app.float.top_image'))
              .height($r('app.float.top_image'))
            Text(item.name)
              .fontSize($r('app.float.item_font_size'))
              .margin({
                top: $r('app.float.text_margin_top')
              })
          }
          .width(CommonConstants.ONE_FOURTH)
          .margin({
            top: Math.floor(index / CommonConstants.ITEM_COUNT) > 0 ? $r('app.float.flex_item_margin') : 0
          })
        }, (item: CardItem, index: number) => index + JSON.stringify(item))
      }
      .margin({
        top: $r('app.float.item_margin_top')
      })
      .borderRadius($r('app.float.common_radius'))
      .backgroundColor(Color.White)
      .padding($r('app.float.service_padding'))
    }
    .alignItems(HorizontalAlign.Start)
  }
}