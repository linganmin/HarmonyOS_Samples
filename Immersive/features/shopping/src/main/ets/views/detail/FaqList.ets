/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { getResourceString } from 'commons';
import { Faq, getFaqData } from '../../models/Detail';

@Component
export struct FaqList {

  getTitle() {
    getResourceString($r('app.string.faq_list_title'), this.getUIContext())
  }

  @Builder
  Header() {
    Row() {
      Image($r('app.media.product_small_1'))
        .width(36)
        .height(36)
        .borderRadius(8)
        .margin({ right: 10 })
      Column() {
        Text('HUAWEI MATE X5')
        Text($r('app.string.faq_list_statistic'))
          .fontSize(12)
          .opacity(0.6)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    TextInput({ placeholder: 'search...' })
      .margin({ top: 10, bottom: 10 })
  }

  @Builder
  FaqItem(faq: Faq) {
    Column() {
      Text(faq.question)
        .fontWeight(500)
      Text(faq.answer)
        .fontSize(13)
        .opacity(0.6)
        .margin({ top: 10, bottom: 10 })
      Row() {
        Image($r('app.media.like'))
          .width(12)
          .margin({ right: 4 })
          .opacity(0.6)
        Text(faq.likeCount?.toString())
          .fontSize(10)
          .opacity(0.6)
      }
      .padding({ top: 6, bottom: 6, left: 10, right: 10 })
      .borderRadius(16)
      .backgroundColor('#0C182431')
      .alignSelf(ItemAlign.End)
    }
    .width('100%')
    .padding({ top: 16, bottom: 16, left: 10, right: 10 })
    .borderRadius(12)
    .backgroundColor(Color.White)
    .margin({ bottom: 10 })
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    NavDestination() {
      Column() {
        this.Header()
        // [Start configure_list_listexpandsafearea]
        // features/shopping/src/main/ets/views/detail/FaqList.ets
        List() {
          // [StartExclude configure_list_listexpandsafearea]
          // [Start implement_infinite_scroll_footer_indicator]
          // features/shopping/src/main/ets/views/detail/FaqList.ets
          ForEach(getFaqData(), (faq: Faq) => {
            ListItem() {
              this.FaqItem(faq)
            }
          }, (faq: Faq) => JSON.stringify(faq))
          ListItem() {
            Text($r('app.string.faq_list_all'))
              .width('100%')
              .textAlign(TextAlign.Center)
              .opacity(0.6)
              .padding({ top: 10, bottom: 10 })
          }
          // [End implement_infinite_scroll_footer_indicator]
          // [EndExclude configure_list_listexpandsafearea]
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        // [End configure_list_listexpandsafearea]
      }
      .width('100%')
      .height('100%')
      .padding({ left: 14, right: 14, top: 8 })
    }
    .title(this.getTitle())
    .backgroundColor('#F1F3F5')
  }
}