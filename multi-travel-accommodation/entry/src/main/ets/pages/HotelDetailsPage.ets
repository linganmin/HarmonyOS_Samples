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

import { CommonConstants } from '../commons/constants/CommonConstants';
import { HotelDetailsPictureView } from '../view/HotelDetailsPictureView';

@Component
export struct HotelDetailsPage {
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_SM;
  @State topLength: number = 225;
  scroller: Scroller = new Scroller();
  isInitialization: boolean = false;

  build() {
    NavDestination(){
      GridRow({
        breakpoints: {
          value: CommonConstants.BREAK_POINTS_VALUE,
          reference: BreakpointsReference.WindowSize
        },
        columns: {
          sm: CommonConstants.COLUMN_SM,
          md: CommonConstants.COLUMN_MD,
          lg: CommonConstants.COLUMN_LG
        },
        direction: GridRowDirection.Row
      }) {
        GridCol({
          span: {
            sm: CommonConstants.COLUMN_SM,
            md: CommonConstants.COLUMN_MD,
            lg: CommonConstants.COLUMN_LG
          }
        }) {
          // [Start scroll_on_reach_start]
          Scroll(this.scroller) {
            HotelDetailsPictureView({ topLength: this.topLength })
          }
          .scrollBar(BarState.Off)
          .width('100%')
          .height('100%')
          .onReachStart(() => {
            if (!this.isInitialization) {
              this.topLength = 225;
              this.isInitialization = true;
            } else {
              this.topLength = 460;
            }
          })
          .onWillScroll((xOffset: number, yOffset: number)=>{
            if (yOffset > 0) {
              this.topLength = 225;
            }
          })
          // [End scroll_on_reach_start]
        }
      }
    }
    .hideTitleBar(true)
  }
}