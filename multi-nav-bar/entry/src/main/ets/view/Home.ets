/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { TabDataModel } from '../model/TabDataModel';
import { TabViewModel } from '../viewmodel/TabViewModel';
import { SideBarView } from './SideBarView';
import { TopTabView } from './TopTabView';
import { VideoInfoView } from './VideoInfoView';

@Component
export struct Home {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = 'sm';
  @State firstLevelIndex: number = 0;
  @State secondLevelIndex: number = 0;
  @State tabViewModel: TabViewModel = new TabViewModel();
  @State tabData: TabDataModel = this.tabViewModel.getTabMap();

  @Builder
  tabBuilder(name: string, index: number) {
    Column() {
      Image(index === this.firstLevelIndex ? $r('app.media.ic_tabs_mine_selected') : $r('app.media.ic_tabs_mine'))
        .width(24)
        .height(24)
      Text(name)
        .fontSize(10)
        .fontWeight(500)
        .fontColor(index === this.firstLevelIndex ? '#0A59F7' : '#99000000')
        .margin({ top: 4 })
    }
    .padding({ bottom: 24 })
    .height(this.currentWidthBreakpoint === 'lg' ? 100 : '100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    // [Start diff_device_container]
    // entry/src/main/ets/view/Home.ets
    if (this.currentWidthBreakpoint === 'xl') {
      // Use SideBarContainer at XL breakpoint.
      SideBarContainer(SideBarContainerType.Embed) {
        SideBarView({
          firstLevelIndex: this.firstLevelIndex,
          secondLevelIndex: this.secondLevelIndex,
          tabViewModel: this.tabViewModel,
          tabData: this.tabData
        })

        Column() {
          Text(this.tabViewModel.getTabNameOfSecondLevel(this.tabViewModel.getTabNameOfFirstLevel(this.firstLevelIndex),
            this.secondLevelIndex))
            .fontSize('20fp')
            .fontWeight(700)
            .margin({
              left: 32,
              top: 71,
              bottom: 14
            })
          VideoInfoView({
            firstLevelIndex: this.firstLevelIndex,
            secondLevelIndex: this.secondLevelIndex
          })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .autoHide(false)
      .divider({ strokeWidth: 0.3 })
      .showControlButton(false)
      .sideBarWidth(240)
      .minSideBarWidth(240)
      .maxSideBarWidth(240)
    } else {
      // [StartExclude diff_device_container]
      // Use Tabs and List at other breakpoints.
      // [Start tab_to_page]
      // entry/src/main/ets/view/Home.ets
      Tabs({
        barPosition: this.currentWidthBreakpoint === 'lg' ? BarPosition.Start : BarPosition.End
      }) {
        TabContent() {
          TopTabView({
            firstLevelIndex: this.firstLevelIndex,
            tabData: this.tabData
          })
        }
        .tabBar(this.tabBuilder(this.tabData.getFirstList()[0], 0))

        TabContent()
          .tabBar(this.tabBuilder(this.tabData.getFirstList()[1], 1))

        TabContent()
          .tabBar(this.tabBuilder(this.tabData.getFirstList()[2], 2))

        TabContent()
          .tabBar(this.tabBuilder(this.tabData.getFirstList()[3], 3))
      }
      // [StartExclude tab_to_page]
      .barBackgroundColor('#CCF1F3F5')
      .barWidth(this.currentWidthBreakpoint === 'lg' ? 96 : '100%')
      .barHeight(this.currentWidthBreakpoint === 'lg' ? '100%' : 76)
      .barMode(this.currentWidthBreakpoint === 'lg' ? BarMode.Scrollable : BarMode.Fixed,
        { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_CENTER })
      .barBackgroundBlurStyle(BlurStyle.COMPONENT_THICK)
      // [EndExclude tab_to_page]
      .vertical(this.currentWidthBreakpoint === 'lg')
      .onChange((index: number) => {
        this.firstLevelIndex = index;
      })
      // [End tab_to_page]
      .scrollable(false)
      .height('100%')
      .width('100%')
      // [EndExclude diff_device_container]
    }
    // [End diff_device_container]
  }
}