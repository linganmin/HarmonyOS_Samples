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

import { fp2pxUtil } from '../common/CommonUtils';
import { HomePage } from '../view/HomePage';
import { SettingsPage } from '../view/SettingsPage';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @StorageLink('toggleState') toggleState: boolean = false;
  private tabsController: TabsController = new TabsController();

  @Builder
  tabBuilder(img: Resource, title: Resource, index: number) {
    Column() {
      Image(img)
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === index ? '#0a59f7' : '#66000000')
      Text(title)
        .margin({ top: '4vp' })
        .fontSize(this.toggleState ? 10 : fp2pxUtil(10))
        .fontWeight(500)
        .fontColor(this.currentIndex === index ? '#0a59f7' : '#66000000')
    }
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(index);
    })
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {
        HomePage()
      }
      .tabBar(this.tabBuilder($r('app.media.person'), $r('app.string.home'), 0))

      TabContent() {
        SettingsPage()
      }
      .tabBar(this.tabBuilder($r('app.media.setting'), $r('app.string.settings'), 1))
    }
    .width('100%')
    .barHeight(56)
    .vertical(false)
    .barMode(BarMode.Fixed)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .backgroundColor('#FFF1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}