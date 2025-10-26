/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { CommonConstants as Const } from 'common';

@Component
export struct UserInfoComponent {
  build() {
    Column() {
      Image($r('app.media.ic_user'))
        .objectFit(ImageFit.Contain)
        .height($r('app.float.default_66'))
        .width($r('app.float.default_66'))
        .margin({
          top: $r('app.float.default_71')
        })

      Column() {
        Text($r('app.string.user_level'))
          .fontWeight(FontWeight.Bolder)
          .fontColor($r('app.color.user_level_font_color'))
          .fontSize($r('app.float.default_12'))
      }
      .width($r('app.float.default_44'))
      .height($r('app.float.default_16'))
      .margin({
        top: $r('app.float.default_n8')
      })
      .border({
        radius: $r('app.float.default_5')
      })
      .backgroundColor($r('app.color.user_level_bg_color'))
      .justifyContent(FlexAlign.Center)

      Text($r('app.string.user_name'))
        .fontFamily(Const.HELVETICA)
        .fontWeight(FontWeight.Normal)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('app.float.default_20'))
        .margin({
          bottom: $r('app.float.default_6')
        })

      Text($r('app.string.user_signature'))
        .fontFamily(Const.PING_FANG_SC_REGULAR)
        .fontWeight(FontWeight.Normal)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('app.float.default_16'))
    }
  }
}