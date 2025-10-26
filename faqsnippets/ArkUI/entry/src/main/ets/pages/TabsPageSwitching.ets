/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:如何控制Tabs内容页单向滑动切换
*/

// [Start tabs_page_switching]
@Component
struct TabsPageSwitching {
  @State currentIndex: number = 0;
  private controller: TabsController = new TabsController();
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Right });

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontSize(16)
        .lineHeight(22)
        .margin({ top: 16, bottom: 16 })
        .fontColor(this.currentIndex === index ? Color.Blue : Color.Black)

      Divider()
        .strokeWidth(2)
        .color(Color.Blue)
        .opacity(this.currentIndex === index ? 1 : 0)
    }
    .width('100%')
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
        TabContent() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(Color.Green)
        }
        .tabBar(this.tabBuilder(0, 'Tab1'))

        TabContent() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(Color.Pink)
            .gesture(PanGesture(this.panOption))
        }
        .tabBar(this.tabBuilder(1, 'Tab2'))

        TabContent() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(Color.Orange)
            .gesture(PanGesture(this.panOption))
        }
        .tabBar(this.tabBuilder(2, 'Tab3'))
      }
      .vertical(false)
      .barMode(BarMode.Fixed)
      .barWidth(360)
      .barHeight(56)
      .animationDuration(200)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .width('100%')
      .height(296)
      .margin({ top: 52 })
    }
    .width('100%')
  }
}
// [End tabs_page_switching]