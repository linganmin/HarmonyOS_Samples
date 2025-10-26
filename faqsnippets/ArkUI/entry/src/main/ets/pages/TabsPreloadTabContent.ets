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
* FAQ:Tabs如何实现预加载特定的TabContent页
*/

// [Start tabs_preload_tab_content]
@Entry
@Component
struct TabsDemo {
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();
  // Set up page switching animations instead of sliding to jump to page animations
  private customContentTransition: (from: number, to: number) => TabContentAnimatedTransition =
    (from: number, to: number) => {
      let tabContentAnimatedTransition = {
        timeout: 1000,
        transition: (proxy: TabContentTransitionProxy) => {
          this.getUIContext().animateTo({
            duration: 0,
            onFinish: () => {
              proxy.finishTransition();
            }
          }, () => {
          })
        }
      } as TabContentAnimatedTransition
      return tabContentAnimatedTransition;
    }

  build() {
    Column() {
      Tabs({ index: this.currentIndex, controller: this.tabsController }) {
        TabContent() {
          MyComponent({ color: '#00CB87' })
        }.tabBar(SubTabBarStyle.of('green'))

        TabContent() {
          MyComponent({ color: '#007DFF' })
        }.tabBar(SubTabBarStyle.of('green'))

        TabContent() {
          MyComponent({ color: '#FFBF00' })
        }.tabBar(SubTabBarStyle.of('green'))

        TabContent() {
          MyComponent({ color: '#E67C92' })
        }.tabBar(SubTabBarStyle.of('green'))
      }
      .customContentTransition(this.customContentTransition)
      .width('100%')
      .height(296)
      .barBackgroundColor('#F1F3F5')
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }
  }
}

@Component
struct MyComponent {
  private color: string = '';

  aboutToAppear(): void {
    // It can be observed by printing the log that no intermediate page has been loaded
    console.info('aboutToAppear backgroundColor:' + this.color);
  }

  aboutToDisappear(): void {
    console.info('aboutToDisappear backgroundColor:' + this.color);
  }

  build() {
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor(this.color)
  }
}

// [End tabs_preload_tab_content]