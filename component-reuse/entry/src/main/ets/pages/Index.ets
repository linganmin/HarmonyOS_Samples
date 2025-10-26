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

import { SameListReusePage } from './SameListReusePage';
import { DiffListReusePage } from './DiffListReusePage';
import { OneTypeItemPage } from './OneTypeItemPage';
import { MultiTypeItemPage } from './MultiTypeItemPage';
import { ComposableItemPage } from './ComposableItemPage';
import { ItemData } from '../model/ItemData';
import { IdleCallback } from '../utils/IdleCallback';
import { genMockItemData } from '../common/MockData';

// [Start prebuild3]
@Entry
@Component
struct Index {
  // [StartExclude prebuild3]
  navPathStack: NavPathStack = new NavPathStack();
  // [EndExclude prebuild3]

  aboutToAppear(): void {
    let dataArray: ItemData[] = [];
    dataArray.push(...genMockItemData(100))
    let context = this.getUIContext();
    context.postFrameCallback(new IdleCallback(context, dataArray));
  }

  // [StartExclude prebuild3]
  @Builder
  PagesMap(name: string) {
    if (name === 'SameListReusePage') {
      SameListReusePage()
    } else if (name === 'DiffListPage') {
      DiffListReusePage()
    } else if (name === 'OneTypeItemPage') {
      OneTypeItemPage()
    } else if (name === 'MultiTypeItemPage') {
      MultiTypeItemPage()
    } else if (name === 'ComposableItemPage') {
      ComposableItemPage()
    }
  }

  build() {
    Navigation(this.navPathStack) {
      Column({ space: 12 }) {
        Button($r('app.string.index_same_list'))
          .width('100%')
          .onClick(() => {
            this.navPathStack.pushPathByName('SameListReusePage', '');
          })
        Button($r('app.string.index_diff_list'))
          .width('100%')
          .onClick(() => {
            this.navPathStack.pushPathByName('DiffListPage', '');
          })
      }
      .justifyContent(FlexAlign.End)
      .height('100%')
      .width('100%')
      .padding({
        bottom: 16,
        left: 16,
        right: 16
      })
    }
    .mode(NavigationMode.Stack)
    .title($r('app.string.EntryAbility_label'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .backgroundColor('#F1F3F5')
    .navDestination(this.PagesMap)
  }
  // [EndExclude prebuild3]
}
// [End prebuild3]