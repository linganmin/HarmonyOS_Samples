/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { Blog } from '../viewmodels/BlogViewModel';

@Component
export struct BlogView {
  blog: Blog | undefined;

  build() {
    Column() {
      Row() {
        Image(this.blog?.getUsrProfile())
          .height($r('app.float.image_size_lg'))
          .width($r('app.float.image_size_lg'))
          .margin({ right: $r('app.float.margin_lg') })
        Column() {
          Text(this.blog?.getUserName())
            .fontSize($r('app.float.font_size_lg'))
            .lineHeight($r('app.float.description_height_md'))
            .margin({ bottom: $r('app.float.margin_sm') })
          Text(this.blog?.getUserType())
            .fontSize($r('app.float.font_size_md'))
            .lineHeight($r('app.float.description_height_sm'))
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Button(CommonConstants.FOLLOW_BUTTON)
          .fontSize($r('app.float.font_size_lg'))
          .fontColor($r('app.color.font_blue'))
          .height($r('app.float.follow_button_height'))
          .width($r('app.float.follow_button_width'))
          .backgroundColor($r('app.color.grey_background'))
      }
      .height($r('app.float.image_size_lg'))
      .width(CommonConstants.HUNDRED_PERCENT)
      .margin({
        top: $r('app.float.margin_xl'),
        bottom: $r('app.float.margin_md')
      })

      Text(this.blog?.getDescription())
        .fontSize($r('app.float.font_size_md'))
        .margin({ bottom: $r('app.float.margin_md') })
      Row() {
        ForEach(this.blog?.getPhotos(), (item: Resource, index: number) => {
          Image(item)
            .objectFit(ImageFit.Cover)
            .layoutWeight(1)
          Blank()
            .width($r('app.float.margin_sm'))
            .visibility(index + 1 === this.blog?.getPhotos().length ? Visibility.None : Visibility.Visible)
        }, (item: Resource, index: number) => (JSON.stringify(item) + index))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width(CommonConstants.HUNDRED_PERCENT)
      .margin({ bottom: $r('app.float.margin_xl') })
    }
    .width(CommonConstants.HUNDRED_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: $r('app.float.margin_xl'),
      right: $r('app.float.margin_xl')
    })
  }
}