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

import { map } from '@kit.MapKit';
import { Common, ColumnTab } from '@ohos/commons/Index';
import { TabViewModel } from '../viewmodel/TabViewModel';
import { RouteContentView } from './RouteContentView';

@Component
export struct RouteTabView {
  @State currentIndex: number = 0;
  @Link columnHeight: number;
  @Link mapController: map.MapComponentController;
  private tabsController: TabsController = new TabsController();
  private tabList: ColumnTab[] = new TabViewModel(this.getUIContext().getHostContext()!).getTabList();

  @Builder
  TabBuilder(item: ColumnTab, targetIndex: number) {
    Row() {
      Image(item.getIconSelected())
        .visibility(this.currentIndex === targetIndex ? Visibility.Visible : Visibility.None)
        .height($r('app.float.tab_image_height'))
        .width($r('app.float.tab_image_width'))
      Text(item.getName())
        .fontSize($r('app.float.tab_font_size'))
        .fontColor((this.currentIndex === targetIndex) ?
          $r('app.color.tab_font_selected') : $r('app.color.tab_font_unselected'))
    }
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(this.currentIndex);
    })
    .justifyContent(FlexAlign.Center)
    .backgroundColor((this.currentIndex === targetIndex) ?
      $r('app.color.tab_selected') : $r('app.color.white'))
    .borderRadius($r('app.float.tab_border_radius'))
    .height($r('app.float.tab_row_height'))
    .width($r('app.float.tab_width'))
  }

  build() {
    Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
      TabContent() {
        RouteContentView({ mapController: this.mapController, columnHeight: this.columnHeight })
          .visibility(this.columnHeight > Common.HEIGHT_LOW ? Visibility.Visible : Visibility.None)
      }
      .tabBar(this.TabBuilder(this.tabList[0], 0))

      TabContent() {

      }
      .tabBar(this.TabBuilder(this.tabList[1], 1))

      TabContent() {
      }
      .tabBar(this.TabBuilder(this.tabList[2], 2))

      TabContent() {
      }
      .tabBar(this.TabBuilder(this.tabList[3], 3))

      TabContent() {
      }
      .tabBar(this.TabBuilder(this.tabList[4], 4))

      TabContent() {
      }
      .tabBar(this.TabBuilder(this.tabList[5], 5))

      TabContent() {
      }
      .tabBar(this.TabBuilder(this.tabList[6], 6))

      TabContent() {
      }
      .tabBar(this.TabBuilder(this.tabList[7], 7))
    }
    .visibility(this.columnHeight > Common.HEIGHT_LOW ? Visibility.Visible : Visibility.None)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .barHeight($r('app.float.bar_height'))
    .width(Common.FULL_WIDTH)
    .scrollable(true)
    .barMode(BarMode.Scrollable)
  }
}