/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { CommonConstants } from '../common/constants/CommonConstants';
import { BreakpointType } from '../common/utils/BreakpointType';
import { HomeConstants } from '../common/constants/HomeConstants';
import { IconInfo, IconInfoViewModel } from '../viewmodel/IconInfoViewModel';

@Component
export struct Categories {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @State isNextCategory: boolean = false;
  private categoryIcons: IconInfo[] = new IconInfoViewModel().getCategoryList();

  build() {
    Column() {
      List({
        space: new BreakpointType(HomeConstants.CATEGORY_LIST_SPACES[0], HomeConstants.CATEGORY_LIST_SPACES[1],
          HomeConstants.CATEGORY_LIST_SPACES[2]).getValue(this.currentBreakpoint)
      }) {
        ForEach(this.categoryIcons, (item: IconInfo) => {
          ListItem() {
            Row() {
              Column() {
                Image(item.getIcon())
                  .height(new BreakpointType($r('app.float.category_img_size_sm'), $r('app.float.category_img_size_md'),
                    $r('app.float.category_img_size_lg')).getValue(this.currentBreakpoint));
                Text(item.getInfo())
                  .fontSize($r('app.float.category_text_font'))
                  .fontWeight(FontWeight.Normal)
                  .lineHeight($r('app.float.category_text_line'));
              };
            }
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .justifyContent(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? FlexAlign.Center :
            FlexAlign.Start);
          }
          .width(new BreakpointType(HomeConstants.CATEGORY_LIST_ITEM_WIDTHS[0],
            HomeConstants.CATEGORY_LIST_ITEM_WIDTHS[1],
            HomeConstants.CATEGORY_LIST_ITEM_WIDTHS[2]).getValue(this.currentBreakpoint))
          .height(new BreakpointType($r('app.float.category_item_height_sm'), $r('app.float.category_item_height_md'),
            $r('app.float.category_item_height_lg')).getValue(this.currentBreakpoint));
        }, (item: IconInfo, index: number) => JSON.stringify(item) + index);
      }
      .lanes(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? 2 : 1,
        $r('app.float.category_lanes_gutter'))
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .width(CommonConstants.FULL_PERCENT)
      .height(new BreakpointType($r('app.float.category_list_height_sm'), $r('app.float.category_list_height_md'),
        $r('app.float.category_list_height_lg')).getValue(this.currentBreakpoint))
      .onScrollIndex((start: number, end: number) => {
        if(end === HomeConstants.NINE) {
          this.isNextCategory = true;
        }
        if(start === 0) {
          this.isNextCategory = false;
        }
      });

      if(this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_SM) {
        Row() {
          Divider()
            .color(this.isNextCategory ? $r('app.color.categories_divider_color_selected') :
            $r('app.color.categories_divider_color'))
            .width($r('app.float.category_divider_width'))
            .strokeWidth(HomeConstants.CATEGORY_DIVIDER_STROKE_WIDTH)
            .lineCap(LineCapStyle.Round);
          Divider()
            .color(this.isNextCategory ? $r('app.color.categories_divider_color') :
            $r('app.color.categories_divider_color_selected'))
            .width($r('app.float.category_divider_width'))
            .strokeWidth(HomeConstants.CATEGORY_DIVIDER_STROKE_WIDTH)
            .lineCap(LineCapStyle.Round);
        }
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.float.category_divider_row_height'))
        .justifyContent(FlexAlign.Center);
      }
    }
    .height(new BreakpointType($r('app.float.category_col_height_sm'), $r('app.float.category_col_height_md'),
      $r('app.float.category_col_height_lg')).getValue(this.currentBreakpoint))
    .width(CommonConstants.FULL_PERCENT)
    .margin({
      top: this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_SM ? $r('app.float.category_col_margin') : 0,
      bottom: 16
    });
  }
}