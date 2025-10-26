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

import { DifferentItemDrag } from './DifferentItemDrag';
import { DirectDragItem } from './DirectDragItem';
import { JitterAnimation } from './JitterAnimation';
import { SameItemDrag } from './SameItemDrag';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pathStack: NavPathStack = new NavPathStack()

  @Builder
  PageMap(name: string) {
    if (name === 'SameItemDrag') {
      SameItemDrag();
    } else if (name === 'DifferentItemDrag') {
      DifferentItemDrag();
    } else if (name === 'DirectDragItem') {
      DirectDragItem();
    } else if (name === 'JitterAnimation') {
      JitterAnimation();
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        Text($r('app.string.grid_element_drag_swap'))
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .height(56)
          .margin({ top: 56 })
        Column({ space: 12 }) {
          Button($r('app.string.same_size_press_drag'))
            .onClick(() => {
              this.pathStack.pushPath({ name: 'SameItemDrag' });
            })
            .width('100%')
          Button($r('app.string.different_size_press_drag'))
            .onClick(() => {
              this.pathStack.pushPath({ name: 'DifferentItemDrag' });
            })
            .width('100%')
          Button($r('app.string.directly_drag_item'))
            .onClick(() => {
              this.pathStack.pushPath({ name: 'DirectDragItem' });
            })
            .width('100%')
          Button($r('app.string.show_jitter_animation'))
            .onClick(() => {
              this.pathStack.pushPath({ name: 'JitterAnimation' });
            })
            .width('100%')
        }
        .height(248)
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(16)
    }
    .mode(NavigationMode.Stack)
    .navDestination(this.PageMap)
    .hideToolBar(true)
  }
}