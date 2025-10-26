/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
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
* FAQ:Tabs如何设置页面margin，使得边距空白跟随页面滑动
*/

// [Start SetTabsMarginDemo]
@Entry
@Component
struct SetTabsMarginDemo {
  private tabsController: TabsController = new TabsController()
  @State currentIndex: number = 0;

  @Builder
  TabBarBuilder(title: string, targetIndex: number) {
    Column(){
      Text(title)
        .fontWeight(targetIndex === this.currentIndex ? FontWeight.Bold : FontWeight.Normal).margin({ left: 10, right: 10 })
        .fontColor(targetIndex === this.currentIndex ? Color.Orange : Color.Gray)
        .onClick(() => {
          this.tabsController.changeIndex(targetIndex)
        })
    }
  }

  build() {
    Row() {
      Column() {
        Flex({ direction: FlexDirection.Row }) {
          this.TabBarBuilder('页签1', 0)
          this.TabBarBuilder('页签2', 1)
          this.TabBarBuilder('页签3', 2)
        }

        Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
          TabContent() {
            Column() {
              Text("页签1页面")
            }
            .height('100%')
            .width('100%')
            .backgroundColor(Color.Yellow)
          }
          // The place where the margins are correctly set.
          .margin({left : 10, right :10})

          TabContent() {
            Column() {
              Text("页签2页面")
            }
            .height('100%')
            .width('100%')
            .backgroundColor(Color.Green)
          }
          // The place where the margins are correctly set.
          .margin({left : 10, right :10})

          TabContent() {
            Column() {
              Text("页签3页面")
            }
            .height('100%')
            .width('100%')
            .backgroundColor(Color.Pink)
          }
          // The place where the margins are correctly set.
          .margin({left : 10, right :10})
        }
        // The parameter for adjusting the margins should not be added here, as it may affect the user experience.
        // .margin({left : 10, right :10})
        .onChange((index: number) => {
          this.currentIndex = index;
        })
      }
    }
  }
}
// [End SetTabsMarginDemo]