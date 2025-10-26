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
import { DishHead, DishSideBar } from '../view/DishInformation';
import { DishDetailsView } from '../view/DishDetailsView';
import { DishComments } from '../view/DishComments';
import { CommonConstants } from '../constants/CommonConstants';

@Component
export struct DishDetails {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('windowTop') windowTop: number = 0;
  @StorageLink('windowBottom') windowBottom: number = 0;
  @Consume('ifShowSides') ifShowSides: boolean;
  // [Start on_scroll_frame_begin]
  @State ifPictureExpansion: Boolean = false;
  @State imageHeightExtension: number = 0;
  @State imageHeightFold: number = 0;
  @State imageHeight: number = 0;
  // [StartExclude on_scroll_frame_begin]
  private informationScroller: Scroller = new Scroller();
  private detailScroller: Scroller = new Scroller();

  // [EndExclude on_scroll_frame_begin]
  build() {
    NavDestination() {
      Scroll(this.informationScroller) {
        GridRow({
          columns: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.ifShowSides ?
          BreakpointConstants.GRID_ROW_COLUMNS[2] : 1
        }) {
          GridCol({
            span: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.ifShowSides ?
            BreakpointConstants.GRID_COLUMN_SPANS[7] : 1
          }) {
            if (this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_LG || this.ifShowSides) {
              DishHead({
                ifPictureExpansion: this.ifPictureExpansion,
                imageHeightExtension: this.imageHeightExtension,
                imageHeightFold: this.imageHeightFold,
                imageHeight: this.imageHeight
              })
            } else {
              DishSideBar()
            }
          }

          // [StartExclude on_scroll_frame_begin]
          GridCol({
            span: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.ifShowSides ?
            BreakpointConstants.GRID_COLUMN_SPANS[7] : 1
          }) {
            Scroll(this.detailScroller) {
              DishDetailsView()
            }
            .height(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.ifShowSides ?
            CommonConstants.FULL_PERCENT : CommonConstants.SELF_ADAPTING)
            .width('100%')
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.PARENT_FIRST
            })
            .scrollBar(BarState.Off)
          }

          if (this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_LG) {
            GridCol({
              span: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.ifShowSides ? 0 : 1
            }) {
              DishComments()
                .height(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.ifShowSides ?
                CommonConstants.FULL_PERCENT : CommonConstants.SELF_ADAPTING)
            }
          }
          // [EndExclude on_scroll_frame_begin]
        }
      }
      // [StartExclude on_scroll_frame_begin]
      .scrollBar(BarState.Off)
      .scrollBarWidth(0)
      .height('100%')
      .backgroundColor('#F2F2F2')
      // [EndExclude on_scroll_frame_begin]
      .onScrollFrameBegin((offset: number, state: ScrollState) => {
        if (!this.ifPictureExpansion && offset < 0) {
          this.imageHeight = this.imageHeightExtension;
          this.ifPictureExpansion = true;
          return { offsetRemain: 0 };
        } else if (this.ifPictureExpansion && offset > 0) {
          this.imageHeight = this.imageHeightFold;
          this.ifPictureExpansion = false;
          return { offsetRemain: 0 };
        } else {
          return { offsetRemain: offset };
        }
      })
    }
    // [StartExclude on_scroll_frame_begin]
    .width('100%')
    .height('100%')
    .hideTitleBar(true)

    // [EndExclude on_scroll_frame_begin]
  }

  // [End on_scroll_frame_begin]
}