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
* FAQ:Tab组件页面切换时，如何不显示中间过渡的tab页
*/

// [Start do_not_display_transitional_tabs]
@Entry
@Component
struct TABTransitionAnimation {
  @State fontColor: string = '#182431';
  @State selectedFontColor: string = '#007DFF';
  @State currentIndex: number = 0;
  private tabController: TabsController = new TabsController();

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize(16)
        .fontWeight(this.currentIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({
          top: 17,
          bottom: 7
        })
      Divider()
        .strokeWidth(2)
        .color($r('sys.color.brand'))
        .opacity(this.currentIndex === index ? 1 : 0)
    }
    .width('100%')
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.tabController }) {
        TabContent() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#00CB87')
        }.tabBar(this.tabBuilder(0, 'green'))


        TabContent() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor($r('sys.color.brand'))
        }.tabBar(this.tabBuilder(1, 'blue'))


        TabContent() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor($r('sys.color.multi_color_11'))
        }.tabBar(this.tabBuilder(2, 'yellow'))


        TabContent() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#E67C92')
        }
        .tabBar(this.tabBuilder(3, 'pink'))
      }
      .width(360)
      .height(296)
      .barWidth(360)
      .barHeight(56)
      .vertical(false)
      .barMode(BarMode.Fixed)
      .backgroundColor('#F1F3F5')
      .margin({ top: 52 })
      .animationDuration(0) // Setting the animation time to 0 can solve the problem of switching between pages and displaying intermediate transition pages
      .onChange((index: number) => {
        if (index >= 0 && index <= 3) {
          this.currentIndex = index;
        }
      })
    }
    .width('100%')
  }
}

// [End do_not_display_transitional_tabs]