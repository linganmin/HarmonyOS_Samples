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
struct BindSheetDemo {
  @State isShowSheet: boolean = false;
  private menuList: ResourceStr[] = [$r('app.string.spicy'), $r('app.string.spicy1'), $r('app.string.spicy2'), $r('app.string.spicy3'), $r('app.string.spicy4'), $r('app.string.spicy5')];
  @Builder mySheet() {
    Column() {
      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
        ForEach(this.menuList, (item: string) => {
          Text(item)
            .fontSize($r('app.float.font_size1'))
            .fontColor($r('app.color.color_bind_sheet'))
            .backgroundColor($r('app.color.color_background_bind'))
            .borderRadius($r('app.float.border_radius1'))
            .margin($r('app.float.text_margin'))
            .padding($r('app.float.text_margin'))
        })
      }
      .padding({
        top: $r('app.float.column_padding'),
        left: $r('app.float.corner_radius_default_m')
      })
    }
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .height(CommonConstants.ONE_HUNDRED_PERCENT)
    .backgroundColor(Color.White)
  }

  build() {
    Navigation() {
      Column() {
        Text($r('app.string.tastes'))
          .fontSize($r('app.float.font_size5'))
          .padding({
            top: $r('app.float.row_padding'),
            bottom: $r('app.float.row_padding')
          })
        Column() {
          Row() {
            Column() {
              Text($r('app.string.choose_flavors'))
                .fontSize($r('app.float.font_size1'))
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
          .borderRadius($r('app.float.column_padding'))
          .shadow({
            radius: $r('app.float.shadow_radius'),
            color: $r('app.color.shadow_color')
          })
          .width(CommonConstants.NINETY_PERCENT)
          .alignItems(VerticalAlign.Center)
          .padding({ left: $r('app.float.column_padding'), top: $r('app.float.column_padding'), bottom: $r('app.float.column_padding') })
          .backgroundColor(Color.White)
          .bindSheet($$this.isShowSheet, this.mySheet(), {
            height: $r('app.float.bind_sheet_height'),
            dragBar: false,
            showClose: false
          })
          .onClick(() => {
            this.isShowSheet = !this.isShowSheet;
          })
        }
        .width(CommonConstants.ONE_HUNDRED_PERCENT)
      }
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .height(CommonConstants.ONE_HUNDRED_ELEVEN_PERCENT)
      .backgroundColor($r('app.color.color_background_bind'))
    }
    .title($r('app.string.bind_sheet_dialog'))
    .titleMode(NavigationTitleMode.Mini)
  }
}
