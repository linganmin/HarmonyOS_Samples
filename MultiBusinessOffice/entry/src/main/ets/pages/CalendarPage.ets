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

import { ItemRestriction, SegmentButtonTextItem, SegmentButton, SegmentButtonOptions } from '@kit.ArkUI';
import { CalendarView } from '../view/CalendarViewPage';
import { CalendarItem } from '../viewmodel/CalendarItem';
import { TripScheduleView } from '../view/TripSchedule';
import { CommonConstants } from '../constants/CommonConstants';
import { CalendarSideBarView } from '../view/CalendarSideBarView';

@Entry
@Component
struct CalendarPage {
  @StorageLink('thirdBreakPoint') breakPoint: string = '';
  @StorageLink('thirdWindowSize') windowSize: number = CommonConstants.COMMON_ZERO;
  @StorageLink('thirdWindowSizeHeight') windowSizeHeight: number = CommonConstants.COMMON_ZERO;
  @StorageLink('deviceType') deviceType: string = '';
  @StorageLink('sideBarStatus') sideBarStatus: boolean = this.deviceType === '2in1' ? true : false;
  @StorageLink('monthStatus') monthStatus: boolean = this.breakPoint === CommonConstants.BREAK_POINT_LG ? false : true;
  @StorageLink('navMode') navMode: NavigationMode = NavigationMode.Split;
  @StorageLink('selectedItem') selectedItem: CalendarItem = new CalendarItem('', '', false);
  @State singleSelectCapsuleOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.year') }, { text: $r('app.string.month') },
      { text: $r('app.string.week') }, { text: $r('app.string.day') }] as ItemRestriction<SegmentButtonTextItem>,
    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,
    backgroundColor: $r('app.color.window_background'),
    selectedBackgroundColor: $r('app.color.start_window_background')
  });
  @State singleSelectCapsuleSelectedIndexes: number[] = [1];
  @Provide('calendarPageInfos') calendarPageInfos: NavPathStack = new NavPathStack();

  @Builder
  pageMap(name: string, param: CalendarItem) {
    if (param.isTrip) {
      NavDestination() {
        Column() {
          Text(CommonConstants.TRIP_SCHEDULE_VIEW[0])
            .fontSize($r('app.float.font_size_title'))
            .fontWeight(FontWeight.Bold)
            .width(CommonConstants.FULL_PERCENT)
          Text(CommonConstants.TRIP_SCHEDULE_VIEW[1] + CommonConstants.TRIP_SCHEDULE_VIEW[2] + param.lunarDate)
            .fontSize($r('app.float.font_size_common'))
            .fontColor($r('app.color.font_color_gray'))
            .width(CommonConstants.FULL_PERCENT)
            .fontWeight(FontWeight.Regular)

          TripScheduleView()
        }
        .width(CommonConstants.FULL_PERCENT)
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        left: CommonConstants.COMMON_MARGIN,
        right: CommonConstants.COMMON_MARGIN
      })
      .backgroundColor($r('app.color.window_background'))
      .hideTitleBar(true)
    } else {
      NavDestination()
        .hideTitleBar(true)
    }
  }

  aboutToAppear(): void {
    this.navMode = NavigationMode.Stack;
  }

  build() {
    SideBarContainer(this.breakPoint === CommonConstants.BREAK_POINT_LG ? SideBarContainerType.Embed :
    SideBarContainerType.Overlay) {
      CalendarSideBarView()

      Stack() {
        if (this.breakPoint !== CommonConstants.BREAK_POINT_LG) {
          Column()
            .height(CommonConstants.FULL_PERCENT)
            .width(CommonConstants.FULL_PERCENT)
            .backgroundColor($r('app.color.sidebar_stack'))
            .zIndex(1)
            .visibility(this.sideBarStatus ? Visibility.Visible : Visibility.Hidden)
        }

        Column() {
          // [Start btn_change_navigation]
          Row() {
            // [StartExclude btn_change_navigation]
            Text(CommonConstants.TRIP_SCHEDULE_VIEW[3])
              .fontSize($r('app.float.symbol_font_size'))
              .lineHeight($r('app.float.line_height_or_top'))
              .fontWeight(FontWeight.Bold)

            Blank()
            // [EndExclude btn_change_navigation]

            if (this.breakPoint !== CommonConstants.BREAK_POINT_SM) {
              Column() {
                // [StartExclude btn_change_navigation]
                SegmentButton({
                  options: this.singleSelectCapsuleOptions,
                  selectedIndexes: $singleSelectCapsuleSelectedIndexes
                })
                // [EndExclude btn_change_navigation]
              }
              // [StartExclude btn_change_navigation]
              .width($r('app.float.navigation_width'))
              .height($r('app.float.image_size'))
              .padding({ top: $r('app.float.notes_c_margin') })

              Blank()

              Column() {
                SymbolGlyph($r('sys.symbol.thumbnails'))
                  .fontSize($r('app.float.symbol_font_size'))
                  .margin($r('app.float.margin_common'))
              }
              .width($r('app.float.image_size'))
              .height($r('app.float.image_size'))
              .borderRadius($r('app.float.border_radius_common'))
              .backgroundColor(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? '' :
              $r('app.color.background_gray'))
              .margin({ right: $r('app.float.margin_common') })
              // [EndExclude btn_change_navigation]
              .onClick(() => {
                if (this.navMode === NavigationMode.Split) {
                  this.navMode = NavigationMode.Stack;
                } else if (this.navMode === NavigationMode.Stack && this.selectedItem.isTrip) {
                  this.navMode = NavigationMode.Split;
                }
              })
            }
            // [StartExclude btn_change_navigation]
            Column() {
              SymbolGlyph($r('sys.symbol.plus'))
                .fontSize($r('app.float.symbol_font_size'))
                .margin($r('app.float.margin_common'))
            }
            .width($r('app.float.image_size'))
            .height($r('app.float.image_size'))
            .borderRadius($r('app.float.border_radius_common'))
            .backgroundColor(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? '' :
            $r('app.color.background_gray'))
            .margin({ right: $r('app.float.margin_common') })

            Column() {
              SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
                .fontSize($r('app.float.symbol_font_size'))
                .margin($r('app.float.margin_common'))
            }
            .width($r('app.float.image_size'))
            .height($r('app.float.image_size'))
            .borderRadius($r('app.float.border_radius_common'))
            .backgroundColor(this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? '' :
            $r('app.color.background_gray'))
          }
          .height($r('app.float.image_size'))
          .width(CommonConstants.FULL_PERCENT)
          .padding({
            left: (this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ||
              this.breakPoint !== CommonConstants.BREAK_POINT_LG) ? $r('app.float.margin_row_top') :
              (this.monthStatus ? $r('app.float.margin_row_top') : CommonConstants.COMMON_MARGIN),
            right: this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.float.margin_right') :
            CommonConstants.COMMON_MARGIN
          })
          .margin({
            top: this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? CommonConstants.COMMON_MARGIN :
            $r('app.float.margin_common'),
            bottom: CommonConstants.COMMON_MARGIN
          })

          if (this.breakPoint === CommonConstants.BREAK_POINT_SM) {
            Row() {
              Column() {
                SegmentButton({
                  options: this.singleSelectCapsuleOptions,
                  selectedIndexes: $singleSelectCapsuleSelectedIndexes
                })
              }
              .width(CommonConstants.FULL_PERCENT)
              .padding({
                left: CommonConstants.COMMON_MARGIN,
                right: CommonConstants.COMMON_MARGIN
              })
              .height($r('app.float.segment_button_height'))
            }
            .width(CommonConstants.FULL_PERCENT)
            .height($r('app.float.image_size'))
          }
          // [EndExclude btn_change_navigation]
          // [Start navigation_calendar_view]
          Navigation(this.calendarPageInfos) {
            CalendarView()
          }
          .navDestination(this.pageMap)
          .mode(this.breakPoint === CommonConstants.BREAK_POINT_SM ? NavigationMode.Stack : this.navMode)
          // [StartExclude btn_change_navigation]
          // [StartExclude navigation_calendar_view]
          .backgroundColor($r('app.color.window_background'))
          .layoutWeight(1)
          .width(CommonConstants.FULL_PERCENT)
          .navBarWidthRange([$r('app.float.nav_bar_width_range'), $r('app.string.eighty_percent')])
          .navBarWidth(this.breakPoint === CommonConstants.BREAK_POINT_LG ?
            this.windowSize - CommonConstants.SIDEBAR_WIDTH - CommonConstants.NOTES_SIDEBAR_WIDTH :
            this.windowSize - CommonConstants.CALENDAR_CONTENT_WIDTH)
          .hideTitleBar(true)
          // [EndExclude navigation_calendar_view]
          // [EndExclude btn_change_navigation]
          .onNavigationModeChange((mode: NavigationMode) => {
            if (this.breakPoint === CommonConstants.BREAK_POINT_SM || mode === NavigationMode.Stack) {
              this.calendarPageInfos.clear();
            } else if (mode === NavigationMode.Split) {
              this.calendarPageInfos.pushPath({ name: this.selectedItem.date, param: this.selectedItem }, false);
            }
          })

          // [End navigation_calendar_view]
          // [End btn_change_navigation]
        }
        .height(CommonConstants.FULL_PERCENT)
        .backgroundColor($r('app.color.window_background'))
        .padding({
          top: this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? CommonConstants.COMMON_ZERO :
          $r('app.float.navigation_margin_top')
        })
      }
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('app.color.window_background'))
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .controlButton({
      icons: {
        hidden: this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.media.close_sidebar') :
        $r('app.media.close_sidebar_bg'),
        shown: this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.media.open_sidebar') :
        $r('app.media.open_sidebar_bg'),
        switching: this.sideBarStatus ?
          (CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.media.open_sidebar') : $r('app.media.open_sidebar_bg')) :
          (CommonConstants.DEVICE_TYPE_2IN1 ? $r('app.media.close_sidebar') : $r('app.media.close_sidebar_bg'))
      },
      top: this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 ? CommonConstants.COMMON_MARGIN :
      CommonConstants.CONTROL_BUTTON_TOP,
      left: (this.deviceType === CommonConstants.DEVICE_TYPE_2IN1 && this.sideBarStatus) ?
      CommonConstants.CONTROL_BUTTON_LEFT : CommonConstants.COMMON_MARGIN,
      width: CommonConstants.CONTROL_BUTTON,
      height: CommonConstants.CONTROL_BUTTON
    })
    .showSideBar(this.breakPoint === CommonConstants.BREAK_POINT_LG ? true : false)
    .sideBarWidth(CommonConstants.SIDEBAR_WIDTH)
    .onChange((value: boolean) => {
      this.sideBarStatus = value;
      this.monthStatus = !value;
    })
    .backgroundColor($r('app.color.window_background'))
  }
}