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

import { SongInfoItem } from '../model/LearningResource';

@Component
export struct ArticleCardView {
  @Prop articleItem: SongInfoItem;
  @Prop isCollected: boolean = false;
  @Prop isLiked: boolean = false;

  build() {
    Row({ space: 16 }) {
      Column() {
        Column() {
          Text($r('app.string.reusable_article_cardView_title'))
            .fontSize($r('app.float.md_font_size'))
            .fontFamily('HarmonyHeiTi')
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .opacity(0.9)
            .maxLines(2)
            .margin({ bottom: $r('app.float.xs_padding_margin') })

          Text($r('app.string.reusable_article_cardView_content'))
            .fontSize($r('app.float.sm_font_size'))
            .fontFamily('HarmonyHeiTi')
            .opacity(0.6)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Start)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Row() {
          ActionButtonBuilder(
            $r('app.media.ic_eye_open'),
            130,
            $r('app.float.view_count_icon_width')
          )

          ActionButtonBuilder(
            this.isLiked ? $r('app.media.btn_good_on') : $r('app.media.btn_good_normal'),
            43,
            $r('app.float.like_icon_width')
          )

          ActionButtonBuilder(
            this.isCollected ? $r('app.media.btn_favorites_on') : $r('app.media.btn_favorites_normal'),
            25,
            $r('app.float.star_icon_width')
          )
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.SpaceAround)

      Image(this.articleItem.cachedImage)
        .interpolation(ImageInterpolation.High)
        .height($r('app.float.article_card_image_height'))
        .width($r('app.float.article_card_image_width'))
        .borderRadius($r('app.float.md_border_radius'))
        .alt($r('app.media.img_placeholder'))
        .objectFit(ImageFit.Cover)
    }
    .padding($r('app.float.md_padding_margin'))
    .borderRadius($r('app.float.lg_border_radius'))
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Top)
    .width('100%')
    .height($r('app.float.article_card_height'))

  }
}

@Builder
function ActionButtonBuilder(imgResource: Resource, count: number, textWidth: Resource) {
  Row() {
    Image(imgResource)
      .size({ width: 16, height: 16 })
      .margin({ right: $r('app.float.action_button_margin_right') })
    Text(count.toString())
      .fontFamily('HarmonyHeiTi')
      .fontSize($r('app.float.small_text_size'))
      .width(textWidth)
      .opacity(0.6)
  }
  .width($r('app.float.action_button_width'))
  .padding({ top: $r('app.float.small_padding') })
  .alignItems(VerticalAlign.Center)
  .justifyContent(FlexAlign.Center)

}

