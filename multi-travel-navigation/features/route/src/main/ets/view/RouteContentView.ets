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

import { map, navi } from '@kit.MapKit';
import { BreakpointConstants, BreakpointType, Common, Logger } from '@ohos/commons/Index';
import { RouteConstants } from '../constants/RouteConstants';
import { CalculateModel } from '../viewmodel/CalculateModel';
import { DrawRouteModel } from '../viewmodel/DrawRouteModel';

@Component
export struct RouteContentView {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_MD;
  @StorageLink('routes') routes: Array<navi.Route> | undefined = [];
  @State currentIndex: number = 0;
  @Link columnHeight: number;
  @Link mapController: map.MapComponentController;
  private calculateMode: CalculateModel = new CalculateModel();
  private drawRouteModel: DrawRouteModel = new DrawRouteModel();

  aboutToAppear(): void {
    if (this.routes !== undefined) {
      this.drawRouteModel.drawRoute(this.mapController, this.routes[0].steps[0].roads).then(() => {
        Logger.info('First draw route success');
      });
    }
  }

  build() {
    if (this.routes !== undefined) {
      if (this.columnHeight > Common.HEIGHT_MIDDLE) {
        List() {
          ForEach(this.routes, (item: navi.Route, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Text($r('app.string.choose'))
                    .fontSize($r('app.float.font_size_small'))
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.currentIndex === index ?
                      $r('app.color.font_color_heavy_selected') : $r('app.color.route_font_color_unselected'))
                    .margin({ bottom: $r('app.float.text_image_margin') })
                  Text(this.calculateMode.getTotalDistance(item).toString() + RouteConstants.KILOMETRES(this.getUIContext().getHostContext()))
                    .fontSize($r('app.float.font_size_small'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.currentIndex === index ?
                      $r('app.color.font_color_light_selected') : $r('app.color.route_font_color_unselected'))
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: $r('app.float.list_margin_border') })

                Text(this.calculateMode.getTotalTime(item).toString().split('.')[0] + RouteConstants.MINUTES(this.getUIContext().getHostContext()))
                  .fontSize($r('app.float.font_size_big'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.currentIndex === index ?
                    $r('app.color.font_color_heavy_selected') : $r('app.color.route_font_color_unselected'))
                  .margin({ right: $r('app.float.list_margin_border') })
              }
              .width(Common.FULL_WIDTH)
              .justifyContent(FlexAlign.SpaceBetween)
              .height($r('app.float.list_group_height'))
              .borderRadius($r('app.float.list_group_border_radius'))
              .shadow({
                radius: $r('app.float.route_radius'),
                color: $r('app.color.route_radius')
              })
            }
            .onClick(() => {
              this.currentIndex = index;
              this.mapController.clear();
              this.drawRouteModel.drawRoute(this.mapController, item.steps[0].roads).then(() => {
                Logger.info('Draw route success');
              });
            })
            .padding({
              top: $r('app.float.list_row_padding_top')
            })
            .width(Common.FULL_WIDTH)
            .height($r('app.float.list_row_height'))
          })
        }
        .width(Common.FULL_WIDTH)
        .height(Common.FULL_HEIGHT)
      } else {
        List() {
          ForEach(this.routes, (item: navi.Route, index: number) => {
            ListItem() {
              Column() {
                Text($r('app.string.choose'))
                  .fontSize($r('app.float.font_size_small'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.currentIndex === index ?
                    $r('app.color.font_color_heavy_selected') : $r('app.color.route_font_color_unselected'))
                  .margin({
                    top: $r('app.float.list_column_margin_top'),
                    left: $r('app.float.list_column_margin_left')
                  })
                Text(this.calculateMode.getTotalTime(item).toString().split('.')[0] + RouteConstants.MINUTES(this.getUIContext().getHostContext()))
                  .fontSize($r('app.float.font_size_big'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.currentIndex === index ?
                    $r('app.color.font_color_heavy_selected') : $r('app.color.route_font_color_unselected'))
                  .margin({ left: $r('app.float.list_column_margin_left') })
                Text(this.calculateMode.getTotalDistance(item).toString() + RouteConstants.KILOMETRES(this.getUIContext().getHostContext()))
                  .fontSize($r('app.float.font_size_small'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.currentIndex === index ?
                    $r('app.color.font_color_light_selected') : $r('app.color.route_font_color_unselected'))
                  .margin({ left: $r('app.float.list_column_margin_left') })
              }
              .margin({ right: $r('app.float.list_column_margin_right') })
              .alignItems(HorizontalAlign.Start)
              .height($r('app.float.list_row_total_height'))
              .width(new BreakpointType($r('app.float.list_row_width_sm'), $r('app.float.list_row_width_md'))
                .getValue(this.currentBreakpoint))
              .borderRadius($r('app.float.list_group_border_radius'))
              .shadow({
                radius: $r('app.float.route_radius'),
                color: $r('app.color.route_radius')
              })
            }
            .onClick(() => {
              this.currentIndex = index;
              this.mapController.clear();
              this.drawRouteModel.drawRoute(this.mapController, item.steps[0].roads).then(() => {
                Logger.info('Draw route success');
              });
            })
          })
        }
        .width(Common.FULL_WIDTH)
        .scrollBar(BarState.Off)
        .listDirection(Axis.Horizontal)
      }
    }
  }
}