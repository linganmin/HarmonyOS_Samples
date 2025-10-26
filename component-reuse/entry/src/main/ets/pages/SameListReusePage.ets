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

@Component
export struct SameListReusePage {
  navPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Button($r('app.string.index_same_list_one_type'))
          .width('100%')
          .onClick(() => {
            this.navPathStack.pushPathByName('OneTypeItemPage', '');
          })
        Button($r('app.string.index_same_list_multi_type'))
          .width('100%')
          .onClick(() => {
            this.navPathStack.pushPathByName('MultiTypeItemPage', '');
          })
        Button($r('app.string.index_same_list_composable_type'))
          .width('100%')
          .onClick(() => {
            this.navPathStack.pushPathByName('ComposableItemPage', '');
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
    .title($r('app.string.index_same_list'))
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack;
    })
  }
}