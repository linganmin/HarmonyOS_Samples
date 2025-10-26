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

import WorkComponent from './WorkComponent'

@Component
export default struct WorkTabsComponent {
  @State currentIndex: number = 0;

  @Builder
  buildAdd() {
    SymbolGlyph($r('sys.symbol.plus_square'))
      .fontSize(40)
      .fontColor([Color.White])
  }

  @Builder
  tabBuild(title: string | Resource, targetIndex: number) {
    Text(title)
      .fontColor(Color.White)
      .fontWeight(this.currentIndex === targetIndex ? FontWeight.Medium : FontWeight.Normal)
      .fontSize(this.currentIndex === targetIndex ? 20 : 15)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      // homepage
      TabContent() {
        // core component
        Stack({ alignContent: Alignment.Bottom }) {
          Column()
            .width('100%')
            .height('30%')
            .backgroundColor(Color.White)

          WorkComponent()
        }
      }
      .tabBar(this.tabBuild($r('app.string.homePage'), 0))
      // friend
      TabContent() {
      }
      .tabBar(this.tabBuild($r('app.string.friend'), 1))
      // publish
      TabContent() {
      }
      .tabBar(this.buildAdd())
      // message
      TabContent() {
      }
      .tabBar(this.tabBuild($r('app.string.message'), 3))
      // me
      TabContent() {
      }
      .tabBar(this.tabBuild($r('app.string.me'), 4))
    }
    .scrollable(false)
    .barBackgroundColor(Color.Black)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}