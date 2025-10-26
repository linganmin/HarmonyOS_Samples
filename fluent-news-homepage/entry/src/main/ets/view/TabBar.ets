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
import { CommonConstants } from '../constants/CommonConstants';
import { HomeConstants as Const } from '../constants/HomeConstants';
import NewsTypeModel from '../viewmodel/NewsTypeModel';
import newsViewModel from '../viewmodel/NewsViewModel';
import { PullToRefreshNews } from './PullToRefreshNews';

@Component
export default struct TabBar {
  @State tabBarArray: NewsTypeModel[] = newsViewModel.getDefaultTypeList();
  @State currentIndex: number = CommonConstants.ZERO;
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;

  // [Start tab_bar]
  // TabBar.ets
  @Builder
  TabBuilder(id: number, index: number) {
    Column() {
      Text(this.tabBarArray[id].name)
      // [StartExclude tab_bar]
        .height(CommonConstants.FULL_PERCENT)
        .padding({ left: Const.TAB_BARS_HORIZONTAL_PADDING, right: Const.TAB_BARS_HORIZONTAL_PADDING })
        .fontSize(this.currentIndex === index ?
          (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ?
          $r('app.float.tab_bar_font_size_20') : $r('app.float.tab_bar_font_size_22')) :
          (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ?
          $r('app.float.tab_bar_font_size_16') : $r('app.float.tab_bar_font_size_18')))
        .fontWeight(this.currentIndex === index ?
        Const.TAB_BARS_SELECT_TEXT_FONT_WEIGHT : Const.TAB_BARS_UN_SELECT_TEXT_FONT_WEIGHT)
        .fontColor($r('app.color.fontColor_text3'))
      // [EndExclude tab_bar]
    }
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Tabs({ barPosition: BarPosition.Start }) {
      ForEach(this.tabBarArray, (tabsItem: NewsTypeModel, index: number) => {
        TabContent() {
          // [StartExclude tab_bar]
          PullToRefreshNews()
          // [EndExclude tab_bar]
        }
        // [StartExclude tab_bar]
        .tabBar(this.TabBuilder(tabsItem.id, index))

        // [EndExclude tab_bar]
      }, (item: NewsTypeModel) => JSON.stringify(item));
    }
    // [StartExclude tab_bar]
    .barHeight(Const.TAB_BARS_BAR_HEIGHT)
    .barMode(BarMode.Scrollable)
    .barWidth(Const.TAB_BARS_BAR_WIDTH)
    .vertical(false)
    // [EndExclude tab_bar]
    .onAnimationStart((_index: number, targetIndex: number, _event: TabsAnimationEvent) => {
      this.currentIndex = targetIndex;
    })
  }

  // [End tab_bar]
}