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
import { CalendarItem } from '../viewmodel/CalendarItem';
import { TripScheduleView } from './TripSchedule';

@Component
export struct CalendarView {
  @StorageLink('thirdBreakPoint') breakPoint: string = '';
  @StorageLink('thirdWindowSizeHeight') windowSizeHeight: number = CommonConstants.COMMON_ZERO;
  @StorageLink('navMode') navMode: NavigationMode = NavigationMode.Split;
  @StorageLink('selectedItem') selectedItem: CalendarItem = new CalendarItem('', '', false);
  @Consume('calendarPageInfos') calendarPageInfos: NavPathStack;
  @State startTime: number = CommonConstants.START_TIME;
  @State stopTime: number = CommonConstants.START_TIME;
  @State selected: number = -1;
  @State isTrip: boolean = false;
  @State day: ResourceStr = '';

  build() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          Column() {
            Row() {
              Grid() {
                ForEach(CommonConstants.WEEK_MESSAGE, (weekInfo: string, index: number) => {
                  GridItem() {
                    Column() {
                      Text(weekInfo)
                        .fontColor((index === CommonConstants.COMMON_ZERO || index === CommonConstants.COMMON_SIX) ?
                        $r('app.color.font_color_gray') : $r('app.color.black'))
                        .font({
                          size: $r('app.float.trip_content_font'),
                          weight: FontWeight.Medium
                        })
                        .lineHeight($r('app.float.height_or_line_height'))
                        .textAlign(TextAlign.Center)
                    }
                    .justifyContent(FlexAlign.Center)
                    .width($r('app.float.grid_item_width'))
                    .height($r('app.float.height_or_line_height'))
                  }
                }, (weekInfo: string) => JSON.stringify(weekInfo))
              }
              .height(CommonConstants.FULL_PERCENT)
              .width(CommonConstants.FULL_PERCENT)
              .columnsTemplate(CommonConstants.GRID_COLUMN_TEMPLATE)
            }
            .height(this.breakPoint === CommonConstants.BREAK_POINT_SM ? $r('app.float.weeks_height') :
            $r('app.float.notes_list_image'))
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ top: $r('app.float.weeks_margin_top') })

            Grid() {
              ForEach(CommonConstants.CALENDAR_TIME_MESSAGE, (dateItem: CalendarItem, temp: number) => {
                GridItem() {
                  Column() {
                    if (this.breakPoint !== CommonConstants.BREAK_POINT_SM) {
                      Column() {
                        Text(dateItem.date)
                          .font({
                            size: $r('app.float.sub_title_font'),
                            weight: CommonConstants.FONT_WEIGHT_500
                          })
                          .fontColor(dateItem.isAug ? $r('app.color.font_color_gray') :
                            (this.selected === temp ? $r('app.color.start_window_background') :
                              ((temp % CommonConstants.COMMON_SEVEN === CommonConstants.COMMON_ZERO ||
                                (temp + CommonConstants.COMMON_ONE) % CommonConstants.COMMON_SEVEN ===
                                CommonConstants.COMMON_ZERO || temp === CommonConstants.COMMON_ZERO) ?
                              $r('app.color.font_color_gray') : $r('app.color.black'))))
                        Text(dateItem.lunarDate)
                          .font({
                            size: $r('app.float.notes_content_font'),
                            weight: CommonConstants.FONT_WEIGHT_400
                          })
                          .fontColor(dateItem.isAug ? $r('app.color.font_color_gray') :
                            (this.selected === temp ? $r('app.color.start_window_background') :
                              ((temp % CommonConstants.COMMON_SEVEN === CommonConstants.COMMON_ZERO ||
                                (temp + CommonConstants.COMMON_ONE) % CommonConstants.COMMON_SEVEN ===
                                CommonConstants.COMMON_ZERO || temp === CommonConstants.COMMON_ZERO) ?
                              $r('app.color.font_color_gray') : $r('app.color.black'))))
                        Row()
                          .width($r('app.float.notes_c_margin'))
                          .height($r('app.float.notes_c_margin'))
                          .borderRadius($r('app.float.common_margin_width'))
                          .backgroundColor(dateItem.isAug ? $r('app.color.start_window_background') :
                            (dateItem.isTrip ? (this.selected === temp ? $r('app.color.start_window_background') :
                            $r('app.color.orange')) : (this.selected === temp ?
                            $r('app.color.orange') : $r('app.color.start_window_background'))))
                      }
                      .backgroundColor(dateItem.isAug ? (this.breakPoint === CommonConstants.BREAK_POINT_SM ? '' :
                      $r('app.color.start_window_background')) : (this.selected === temp ?
                      $r('app.color.orange') : $r('app.color.start_window_background')))
                      .borderRadius($r('app.float.schedule_border_radius'))
                      .justifyContent(FlexAlign.Center)
                      .width($r('app.float.schedule_size'))
                      .height($r('app.float.schedule_size'))
                      .onClick(() => {
                        if (!dateItem.isAug) {
                          this.selected = temp;
                          this.selectedItem = dateItem;
                          if (dateItem.isTrip && this.breakPoint !== CommonConstants.BREAK_POINT_SM) {
                            this.navMode = NavigationMode.Split;
                            this.calendarPageInfos.replacePath({ name: dateItem.date, param: dateItem }, false);
                          } else {
                            this.navMode = NavigationMode.Stack;
                            this.calendarPageInfos.clear();
                          }
                        }
                        if (dateItem.isTrip) {
                          this.isTrip = true;
                          this.day = dateItem.lunarDate;
                        } else {
                          this.isTrip = false;
                        }
                      })

                      if (dateItem.isTrip) {
                        ForEach(CommonConstants.TRIP_LIST, (tripItem: number) => {
                          Row() {
                            Text($r('app.string.trip_content'))
                              .maxLines(1)
                              .textOverflow({ overflow: TextOverflow.Ellipsis })
                              .fontColor($r('app.color.purple'))
                              .fontSize($r('app.float.trip_content_font'))
                              .lineHeight($r('app.float.height_or_line_height'))
                              .fontWeight(FontWeight.Medium)
                              .margin({ left: $r('app.float.common_margin_width') })
                          }
                          .width($r('app.float.content_width'))
                          .height($r('app.float.height_or_line_height'))
                          .borderRadius($r('app.float.notes_c_margin'))
                          .margin($r('app.float.common_margin_width'))
                          .border({
                            style: { left: BorderStyle.Solid },
                            color: { left: $r('app.color.purple') },
                            width: { left: $r('app.float.common_margin_width') }
                          })
                          .backgroundColor($r('app.color.trip_background_color'))
                        }, (tripItem: number) => JSON.stringify(tripItem))
                      }
                    } else {
                      Column() {
                        Text(dateItem.date)
                          .font({
                            size: $r('app.float.sub_title_font'),
                            weight: CommonConstants.FONT_WEIGHT_500
                          })
                          .fontColor(dateItem.isAug ? $r('app.color.font_color_gray') :
                            (this.selected === temp ? $r('app.color.start_window_background') :
                              ((temp % CommonConstants.COMMON_SEVEN === CommonConstants.COMMON_ZERO ||
                                (temp + CommonConstants.COMMON_ONE) % CommonConstants.COMMON_SEVEN ===
                                CommonConstants.COMMON_ZERO || temp === CommonConstants.COMMON_ZERO) ?
                              $r('app.color.font_color_gray') : $r('app.color.black'))))
                        Text(dateItem.lunarDate)
                          .font({
                            size: $r('app.float.notes_content_font'),
                            weight: CommonConstants.FONT_WEIGHT_400
                          })
                          .fontColor(dateItem.isAug ? $r('app.color.font_color_gray') :
                            (this.selected === temp ? $r('app.color.start_window_background') :
                              ((temp % CommonConstants.COMMON_SEVEN === CommonConstants.COMMON_ZERO ||
                                (temp + CommonConstants.COMMON_ONE) % CommonConstants.COMMON_SEVEN ===
                                CommonConstants.COMMON_ZERO || temp === CommonConstants.COMMON_ZERO) ?
                              $r('app.color.font_color_gray') : $r('app.color.black'))))
                        Row()
                          .width($r('app.float.notes_c_margin'))
                          .height($r('app.float.notes_c_margin'))
                          .borderRadius($r('app.float.common_margin_width'))
                          .backgroundColor(dateItem.isAug ? '' : (dateItem.isTrip ? (this.selected === temp ?
                          $r('app.color.start_window_background') : $r('app.color.orange')) :
                            (this.selected === temp ? $r('app.color.orange') : '')))
                      }
                      .backgroundColor(dateItem.isAug ? '' : (this.selected === temp ? $r('app.color.orange') : ''))
                      .borderRadius($r('app.float.schedule_border_radius'))
                      .justifyContent(FlexAlign.Center)
                      .width($r('app.float.schedule_size'))
                      .height($r('app.float.schedule_size'))
                      .onClick(() => {
                        if (!dateItem.isAug) {
                          this.selected = temp;
                          this.selectedItem = dateItem;
                          if (dateItem.isTrip) {
                            this.isTrip = true;
                            this.day = dateItem.lunarDate;
                          } else {
                            this.isTrip = false;
                          }
                        }
                      })
                    }
                  }
                }
                .align(Alignment.Top)
              }, (dateItem: CalendarItem) => JSON.stringify(dateItem))
            }
            .width(CommonConstants.FULL_PERCENT)
            .columnsTemplate(CommonConstants.GRID_COLUMN_TEMPLATE)
            .rowsTemplate(CommonConstants.GRID_ROW_TEMPLATE)
          }
          .backgroundColor(this.breakPoint === CommonConstants.BREAK_POINT_SM ? '' :
          $r('app.color.start_window_background'))
          .width(CommonConstants.FULL_PERCENT)
          .height(this.breakPoint === CommonConstants.BREAK_POINT_SM ? $r('app.float.calendar_height') :
          CommonConstants.FULL_PERCENT)
          .borderRadius($r('app.float.height_or_line_height'))
          .margin({
            bottom: $r('app.float.day_button_radius'),
            left: CommonConstants.COMMON_MARGIN,
            right: CommonConstants.COMMON_MARGIN
          })

          if (this.breakPoint === CommonConstants.BREAK_POINT_SM && this.isTrip) {
            Column() {
              Row() {
                Text(CommonConstants.TRIP_SCHEDULE_VIEW[0])
                  .fontSize($r('app.float.common_font_size'))
                  .lineHeight($r('app.float.line_height_common'))
                  .fontWeight(FontWeight.Bold)
                Text(CommonConstants.TRIP_SCHEDULE_VIEW[1] + CommonConstants.TRIP_SCHEDULE_VIEW[2] + this.day)
                  .fontSize($r('app.float.trip_content_font'))
                  .lineHeight($r('app.float.height_or_line_height'))
                  .fontColor($r('app.color.font_color_gray'))
                  .fontWeight(FontWeight.Regular)
                  .margin({ left: $r('app.float.margin_common') })
              }
              .width($r('app.float.navigation_width'))
              .margin({
                top: $r('app.float.trip_margin_top'),
                bottom: $r('app.float.common_height_line_height')
              })

              TripScheduleView()
            }
          }
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .padding({
      left: CommonConstants.COMMON_MARGIN,
      right: CommonConstants.COMMON_MARGIN,
      bottom: AppStorage.get('naviIndicatorHeight') as number
    })
    .backgroundColor($r('app.color.window_background'))
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}