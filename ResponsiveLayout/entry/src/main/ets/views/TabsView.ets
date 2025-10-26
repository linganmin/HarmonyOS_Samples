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

import { WindowInfo } from '../utils/WindowUtil';

class FooterTab {
  tabName: Resource;
  tabIcon: Resource;
  tabIconSel: Resource;

  constructor(tabName: Resource, tabIcon: Resource, tabIconSel: Resource) {
    this.tabName = tabName;
    this.tabIcon = tabIcon;
    this.tabIconSel = tabIconSel;
  }
}

const FOOTER_TAB_LIST: FooterTab[] = [
  new FooterTab($r('app.string.tab_home'), $r('app.media.tab_home'), $r('app.media.tab_home_selected')),
  new FooterTab($r('app.string.tab_category'), $r('app.media.tab_category'), $r('app.media.tab_category_selected')),
  new FooterTab($r('app.string.tab_discovery'), $r('app.media.tab_discovery'), $r('app.media.tab_discovery_selected')),
  new FooterTab($r('app.string.tab_shopping_bag'), $r('app.media.tab_bag'), $r('app.media.tab_bag_selected')),
  new FooterTab($r('app.string.tab_mine'), $r('app.media.tab_mine'), $r('app.media.tab_mine_selected'))
];

@Component
export struct TabsView {
  @ObjectLink mainWindowInfo: WindowInfo;
  @State currentBottomIndex: number = 0;
  pageInfos: NavPathStack = new NavPathStack();

  @Builder
  BottomTabBuilder(item: FooterTab, index: number) {
    Column() {
      Image(index !== this.currentBottomIndex ? item.tabIcon : item.tabIconSel)
        .width(24)
        .height(24)
      Text(item.tabName)
        .fontSize(10)
        .fontColor(index === this.currentBottomIndex ? '#D0092D' : Color.Black)
        .margin({ top: 4 })
        .opacity(index === this.currentBottomIndex ? 1 : 0.4)
    }
    .padding({
      bottom: this.getUIContext().px2vp(this.mainWindowInfo.AvoidNavigationIndicator?.bottomRect.height)
    })
    .height(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG ? 80 : '100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      // [Start tabs_view]
      Tabs({ barPosition: this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG ? BarPosition.Start :
        BarPosition.End }) {
        // [StartExclude tabs_view]
        ForEach(FOOTER_TAB_LIST, (item: FooterTab, index: number) => {
          TabContent() {
            Column() {
              Row() {
                Image($r('app.media.ic_public_back'))
                  .width(40)
                  .height(40)
                  .margin({ right: 12 })
                  .onClick(() => {
                    this.pageInfos.pop();
                  })
                Text($r('app.string.tabs'))
                  .fontSize(24)
              }
              .width('100%')
              .margin({ bottom: 12 })
              .padding({
                left: 16,
                right: 16
              })
            }
            .height('100%')
            .width('100%')
          }
          .tabBar(this.BottomTabBuilder(item, index))
          .padding({ top: this.getUIContext().px2vp(this.mainWindowInfo.AvoidSystem?.topRect.height) + 12})
        }, (item: number, index: number) => index + JSON.stringify(item))
        // [EndExclude tabs_view]
      }
      // Change the position and size of the tab at the bottom.
      .barWidth(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG ? 96 : '100%')
      .barHeight(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG ? '100%' :
        56 + this.getUIContext().px2vp(this.mainWindowInfo.AvoidNavigationIndicator?.bottomRect.height))
      .barMode(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG ? BarMode.Scrollable : BarMode.Fixed,
        { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_CENTER })
      .vertical(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG)
      // [End tabs_view]
      .barBackgroundColor('#F1F3F5')
      .onChange((index: number) => {
        this.currentBottomIndex = index;
      })
      .scrollable(false)
    }
  }
}