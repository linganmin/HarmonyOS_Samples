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
struct TwoLevelPageSheet {
  @State isShow: boolean = false
  @State isShow2: boolean = false
  @State sheetHeight: string = '60%';
  @State sheetHeight2: number = 200;
  @State showDragBar: boolean = true;
  @State showDragBar2: boolean = true;

  @Builder
  myBuilder() {
    Column() {
      TextInput()
        .margin({
          top: $r('app.float.margin_top'),
          left: $r('app.float.corner_radius'),
          right: $r('app.float.corner_radius')
        })
      Row({ space: CommonConstants.SPACE_ONE }) {
        Button($r('app.string.button_two'))
          .fontSize($r('app.float.font_size'))
          .onClick(() => {
            this.isShow = false;
          })
        Button($r('app.string.button_three'))
          .fontSize($r('app.float.font_size'))
          .onClick(() => {
            this.isShow2 = true;
          })
          .bindSheet($$this.isShow2, this.myBuilder2(),
            {
              height: this.sheetHeight2,
              dragBar: this.showDragBar2,
              backgroundColor: $r('app.color.color_background'),
              maskColor: Color.Black,
            })
      }
      .margin({ bottom: $r('app.float.builder_height') })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .height(CommonConstants.ONE_HUNDRED_PERCENT)
  }

  @Builder
  myBuilder2() {
    Column() {
        Button($r('app.string.button_four'))
          .width(CommonConstants.ONE_HUNDRED_PERCENT)
          .margin({ bottom: $r('app.float.button_margin') })
          .fontSize($r('app.float.font_size'))
          .onClick(() => {
            this.isShow2 = false;
          })
        Button($r('app.string.button_five'))
          .margin({ bottom: $r('app.float.builder_height') })
          .width(CommonConstants.ONE_HUNDRED_PERCENT)
          .fontSize($r('app.float.font_size'))
          .onClick(() => {
            this.isShow = false;
            this.isShow2 = false;
          })
    }
    .padding({
      left: $r('app.float.card_padding'),
      right: $r('app.float.card_padding')
    })
    .justifyContent(FlexAlign.End)
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .height(CommonConstants.ONE_HUNDRED_PERCENT)
  }

  build() {
    Navigation() {
      Column() {
        Button($r('app.string.button_one'))
          .onClick(() => {
            this.isShow = true
          })
          .margin({ bottom: $r('app.float.card_padding') })
          .fontSize($r('app.float.font_size'))
          .bindSheet($$this.isShow, this.myBuilder(), {
            height: this.sheetHeight,
            dragBar: this.showDragBar,
            backgroundColor: $r('app.color.dialog_background'),
            maskColor: Color.Black,
          })
      }
      .justifyContent(FlexAlign.End)
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .height(CommonConstants.ONE_HUNDRED_PERCENT)
    }
    .title($r('app.string.two_level_dialog'))
    .titleMode(NavigationTitleMode.Mini)
  }
}