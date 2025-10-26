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

import { LazyForEachSwiper } from './LazyForEachSwiper';
import { PreloadDataSwiper } from './PreloadDataSwiper';

@Entry
@Component
struct Index {
  private navPathStack: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string) {
    if (name === 'LazyForEachSwiper') {
      LazyForEachSwiper()
    } else if (name === 'PreloadDataSwiper') {
      PreloadDataSwiper()
    }
  }

  build() {
    Navigation(this.navPathStack) {
      Column({ space: 12 }) {

        Button($r('app.string.Use_LazyForEach'))
          .width('100%')
          .onClick(() => {
            this.navPathStack.pushPath({ name: 'LazyForEachSwiper' });
          })

        Button($r('app.string.Use_Preload'))
          .width('100%')
          .onClick(() => {
            this.navPathStack.pushPath({ name: 'PreloadDataSwiper' });
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
      .padding({
        left: 16,
        right: 16,
        top: AppStorage.get<number>('statusBarHeight') ?? 0,
        bottom: (AppStorage.get<number>('naviIndicatorHeight') ?? 0) + 16
      })
    }
    .mode(NavigationMode.Stack)
    .title($r('app.string.title_main'))
    .backgroundColor($r('sys.color.background_secondary'))
    .navDestination(this.PageMap)
  }
}