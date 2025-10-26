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

import { componentUtils } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { initTabData } from '../viewmodel/TabViewModel';
import { TabItem } from '../viewmodel/TabItem';
import { Constants } from '../common/Constants';

@Entry
@Component
struct SlideAndMoreTab {
  @State tabArray: Array<TabItem> = initTabData();
  @State focusIndex: number = 0;
  @State pre: number = 0;
  @State index: number = 0;
  @State test: boolean = false;
  @State indicatorLeftMargin: number = 0;
  @State indicatorWidth: number = 0;
  private controller: TabsController = new TabsController();
  private listScroller: Scroller = new Scroller();
  private tabsWidth: number = 0;
  private tabWidth: number = 0;
  private iteration: number = 1;
  private swipeRatio: number = 0.5;

  @Builder
  Tab(tabName: string | Resource, tabIndex: number) {
    Row() {
      Text(tabName)
        .fontSize(16)
        .fontColor(tabIndex === this.focusIndex ? '#0A59F7' : '#E6000000')
        .id(tabIndex.toString())
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          if (this.focusIndex === tabIndex &&
            (this.indicatorLeftMargin === 0 || this.indicatorWidth === 0)) {
            if (newValue.position.x !== undefined) {
              let positionX = Number.parseFloat(newValue.position.x.toString());
              this.indicatorLeftMargin = Number.isNaN(positionX) ? 0 : positionX;
            }
            let width = Number.parseFloat(newValue.width.toString());
            this.tabWidth = Number.isNaN(width) ? 0 : width;
            this.indicatorWidth = this.tabWidth;
          }
        })
    }
    .padding({ left: 12, right: 12 })
    .justifyContent(FlexAlign.Center)
    .height(30)
    .onClick(() => {
      this.controller.changeIndex(tabIndex);
      this.focusIndex = tabIndex;
    })
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          // [Start Slide_and_moreTab_row_part]
          Row() {
            List({ initialIndex: 0, scroller: this.listScroller }) {
              ForEach(this.tabArray, (item: TabItem, index: number) => {
                this.Tab(item.name, index)
              }, (item: TabItem, index: number) => JSON.stringify(item) + index)
            }
            .listDirection(Axis.Horizontal)
            .height(30)
            .scrollBar(BarState.Off)
            .width('85%')
            .friction(0.6)
            .onWillScroll((xOffset: number) => {
              this.indicatorLeftMargin -= xOffset;
            })

            Image($r('app.media.more'))
              .width(20)
              .height(15)
              .margin({ left: 16 })
          }
          .height(52)
          .width('100%')
          // [End Slide_and_moreTab_row_part]
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')

        Column()
          .height(2)
          .width(this.indicatorWidth)
          .margin({ left: this.indicatorLeftMargin, top: 40 })
          .backgroundColor('#0A59F7')
      }
      .width('100%')

      Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
        ForEach(this.tabArray, (item: TabItem) => {
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
        }, (item: TabItem, index: number) => JSON.stringify(item) + index)
      }
      .onAreaChange((_oldValue: Area, newValue: Area) => {
        let width = Number.parseFloat(newValue.width.toString());
        this.tabsWidth = Number.isNaN(width) ? 0 : width;
      })
      .width('100%')
      .barHeight(0)
      .animationDuration(Constants.ANIMATION_DURATION)
      .onAnimationStart((index: number, targetIndex: number) => {
        hilog.info(0x0000, 'index', index.toString());
        this.focusIndex = targetIndex;
        let targetIndexInfo = this.getTextInfo(targetIndex);
        this.startAnimateTo(Constants.ANIMATION_DURATION, targetIndexInfo.left, targetIndexInfo.width);
        this.listScroller.scrollToIndex(targetIndex, true, ScrollAlign.CENTER);
      })
      .onAnimationEnd((index: number, event: TabsAnimationEvent) => {
        let currentIndicatorInfo = this.getCurrentIndicatorInfo(index, event);
        this.startAnimateTo(0, currentIndicatorInfo.left, currentIndicatorInfo.width);
      })
      .onGestureSwipe((index: number, event: TabsAnimationEvent) => {
        let currentIndicatorInfo = this.getCurrentIndicatorInfo(index, event);
        this.focusIndex = currentIndicatorInfo.index;
        this.indicatorLeftMargin = currentIndicatorInfo.left;
        this.tabWidth = currentIndicatorInfo.width;
        this.indicatorWidth = currentIndicatorInfo.width;
      })
    }
    .height('100%')
  }

  // Gets component size, position, translation, scaling rotation, and affine matrix attribute information.
  private getTextInfo(index: number): Record<string, number> {
    let modePosition: componentUtils.ComponentInfo | null = null;
    try {
      modePosition = this.getUIContext().getComponentUtils().getRectangleById(index.toString());
    } catch (error) {
      hilog.error(0x0000, 'testTag',`getRectangleById failed, Code:${error.code}, message:${error.message}`);
    }
    return { 'left': this.getUIContext().px2vp(modePosition?.windowOffset.x), 'width': this.getUIContext().px2vp(modePosition?.size.width) }
  }

  private getCurrentIndicatorInfo(index: number, event: TabsAnimationEvent): Record<string, number> {
    let nextIndex = index;
    if (index > Constants.TAB_INDEX_ZERO && event.currentOffset > Constants.TAB_INDEX_ZERO) {
      nextIndex--;
    } else if (index < this.tabArray.length - Constants.TAB_INDEX_ONE && event.currentOffset < Constants.TAB_INDEX_ZERO) {
      nextIndex++;
    }
    let indexInfo = this.getTextInfo(index);
    let nextIndexInfo = this.getTextInfo(nextIndex);
    let swipeRatio = Math.abs(event.currentOffset / this.tabsWidth);
    let currentIndex = swipeRatio > this.swipeRatio ? nextIndex : index;
    let currentLeft = indexInfo.left + (nextIndexInfo.left - indexInfo.left) * swipeRatio;
    let currentWidth = indexInfo.width + (nextIndexInfo.width - indexInfo.width) * swipeRatio;
    return { 'index': currentIndex, 'left': currentLeft, 'width': currentWidth };
  }

  private startAnimateTo(duration: number, leftMargin: number, width: number) {
    this.getUIContext().animateTo({
      duration: duration,
      curve: Curve.Linear,
      iterations: this.iteration,
      playMode: PlayMode.Normal,
    }, () => {
      this.indicatorLeftMargin = leftMargin;
      this.indicatorWidth = width;
    })
  }
}