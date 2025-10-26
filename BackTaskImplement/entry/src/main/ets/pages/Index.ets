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

import { ShortTermTaskPage } from '../view/ShortTermTaskPage';
import { LongTermTaskPage } from '../view/LongTermTaskPage';

@Entry
@Component
struct Index {
  private pageStack: NavPathStack = new NavPathStack();

  @Styles
  buttonStyles() {
    .width('100%')
    .height(40)
  }

  @Builder
  pageMap(pageName: string): void {
    if (pageName === 'ShortTermTaskPage') {
      ShortTermTaskPage()
    } else if (pageName === 'LongTermTaskPage') {
      LongTermTaskPage()
    }
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Button($r('app.string.short_time_task'))
          .buttonStyles()
          .margin({
            bottom: 12
          })
          .onClick(() => {
            this.pageStack.pushDestinationByName('ShortTermTaskPage', null, true);
          })

        Button($r('app.string.long_time_task'))
          .buttonStyles()
          .margin({
            bottom: 16
          })
          .onClick(() => {
            this.pageStack.pushDestinationByName('LongTermTaskPage', null, true);
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
      .padding({
        right: 16,
        left: 16
      })
    }
    .title($r('app.string.EntryAbility_label'))
    .navDestination(this.pageMap)
    .hideToolBar(true)
  }
}