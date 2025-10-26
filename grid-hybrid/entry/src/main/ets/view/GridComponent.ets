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

import { GridData } from '../model/GridListDataSources';
import { CommonConstants } from '../constants/CommonConstants';
import GridItemComponent from './GridItemComponent';

@Component
export default struct GridComponent {
  @State gridData: GridData = new GridData('', []);
  @State isLastItem: boolean = false;

  build() {
    Column() {
      Row() {
        Text(this.gridData.groupName)
          .fontSize($r('app.float.grid_title_font_size'))
          .height($r('app.float.grid_title_height'))
          .fontWeight(FontWeight.Bold)
          .margin({ top: $r('app.float.title_list_top_margin') })
      }
      .padding({ left: $r('app.float.title_padding') })
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)

      Grid() {
        ForEach(this.gridData.gridItemList, (item: string) => {
          GridItemComponent({ itemName: item })
        },(item:string,index:number)=>index+JSON.stringify(item))
      }
      .margin({
        left: $r('app.float.grid_left_margin'),
        right: $r('app.float.grid_right_margin'),
        top: $r('app.float.grid_top_margin')
      })
      .borderRadius($r('app.float.grid_border_radius'))
      .padding($r('app.float.grid_padding_size'))
      .height(this.getGridHeight())
      .rowsGap($r('app.float.grid_rows_gap_size'))
      .scrollBar(BarState.Off)
      .columnsTemplate(CommonConstants.GRID_COLUMNS_TEMPLATE)
      .backgroundColor(Color.White)

      if (this.isLastItem) {
        Blank()
          .height(CommonConstants.FULL_PERCENT)
      }
    }
  }

  getGridHeight(): number {
    //Grid height to be calculated
    let gridHeight: number = 0;
    //Total height of grid items in each row.
    gridHeight += Math.ceil(this.gridData.gridItemList.length / 4) * 68;
    //Total height of the intervals between grid items.
    gridHeight += (Math.ceil(this.gridData.gridItemList.length / 4) - 1) * 8;
    //Top and bottom margins of the grid
    gridHeight += 12 * 2;
    return gridHeight;
  }
}