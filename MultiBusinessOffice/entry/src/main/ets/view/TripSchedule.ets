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
import { TripData } from '../viewmodel/TripData';
import { common } from '@kit.AbilityKit';

@Component
export struct TripScheduleView {
  @StorageLink('thirdBreakPoint') breakPoint: string = '';
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    Column() {
      Scroll() {
        Column() {
          ForEach(CommonConstants.TRIP_SCHEDULE, (tripItem: TripData) => {
            Row() {
              Column() {
                Text(tripItem.startTime)
                  .fontSize($r('app.float.trip_content_font'))

                Row()
                  .border({
                    style: { left: BorderStyle.Solid },
                    color: { left: $r('sys.color.icon_fourth') },
                    width: { left: CommonConstants.COMMON_ONE }
                  })
                  .margin({ left: $r('app.float.trip_icon_margin') })
                  .height(CommonConstants.COMMON_SEVEN)
                  .width(CommonConstants.COMMON_ONE)
                Row()
                  .borderColor($r('app.color.purple'))
                  .borderRadius($r('app.float.trip_schedule_icon_radius'))
                  .borderWidth($r('app.float.trip_schedule_icon_width'))
                  .height(CommonConstants.COMMON_FIVE)
                  .width(CommonConstants.COMMON_FIVE)
                Row()
                  .border({
                    style: { left: BorderStyle.Solid },
                    color: { left: $r('sys.color.icon_fourth') },
                    width: { left: CommonConstants.COMMON_ONE }
                  })
                  .margin({ left: $r('app.float.trip_icon_margin') })
                  .height(CommonConstants.COMMON_SEVEN)
                  .width(CommonConstants.COMMON_ONE)

                Text(tripItem.endTime)
                  .fontSize($r('app.float.trip_content_font'))
                  .fontColor($r('app.color.font_color_gray'))
              }
              .width($r('app.float.trip_icon_width'))
              .margin({
                top: $r('app.float.trip_icon_margin_top'),
                left: $r('app.float.width_or_margin')
              })
              .height($r('app.float.trip_icon_height'))
              .justifyContent(FlexAlign.SpaceBetween)

              Column() {
                Row() {
                  Text() {
                    Span(tripItem.date + ' ')
                      .fontSize($r('app.float.common_font_size'))
                      .lineHeight($r('app.float.line_height_common'))
                      .fontWeight(FontWeight.Medium)
                    if (tripItem.conflicting) {
                      Span(' ' + this.context.resourceManager.getStringSync($r('app.string.trip_conflicting').id) + ' ')
                        .fontColor($r('app.color.start_window_background'))
                        .fontSize($r('app.float.trip_content_font'))
                        .lineHeight($r('app.float.line_height_common'))
                        .textBackgroundStyle({
                          color: $r('app.color.orange'),
                          radius: $r('app.float.trip_item_location_margin')
                        })
                    }
                  }
                  .maxLines(2)
                  .padding({
                    right: this.breakPoint === CommonConstants.BREAK_POINT_SM ? $r('app.float.trip_item_padding_sm') :
                    $r('app.float.trip_item_date_padding')
                  })
                  .width(CommonConstants.FULL_PERCENT)
                }
                .width(CommonConstants.FULL_PERCENT)
                .justifyContent(FlexAlign.Start)

                Row() {
                  Text(tripItem.location)
                    .fontSize($r('app.float.font_size_common'))
                    .lineHeight($r('app.float.common_line_height'))
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('app.color.font_color_gray'))
                }
                .margin({ top: $r('app.float.trip_item_location_margin') })
                .width(CommonConstants.FULL_PERCENT)
                .justifyContent(FlexAlign.Start)
              }
              .margin({ left: $r('app.float.width_or_margin') })
              .layoutWeight(CommonConstants.COMMON_ONE)
              .height(CommonConstants.FULL_PERCENT)
              .justifyContent(FlexAlign.Center)
            }
            .margin({ bottom: $r('app.float.day_button_radius') })
            .backgroundColor($r('app.color.start_window_background'))
            .height($r('app.float.trip_height'))
            .width(CommonConstants.FULL_PERCENT)
            .borderRadius($r('app.float.border_radius_entry'))
            .justifyContent(FlexAlign.Start)
          }, (tripItem: TripData) => JSON.stringify(tripItem))
        }
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.float.trip_schedule_height'))
        .justifyContent(FlexAlign.Start)
      }
      .scrollBar(BarState.Off)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(this.breakPoint === CommonConstants.BREAK_POINT_SM ? $r('app.float.calendar_height') :
    CommonConstants.FULL_PERCENT)
  }
}