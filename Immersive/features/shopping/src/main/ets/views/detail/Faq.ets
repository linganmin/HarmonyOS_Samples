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

import { getFaqQuestions } from '../../models/Detail';

@Component
export struct Faq {
  @Consume('navPageInfos') navPageInfos: NavPathStack;

  build() {
    Column() {
      Row() {
        Text($r('app.string.faq_title'))
          .fontWeight(500)
        Blank()
        Text($r('app.string.faq_more'))
          .fontSize(14)
          .opacity(0.6)
          .margin({ right: 4 })
        Image($r('app.media.arrow_right'))
          .width(8)
          .height(16)
          .opacity(0.4)
      }
      .width('100%')
      .margin({ bottom: 4 })
      ForEach(getFaqQuestions(), (question: ResourceStr) => {
        Row() {
          Image($r('app.media.question'))
            .width(18)
            .height(18)
            .margin({ right: 8 })
            .opacity(0.6)
          Text(question)
            .fontSize(14)
        }
        .width('100%')
        .margin({ top: 10 })
      }, (question: ResourceStr) => JSON.stringify(question))
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding(12)
    .borderRadius(16)
    .onClick(() => {
      this.navPageInfos.pushPath({ name: 'FaqList' })
    })
  }
}
