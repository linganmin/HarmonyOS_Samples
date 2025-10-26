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

import { CommonConstants } from '../constants/CommonConstants';

@Component
export struct CalendarSideBarView {
  @StorageLink('deviceType') deviceType: string = '';

  build() {
    Column() {
      if (this.deviceType === CommonConstants.DEVICE_TYPE_2IN1) {
        Row() {
          Image($r('app.media.calendar'))
            .width($r('app.float.button_image_size'))
            .height($r('app.float.button_image_size'))
            .margin({ right: $r('app.float.width_or_margin') })
          Text(CommonConstants.CALENDAR_SIDE_BAR_TEXT[0])
            .fontSize($r('app.float.sub_title_font'))
            .lineHeight($r('app.float.text_line_height'))
            .fontWeight(FontWeight.Medium)
        }
        .position({
          x: $r('app.float.position_x'),
          y: $r('app.float.margin_common_top')
        })
      }
      Row() {
        Text(CommonConstants.CALENDAR_SIDE_BAR_TEXT[1])
          .fontSize($r('app.float.sub_title_font'))
          .lineHeight($r('app.float.text_line_height'))
          .fontWeight(FontWeight.Bold)

        Text(CommonConstants.CALENDAR_SIDE_BAR_TEXT[2])
          .fontSize($r('app.float.font_size_common'))
          .lineHeight($r('app.float.common_line_height'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.orange'))
      }
      .width(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_width_2in1') :
      $r('app.float.sidebar_row_width'))
      .height(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_height_2in1') :
      $r('app.float.notes_list_image'))
      .margin({
        top: $r('app.float.notes_list_height')
      })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text(CommonConstants.CALENDAR_SIDE_BAR_TEXT[3])
          .fontSize($r('app.float.font_size_common'))
          .lineHeight($r('app.float.common_line_height'))
          .fontWeight(FontWeight.Medium)
      }
      .width(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_width_2in1') :
      $r('app.float.sidebar_row_width'))
      .height(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_height_2in1') :
      $r('app.float.image_size'))
      .justifyContent(FlexAlign.SpaceBetween)

      Column() {
        Row() {
          Column() {
            SymbolGlyph($r('sys.symbol.checkmark'))
              .fontSize($r('app.float.common_font_size'))
              .fontColor([$r('app.color.start_window_background')])
          }
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.orange'))
          .width($r('app.float.common_height_line_height'))
          .height($r('app.float.common_height_line_height'))
          .borderRadius($r('app.float.sidebar_border_radius'))

          Text(CommonConstants.CALENDAR_SIDE_BAR_TEXT[4])
            .fontSize($r('app.float.common_font_size'))
            .lineHeight($r('app.float.common_height_line_height'))
            .margin({ left: $r('app.float.sidebar_margin_left') })
            .fontWeight(FontWeight.Medium)
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.Start)

        Row() {
          Column() {
            SymbolGlyph($r('sys.symbol.checkmark'))
              .fontSize($r('app.float.common_font_size'))
              .fontColor([$r('app.color.start_window_background')])
          }
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.gray'))
          .width($r('app.float.common_height_line_height'))
          .height($r('app.float.common_height_line_height'))
          .borderRadius($r('app.float.sidebar_border_radius'))

          Text(CommonConstants.CALENDAR_SIDE_BAR_TEXT[5])
            .fontSize($r('app.float.common_font_size'))
            .lineHeight($r('app.float.common_height_line_height'))
            .margin({ left: $r('app.float.sidebar_margin_left') })
            .fontWeight(FontWeight.Medium)
        }
        .margin({ top: $r('app.float.margin_entry_title') })
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.Start)
      }
      .width(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_width_2in1') :
      $r('app.float.sidebar_row_width'))
      .height(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_group_height') :
      $r('app.float.sidebar_group_height_not2i1'))

      Row() {
        Text(CommonConstants.CALENDAR_SIDE_BAR_TEXT[6])
          .fontSize($r('app.float.font_size_common'))
          .lineHeight($r('app.float.common_line_height'))
          .fontWeight(FontWeight.Medium)
      }
      .width(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_width_2in1') :
      $r('app.float.sidebar_row_width'))
      .height(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_height_2in1') :
      $r('app.float.image_size'))
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Column() {
          SymbolGlyph($r('sys.symbol.checkmark'))
            .fontSize($r('app.float.common_font_size'))
            .fontColor([$r('app.color.start_window_background')])
        }
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.purple'))
        .width($r('app.float.common_height_line_height'))
        .height($r('app.float.common_height_line_height'))
        .borderRadius($r('app.float.sidebar_border_radius'))

        Text(CommonConstants.CALENDAR_SIDE_BAR_TEXT[7])
          .fontSize($r('app.float.common_font_size'))
          .lineHeight($r('app.float.common_height_line_height'))
          .margin({ left: $r('app.float.sidebar_margin_left') })
          .fontWeight(FontWeight.Medium)
      }
      .width(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_width_2in1') :
      $r('app.float.sidebar_row_width'))
      .height($r('app.float.sidebar_height_2in1'))
      .justifyContent(FlexAlign.Start)

      Row() {
        Text(CommonConstants.CALENDAR_SIDE_BAR_TEXT[8])
          .fontSize($r('app.float.sub_title_font'))
          .lineHeight($r('app.float.text_line_height'))
          .fontWeight(FontWeight.Bold)

        Text(CommonConstants.CALENDAR_SIDE_BAR_TEXT[9])
          .fontSize($r('app.float.font_size_common'))
          .lineHeight($r('app.float.common_line_height'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.orange'))
      }
      .width(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_width_2in1') :
      $r('app.float.sidebar_row_width'))
      .height(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_height_2in1') :
      $r('app.float.notes_list_image'))
      .justifyContent(FlexAlign.SpaceBetween)

      Column() {
        Row() {
          Column() {
            Row()
              .border({
                width: CommonConstants.COMMON_ONE,
                radius: $r('app.float.day_button_radius')
              })
              .width($r('app.float.border_radius_common'))
              .height($r('app.float.border_radius_common'))
          }
          .justifyContent(FlexAlign.Center)
          .width($r('app.float.common_height_line_height'))
          .height($r('app.float.common_height_line_height'))
          .borderRadius($r('app.float.sidebar_border_radius'))

          Text(CommonConstants.CALENDAR_SIDE_BAR_TEXT[10])
            .fontSize($r('app.float.common_font_size'))
            .lineHeight($r('app.float.common_height_line_height'))
            .margin({ left: $r('app.float.sidebar_margin_left') })
            .fontWeight(FontWeight.Medium)
        }
        .width(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_width_2in1') :
        $r('app.float.sidebar_row_width'))
        .height(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_height_2in1') :
        $r('app.float.image_size'))
        .justifyContent(FlexAlign.Start)

        Row() {
          Column() {
            Row()
              .border({
                width: CommonConstants.COMMON_ONE,
                radius: $r('app.float.day_button_radius')
              })
              .width($r('app.float.border_radius_common'))
              .height($r('app.float.border_radius_common'))
          }
          .justifyContent(FlexAlign.Center)
          .width($r('app.float.common_height_line_height'))
          .height($r('app.float.common_height_line_height'))
          .borderRadius($r('app.float.sidebar_border_radius'))

          Text(CommonConstants.CALENDAR_SIDE_BAR_TEXT[11])
            .fontSize($r('app.float.common_font_size'))
            .lineHeight($r('app.float.common_height_line_height'))
            .margin({ left: $r('app.float.sidebar_margin_left') })
            .fontWeight(FontWeight.Medium)
        }
        .width(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_width_2in1') :
        $r('app.float.sidebar_row_width'))
        .height(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.image_size') :
        $r('app.float.sidebar_height_2in1'))
        .justifyContent(FlexAlign.Start)
      }
      .width($r('app.float.sidebar_width_not_lg'))

      Row() {
        Text(CommonConstants.CALENDAR_SIDE_BAR_TEXT[12])
          .fontSize($r('app.float.sub_title_font'))
          .lineHeight($r('app.float.text_line_height'))
          .fontWeight(FontWeight.Bold)
      }
      .width(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_width_2in1') :
      $r('app.float.sidebar_row_width'))
      .height(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_height_2in1') :
      $r('app.float.notes_list_image'))
      .justifyContent(FlexAlign.Start)

      Column() {
        Row() {
          Text(CommonConstants.CALENDAR_SIDE_BAR_TEXT[13])
            .fontSize($r('app.float.common_font_size'))
            .lineHeight($r('app.float.common_height_line_height'))
            .fontWeight(FontWeight.Medium)
          Image($r('app.media.next'))
            .width($r('app.float.width_or_margin'))
            .height($r('app.float.button_image_size'))
        }
        .width(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_width_2in1') :
        $r('app.float.sidebar_row_width'))
        .height(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.image_size') :
        $r('app.float.sidebar_height_2in1'))
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text(CommonConstants.CALENDAR_SIDE_BAR_TEXT[14])
            .fontSize($r('app.float.common_font_size'))
            .lineHeight($r('app.float.common_height_line_height'))
            .fontWeight(FontWeight.Medium)
          Image($r('app.media.next'))
            .width($r('app.float.width_or_margin'))
            .height($r('app.float.button_image_size'))
        }
        .width(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_width_2in1') :
        $r('app.float.sidebar_row_width'))
        .height(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.image_size') :
        $r('app.float.sidebar_height_2in1'))
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.sidebar_width_2in1') :
      $r('app.float.sidebar_row_width'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.window_background'))
    .padding({
      top: this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? CommonConstants.COMMON_ZERO :
      $r('app.float.navigation_margin_top')
    })
  }
}