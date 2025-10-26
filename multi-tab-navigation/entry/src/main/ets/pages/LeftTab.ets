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
import { resourceManager } from '@kit.LocalizationKit';

@Entry
@Component
struct LeftTab {
  @State tabArray: Array<number> = [0, 1, 2];
  @State currentIndex: number = 0;
  @State indicatorLeftMargin: number = 0;
  @State indicatorWidth: number = 0;
  @State tabsWidth: number = 0;
  private controller: TabsController = new TabsController();
  private tabLeftOffset: number = 0;
  private animationDuration: number = 300;
  private resource: resourceManager.ResourceManager | undefined = AppStorage.get('resourceManager');
  private tabStr: string = '';
  private pageStr: string = '';
  private contentStr: string = '';

  aboutToAppear(): void {
    try {
      this.tabStr = this.resource?.getStringSync($r('app.string.tab')?.id) ?? 'tab';
      this.pageStr = this.resource?.getStringSync($r('app.string.page')?.id) ?? 'this is page';
      this.contentStr = this.resource?.getStringSync($r('app.string.page_content')?.id) ?? 'content';
    } catch (error) {
      hilog.error(0x0000, 'testTag',`getStringSync failed, Code:${error.code}, message:${error.message}`);
    }
  }

  // [Start LeftTab_builder_tab]
  @Builder
  tab(tabName: string, _tabItem: number, tabIndex: number) {
    Row() {
      Text(tabName)
        .fontSize(16)
        .lineHeight(22)
        .fontColor(tabIndex === this.currentIndex ? '#0A59F7' : '#E6000000')
        .id(tabIndex.toString())
        .onAreaChange((_, newValue: Area) => {
          if (this.currentIndex === tabIndex && (this.indicatorLeftMargin === 0 || this.indicatorWidth === 0)) {
            let positionX: number;
            let width: number = Number.parseFloat(newValue.width.toString());
            if (newValue.position.x !== undefined) {
              positionX = Number.parseFloat(newValue.position.x?.toString())
              this.indicatorLeftMargin = Number.isNaN(positionX) ? 0 : positionX;
            }
            this.indicatorWidth = width;
          }
        })
    }
    .justifyContent(FlexAlign.Center)
    .constraintSize({ minWidth: 35 })
    .width(64)
    .height(35)
    .onClick(() => {
      this.controller.changeIndex(tabIndex);
      this.currentIndex = tabIndex;
    })
  }
  // [End LeftTab_builder_tab]

  build() {
    Column() {
      // [Start LeftTab_stack]
      Stack({ alignContent: Alignment.TopStart }) {
        // The text of tab.
        Row() {
          ForEach(this.tabArray, (item: number, index: number) => {
            this.tab(this.tabStr + item, item, index);
          }, (item: number, _index: number) => item.toString())
          Blank()
          Text('+')
            .width(24)
            .height(24)
            .fontSize(24)
            .textAlign(TextAlign.Center)
            .margin({ right: 24 })
        }
        .justifyContent(FlexAlign.Start)
        .width('100%')

        // The underline of tab.
        Column()
          .width(this.indicatorWidth)
          .height(1.5)
          .backgroundColor('#0A59F7')
          .borderRadius(1)
          .margin({ left: this.indicatorLeftMargin, top: 35 })

      }
      .height(56)
      .margin({ left: this.tabLeftOffset })
      // [End LeftTab_stack]

      Tabs({ controller: this.controller }) {
        ForEach(this.tabArray, (item: number) => {
          TabContent() {
            Row() {
              Text(this.pageStr + ' ' + item + ' ' + this.contentStr);
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }
        }, (item: number, _index: number) => item.toString())
      }
      .onAreaChange((_, newValue: Area) => {
        this.tabsWidth = Number.parseFloat(newValue.width.toString());
      })
      .barWidth('100%')
      .barHeight(0)
      .width('100%')
      .height('100%')
      .animationDuration(this.animationDuration)
      // swipe by touch.
      // [Start on_gesture_swipe]
      .onGestureSwipe((index: number, event: TabsAnimationEvent) => {
        let currentIndicator = this.getCurrentIndicatorInfo(index, event);
        this.currentIndex = currentIndicator.index;
        this.indicatorLeftMargin = currentIndicator.left;
        this.indicatorWidth = currentIndicator.width;
      })
      // [End on_gesture_swipe]
      // swipe by click tab.
      // [Start on_animation_start]
      .onAnimationStart((_index: number, targetIndex: number, _event: TabsAnimationEvent) => {
        this.currentIndex = targetIndex;
        let targetIndexInfo = this.getTextInfo(targetIndex);
        this.startAnimateTo(this.animationDuration, targetIndexInfo.left, targetIndexInfo.width);
      })
      // [End on_animation_start]
    }
    .height('100%')
  }

  // [Start on_gesture_swipe]
  private getCurrentIndicatorInfo(index: number, event: TabsAnimationEvent): Record<string, number> {
    let nextIndex = index;
    if (index > 0 && event.currentOffset > 0) {
      // swipe to left.
      nextIndex--;
    } else if (index < this.tabArray.length && event.currentOffset > 0) {
      // swipe to right.
      nextIndex++;
    } else {
      // error condition.
      hilog.info(0x0000, 'leftTab', 'the index is out of boundary: %{public}s', index);
    }
    let indexInfo = this.getTextInfo(index);
    let nextIndexInfo = this.getTextInfo(index);

    let swipeRatio = Math.abs(event.currentOffset / this.tabsWidth);
    let currentIndex = swipeRatio > 0.5 ? nextIndex : index;
    let currentIndicatorLeft: number = indexInfo.left + (nextIndexInfo.left - indexInfo.left) * swipeRatio;
    let currentIndicatorWidth: number = indexInfo.width + (nextIndexInfo.width - indexInfo.width) * swipeRatio;
    return { 'index': currentIndex, 'left': currentIndicatorLeft, 'width': currentIndicatorWidth };
  }
  // [End on_gesture_swipe]

  // [Start on_animation_start]
  private getTextInfo(index: number): Record<string, number> {
    let modePosition: componentUtils.ComponentInfo | null = null;
    try {
      modePosition = this.getUIContext().getComponentUtils().getRectangleById(index.toString());
    } catch (error) {
      hilog.error(0x0000, 'testTag',`getRectangleById failed, Code:${error.code}, message:${error.message}`);
    }
    return { 'left': this.getUIContext().px2vp(modePosition?.windowOffset.x), 'width': this.getUIContext().px2vp(modePosition?.size.width) };
  }

  private startAnimateTo(duration: number, leftMargin: number, width: number) {
    this.getUIContext().animateTo({
      duration: duration,
      curve: Curve.Linear,
      iterations: 1,
      playMode: PlayMode.Normal,
    }, () => {
      this.indicatorLeftMargin = leftMargin;
      this.indicatorWidth = width;
    })
  }
  // [End on_animation_start]
}