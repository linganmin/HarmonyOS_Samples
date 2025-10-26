/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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

import { Article } from '../model/Article';

@Reusable
@Component
export struct ArticleItem {
  @Prop article: Article;

  build() {
    Column() {
      Image(this.article.cover)
        .width('100%')
        .objectFit(ImageFit.Fill)

      Column() {
        Text(this.article.title)
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))

        Row() {
          Image(this.article.avatar)
            .width(16)
            .height(16)
            .borderRadius(8)

          Text(this.article.author)
            .fontSize(12)
            .fontColor($r('sys.color.font_tertiary'))
            .margin({ left: 6 })

          Blank()

          SymbolGlyph($r('sys.symbol.heart'))
            .fontSize(16)
            .fontColor([$r('sys.color.font_secondary')])

          Text(this.article.favoriteNum.toString())
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ left: 2 })
        }
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .margin({ top: 8 })
        .height(16)
      }
      .padding($r('sys.float.padding_level6'))
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .clip(true)
    .width(`calc(50% - 4vp)`)
  }
}