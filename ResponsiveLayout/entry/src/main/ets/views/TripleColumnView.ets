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

import { WidthBreakpointType } from '../utils/WidthBreakpointType';
import { WindowInfo } from '../utils/WindowUtil';
import { NavigationBarView } from './NavigationBarView';
import { NavigationContent1, NavigationContent2 } from './NavigationContentView';

@Component
export struct TripleColumnView {
  @ObjectLink @Watch('widthBpChange') mainWindowInfo: WindowInfo;
  @State isShowingSidebar: boolean = this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG ||
    this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_XL ? true : false;
  pageInfos: NavPathStack = new NavPathStack();
  pathStack: NavPathStack = new NavPathStack();

  widthBpChange(): void {
    if (this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_LG ||
      this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_XL) {
      this.isShowingSidebar = true;
    } else {
      this.isShowingSidebar = false;
    }
  }

  @Builder
  PageMap(name: string) {
    if (name === 'navigationContent1') {
      NavigationContent1({
        mainWindowInfo: this.mainWindowInfo,
        isTripleView: true
      })
    } else if (name === 'navigationContent2') {
      NavigationContent2({ mainWindowInfo: this.mainWindowInfo })
    }
  }

  build() {
    // [Start triple_column_view]
    SideBarContainer(new WidthBreakpointType(SideBarContainerType.Overlay, SideBarContainerType.Overlay,
      SideBarContainerType.Embed).getValue(this.mainWindowInfo.widthBp)) {
      Column() {
        // [StartExclude triple_column_view]
        Image($r('app.media.open_sidebar'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.isShowingSidebar = !this.isShowingSidebar;
          })
        Column() {
          Text('SidebarContainer')
            .fontSize(18)
            .margin({ bottom: 12 })
          Text($r('app.string.side_bar'))
            .fontSize(24)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        // [EndExclude triple_column_view]
      }
      // [StartExclude triple_column_view]
      .alignItems(HorizontalAlign.Start)
      .backgroundColor('#FFD6B5D6')
      .width('100%')
      .height('100%')
      .padding({
        top: this.getUIContext().px2vp(this.mainWindowInfo.AvoidSystem?.topRect.height) + 12,
        bottom: this.getUIContext().px2vp(this.mainWindowInfo.AvoidNavigationIndicator?.bottomRect.height),
        left: 16,
        right: 16
      })
      // [EndExclude triple_column_view]

      Column() {
        Navigation(this.pathStack) {
          NavigationBarView({
            mainWindowInfo: this.mainWindowInfo,
            pageInfos: this.pageInfos,
            pathStack: this.pathStack,
            isShowingSidebar: this.isShowingSidebar,
            isTriView: true
          })
        }
        .width('100%')
        .height('100%')
        .mode(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ? NavigationMode.Stack : NavigationMode.Split)
        .navBarWidth(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_MD ? '50%' : '40%')
        .navDestination(this.PageMap)
        .backgroundColor('#B8EEB2')
      }
      // [StartExclude triple_column_view]
      .width('100%')
      .height('100%')
      // [EndExclude triple_column_view]
    }
    .showSideBar(this.isShowingSidebar)
    .sideBarWidth(new WidthBreakpointType('80%', '50%', '20%').getValue(this.mainWindowInfo.widthBp))
    // [End triple_column_view]
    .controlButton({ top: this.getUIContext().px2vp(this.mainWindowInfo.AvoidSystem?.topRect.height) + 12 })
    .showControlButton(false)
    .autoHide(false)}
}