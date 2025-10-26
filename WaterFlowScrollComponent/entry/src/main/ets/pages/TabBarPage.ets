/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { CommonConstants } from '../common/constants/CommonConstants';
import { SharedPoolPage } from './SharedPoolPage';
import { SharedPoolSecondPage } from './SharedPoolSecondPage';
import { SymbolGlyphModifier } from '@kit.ArkUI';

@Entry
@Component
struct TabBarPage {
  controller: TabsController = new TabsController();
  @State selectedIndex: number = 0;
  @State titles: Resource[] = [$r("app.string.page_one"), $r("app.string.page_two")];
  symbols: SymbolGlyphModifier[] = [];

  @Builder
  tabBuilder(title: Resource, targetIndex: number) {
    Column() {
      Image($rawfile('person_crop_circle_fill_1.svg'))
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
        .fillColor(this.selectedIndex === targetIndex ? $r('app.color.tab_selected_color') : 'rgba(0, 0, 0, 0.6)')
        .objectFit(ImageFit.Contain)
      Text(title)
        .fontSize(10)
        .fontColor(this.selectedIndex === targetIndex ? $r('app.color.tab_selected_color') : 'rgba(0, 0, 0, 0.6)')
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
        ForEach(this.titles, (item: string, index: number) => {
          TabContent() {
            if (index === 0) {
              SharedPoolPage()
            } else {
              SharedPoolSecondPage()
            }
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          .tabBar(this.tabBuilder(this.titles[index], index))
        }, (item: string) => JSON.stringify(item))
      }
      .onChange((index: number) => {
        this.selectedIndex = index;
      })
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
  }
}