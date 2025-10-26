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

import { BreakpointConstants } from '../constants/BreakpointConstants';
import { BreakpointType } from '../utils/BreakpointSystem';
import { FunctionEntryListData } from '../model/FunctionEntryListData';
import { FunctionEntryData } from '../model/FunctionEntryData';
import { HomeConstants } from '../constants/HomeConstants';
import { CommonConstants } from '../constants/CommonConstants';

@Component
export struct FunctionView {
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink(CommonConstants.LANGUAGE) language:string = CommonConstants.CHINESE_LANGUAGE;
  @Watch('aboutToAppear') @Link freshFlag: boolean;
  @State functionEntryListData: FunctionEntryListData = new FunctionEntryListData();
  @State functionEntryData: FunctionEntryData[] = [];
  @State functionEntryFirstData: FunctionEntryData[] = [];
  @State functionEntrySecondData: FunctionEntryData[] = [];
  @State pageSizeList: number[] = [CommonConstants.FUNCTION_FIRST_INDEX, CommonConstants.FUNCTION_SECOND_INDEX];
  @State currentIndex: number = CommonConstants.FUNCTION_FIRST_INDEX;
  @State gridHeight: number = HomeConstants.FUNCTION_TWO_LINES_HEIGHT;

  async aboutToAppear(): Promise<void> {
    let arr: FunctionEntryData[] = await this.functionEntryListData.getData();
    this.functionEntryData = arr;
    this.functionEntryFirstData = arr.slice(CommonConstants.NUMBER_DEFAULT_VALUE, CommonConstants.FUNCTION_FIRST_COUNT);
    this.functionEntrySecondData = arr.slice(CommonConstants.FUNCTION_FIRST_COUNT,
      CommonConstants.FUNCTION_FIRST_COUNT + CommonConstants.FUNCTION_SECOND_COUNT);
  }

  build() {
    Swiper() {
      Grid() {
        if (this.functionEntryData.length === CommonConstants.NUMBER_DEFAULT_VALUE) {
          this.DefaultGrid();
        } else {
          this.FunctionGrid(this.functionEntryFirstData);
        }
      }
      .rowsGap($r('app.float.function_row_gap'))
      .padding({ bottom: $r('app.float.function_padding_bottom') })
      .height(this.gridHeight)
      .rowsTemplate(HomeConstants.FUNCTION_ROWS_PAGE_ONE)
      .columnsTemplate(HomeConstants.FUNCTION_COLUMN);

      Grid() {
        if (this.functionEntryData.length === CommonConstants.NUMBER_DEFAULT_VALUE) {
          this.DefaultGrid();
        } else {
          this.FunctionGrid(this.functionEntrySecondData);
        }
      }
      .rowsGap($r('app.float.function_row_gap'))
      .padding({ bottom: $r('app.float.function_padding_bottom') })
      .height(this.gridHeight)
      .rowsTemplate(HomeConstants.FUNCTION_ROWS_PAGE_TWO)
      .columnsTemplate(HomeConstants.FUNCTION_COLUMN);
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .onContentDidScroll((selectedIndex: number, index: number, position: number) => {
      if (selectedIndex === CommonConstants.FUNCTION_FIRST_INDEX && index === CommonConstants.FUNCTION_FIRST_INDEX) {
        this.gridHeight = HomeConstants.FUNCTION_TWO_LINES_HEIGHT +
          (HomeConstants.FUNCTION_TWO_LINES_HEIGHT - HomeConstants.FUNCTION_THREE_LINES_HEIGHT) * position;
      }
      if (selectedIndex === CommonConstants.FUNCTION_SECOND_INDEX && index === CommonConstants.FUNCTION_SECOND_INDEX) {
        this.gridHeight = HomeConstants.FUNCTION_THREE_LINES_HEIGHT +
          (HomeConstants.FUNCTION_TWO_LINES_HEIGHT - HomeConstants.FUNCTION_THREE_LINES_HEIGHT) * position;
      }
    })
    .loop(false)
    .margin({
      left: new BreakpointType({
        sm: BreakpointConstants.FUNCTION_MARGIN_LEFT_SM,
        md: BreakpointConstants.FUNCTION_MARGIN_LEFT_MD,
        lg: BreakpointConstants.FUNCTION_MARGIN_LEFT_LG
      }).getValue(this.currentBreakpoint),
      right: new BreakpointType({
        sm: BreakpointConstants.FUNCTION_MARGIN_RIGHT_SM,
        md: BreakpointConstants.FUNCTION_MARGIN_RIGHT_MD,
        lg: BreakpointConstants.FUNCTION_MARGIN_RIGHT_LG
      }).getValue(this.currentBreakpoint)
    });
  }

  @Builder
  DefaultGrid() {
    ForEach(HomeConstants.FUNCTION_DEFAULT_ICONS,
      () => {
        GridItem() {
          Column() {
            Column() {
            }
            .height($r('app.float.function_gridItem_image_height'))
            .width($r('app.float.function_gridItem_image_width'))
            .borderRadius($r('app.float.function_gridItem_border_radius'))
            .backgroundColor($r('app.color.function_default_color'));

            Column() {
            }
            .height($r('app.float.function_gridItem_gray_height'))
            .width($r('app.float.function_gridItem_gray_width'))
            .backgroundColor($r('app.color.function_default_color'))
            .margin({ top: $r('app.float.function_gridItem_gray_marge_top') });
          }
          .margin({ bottom: $r('app.float.function_gridItem_marge_bottom') })
          .height($r('app.float.function_gridItem_height'));
        };
      }, (item: FunctionEntryData): string => item.index.toString());
  }

  @Builder
  FunctionGrid(data: FunctionEntryData[]) {
    ForEach(data, (item: FunctionEntryData) => {
      GridItem() {
        Column() {
          Image(item.icon)
            .height($r('app.float.function_gridItem_image_height'))
            .width($r('app.float.function_gridItem_image_width'))
            .borderRadius($r('app.float.function_gridItem_border_radius'));
          Text(this.language === CommonConstants.CHINESE_LANGUAGE ? item.name : item.nameEn)
            .fontSize($r('app.float.category_text_font'))
            .lineHeight($r('app.float.function_gridItem_text_line_height'))
            .margin({ top: $r('app.float.function_gridItem_text_margin_top') });
        };
      }
      .width($r('app.float.function_gridItem_width'))
      .height($r('app.float.function_gridItem_height'));
    }, (item: FunctionEntryData): string => item.index.toString());
  }
}

