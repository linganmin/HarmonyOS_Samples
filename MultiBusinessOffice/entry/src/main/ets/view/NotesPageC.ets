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
export struct NotesPageC {
  @StorageLink('secondBreakPoint') breakPoint: string = '';
  @StorageLink('deviceType') deviceType: string = '';
  @StorageLink('notesNavMode') notesNavMode: NavigationMode = NavigationMode.Split;
  @StorageLink('arrowStatus') arrowStatus: boolean = true;
  @StorageLink('sideBarStatus') sideBarStatus: boolean = true;
  @StorageLink('sideBarIsShown') sideBarIsShown: boolean = true;
  @StorageLink('notesPageInfos') notesPageInfos: NavPathStack = new NavPathStack();
  @State hoverBgcolor: Resource | string = '';
  itemsTitle: string = '';

  build() {
    Column() {
      // [Start notes_nav_mode_change_navigation]
      Row() {
        if (this.arrowStatus && this.breakPoint !== CommonConstants.BREAK_POINT_SM) {
          Column() {
            // [StartExclude notes_nav_mode_change_navigation]
            SymbolGlyph($r('sys.symbol.arrow_up_left_and_arrow_down_right'))
              .fontSize($r('app.float.symbol_font_size'))
              .margin($r('app.float.margin_common'))
            // [EndExclude notes_nav_mode_change_navigation]
          }
          // [StartExclude notes_nav_mode_change_navigation]
          .width($r('app.float.image_size'))
          .height($r('app.float.image_size'))
          .borderRadius(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.margin_common') :
          $r('app.float.border_radius_common'))
          .backgroundColor(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? this.hoverBgcolor :
          $r('app.color.background_gray'))
          // [EndExclude notes_nav_mode_change_navigation]
          .onClick(() => {
            this.notesNavMode = NavigationMode.Stack;
            this.arrowStatus = false;
            this.sideBarIsShown = false;
          })
          // [StartExclude notes_nav_mode_change_navigation]
          .onHover((isHover: boolean) => {
            if (isHover) {
              this.hoverBgcolor = $r('sys.color.interactive_hover');
            } else {
              this.hoverBgcolor = '';
            }
          })

          // [EndExclude notes_nav_mode_change_navigation]
        } else {
          Column() {
            // [StartExclude notes_nav_mode_change_navigation]
            SymbolGlyph($r('sys.symbol.arrow_down_right_and_arrow_up_left'))
              .fontSize($r('app.float.symbol_font_size'))
              .margin($r('app.float.margin_common'))
            // [EndExclude notes_nav_mode_change_navigation]
          }
          // [StartExclude notes_nav_mode_change_navigation]
          .width($r('app.float.image_size'))
          .height($r('app.float.image_size'))
          .borderRadius(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.margin_common') :
          $r('app.float.border_radius_common'))
          .backgroundColor(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? this.hoverBgcolor :
          $r('app.color.background_gray'))
          // [EndExclude notes_nav_mode_change_navigation]
          .onClick(() => {
            if (this.breakPoint === CommonConstants.BREAK_POINT_SM) {
              this.notesPageInfos.pop();
            } else {
              this.notesNavMode = NavigationMode.Split;
              this.arrowStatus = true;
            }
            this.sideBarIsShown = true;
            if (this.breakPoint === CommonConstants.BREAK_POINT_LG) {
              this.sideBarStatus = true;
            }
          })
          // [StartExclude notes_nav_mode_change_navigation]
          .onHover((isHover: boolean) => {
            if (isHover) {
              this.hoverBgcolor = $r('sys.color.interactive_hover');
            } else {
              this.hoverBgcolor = '';
            }
          })

          // [EndExclude notes_nav_mode_change_navigation]
        }
        // [StartExclude notes_nav_mode_change_navigation]
        if (this.breakPoint === CommonConstants.BREAK_POINT_LG) {
          Blank()
          Column() {
            SymbolGlyph($r('sys.symbol.share'))
              .fontSize($r('app.float.symbol_font_size'))
              .margin($r('app.float.margin_common'))
          }
          .width($r('app.float.image_size'))
          .height($r('app.float.image_size'))
          .borderRadius($r('app.float.border_radius_common'))
          .backgroundColor(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? '' : $r('app.color.background_gray'))
          .margin({ right: $r('app.float.margin_common') })

          Column() {
            SymbolGlyph($r('sys.symbol.star'))
              .fontSize($r('app.float.symbol_font_size'))
              .margin($r('app.float.margin_common'))
          }
          .width($r('app.float.image_size'))
          .height($r('app.float.image_size'))
          .borderRadius($r('app.float.border_radius_common'))
          .backgroundColor(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? '' : $r('app.color.background_gray'))
          .margin({ right: $r('app.float.margin_common') })

          Column() {
            SymbolGlyph($r('sys.symbol.ohos_trash'))
              .fontSize($r('app.float.symbol_font_size'))
              .margin($r('app.float.margin_common'))
          }
          .width($r('app.float.image_size'))
          .height($r('app.float.image_size'))
          .borderRadius($r('app.float.border_radius_common'))
          .backgroundColor(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? '' : $r('app.color.background_gray'))
          .margin({ right: $r('app.float.margin_common') })

          Column() {
            SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
              .fontSize($r('app.float.symbol_font_size'))
              .margin($r('app.float.margin_common'))
          }
          .width($r('app.float.image_size'))
          .height($r('app.float.image_size'))
          .borderRadius($r('app.float.border_radius_common'))
          .backgroundColor(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? '' : $r('app.color.background_gray'))
          .margin({
            right: this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.margin_right') :
            $r('app.float.notes_descriptions_margin')
          })
        }
        // [EndExclude notes_nav_mode_change_navigation]
      }
      // [End notes_nav_mode_change_navigation]
      .height($r('app.float.image_size'))
      .width(CommonConstants.FULL_PERCENT)
      .margin({
        top: $r('app.float.width_or_margin'),
        left: $r('app.float.notes_descriptions_margin'),
        bottom: $r('app.float.width_or_margin')
      })

      Text(this.itemsTitle)
        .fontSize($r('app.float.symbol_font_size'))
        .lineHeight($r('app.float.line_height_or_top'))
        .fontWeight(FontWeight.Bold)
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          left: $r('app.float.notes_descriptions_margin'),
          right: $r('app.float.notes_descriptions_margin')
        })
        .constraintSize({ maxWidth: $r('app.float.notes_content_max_width') })

