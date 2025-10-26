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

import { BreakpointType } from '../utils/BreakpointType';
import { StockDetailsPage } from './StockDetailsPage';
import { OptionPage } from './OptionPage';

@Entry
@Component
struct Index {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: number = 1;
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: number = 1;
  @StorageLink('isSplitScreen') isSplitScreen: boolean = false;
  @StorageLink('sharesHeldNumber') sharesHeldNumber: number = 0;
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @Provide('tabletMode') tabletMode: NavigationMode = NavigationMode.Split;
  @State currentTabIndex: number = 2;
  @State backgroundImageY: number = 0;

  @Builder
  pageMap(pageName: string): void {
    if (pageName === 'StockDetailsPage') {
      StockDetailsPage();
    }
  }

  getTabBarColor(index: number, currentTabIndex: number, breakPoint: number): ResourceColor {
    if (this.backgroundImageY < -20 && this.currentTabIndex === 0 && index === 0) {
      return '#E53137';
    } else if (index === 0 && breakPoint === 3) {
      return currentTabIndex === index ? Color.White : '#33000000';
    }
    return currentTabIndex === index ? '#E53137' : '#33000000';
  }

  @Builder
  BuildTabs(icon: Resource, title: ResourceStr, index: number): void {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(this.getTabBarColor(index, this.currentTabIndex, this.currentWidthBreakpoint))
      Text(title)
        .fontSize(10)
        .lineHeight(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getTabBarColor(index, this.currentTabIndex, this.currentWidthBreakpoint))
    }
  }

  @Builder
  BuildTabsMine(icon: Resource, unIcon: Resource, title: ResourceStr, index: number): void {
    Column() {
      Image(this.currentTabIndex === index ? icon : unIcon)
        .width(24)
        .height(24)
      Text(title)
        .fontSize(10)
        .lineHeight(14)
        .fontColor(this.getTabBarColor(index, this.currentTabIndex, this.currentWidthBreakpoint))
    }
  }

  aboutToAppear(): void {
    setTimeout(() => {
      if (this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG || this.isSplitScreen) {
        this.pageInfos.replacePathByName('StockDetailsPage', null, true);
      }
    }, 100);
  }

  build() {
    Navigation(this.pageInfos) {
      GridRow({
        columns: {
          sm: 4,
          md: 8,
          lg: 12
        },
        direction: GridRowDirection.Row
      }) {
        GridCol({
          span: {
            sm: 4,
            md: 8,
            lg: 12
          }
        }) {
          Column() {
            // [Start homepage_tabs]
            Tabs({
              barPosition: new BreakpointType(BarPosition.End, BarPosition.End, BarPosition.Start)
                .getValue(this.currentWidthBreakpoint),
              index: 2
            }) {
              // [StartExclude homepage_tabs]
              TabContent() {
              }
              .tabBar(this.BuildTabs($r('app.media.house_fill'), $r('app.string.home_page'), 0))
              .backgroundColor(Color.White)

              TabContent() {
              }
              .tabBar(this.BuildTabs($r('app.media.doc_text_fill'), $r('app.string.information'), 1))
              .backgroundColor(Color.White)

              TabContent() {
                OptionPage()
              }
              .tabBar(this.BuildTabs($r('app.media.square_and_pencil_fill'), $r('app.string.optional'), 2))
              .backgroundColor(Color.White)

              TabContent() {
              }
              .tabBar(this.BuildTabs($r('app.media.doc_plaintext_fill'), $r('app.string.market'), 3))
              .backgroundColor(Color.White)
              // [EndExclude homepage_tabs]
            }
            .vertical(this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG)
            .barWidth(this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG ? 96 : '100%')
            .barHeight(this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG ? '50%' : 56)
            .backgroundImageSize(ImageSize.Contain)
            .backgroundColor('#F3F4F5')
            .scrollable(false)
            // [End homepage_tabs]
            .backgroundImagePosition({
              y: this.backgroundImageY
            })
            .onChange((index: number) => {
              if (this.currentWidthBreakpoint !== 3) {
                this.currentTabIndex = index;
              }
            })
            .onContentWillChange(() => {
              if (this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG) {
                return false;
              }
              return true;
            })
            .padding({
              bottom: this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_LG ? 0 :
                AppStorage.get<number>('naviIndicatorHeight') as number - 10
            })
          }
          .width('100%')
          .height('100%')
        }
      }
    }
    .navDestination(this.pageMap)
    .navBarWidthRange([474, 474])
    .mode(new BreakpointType(NavigationMode.Stack, NavigationMode.Stack, this.tabletMode)
      .getValue(this.currentWidthBreakpoint))
    .hideTitleBar(true)
    .hideToolBar(true)
    .height('100%')
    .backgroundColor($r('sys.color.gray_01'))
  }
}