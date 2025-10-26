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

import { CommonConstants as Const } from '../common/CommonConstants';

@Component
export struct Side {
  @State head: Resource = $r('app.media.app_icon');
  @State likeCount: string = '';
  @State commentCount: string = '';
  @State favoriteCount: string = '';
  @State shareCount: string = '';
  @State isFocus: boolean = true;
  @State isLike: boolean = false;
  @State isFavorite: boolean = true;
  @State index: number = 0;

  /**
   * The callback function for the click event of the like button.
   * @param isAdd
   */
  private changeLikeCount(isAdd: boolean) {
    let likeCountNum = Number(this.likeCount);
    if(isAdd) {
      likeCountNum++;
    } else {
      likeCountNum--;
    }
    this.likeCount = '' + likeCountNum;
    this.getUIContext().animateTo({ duration: Const.DURATION, curve: Curve.EaseInOut }, () => {
      this.isLike = !this.isLike;
    })
  }

  /**
   * The callback function for the click event of the favorite button.
   * @param isIncrease
   */
  private changeFavoriteCount(isIncrease: boolean) {
    let favoriteCountNum = Number(this.favoriteCount);
    if(isIncrease) {
      favoriteCountNum++;
    } else {
      favoriteCountNum--;
    }
    this.favoriteCount = '' + favoriteCountNum;
    this.getUIContext().animateTo({ duration: Const.DURATION, curve: Curve.EaseInOut }, () => {
      this.isFavorite = !this.isFavorite;
    })
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        Image(this.head)
          .width($r('app.integer.avatar_size'))
          .height($r('app.integer.avatar_size'))
          .borderRadius($r('app.float.avatar_borderRadius'))
          .border({
            width: 1,
            color: Color.White
          })
        if (this.isFocus) {
          Image($r('app.media.img'))
            .width($r('app.integer.concern_size'))
            .height($r('app.integer.concern_size'))
            .borderRadius($r('app.integer.concern_border_radius'))
            .margin({ bottom: $r('app.integer.concern_margin_bottom') })
            .onClick(() => {
              this.getUIContext().animateTo({ duration: Const.DURATION, curve: Curve.EaseInOut }, () => {
                this.isFocus = !this.isFocus;
              })
            })
        }
        if (!this.isFocus) {
          Image($r('app.media.follow1'))
            .width($r('app.integer.concern_size'))
            .height($r('app.integer.concern_size'))
            .borderRadius($r('app.integer.concern_border_radius'))
            .margin({ bottom: $r('app.integer.concern_margin_bottom') })
            .onClick(() => {
              this.getUIContext().animateTo({ duration: Const.DURATION, curve: Curve.EaseInOut }, () => {
                this.isFocus = !this.isFocus;
              })
            })
        }
      }
      .width(Const.FULL_SIZE)
      .height($r('app.integer.avatar_height'))
      .padding({ bottom: $r('app.integer.avatar_padding_bottom') })

      Column() {
        if (!this.isLike) {
          Image($r('app.media.fabulous'))
            .height($r('app.integer.fabulous_height'))
            .width($r('app.integer.fabulous_width'))
            .objectFit(ImageFit.ScaleDown)
            .onClick(() => {
              this.changeLikeCount(true);
            })
            .margin({ bottom: $r('app.integer.fabulous_margin_bottom') })
          Text(this.likeCount)
            .fontSize($r('app.integer.fabulous_font_size'))
            .fontColor(Color.White)
            .opacity($r('app.float.fabulous_opacity'))
        }
        if (this.isLike) {
          Image($r('app.media.fabulo'))
            .height($r('app.integer.fabulous_height'))
            .width($r('app.integer.fabulous_width'))
            .objectFit(ImageFit.ScaleDown)
            .onClick(() => {
              this.changeLikeCount(false);
            })
            .margin({ bottom: $r('app.integer.fabulous_margin_bottom') })
          Text(this.likeCount)
            .fontSize($r('app.integer.fabulous_font_size'))
            .fontColor(Color.White)
            .opacity($r('app.float.fabulous_opacity'))
        }
      }.width(Const.COLUMN_WIDTH)
      .height($r('app.integer.all_fabulous_height'))

      Column() {
        Image($r('app.media.new_icon'))
          .height($r('app.integer.fabulous_height'))
          .width($r('app.integer.fabulous_width'))
          .objectFit(ImageFit.ScaleDown)
          .margin({ bottom: $r('app.integer.fabulous_margin_bottom') })
        Text(this.commentCount)
          .fontSize($r('app.integer.fabulous_font_size'))
          .fontColor(Color.White)
          .opacity($r('app.float.fabulous_opacity'))
      }.width(Const.COLUMN_WIDTH)
      .height($r('app.integer.all_fabulous_height'))

      Column() {
        if (this.isFavorite) {
          Image($r('app.media.ic_public_highlightsed_white'))
            .height($r('app.integer.fabulous_height'))
            .width($r('app.integer.fabulous_width'))
            .onClick(() => {
              this.changeFavoriteCount(true);
            })
            .margin({ bottom: $r('app.integer.fabulous_margin_bottom') })
          Text(this.favoriteCount)
            .fontSize($r('app.integer.fabulous_font_size'))
            .fontColor(Color.White)
            .opacity($r('app.float.fabulous_opacity'))
        }
        if (!this.isFavorite) {
          Image($r('app.media.ic_public_highlightsed_yellow'))
            .height($r('app.integer.fabulous_height'))
            .width($r('app.integer.fabulous_width'))
            .onClick(() => {
              this.changeFavoriteCount(false);
            })
            .margin({ bottom: $r('app.integer.fabulous_margin_bottom') })
          Text(this.favoriteCount)
            .fontSize($r('app.integer.fabulous_font_size'))
            .fontColor(Color.White)
            .opacity($r('app.float.fabulous_opacity'))
        }
      }.width(Const.COLUMN_WIDTH)
      .height($r('app.integer.all_fabulous_height'))

      Column() {
        Image($r('app.media.share1'))
          .height($r('app.integer.share_height'))
          .width($r('app.integer.share_height'))
          .objectFit(ImageFit.ScaleDown)
        Text($r('app.string.share'))
          .fontSize($r('app.integer.fabulous_font_size'))
          .fontColor(Color.White)
          .opacity($r('app.float.fabulous_opacity'))
      }.width(Const.COLUMN_WIDTH)
      .height($r('app.integer.share_all_width'))
    }
    .margin({ bottom: $r('app.integer.side_margin_bottom') })
    .height(Const.COLUMN_HEIGHT)
    .width($r('app.integer.side_width'))
    .justifyContent(FlexAlign.End)
  }
}

@Component
export struct VideoDes {
  @State name: string = '';
  @State description: string = '';
  @State hotspot: string = '';
  @State time: string = '';

  build() {
    Column() {
      Text(this.name)
        .fontSize($r('app.integer.name_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ bottom: $r('app.integer.name_margin_bottom') })

      Text(this.description)
        .fontSize($r('app.integer.new_font_size'))
        .fontColor(Color.White)
        .width(Const.TEXT_WIDTH)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row() {
        Text(this.time)
          .fontSize($r('app.integer.time_font_size'))
          .fontColor($r('app.color.time_color'))
      }
    }
    .padding({ left: $r('app.integer.name_padding_left') })
    .alignItems(HorizontalAlign.Start)
    .width(Const.VIDEO_INFO_WIDTH)
  }
}
