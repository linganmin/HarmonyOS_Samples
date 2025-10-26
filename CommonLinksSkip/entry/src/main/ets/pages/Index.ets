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

import { LinksPage } from './LinksPage';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pathStack: NavPathStack = new NavPathStack();

  @Builder
  pageMap(name: string) {
    if (name === 'LinksPage') {
      LinksPage();
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        Text($r('app.string.jump_scene'))
          .fontSize(30)
          .opacity(0.9)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .height(56)
          .margin({ top: 12 })
        Column({ space: 12 }) {
          Button($r('app.string.common_link_jump_scenarios'))
            .width('100%')
            .onClick(() => {
              this.pathStack.pushPath({ name: 'LinksPage' })
            })
        }
      }
      .padding(16)
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .navDestination(this.pageMap)
    .mode(NavigationMode.Stack)
    .hideToolBar(true)
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
  }
}