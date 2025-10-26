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

import { Constants } from '../common/Constants';
import { initTabData } from '../viewmodel/TabViewModel';
import { TabItem } from '../viewmodel/TabItem';

@Component
export struct DiscoverPage {
  @State tabArray: Array<TabItem> = initTabData();
  @State focusIndex: number = 0;
  controller: TabsController = new TabsController();
  private listScroller: Scroller = new Scroller();
  private subController: TabsController = new TabsController();
  private panOptionRight: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Left });
  private barHeight: number = 0;

  @Builder
  subTabBuilder(tabName: string | Resource, tabIndex: number) {
    Row() {
      Text(tabName)
        .fontSize($r('app.float.text_size'))
        .fontColor(tabIndex === this.focusIndex ? $r('app.color.checked_color') : $r('app.color.text_color'))
        .id(tabIndex.toString())
    }
    .justifyContent(FlexAlign.Center)
    .padding({ left: Constants.TAB_PADDING, right: Constants.TAB_PADDING })
    .height(Constants.SUB_TAB_HEIGHT)
    .onClick(() => {
      this.subController.changeIndex(tabIndex);
      this.focusIndex = tabIndex;
    })
  }

  build() {
    Column() {
      Column() {
        Row() {
          List({ initialIndex: Constants.TAB_INDEX_ZERO, scroller: this.listScroller }) {
            ForEach(this.tabArray, (item: TabItem, index: number) => {
              this.subTabBuilder(item.name, index)
            }, (item: TabItem, index: number) => JSON.stringify(item) + index)
          }
          .listDirection(Axis.Horizontal)
          .height(Constants.SUB_TAB_HEIGHT)
          .scrollBar(BarState.Off)
          .width(Constants.SUB_LIST_WIDTH)
          .friction($r('app.float.list_friction'))

          Image($r('app.media.more'))
            .width(Constants.MORE_IMAGE_WIDTH)
            .height(Constants.MORE_IMAGE_HEIGHT)
            .margin({ left:  $r('app.float.margin_sixteen') })
        }
        .height(Constants.SUB_TAB_BOT_HEIGHT)
        .width(Constants.FULL_WIDTH)
      }
      .alignItems(HorizontalAlign.Center)
      .width(Constants.FULL_WIDTH)
      .padding({ left: $r('app.float.padding_double_tab_left') })

      Tabs({ barPosition: BarPosition.Start, controller: this.subController }) {
        ForEach(this.tabArray, (item: TabItem) => {
          if (item.id === this.tabArray.length - 1) {
            TabContent() {
              Row() {
                Text(item.name)
                  .height(Constants.CONTENT_HEIGHT)
                  .fontSize($r('app.float.content_font_size'))
              }
              .width(Constants.FULL_WIDTH)
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
                  .height(Constants.CONTENT_HEIGHT)
                  .fontSize($r('app.float.content_font_size'))
              }
              .width(Constants.FULL_WIDTH)
              .justifyContent(FlexAlign.Center)
            }
            .backgroundColor(Color.White)
          }
        }, (item: TabItem, index: number) => JSON.stringify(item) + index)
      }
      .barHeight(this.barHeight)
      .animationDuration(Constants.ANIMATION_DURATION)
      .onAnimationStart((_index: number, targetIndex: number) => {
        this.focusIndex = targetIndex;
        this.listScroller.scrollToIndex(targetIndex, true, ScrollAlign.CENTER);
      })
    }
  }
}