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

import { Constants } from '../common/Constants';
import { Menu, MenuViewMode } from '../viewmodel/MenuViewModel';
import { Home } from './Home';
import { ReceivePaymentPage } from './ReceivePaymentPage';
import { ScanQRCodePage } from './ScanQRCodePage';

@Entry
@Component
struct Index {
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  @StorageLink('currentBreakpoint') curBp: string = Constants.BREAKPOINT_SM;
  @State currentIndex: number = 0;
  @State menus: Menu[] = new MenuViewMode().getMenus();
  private tabsController: TabsController = new TabsController();

  @Builder
  PageMap(name: string) {
    NavDestination() {
      if (name === 'ReceivePaymentPage') {
        ReceivePaymentPage()
      } else if (name === 'ScanQRCodePage') {
        ScanQRCodePage()
      }
    }
    .hideTitleBar(true)
  }

  @Builder
  tabBuilder(title: Resource, targetIndex: number, icon: Resource) {
    Column() {
      Image(icon)
        .width($r('app.float.tabs_icon_size'))
        .height($r('app.float.tabs_icon_size'))
        .objectFit(ImageFit.Contain)
        .fillColor(this.currentIndex === targetIndex ? $r('app.color.tabs_text_selected_color') :
        $r('app.color.tabs_text_unselect_color'))
      Text(title)
        .fontFamily($r('app.string.medium_font_family'))
        .fontSize($r('app.float.tabs_text_size'))
        .fontColor(this.currentIndex === targetIndex ? $r('app.color.tabs_text_selected_color') :
        $r('app.color.tabs_text_unselect_color'))
        .textAlign(TextAlign.Center)
        .lineHeight($r('app.float.tabs_text_line_height'))
        .fontWeight(Constants.FONT_WEIGHT[1])
    }
    .width(Constants.FULL_WIDTH)
    .height(this.curBp === Constants.BREAKPOINT_LG ? $r('app.float.tabs_width') : Constants.FULL_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(targetIndex);
    })
  }

  @Builder
  CustomNavBar() {
    Flex({
      direction: this.curBp === Constants.BREAKPOINT_LG ?
        FlexDirection.Column : FlexDirection.Row,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Center
    }) {
      ForEach(this.menus, (menu: Menu, index: number) => {
        this.tabBuilder(menu.getTitle(), index, menu.getIcon())
      })
    }
    .width(this.curBp === Constants.BREAKPOINT_LG ? $r('app.float.tabs_width') : Constants.FULL_WIDTH)
    .height(this.curBp === Constants.BREAKPOINT_LG ? Constants.FULL_HEIGHT : $r('app.float.tabs_height'))
    .backgroundColor($r('app.color.bar_background_color'))
  }

  build() {
    Navigation(this.pathInfos) {
      Stack({ alignContent: Alignment.TopStart }) {
        Image($r('app.media.header_background'))
          .height($r('app.float.background_image_height'))
          .width(Constants.FULL_WIDTH)
          .objectFit(ImageFit.Fill)

        Flex({
          direction: this.curBp === Constants.BREAKPOINT_LG ?
            FlexDirection.RowReverse : FlexDirection.Column,
        }) {
          Tabs({
            controller: this.tabsController
          }) {
            TabContent() {
              Home()
            }

            TabContent() {
            }

            TabContent() {
            }

            TabContent() {
            }

            TabContent() {
            }
          }
          .barHeight(0)
          .scrollable(false)

          this.CustomNavBar()
        }
        .margin({ top: $r('app.float.avoid_area_top') })
      }
      .backgroundColor($r('app.color.body_background_color'))
      .padding({ bottom: $r('app.float.avoid_area_bottom') })
    }
    .hideTitleBar(true)
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
  }
}