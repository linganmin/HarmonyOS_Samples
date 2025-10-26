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
import { HomeFullView } from '@ohos/home/Index';
import { FooterTabViewModel } from '../viewmodel/FooterTabViewModel';

@Component
export struct TabView {
  @State currentIndex: number = 0;
  @Link mapController: map.MapComponentController;
  @Link columnHeight: number;
  private tabsController: TabsController = new TabsController();
  private tabList: ColumnTab[] = new FooterTabViewModel(this.getUIContext().getHostContext()!).getTabList();

  @Builder
  TabBuilder(item: ColumnTab, targetIndex: number) {
    Column() {
      Image(targetIndex !== this.currentIndex ? item.getIcon() : item.getIconSelected())
        .height($r('app.float.tab_image_size'))
        .width($r('app.float.tab_image_size'))
      Text(item.getName())
        .fontSize($r('app.float.tab_font_size'))
        .fontColor((this.currentIndex === targetIndex) ?
          $r('app.color.tab_font_selected_color') : $r('app.color.tab_font_unselected'))
    }
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(this.currentIndex);
    })
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {
        HomeFullView({ mapController: this.mapController, columnHeight: this.columnHeight })
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
    }
    .scrollable(false)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .barHeight($r('app.float.tab_height'))
    .margin({ bottom: $r('app.float.tab_margin_bottom') })
    .width(Common.FULL_WIDTH)
    .height(Common.FULL_HEIGHT)
  }
}