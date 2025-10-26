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
* FAQ:Tabs组件子组件包含if节点，if条件变更后，tabBar页签联动异常，有没有解决方案
*/

// [Start tabs_linkage_abnormal]
@Entry
@Component
struct Index {
  private currentIndex: number = 0;
  private controller: TabsController = new TabsController();
  @State change: boolean = true;

  @Builder
  tabBuilder(index: number, name: string) {
    RelativeContainer() {
      Text(name)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#182431')
        .fontSize(16)
        .fontWeight(this.currentIndex === index ? 500 : 400)
        .height('auto')
        .padding({
          left: 8,
          right: 8,
          top: 6,
          bottom: 6
        })
        .id('textTitle')
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })
      Divider()
        .strokeWidth(1)
        .color('#C3C3C3')
        .width(100)
        .alignRules({ bottom: { anchor: '__container__', align: VerticalAlign.Bottom } })
      Divider()
        .strokeWidth(2)
        .color('#007DFF')
        .opacity(this.currentIndex === index ? 1 : 0)
        .width(100)
        .alignRules({ bottom: { anchor: '__container__', align: VerticalAlign.Bottom } })
    }
    .width(100)
    .backgroundColor('#F0F1F3')
  }

  build() {
    RelativeContainer() {
      Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
        TabContent() {
          Text('Page One')
        }
        .tabBar(this.tabBuilder(0, 'Page One'))
        .backgroundColor('#ffa2051d')

        TabContent() {
          Text('Page Two, Click on Page Three to show or hide')
            .onClick(() => {
              this.change = !this.change;
            })
        }
        .tabBar(this.tabBuilder(1, 'Page Two'))
        .backgroundColor('#ffefd005')

        if (this.change) {
          TabContent() {
            Text('Page Three')
          }
          .tabBar(this.tabBuilder(2, 'Page Three'))
          .backgroundColor('#ff061ef8')

          TabContent() {
            Text('Page Four')
          }
          .tabBar(this.tabBuilder(3, 'Page Four'))
          .backgroundColor('#ff039105')

          TabContent() {
            Text('Page Five')
          }
          .tabBar(this.tabBuilder(4, 'Page Five'))
          .backgroundColor('#ff02e7c4')
        }
        // When the page is hidden, it is necessary to ensure that the first parameter Index of the TabContent page is continuous
        else {
          TabContent() {
            Text('Page Four')
          }
          .tabBar(this.tabBuilder(2, 'Page Four'))
          .backgroundColor('#ff039105')

          TabContent() {
            Text('Page Five')
          }
          .tabBar(this.tabBuilder(3, 'Page Five'))
          .backgroundColor('#ff02e7c4')
        }
      }
      .barMode(BarMode.Scrollable)
      .barBackgroundColor('#fff3f3f3')
      .onChange((index) => {
        this.currentIndex = index;
      })
      .animationDuration(400)
      .scrollable(true)
      .vertical(false)
      .width('100%')
      .fadingEdge(false)
    }
  }
}

// [End tabs_linkage_abnormal]