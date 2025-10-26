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

import { CardData } from '../model/CardData';
import { resourceToString } from '../common/TypeCasting';

@Component
export struct CardComponent {
  cardData?: CardData;
  @State private cardTitle: string = '';
  @State private cardAbstract: string = '';

  aboutToAppear() {
    resourceToString(this.getUIContext(), $r('app.string.text_card_title')).then(value => {
      this.cardTitle = value + this.cardData!.getId();
    })
    resourceToString(this.getUIContext(), $r('app.string.text_card_abstract')).then(value => {
      this.cardAbstract = value + this.cardData!.getId();
    })
  }

  build() {
    Column() {
      Row() {
        // Thumbnail on the left
        Image($r('app.media.SampleImage'))
          .width($r('app.string.card_image_size'))
          .height($r('app.string.card_image_size'))

        // Text on the right
        Column() {
          Column() {
            Text(this.cardTitle)
              .fontSize($r('app.string.card_title_font_size'))
              .fontWeight(FontWeight.Medium)
              .lineHeight($r('app.string.card_title_line_height'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(this.cardAbstract)
              .fontSize($r('app.string.card_abstract_font_size'))
              .fontWeight(FontWeight.Regular)
              .lineHeight($r('app.string.card_abstract_line_height'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width($r('app.string.percent_100'))
          .padding({
            top: $r('app.string.spacing_xl'),
            bottom: $r('app.string.spacing_xl')
          })
          .alignItems(HorizontalAlign.Start)

          Divider()
            .width($r('app.string.percent_100'))
            .strokeWidth(0.5)
            .color($r('app.string.divider_color'))
        }
        .layoutWeight(1)
        .margin({ left: $r('app.string.spacing_xxl') })
      }
    }
    .width($r('app.string.percent_100'))
    .height($r('app.string.card_height'))
    .margin({
      top: $r('app.string.spacing_s'),
      bottom: $r('app.string.spacing_s')
    })
    .padding({
      left: $r('app.string.spacing_l'),
      right: $r('app.string.spacing_l')
    })
  }
}