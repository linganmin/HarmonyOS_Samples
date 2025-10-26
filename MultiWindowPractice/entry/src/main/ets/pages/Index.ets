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

@Entry
@Component
struct Index {
  @Provide navPathStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.navPathStack) {
      Scroll() {
        Column({ space: 12 }) {
          Blank()
            .layoutWeight(1)

          ForEach(Constants.QUESTION_ARRAY, (item: Resource, index: number) => {
            Button(item)
              .height(40)
              .width('100%')
              .onClick(() => {
                this.navPathStack.pushPath({ name: 'Question', param: index });
              })
          }, (item: string) => item)
        }
        .padding(16)
        .justifyContent(FlexAlign.End)
      }
      .height('100%')
      .width('100%')
      .padding({
        bottom: AppStorage.get<number>('naviIndicatorHeight') ?? 0
      })
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
  }
}