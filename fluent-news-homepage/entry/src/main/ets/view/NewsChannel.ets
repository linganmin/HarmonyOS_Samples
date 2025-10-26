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

import { CommonConstants as Constants } from '../constants/CommonConstants';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { PullToRefreshNews } from './PullToRefreshNews';

@Component
export struct NewsChannel {
  @StorageProp('currentBreakpoint') curBp: string = '';
  private scroller: Scroller = new Scroller();

  build() {
    Column() {
      Scroll(this.scroller) {
        GridRow({
          columns: {
            sm: BreakpointConstants.GRID_ROW_COLUMNS[0],
            md: BreakpointConstants.GRID_ROW_COLUMNS[1],
            lg: BreakpointConstants.GRID_ROW_COLUMNS[2]
          },
          gutter: {
            x: { md: Constants.GRID_HORIZONTAL_GUTTER[0], lg: Constants.GRID_HORIZONTAL_GUTTER[1] },
            y: { sm: Constants.GRID_VERTICAL_GUTTER[0], md: Constants.GRID_VERTICAL_GUTTER[1] }
          }
        },
        ) {
          PullToRefreshNews()
        }
        .onBreakpointChange((breakPoint: string) => {
          this.curBp = breakPoint;
        })
        .width(Constants.NINETY_PERCENT)
      }
      .scrollBar(BarState.Off)
    }
    .width(Constants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
  }
}