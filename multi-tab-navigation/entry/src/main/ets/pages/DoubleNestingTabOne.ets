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
struct DoubleNestingTabOne {
  @State tabArray: Array<TabItem> = initTabData();
  @State topTabData: Array<string | Resource> = Constants.TOP_TAB_DATA;
  @State focusIndex: number = 0;
  @State currentIndex: number = 0;
  @State subCurrentIndex: number = 0;
  private controller: TabsController = new TabsController();
  private listScroller: Scroller = new Scroller();
  private subController: TabsController = new TabsController();
  private panOptionRight: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Left });

  @Builder
  tabBuilder(index: number, name: string | Resource) {
    Column() {
      Text(name)
        .fontColor($r('app.color.text_color'))
        .fontSize(this.currentIndex === index ? 20 : 18)
        .fontWeight(this.currentIndex === index ? 600 : FontWeight.Normal)
    }
    .width('100%')
  }
  // [Start Double_nesting_tab_one_sub_tab_builder]
  @Builder
  subTabBuilder(tabName: string | Resource, tabIndex: number) {
    Row() {
      Text(tabName)
        .fontSize(16)
        .fontColor(tabIndex === this.focusIndex ? '#0A59F7' : '#E6000000')
        .id(tabIndex.toString())
    }
    .justifyContent(FlexAlign.Center)
    .padding({ left: 12, right: 12 })
    .height(30)
    .onClick(() => {
      this.subController.changeIndex(tabIndex);
      this.focusIndex = tabIndex;
    })
  }
  // [End Double_nesting_tab_one_sub_tab_builder]

  @Builder
  contentBuilder(index: number, text: string | Resource) {
    TabContent() {
      Column() {
        Row() {
          Text(text)
            .height(300)
            .fontSize(30)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
    }
    .tabBar(this.tabBuilder(index, text))
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
        // [Start Double_nesting_tab_one_sub_tab_builder]
        TabContent() {
          Column() {
            Column() {
              Row() {
                List({ initialIndex: Constants.TAB_INDEX_ZERO, scroller: this.listScroller }) {
                  ForEach(this.tabArray, (item: TabItem, index: number) => {
                    this.subTabBuilder(item.name, index)
                  }, (item: TabItem, index: number) => JSON.stringify(item) + index)
                }
                .listDirection(Axis.Horizontal)
                .height(30)
                .scrollBar(BarState.Off)
                .width('85%')
                .friction(0.6)

                Image($r('app.media.more'))
                  .width(20)
                  .height(15)
                  .margin({ left: 16 })
              }
              .height(25)
              .width('100%')
            }
            .alignItems(HorizontalAlign.Center)
            .width('100%')
            .padding({ left: 4 })
            Tabs({ barPosition: BarPosition.Start, controller: this.subController }) {
              // [StartExclude Double_nesting_tab_one_sub_tab_builder]
              ForEach(this.tabArray, (item: TabItem) => {
                if (item.id === this.tabArray.length - 1) {
                  TabContent() {
                    Row() {
                      Text(item.name)
                        .height(300)
                        .fontSize(30)
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.Center)
                    .gesture(
                      PanGesture(this.panOptionRight)
                        .onActionEnd(() => {
                          this.controller.changeIndex(1);
                        })
                    )
                  }
                  .backgroundColor(Color.White)
                } else {
                  TabContent() {
                    Row() {
                      Text(item.name)
                        .height(300)
                        .fontSize(30)
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.Center)
                  }
                  .backgroundColor(Color.White)
                }
              }, (item: TabItem, index: number) => JSON.stringify(item) + index)
              // [EndExclude Double_nesting_tab_one_sub_tab_builder]
            }
            .barHeight(0)
            .animationDuration(Constants.ANIMATION_DURATION)
            .onAnimationStart((index: number, targetIndex: number) => {
              hilog.info(0x0000, 'index', index.toString());
              this.focusIndex = targetIndex;
              this.listScroller.scrollToIndex(targetIndex, true, ScrollAlign.CENTER);
            })
          }
        }
        .tabBar(this.tabBuilder(Constants.TAB_INDEX_ZERO, this.topTabData[Constants.TAB_INDEX_ZERO]))
        // [End Double_nesting_tab_one_sub_tab_builder]
        this.contentBuilder(Constants.TAB_INDEX_ONE, this.topTabData[Constants.TAB_INDEX_ONE])
        this.contentBuilder(Constants.TAB_INDEX_TWO, this.topTabData[Constants.TAB_INDEX_TWO])
        this.contentBuilder(Constants.TAB_INDEX_THREE, this.topTabData[Constants.TAB_INDEX_THREE])
      }
      .vertical(false)
      .barMode(BarMode.Fixed)
      .barWidth('100%')
      .barHeight(52)
      .animationDuration(Constants.ANIMATION_DURATION)
      .onAnimationStart((index: number, targetIndex: number) => {
        hilog.info(0x0000, 'index', index.toString());
        this.currentIndex = targetIndex;
      })
      .width('100%')
      .height('100%')
    }
    .width('100%')
  }
}