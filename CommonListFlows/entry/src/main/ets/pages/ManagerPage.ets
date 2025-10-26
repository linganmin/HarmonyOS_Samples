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

import { CustomListItem } from './CustomListItem';

@Builder
export function ManagerPageBuilder() {
  ManagerPage()
}

@Preview
@Component
struct ManagerPage {
  @State currentTabIndex: number = 0;
  @State currentIndex: number = 0;
  private borderRadiusVal = 16;
  private listScroller: Scroller = new Scroller();
  private scrollController: Scroller = new Scroller();
  private tabsController: TabsController = new TabsController();
  private contentTabController: TabsController = new TabsController();
  private tabArray: Resource[] =
    [$r('app.string.follow'), $r('app.string.hot_search'), $r('app.string.recommend'), $r('app.string.more')];

  // More investment content.
  @Builder
  moreContentBuilder(value: Resource) {
    Row() {
      Image($r('app.media.app_icon'))
        .width(28)
        .height(28)
        .opacity(0.6)
      Text(value)
        .fontSize(16)
        .padding({ left: 16 })
    }
    .width('100%')
    .padding(16)
  }

  // TabBar Builder
  // [Start tab_builder]
  @Builder
  tabBuilder(img: Resource, title: Resource, index: number) {
    Column() {
      Image(img)
        // [StartExclude tab_builder]
        .width(24)
        .height(24)
        // [EndExclude tab_builder]
        .fillColor(this.currentIndex === index ? '#0a59f7' : '#66000000')
      Text(title)
        // [StartExclude tab_builder]
        .margin({ top: '4vp' })
        .fontSize(10)
        .fontWeight(500)
        // [EndExclude tab_builder]
        .fontColor(this.currentIndex === index ? '#0a59f7' : '#66000000')
    }
    // [StartExclude tab_builder]
    .justifyContent(FlexAlign.Center)
    .height('56vp')
    .width('100%')
    // [EndExclude tab_builder]
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(this.currentIndex);
    })
  }
  // [End tab_builder]

  build() {
    NavDestination() {
      // [Start bottom_tabs]
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        TabContent() {
          // [StartExclude bottom_tabs]
          Stack({ alignContent: Alignment.Top }) {
            // [Start home_page_content]
            // Home page content.
            Scroll(this.scrollController) {
              Column() {
                // Image position-holder area
                Image($r('app.media.pic5'))
                  // [StartExclude home_page_content]
                  .width('100%')
                  .height(186)
                  .borderRadius(this.borderRadiusVal)
                  // [EndExclude home_page_content]

                Column() {
                  // Customize tabBar.
                  Row({ space: 16 }) {
                    ForEach(this.tabArray, (item: string, index: number) => {
                      Text(item)
                        .fontColor(this.currentTabIndex === index ? '#0a59f7' : Color.Black)
                        .onClick(() => {
                          // Click to switch tabs content.
                          this.contentTabController.changeIndex(index);
                          this.currentTabIndex = index;
                        })
                    }, (item: string) => item)
                  }
                  // [StartExclude home_page_content]
                  .width('100%')
                  .height(40)
                  .justifyContent(FlexAlign.Start)
                  // [EndExclude home_page_content]

                  // Tabs
                  // [Start list_nested_scroll]
                  Tabs({ barPosition: BarPosition.Start, controller: this.contentTabController }) {
                    TabContent() {
                      List({ space: 10, scroller: this.listScroller }) {
                        // [StartExclude list_nested_scroll]
                        CustomListItem({
                          imgUrl: $r('app.media.pic1'),
                          title: $r('app.string.manager_content')
                        })
                        // [StartExclude home_page_content]
                        CustomListItem({
                          imgUrl: $r('app.media.pic2'),
                          title: $r('app.string.manager_content')
                        })
                        CustomListItem({
                          imgUrl: $r('app.media.pic3'),
                          title: $r('app.string.manager_content')
                        })
                        CustomListItem({
                          imgUrl: $r('app.media.pic4'),
                          title: $r('app.string.manager_content')
                        })
                        // [EndExclude home_page_content]
                        // [EndExclude list_nested_scroll]
                      }
                      // [StartExclude list_nested_scroll]
                      // [StartExclude home_page_content]
                      .width('100%')
                      .height('100%')
                      .scrollBar(BarState.Off)
                      .edgeEffect(EdgeEffect.None)
                      // [EndExclude list_nested_scroll]
                      // Customize the tabBar to achieve ceiling suction by combining the nestedScroll attribute with Calc to calculate height.
                      .nestedScroll({
                        scrollForward: NestedScrollMode.PARENT_FIRST, // Set the effect of scrolling the component to the end: The parent component rolls first, and then rolls itself to the edge
                        scrollBackward: NestedScrollMode.SELF_FIRST // Set the effect of rolling the component to the start end: Rolls itself first, and then the parent component scrolls to the edge
                      })
                      // [EndExclude home_page_content]
                    }
                    .tabBar('follow')
                    // [StartExclude list_nested_scroll]
                    // [StartExclude home_page_content]
                    TabContent() {
                      Text($r('app.string.hot_search_content'))
                    }
                      .tabBar($r('app.string.hot_search'))

                    TabContent() {
                      Text($r('app.string.recommend_content'))
                    }
                    .tabBar($r('app.string.recommend'))

                    TabContent() {
                      Text($r('app.string.more_content'))
                    }
                    .tabBar($r('app.string.more'))
                    // [EndExclude home_page_content]
                    // [EndExclude list_nested_scroll]
                  }
                  // [StartExclude home_page_content]
                  .barHeight(0)
                  .height('calc(100% - 100vp)')
                  .onChange((index: number) => {
                    this.currentTabIndex = index;
                  })
                  // [End list_nested_scroll]
                  // [EndExclude home_page_content]
                }
                // [StartExclude home_page_content]
                .margin({ top: 12 })
                .backgroundColor(0xF1F3F5)
                // [EndExclude home_page_content]
              }
            }
            // [StartExclude home_page_content]
            .width('100%')
            .height('100%')
            .margin({ top: 65 })
            // [EndExclude home_page_content]
            .scrollBar(BarState.Off) // Hide the scroll bar
            // [End home_page_content]

            // Top input box.
            // [Start top_input_box]
            Row() {
              Image($r('app.media.app_icon'))
                // [StartExclude top_input_box]
                .width(30)
                .height(30)
                // [EndExclude top_input_box]
              Search({
                placeholder: $r('app.string.want_search'),
              })
                .searchButton('search', { fontSize: 14 })
                // [StartExclude top_input_box]
                .width('100%')
                .height(40)
                .textFont({ size: 14 })
                .placeholderFont({ size: 14 })
                .backgroundColor('#E6E8E9')
                .layoutWeight(1)
                .margin({ left: 16, right: 16 })
                // [EndExclude top_input_box]
              Text($r('app.string.search'))
                // [StartExclude top_input_box]
                .fontSize(14)
                // [EndExclude top_input_box]
            }
            // [End top_input_box]
            .width('100%')
            .height(60)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height('100%')
          .padding({ left: 16, right: 16 })
          // [EndExclude bottom_tabs]
        }
        .tabBar(this.tabBuilder($r('app.media.mine'), $r('app.string.tabBar1'), 0))

        // [StartExclude bottom_tabs]
        TabContent() {
          Text($r('app.string.tabBar2_content'))
        }
        .tabBar(this.tabBuilder($r('app.media.mine'), $r('app.string.tabBar2'), 1))

        TabContent() {
          Text($r('app.string.tabBar3_content'))
        }
        .tabBar(this.tabBuilder($r('app.media.mine'), $r('app.string.tabBar3'), 2))

        TabContent() {
          Text($r('app.string.tabBar4_content'))
        }
        .tabBar(this.tabBuilder($r('app.media.mine'), $r('app.string.tabBar4'), 3))

        TabContent() {
          Text($r('app.string.tabBar5_content'))
        }
        .tabBar(this.tabBuilder($r("app.media.mine"), $r('app.string.tabBar5'), 4))
        // [EndExclude bottom_tabs]
      }
      // [StartExclude bottom_tabs]
      .barHeight(56)
      .vertical(false)
      .barMode(BarMode.Fixed)
      // [EndExclude bottom_tabs]
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      // [End bottom_tabs]
    }
    .hideTitleBar(true)
    .backgroundColor(0xF1F3F5)
  }
}