/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { getTabBars, TabBar } from '../models/Index';
import { Home } from './home/Index';

@Component
export struct Shopping {
  @State activeTabIndex: number = 0;

  @Builder
  TabBarBuilder(tabBar: TabBar, index: number) {
    Column() {
      Image(this.isActive(index) ? tabBar.activeIcon : tabBar.icon)
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
      Text(tabBar.text)
        .fontSize(10)
        .fontWeight(500)
        .fontColor(this.isActive(index) ? '#D0092D' : Color.Black)
        .opacity(this.isActive(index) ? 1 : 0.4)
    }
  }

  isActive(index: number): boolean {
    return this.activeTabIndex === index;
  }

  onActiveTabChange(index: number) {
    this.activeTabIndex = index;
  }

  build() {
    NavDestination() {
      // [Start tabs]
      // features/shopping/src/main/ets/views/Index.ets
      Tabs({ barPosition: BarPosition.End }) {
        // [StartExclude tabs]
        ForEach(getTabBars(), (tabBar: TabBar, index) => {
          TabContent() {
            if (index === 0) {
              Home()
            }
          }
          .tabBar(this.TabBarBuilder(tabBar, index))
        }, (tabBar: TabBar) => JSON.stringify(tabBar))
        // [EndExclude tabs]
      }
      .backgroundColor('#F1F3F5')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      // [End tabs]
      .onChange((index: number) => this.onActiveTabChange(index))
    }
    .hideTitleBar(true)
  }
}
