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

import { map } from '@kit.MapKit';
import { BreakpointConstants, BreakpointType, Common } from '@ohos/commons/Index';
import { RouteConstants } from '../constants/RouteConstants';
import { RouteTabView } from './RouteTabView';

@Component
export struct RoutePlanView {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_MD;
  @StorageLink('isShowBack') isShowBack: boolean = false;
  @StorageLink('isOnShowRoute') isOnShowRoute: boolean = false;
  @StorageLink('terminalPoint') terminalPoint: string = '';
  @Consume('pageInfo') pageInfo: NavPathStack;
  @Link mapController: map.MapComponentController;
  @Link columnHeight: number;

  aboutToAppear(): void {
    this.isShowBack = true;
    this.isOnShowRoute = true;
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.back'))
                .width($r('app.float.button_back_icon'))
            }
            .width($r('app.float.button_back'))
            .height($r('app.float.button_back'))
            .backgroundColor($r('app.color.back_button'))
            .visibility((this.columnHeight === AppStorage.get('columnMaxHeight') ||
              this.columnHeight === Common.HEIGHT_MD) ? Visibility.Visible : Visibility.None)
            .onClick(() => {
              this.pageInfo.pop();
              this.mapController.clear();
            })

            Row() {
              Image($r('app.media.meadress'))
                .height($r('app.float.meadress_height'))
                .width($r('app.float.meadress_width'))
                .margin({ left: $r('app.float.meadress_margin') })

              Column() {
                TextInput({ placeholder: $r('app.string.my_location') })
                  .backgroundColor($r('app.color.input_area'))
                  .height($r('app.float.text_input_height'))

                Divider()
                  .strokeWidth(RouteConstants.STROKE_WIDTH)
                  .lineCap(LineCapStyle.Round)
                  .margin({ left: $r('app.float.divider_margin') })

                TextInput({
                  placeholder: $r('app.string.input_terminal_point'),
                  text: this.terminalPoint
                })
                  .backgroundColor($r('app.color.input_area'))
                  .height($r('app.float.text_input_height'))
                  .enableKeyboardOnFocus(false)
              }
              .width(RouteConstants.TEXT_INPUT_WIDTH)

              Image($r('app.media.add'))
                .width($r('app.float.small_icon_size'))
              Image($r('app.media.change'))
                .width($r('app.float.small_icon_size'))
              Image($r('app.media.micro'))
                .width($r('app.float.small_icon_size'))
            }
            .width(Common.FULL_WIDTH)
            .backgroundColor($r('app.color.input_area'))
            .borderRadius($r('app.float.input_area_border'))
            .layoutWeight(1)
            .justifyContent(FlexAlign.SpaceAround)
            .margin({
              left: this.columnHeight > Common.HEIGHT_MIDDLE ?
                $r('app.float.input_area_margin_left') : $r('app.float.input_area_left')
            })
          }
          .alignItems(VerticalAlign.Top)
          .width(Common.FULL_WIDTH)
          .height($r('app.float.input_area_height'))

          RouteTabView({
            mapController: this.mapController,
            columnHeight: this.columnHeight
          })
        }
        .alignItems(HorizontalAlign.Start)
        .width(Common.FULL_WIDTH)
        .height(RouteConstants.TAB_AREA_WIDTH)
        .padding({
          left: $r('app.float.input_area_padding'),
          right: $r('app.float.input_area_padding')
        })

        Row() {
          Column() {
            Image($r('app.media.favor'))
              .height($r('app.float.choose_height'))
            Text($r('app.string.favor'))
              .fontSize($r('app.float.public_desc_size'))
              .margin({ top: $r('app.float.public_image_margin') })
              .fontColor($r('app.color.public_text_color'))
          }

          Column() {
            Image($r('app.media.share'))
              .height($r('app.float.choose_height'))
            Text($r('app.string.share'))
              .fontSize($r('app.float.public_desc_size'))
              .margin({ top: $r('app.float.public_image_margin') })
              .fontColor($r('app.color.public_text_color'))
          }

          Button() {
            Row() {
              Image($r('app.media.navigate'))
                .width($r('app.float.start_navigate_icon'))
              Text($r('app.string.start_navigate'))
                .fontSize($r('app.float.start_navigate'))
                .fontColor($r('app.color.start_navigate'))
                .margin({ left: $r('app.float.button_margin') })
            }
          }
          .width($r('app.float.tip_button_width'))
          .height($r('app.float.tip_button_height'))
          .linearGradient({
            direction: GradientDirection.Right,
            repeating: false,
            colors: [[$r('app.color.button_left'), 0], [$r('app.color.button_right'), 1]]
          })
        }
        .height($r('app.float.button_row_height'))
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Bottom)
        .width(Common.FULL_WIDTH)
        .padding({
          left: new BreakpointType($r('app.float.button_row_margin_left_sm'), $r('app.float.button_row_margin_left_md'))
            .getValue(this.currentBreakpoint),
          right: $r('app.float.button_row_margin_right')
        })
        .visibility(this.columnHeight < Common.HEIGHT_MIDDLE ? Visibility.None : Visibility.Visible)
      }
      .padding({ bottom: $r('app.float.column_bottom_space') })
      .width(Common.FULL_WIDTH)
      .height(this.columnHeight - RouteConstants.LIST_DIFFER_HEIGHT)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .expandSafeArea([])
    .borderRadius({
      bottomLeft: new BreakpointType($r('app.float.border_zero'), $r('app.float.border_radius')).getValue(this.currentBreakpoint),
      bottomRight: new BreakpointType($r('app.float.border_zero'), $r('app.float.border_radius')).getValue(this.currentBreakpoint)
    })
    .hideTitleBar(true)
  }
}