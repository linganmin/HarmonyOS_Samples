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
import { NavigationBarView } from '../view/NavigationBarView';
import { HomeContent } from '../view/HomeContent';

@Component
export struct IndexNavDestination {
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @Link windowsHeight: number;
  private swiperController: SwiperController = new SwiperController();
  private scroller: Scroller = new Scroller();
  private waterFlowScroller: Scroller = new Scroller();

  build() {
    NavDestination() {
      Flex({
        direction: new BreakpointType(
          {
            sm: FlexDirection.Column,
            md: FlexDirection.Column,
            lg: FlexDirection.Row,
          }
        ).getValue(this.currentBreakpoint),
        wrap: FlexWrap.NoWrap,
        justifyContent: FlexAlign.Start,
        alignItems: ItemAlign.Start,
        alignContent: FlexAlign.Start
      }) {
        Column() {
          HomeContent({
            scroller: this.scroller,
            waterFlowScroller: this.waterFlowScroller,
            windowsHeight: this.windowsHeight
          });
        }
        .width($r('app.string.full_screen'))
        .height($r('app.string.full_screen'));

        NavigationBarView({
          swiperController: this.swiperController,
          scroller: this.scroller,
          waterFlowScroller: this.waterFlowScroller
        });
      }
      .direction(
        new BreakpointType(
          {
            sm: Direction.Auto,
            md: Direction.Auto,
            lg: Direction.Rtl,
          }
        ).getValue(this.currentBreakpoint)
      )
      .width($r('app.string.full_screen'))
      .height($r('app.string.full_screen'))
      .backgroundColor($r('app.color.start_window_background'));
    };
  }
}