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
import { CommonConstants } from '../common/constants/CommonConstants';

@Entry
@Component
struct Index {
  @Builder
  Options(name: Resource, url: string) {
    Row() {
      Column() {
        Text(name)
          .fontSize($r('app.float.card_padding'))
          .fontWeight(FontWeight.Medium)
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
      Row()
        .width($r('app.float.button_margin'))
        .height($r('app.float.button_margin'))
        .margin({ right: $r('app.float.column_padding') })
        .border({
          width: { top: $r('app.float.border'), right: $r('app.float.border') },
          color: $r('app.color.color_border')
        })
        .rotate({ angle: CommonConstants.ANGLE })
    }
    .borderRadius($r('app.float.text_size_headline'))
    .shadow({
      radius: $r('app.float.shadow_radius'),
      color: $r('app.color.shadow_color')
    })
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .height($r('app.float.row_height'))
    .alignItems(VerticalAlign.Center)
    .padding({
      left: $r('app.float.column_padding'),
      top: $r('app.float.column_padding'),
      bottom: $r('app.float.column_padding')
    })
    .backgroundColor(Color.White)
    .onClick(() => {
      this.getUIContext().getRouter().pushUrl({
        url
      })
    })
  }

  build() {
    Column({ space: CommonConstants.SPACE }) {
      Text($r('app.string.index_name'))
        .fontSize($r('app.float.font_size4'))
        .margin({ bottom: $r('app.float.text_margin') })
      this.Options($r('app.string.scroll_option'), 'pages/ScrollOption')
      this.Options($r('app.string.dialog_name'), 'pages/BindContentCoverDemo')
      this.Options($r('app.string.bind_sheet_dialog'), 'pages/BindSheet')
      this.Options($r('app.string.toast_dialog'), 'pages/Toast')
      this.Options($r('app.string.toast_private_dialog'), 'pages/Privacy')
      this.Options($r('app.string.full_screen'), 'pages/FullScreen')
      this.Options($r('app.string.calendar_dialog'), 'pages/CustomCalendar')
      this.Options($r('app.string.two_level_dialog'), 'pages/TwoLevelPageSheet')
    }
    .padding($r('app.float.column_padding'))
    .height(CommonConstants.ONE_HUNDRED_ELEVEN_PERCENT)
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .backgroundColor($r('app.color.color_background'))
  }
}