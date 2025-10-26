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
* FAQ:Tabs组件，自定义tabBar切换动画有延迟，Tabs页面切换完才触发tabBar切换，如何修改
*/

// [Start tabBar_animation]
@Component
struct TabsDemo {
  @State tabArray: Array<number> = [0, 1, 2, 3];
  @State selectedIndex: number = 0;
  @State currentIndex: number = 0;
  @State selectedFontColor: Color = Color.Blue;
  @State fontColor: Color = Color.Black;
  private controller: TabsController = new TabsController();

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontSize(16)
        .lineHeight(22)
        .fontWeight(this.selectedIndex === index ? 500 : 400)
        .fontColor(this.selectedIndex === index ? this.selectedFontColor : this.fontColor)

      Divider()
        .strokeWidth(2)
        .color('#007DEF')
        .opacity(this.selectedIndex === index ? 1 : 0)
    }
    .width('100%')
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
        ForEach(this.tabArray,(item: number, index:number) => {
          // The system has its own tab.
          TabContent() {
            Text('我的内容' + item)
              .fontSize(30)
          }
          .tabBar(this.tabBuilder(item, 'bar' + item))
        })
      }
      .onChange((index: number) => {
        // CurrentIndex Control TabContent Display Tab.
        this.currentIndex = index;
      })
      .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
        if(index === targetIndex) {
          return;
        }
        // SelectedIndex controls the color switching between Image and Text in the custom TabBar.
        this.selectedIndex = targetIndex;
      })
    }
    .width('100%')
  }
}
// [End tabBar_animation]