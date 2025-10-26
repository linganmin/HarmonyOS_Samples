/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import TitleBar from '../view/TitleBar';
import CommonConstants from '../common/CommonConstants';

@Entry
@Component
struct Home {
  build() {
    Column() {
      TitleBar()
      Stack() {
        Image($r('app.media.home'))
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .objectFit(ImageFit.Fill)
          .opacity($r('app.float.image_opacity'))
        Text($r('app.string.message_unlock'))
          .fontSize($r('app.float.tips_font_size'))
          .fontWeight(FontWeight.Bold)
          .padding($r('app.float.tips_padding'))
          .alignSelf(ItemAlign.Center)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.background_color'))
  }
}