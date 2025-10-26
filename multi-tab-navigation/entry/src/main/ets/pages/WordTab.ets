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
struct WordTab {
  @State tabArray: Array<TabItem> = initTabData();
  @State currentIndex: number = 0;
  // [Start Word_tab_tab_builder]
  @Builder
  tabBuilder(index: number, name: string | Resource) {
    Text(name)
      .fontColor(Color.Black)
      .fontSize(this.currentIndex === index ? 20 : 16)
      .fontWeight(this.currentIndex === index ? 600 : FontWeight.Normal)
      .lineHeight(22)
      .id(index.toString())
  }
  // [End Word_tab_tab_builder]

  build() {
    // [Start Word_tab_tabs]
    Tabs({ barPosition: BarPosition.Start }) {
      ForEach(this.tabArray.slice(0, 4), (item: TabItem) => {
        TabContent() {
          Row() {
            Text(item.name)
              .height(300)
              .fontSize(30)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .height('100%')
        }.tabBar(this.tabBuilder(item.id, item.name))
      }, (item: TabItem, index: number) => JSON.stringify(item) + index)
    }
    // [End Word_tab_tabs]
    .barWidth('100%')
    .barHeight(52)
    .width('100%')
    .height('100%')
    .animationDuration(Constants.ANIMATION_DURATION)
    .onAnimationStart((index: number, targetIndex: number) => {
      hilog.info(0x0000, 'index', index.toString());
      this.currentIndex = targetIndex;
    })
  }
}