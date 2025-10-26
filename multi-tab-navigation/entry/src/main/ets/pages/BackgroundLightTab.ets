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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { initTabData } from '../viewmodel/TabViewModel';
import { TabItem } from '../viewmodel/TabItem';
import { Constants } from '../common/Constants';

@Entry
@Component
struct BackgroundLightTab {
  @State tabArray: Array<TabItem> = initTabData();
  @State focusIndex: number = 0;
  @State index: number = 0;
  private controller: TabsController = new TabsController();
  private listScroller: Scroller = new Scroller();
  private barHeight: number = 0;

  @Builder
  tabBuilder(tabName: string | Resource, tabIndex: number) {
    Row() {
      Text(tabName)
        .fontSize(14)
        .fontColor(tabIndex === this.focusIndex ? Color.White : '#E6000000')
        .id(tabIndex.toString())
    }
    .justifyContent(FlexAlign.Center)
    .width(96)
    .backgroundColor(tabIndex === this.focusIndex ? '#0A59F7' : '#0D000000')
    .borderRadius(21)
    .height(40)
    .margin({ left: 8, right: 8 })
    .onClick(() => {
      this.controller.changeIndex(tabIndex);
      this.listScroller.scrollToIndex(tabIndex, true, ScrollAlign.CENTER);
    })
  }

  build() {
    Column() {
      Row() {
        // [Start BackgroundLightTab_list]
        List({ scroller: this.listScroller }) {
          ForEach(this.tabArray.slice(0, 6),
            (item: TabItem, index: number) => {
              this.tabBuilder(item.name, index);
            }, (item: TabItem, index: number) => JSON.stringify(item) + index)
        }
        // [End BackgroundLightTab_list]
        .width('100%')
        .height('100%')
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
      }
      .alignItems(VerticalAlign.Center)
      .height(52)
      .margin({ top: 8 })
      // [Start Underline_tab_tabs_part]
      Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
        ForEach(this.tabArray.slice(0, 6),
          (item: TabItem) => {
            TabContent() {
              Row() {
                Text(item.name)
                  .height(300)
                  .fontSize(30)
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
            .backgroundColor(Color.White)
          }, (item: TabItem, index: number) => JSON.stringify(item) + index)
      }
      .width('100%')
      // [End Underline_tab_tabs_part]
      .barHeight(this.barHeight)
      .animationDuration(Constants.ANIMATION_DURATION)
      .onAnimationStart((index: number, targetIndex: number) => {
        hilog.info(0x0000, 'index', index.toString());
        this.focusIndex = targetIndex;
        this.listScroller.scrollToIndex(targetIndex, true, ScrollAlign.CENTER);
      })
    }
    .height('100%')
  }
}