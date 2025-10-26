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

import { getNWeb } from './WebPage';
import { Constants } from '../common/Constants';

@Entry
@Component
struct WebPreRender {
  @State isShowSheet: boolean = false;

  @Builder
  mySheet() {
    Column() {
      NodeContainer(getNWeb(Constants.WEB_URL))
        .height($r('app.string.full_height_width'))
        .width($r('app.string.width_percentage_ninety'))
    }
    .padding({ top: $r('app.string.index_tab') })
    .width($r('app.string.full_height_width'))
    .height($r('app.string.full_height_width'))
    .backgroundColor(Color.White)
  }

  build() {
    Column() {
      Text($r('app.string.title'))
        .fontColor($r('app.color.title_color'))
        .fontSize($r('app.string.title_size'))
        .fontWeight(FontWeight.Bold)
        .padding({
          top: $r('app.string.title_padding_top_bot'),
          bottom: $r('app.string.title_padding_top_bot'),
          left: $r('app.string.title_padding_left_right'),
          right: $r('app.string.title_padding_left_right')
        })
        .width($r('app.string.full_height_width'))
        .margin({ top: $r('app.string.index_tab') })

      Row() {
        Column() {
          Text($r('app.string.text_name'))
            .fontSize($r('app.string.text_size'))
            .fontWeight(FontWeight.Medium)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .margin({ top: $r('app.string.row_top') })
      .borderRadius(Constants.TEXT_BORDER_RADIUS)
      .width($r('app.string.width_percentage_ninety'))
      .alignItems(VerticalAlign.Center)
      .padding({
        left: $r('app.string.row_padding'),
        top: $r('app.string.row_padding'),
        bottom: $r('app.string.row_padding')
      })
      .backgroundColor(Color.White)
      .bindSheet(this.isShowSheet, this.mySheet(), {
        height: Constants.BIND_SHEET_HEIGHT,
        detents: [SheetSize.MEDIUM, SheetSize.LARGE, 200],
        backgroundColor: Color.White,
        onDisappear: () => {
          this.isShowSheet = !this.isShowSheet;
        }
      })
      .onClick(() => {
        this.isShowSheet = !this.isShowSheet;
      })
    }
    .width($r('app.string.full_height_width'))
    .height($r('app.string.full_height_width'))
    .backgroundColor($r('app.color.back_color'))
  }
}