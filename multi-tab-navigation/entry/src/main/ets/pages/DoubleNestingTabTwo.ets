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
import { DiscoverPage } from '../view/DiscoverPage';

@Entry
@Component
struct DoubleNestingTabOne {
  @State topTabData: Array<string | Resource> = Constants.TOP_TAB_DATA;
  @State currentIndex: number = 0;
  private controller: TabsController = new TabsController();

  @Builder
  tabBuilder(index: number, name: string | Resource) {
    Column() {
      Text(name)
        .fontColor($r('app.color.text_color'))
        .fontSize(this.currentIndex === index ? $r('app.float.current_text_size') : $r('app.float.double_text_size'))
        .fontWeight(this.currentIndex === index ? Constants.FONT_WEIGHT_TAB : FontWeight.Normal)
    }
    .width(Constants.FULL_WIDTH)
  }

  @Builder
  contentBuilder(index: number, text: string | Resource) {
    TabContent() {
      Column() {
        Row() {
          Text(text)
            .height(Constants.CONTENT_HEIGHT)
            .fontSize($r('app.float.content_font_size'))
        }
        .width(Constants.FULL_WIDTH)
        .height(Constants.FULL_HEIGHT)
        .justifyContent(FlexAlign.Center)
      }
      .width(Constants.FULL_WIDTH)
    }
    .tabBar(this.tabBuilder(index, text))
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
        TabContent() {
          DiscoverPage({ controller: this.controller })
        }
        .tabBar(this.tabBuilder(Constants.TAB_INDEX_ZERO, this.topTabData[Constants.TAB_INDEX_ZERO]))

        this.contentBuilder(Constants.TAB_INDEX_ONE, this.topTabData[Constants.TAB_INDEX_ONE])
        this.contentBuilder(Constants.TAB_INDEX_TWO, this.topTabData[Constants.TAB_INDEX_TWO])
        this.contentBuilder(Constants.TAB_INDEX_THREE, this.topTabData[Constants.TAB_INDEX_THREE])
      }
      .vertical(false)
      .barMode(BarMode.Fixed)
      .barWidth(Constants.FULL_WIDTH)
      .barHeight($r('app.float.mainPage_barHeight'))
      .animationDuration(Constants.ANIMATION_DURATION)
      .onAnimationStart((_index: number, targetIndex: number) => {
        this.currentIndex = targetIndex;
      })
      .width(Constants.FULL_WIDTH)
      .height(Constants.FULL_HEIGHT)
    }
    .width(Constants.FULL_WIDTH)
  }
}