      Row() {
        Column() {
          Row() {
            Text(CommonConstants.NOTES_CONTENT[0])
              .fontSize($r('app.float.trip_content_font'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.start_window_background'))
              .lineHeight($r('app.float.height_or_line_height'))
              .margin({ left: $r('app.float.margin_common') })

            SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
              .fontSize($r('app.float.select_icon'))
              .fontColor([$r('app.color.start_window_background')])
              .margin($r('app.float.margin_common'))
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
        }
        .backgroundColor($r('app.color.notes_sidebar_color'))
        .width($r('app.float.content_width'))
        .height($r('app.float.button_image_size'))
        .borderRadius($r('app.float.border_radius_common'))

        Column() {
          Text(CommonConstants.NOTES_CONTENT[1])
            .fontSize($r('app.float.font_size_common'))
            .lineHeight($r('app.float.common_line_height'))
            .fontWeight(FontWeight.Regular)
            .width(CommonConstants.FULL_PERCENT)
            .margin({ left: $r('app.float.margin_common') })
        }
        .width(CommonConstants.FULL_PERCENT)
      }
      .padding({
        top: $r('app.float.margin_common'),
        left: $r('app.float.notes_descriptions_margin'),
        bottom: $r('app.float.margin_bottom')
      })
      .width(CommonConstants.FULL_PERCENT)
      .constraintSize({ maxWidth: $r('app.float.notes_content_max_width') })

      Row() {
        Text(this.itemsTitle === 'Yesterday Once More' ? CommonConstants.NOTES_ENGLISH_CONTENT :
        CommonConstants.NOTES_CONTENT[2])
          .fontSize($r('app.float.common_font_size'))
          .lineHeight($r('app.float.line_height_common'))
          .fontWeight(FontWeight.Regular)
          .margin({
            right: CommonConstants.COMMON_MARGIN,
            left: $r('app.float.notes_descriptions_margin'),
            bottom: $r('app.float.margin_common')
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .constraintSize({ maxWidth: $r('app.float.notes_content_max_width') })

      Row() {
        Image($r('app.media.notes_image'))
          .width(CommonConstants.FULL_PERCENT)
          .objectFit(ImageFit.Contain)
          .constraintSize({ maxWidth: $r('app.float.notes_image_max_width') })
      }
      .padding({
        right: $r('app.float.notes_descriptions_margin'),
        left: $r('app.float.notes_descriptions_margin'),
        bottom: $r('app.float.margin_common')
      })
      .width(CommonConstants.FULL_PERCENT)
      .constraintSize({ maxWidth: $r('app.float.notes_content_max_width') })

      Blank()

      if (this.breakPoint !== CommonConstants.BREAK_POINT_LG) {
        Row() {
          Column() {
            SymbolGlyph($r('sys.symbol.share'))
              .fontSize($r('app.float.symbol_font_size'))
            Text(CommonConstants.NOTES_CONTENT[3])
              .fontSize($r('app.float.notes_content_font'))
              .lineHeight($r('app.float.notes_icon_line_height'))
              .fontWeight(FontWeight.Medium)
              .margin({ top: $r('app.float.notes_c_margin') })
          }

          Column() {
            SymbolGlyph($r('sys.symbol.star'))
              .fontSize($r('app.float.symbol_font_size'))
            Text(CommonConstants.NOTES_CONTENT[4])
              .fontSize($r('app.float.notes_content_font'))
              .lineHeight($r('app.float.notes_icon_line_height'))
              .fontWeight(FontWeight.Medium)
              .margin({ top: $r('app.float.notes_c_margin') })
          }

          Column() {
            SymbolGlyph($r('sys.symbol.ohos_trash'))
              .fontSize($r('app.float.symbol_font_size'))
            Text(CommonConstants.NOTES_CONTENT[5])
              .fontSize($r('app.float.notes_content_font'))
              .lineHeight($r('app.float.notes_icon_line_height'))
              .fontWeight(FontWeight.Medium)
              .margin({ top: $r('app.float.notes_c_margin') })
          }

          Column() {
            SymbolGlyph($r('sys.symbol.square_grid_2x2'))
              .fontSize($r('app.float.symbol_font_size'))
            Text(CommonConstants.NOTES_CONTENT[6])
              .fontSize($r('app.float.notes_content_font'))
              .lineHeight($r('app.float.notes_icon_line_height'))
              .fontWeight(FontWeight.Medium)
              .margin({ top: $r('app.float.notes_c_margin') })
          }
        }
        .margin({ bottom: $r('app.float.notes_content_button_margin') })
        .justifyContent(FlexAlign.SpaceAround)
        .width(CommonConstants.FULL_PERCENT)
      }
    }
    .padding({
      top: this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? CommonConstants.COMMON_ZERO :
      $r('app.float.navigation_margin_top')
    })
    .justifyContent(FlexAlign.Start)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}