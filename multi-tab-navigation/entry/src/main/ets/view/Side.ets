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

import { TabContentConstants } from '../common/TabContentConstants';
import { Utils } from '../common/Utils';

@Component
export struct Side {
  @State likeCount: number = TabContentConstants.SIDE_NUMBER;
  @State commentCount: number = TabContentConstants.SIDE_NUMBER;
  @State favoriteCount: number = TabContentConstants.SIDE_NUMBER;
  @State isFocus: boolean = false;
  @State isLike: boolean = false;
  @State isFavorite: boolean = false;
  private utils = new Utils();
  private head: Resource = $r('app.media.tab_head_image');

  // Callback function for clicking the like button.
  private changeLikeCount() {
    if (!this.isLike) {
      this.likeCount++;
    } else {
      this.likeCount--;
    }
    this.getUIContext().animateTo({ duration: TabContentConstants.TAB_DURATION, curve: Curve.EaseInOut }, () => {
      this.isLike = !this.isLike;
    })
  }

  // Callback function for clicking the favorites button.
  private changeFavoriteCount() {
    if (!this.isFavorite) {
      this.favoriteCount++;
    } else {
      this.favoriteCount--;
    }
    this.getUIContext().animateTo({ duration: TabContentConstants.TAB_DURATION, curve: Curve.EaseInOut }, () => {
      this.isFavorite = !this.isFavorite;
    })
  }

  build() {
    RelativeContainer() {
      Image(this.head)
        .width($r('app.integer.tab_head_image_width'))
        .height($r('app.integer.tab_head_image_height'))
        .borderRadius(TabContentConstants.TAB_HEAD_IMAGE_BORDER_RADIUS)
        .border({
          width: $r('app.integer.tab_head_image_border_width'),
          color: Color.White
        })
        .id(TabContentConstants.TAB_HEAD_IMAGE)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_CONTAINER, align: VerticalAlign.Top },
          left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start }
        })
        .margin({ left: TabContentConstants.TAB_HEAD_IMAGE_MARGIN_LEFT })
        .onClick(() => {
          this.utils.showPromptAction();
        })
      Image(this.isFocus ? $r("app.media.tab_follow") : $r('app.media.tab_focus_add'))
        .width($r('app.integer.tab_focus_image_width'))
        .height($r('app.integer.tab_focus_image_height'))
        .borderRadius($r('app.integer.tab_focus_image_border_radius'))
        .margin({
          top: $r('app.integer.tab_focus_image_margin'),
          left: $r('app.integer.tab_focus_image_margin')
        })
        .onClick(() => {
          this.getUIContext().animateTo({ duration: TabContentConstants.TAB_DURATION, curve: Curve.EaseInOut }, () => {
            this.isFocus = !this.isFocus;
          })
        })
        .id(TabContentConstants.TAB_FOCUS_IMAGE)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_HEAD_IMAGE, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_HEAD_IMAGE, align: HorizontalAlign.Center }
        })
      Image(this.isLike ? $r("app.media.tab_fabulous_full") : $r('app.media.tab_fabulous'))
        .width($r('app.integer.tab_like_image_width'))
        .height($r('app.integer.tab_like_image_height'))
        .objectFit(ImageFit.ScaleDown)
        .onClick(() => {
          this.changeLikeCount();
        })
        .id(TabContentConstants.TAB_LIKE_IMAGE)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_FOCUS_IMAGE, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start },
          right: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.End }
        })
        .margin({ top: $r('app.integer.tab_like_image_margin_top') })
      Text(this.likeCount.toString())
        .fontSize($r('app.integer.tab_like_text_font_size'))
        .fontColor(Color.White)
        .opacity(TabContentConstants.TAB_TEXT_OPACITY)
        .id(TabContentConstants.TAB_LIKE_TEXT)
        .textAlign(TextAlign.Center)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_LIKE_IMAGE, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start },
          right: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.End }
        })
        .margin({ top: $r('app.integer.tab_like_text_margin_top') })
      Image($r('app.media.tab_comment'))
        .width($r('app.integer.tab_like_image_width'))
        .height($r('app.integer.tab_like_image_height'))
        .objectFit(ImageFit.ScaleDown)
        .id(TabContentConstants.TAB_COMMENT_IMAGE)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_LIKE_TEXT, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start },
          right: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.End }
        })
        .margin({ top: $r('app.integer.tab_like_image_margin_top') })
        .onClick(() => {
          this.utils.showPromptAction();
        })
      Text(this.commentCount.toString())
        .fontSize($r('app.integer.tab_like_text_font_size'))
        .fontColor(Color.White)
        .opacity(TabContentConstants.TAB_TEXT_OPACITY)
        .id(TabContentConstants.TAB_COMMENT_TEXT)
        .textAlign(TextAlign.Center)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_COMMENT_IMAGE, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start },
          right: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.End }
        })
        .margin({ top: $r('app.integer.tab_like_text_margin_top') })
      Image(this.isFavorite ? $r('app.media.tab_high_yellow') :
      $r('app.media.tab_high_white'))
        .width($r('app.integer.tab_like_image_width'))
        .height($r('app.integer.tab_like_image_height'))
        .onClick(() => {
          this.changeFavoriteCount();
        })
        .id(TabContentConstants.TAB_FAVORITE_IMAGE)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_COMMENT_TEXT, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start },
          right: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.End }
        })
        .margin({ top: $r('app.integer.tab_like_image_margin_top') })
      Text(this.favoriteCount.toString())
        .fontSize($r('app.integer.tab_like_text_font_size'))
        .fontColor(Color.White)
        .opacity(TabContentConstants.TAB_TEXT_OPACITY)
        .id(TabContentConstants.TAB_FAVORITE_TEXT)
        .textAlign(TextAlign.Center)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_FAVORITE_IMAGE, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start },
          right: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.End }
        })
        .margin({ top: $r('app.integer.tab_like_text_margin_top') })
      Image($r('app.media.tab_share'))
        .width($r('app.integer.tab_like_image_width'))
        .height($r('app.integer.tab_like_image_height'))
        .objectFit(ImageFit.ScaleDown)
        .id(TabContentConstants.TAB_SHARE_IMAGE)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_FAVORITE_TEXT, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start },
          right: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.End }
        })
        .margin({ top: $r('app.integer.tab_like_image_margin_top') })
        .onClick(() => {
          this.utils.showPromptAction();
        })
      Text($r('app.string.tab_share'))
        .fontSize($r('app.integer.tab_like_text_font_size'))
        .fontColor(Color.White)
        .opacity(TabContentConstants.TAB_TEXT_OPACITY)
        .id(TabContentConstants.TAB_SHARE_TEXT)
        .textAlign(TextAlign.Center)
        .alignRules({
          top: { anchor: TabContentConstants.TAB_SHARE_IMAGE, align: VerticalAlign.Bottom },
          left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start },
          right: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.End }
        })
        .margin({ top: $r('app.integer.tab_like_text_margin_top') })
    }
    .height($r('app.integer.tab_relative_container_height'))
    .width($r('app.integer.tab_relative_container_width'))
  }
}