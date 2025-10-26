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

import { CommonConstants } from '../common/CommonConstants';
import { ImageSwitch } from './ImageSwitch';
import { StackSwitch } from './StackSwitch';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pathStack: NavPathStack = new NavPathStack();

  @Builder
  PagesMap(name: string) {
    if (name == 'ImageSwitch') {
      ImageSwitch()
    } else if (name == 'StackSwitch') {
      StackSwitch()
    }
  }

  @Builder
  NavigationTitle() {
    Column() {
      Text('Carousel layout')
        .fontSize('30vp')
        .lineHeight('20vp')
        .fontWeight(700)
        .width('100%')
        .margin({ top: 36 })
    }
    .padding({ left: 16 })
    .width('100%')
  }

  build() {
    Navigation(this.pathStack) {
      Column({ space: CommonConstants.COLUMN_SPACE }) {
        Button('ImageSwitch', { stateEffect: true, type: ButtonType.Capsule })
          .onClick(() => {
            this.pathStack.pushPathByName('ImageSwitch', null, false);
          })
          .width(CommonConstants.FULL_PERCENT)
        Button('StackSwitch', { stateEffect: true, type: ButtonType.Capsule })
          .onClick(() => {
            this.pathStack.pushPathByName('StackSwitch', null, false);
          })
          .width('100%')
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height('100%')
      .padding({
        bottom: 44,
        left: 16,
        right: 16
      })
    }
    .navDestination(this.PagesMap)
    .title(this.NavigationTitle())
    .titleMode(NavigationTitleMode.Full)
  }
}