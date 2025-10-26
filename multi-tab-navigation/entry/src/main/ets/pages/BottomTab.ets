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
import { Constants } from '../common/Constants';

@Entry
@Component
struct BottomTab {
  @State currentIndex: number = 0;
  private  msgNum: number = 9999;
  private tabsController: TabsController = new TabsController();

  // [Start tab_builder]
  @Builder
  tabBuilder(title: Resource, index: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      if (index === 0) {
        Badge({
          count: this.msgNum,
          style: { badgeSize: 14 },
          maxCount: 999,
          position: BadgePosition.RightTop
        }) {
          Image(this.currentIndex === index ? selectedImg : normalImg)
            .width(24)
            .height(24)
            .objectFit(ImageFit.Contain)
        }
        .width(30)
      } else if (index === 1) {
        Image(this.currentIndex === index ? selectedImg : normalImg)
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
      } else {
        Badge({
          value: '',
          style: { badgeSize: 6 },
          position: BadgePosition.RightTop
        }) {
          Image(this.currentIndex === index ? selectedImg : normalImg)
            .width(24)
            .height(24)
            .objectFit(ImageFit.Contain)
        }
        .width(30)
      }

      Text(title)
        .margin({ top: 4 })
        .fontSize(10)
        .fontColor(this.currentIndex === index ? '#3388ff' : '#E6000000')
    }
    .justifyContent(FlexAlign.Center)
    .height(52)
    .width('100%')
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(this.currentIndex);
    })
  }
  // [End tab_builder]

  // [Start tab_content_builder]
  @Builder
  tabContentBuilder(text: Resource, index: number, selectedImg: Resource, normalImg: Resource) {
    TabContent() {
      Row() {
        Text(text)
          .height(300)
          .fontSize(30)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .padding({ left: 12, right: 12 })
    .backgroundColor(Color.White)
    .tabBar(this.tabBuilder(text, index, selectedImg, normalImg))
  }
  // [End tab_content_builder]
  // [Start Tabs]
  build() {
    Tabs({
      barPosition: BarPosition.End,
      controller: this.tabsController
    }) {
      this.tabContentBuilder($r('app.string.message'),
        Constants.TAB_INDEX_ZERO, $r('app.media.activeMessage'), $r('app.media.message'))
      this.tabContentBuilder($r('app.string.people'),
        Constants.TAB_INDEX_ONE, $r('app.media.activePeople'), $r('app.media.people'))
      this.tabContentBuilder($r('app.string.activity'),
        Constants.TAB_INDEX_TWO, $r('app.media.activeStar'), $r('app.media.star'))
    }
    .width('100%')
    .backgroundColor('#F3F4F5')
    .barHeight(52)
    .barMode(BarMode.Fixed)
    .onAnimationStart((index: number, targetIndex: number) => {
      hilog.info(0x0000, 'index', index.toString());
      this.currentIndex = targetIndex;
    })
  }
  // [End Tabs]
}