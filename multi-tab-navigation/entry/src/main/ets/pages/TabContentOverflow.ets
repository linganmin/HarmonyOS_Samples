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

import { TabContentConstants } from '../common/TabContentConstants';
import { VideoTabContent } from '../view/VideoTabContent';

@Entry
@Component
struct TabContentOverFlow {
  @State tabArray: string[] = TabContentConstants.TAB_ARRAY;
  @State imageArray: string[] = TabContentConstants.IMAGE_ARRAY;
  @State imageClickArray: string[] = TabContentConstants.IMAGE_CLICK_ARRAY;
  @State index: number = 1;
  private tabsController: TabsController = new TabsController();

  build() {
    RelativeContainer() {
      Tabs({ index: this.index, controller: this.tabsController }) {
        TabContent() {
          Text($r('app.string.tip1'))
            .fontSize($r('app.integer.tab_text_size'))
        }
        .align(Alignment.Center)
        .height($r('app.string.tab_video_height'))
        .width($r('app.string.tab_full_size'))

        TabContent() {
          VideoTabContent()
        }

        TabContent() {
          Text($r('app.string.tip2'))
            .fontSize($r('app.integer.tab_text_size'))
        }
        .align(Alignment.Center)
        .height($r('app.string.tab_video_height'))
        .width($r('app.string.tab_full_size'))

        TabContent() {
          Text($r('app.string.tip3'))
            .fontSize($r('app.integer.tab_text_size'))
        }
        .align(Alignment.Center)
        .height($r('app.string.tab_video_height'))
        .width($r('app.string.tab_full_size'))
      }
      .zIndex(TabContentConstants.TAB_Z_INDEX)
      .scrollable(false)
      .barHeight($r('app.integer.tabs_bar_height'))
      .animationDuration(TabContentConstants.TAB_TABS_DURATION)
      .onChange((index: number) => {
        this.index = index;
      })
      .hitTestBehavior(HitTestMode.Transparent)
      .id(TabContentConstants.TAB_TABS)
      .alignRules({
        top: { anchor: TabContentConstants.TAB_CONTAINER, align: VerticalAlign.Top },
        left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start }
      })

      Row() {
        ForEach(this.tabArray, (item: string, index: number) => {
          Column() {
            Text($r(item))
              .fontColor(this.index === index ? $r('app.color.tab_click_color') :
              $r('app.color.tab_white'))
              .margin({ top: $r('app.integer.tab_white_top') })
          }
          .width($r('app.integer.tab_row_column_width'))
          .margin({ top: $r('app.integer.tab_margin_small') })
          .height($r('app.integer.tab_row_column_height'))
          .onClick(() => {
            this.index = index;
            this.tabsController.changeIndex(this.index);
          })
        }, (item: string, index: number) => JSON.stringify(item) + index)
      }
      .offset({
        y: $r('app.integer.tab_row_offset')
      })
      .width($r('app.string.tab_full_size'))
      // Extend to all non-secure areas.
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .backgroundColor($r('app.color.tab_row_background'))
      .justifyContent(FlexAlign.SpaceAround)
      .id(TabContentConstants.TAB_TAB_BAR)
      .alignRules({
        top: { anchor: TabContentConstants.TAB_CONTAINER, align: VerticalAlign.Bottom },
        left: { anchor: TabContentConstants.TAB_CONTAINER, align: HorizontalAlign.Start }
      })
    }
  }
}