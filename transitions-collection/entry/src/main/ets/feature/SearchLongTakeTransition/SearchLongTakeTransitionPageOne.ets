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

import { curves } from '@kit.ArkUI';
import { getResourceString } from '../../utils/commonutils/ResourceString';

@Builder
export function SearchLongTakeTransitionPageOneBuilder() {
  SearchLongTakeTransitionPageOne()
}

// [Start set_geometry_transition]
@Entry
@Component
struct SearchLongTakeTransitionPageOne {
  @State translateY: number = 0;
  @State transitionEffect: TransitionEffect = TransitionEffect.IDENTITY;
  private pageInfos: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column({ space: 20 }) {
        // [Start Search_start]
        Search({ placeholder: 'Search' })
          .height(40)
          .placeholderColor($r('sys.color.mask_secondary'))
          .width('100%')
          // set geometry transition
          .geometryTransition('SEARCH_ONE_SHOT_DEMO_TRANSITION_ID', { follow: true })
          .backgroundColor('#0D000000')
          .defaultFocus(false)
          .focusOnTouch(false)
          .focusable(false)
          // [End Search_start]
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Up) {
              // set search animation
              this.showSearchPage();
            }
          })
      }
      .size({
        width: '90%',
        height: '100%'
      })
    }
    .transition(TransitionEffect.OPACITY)
    .backgroundColor('#F1F3F5')
    .title(getResourceString(this.getUIContext(), $r('app.string.search_title'), this))
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
    .onBackPressed(() => {
      this.transitionEffect = TransitionEffect.IDENTITY;
      this.pageInfos.pop(true);
      return true;
    })
  }

  // [Start showSearchPage_start]
  // Search animation
  private showSearchPage(): void {
    this.transitionEffect = TransitionEffect.OPACITY;
    this.getUIContext().animateTo({
      curve: curves.interpolatingSpring(0, 1, 342, 38)
    }, () => {
      this.pageInfos.pushPath({ name: 'SearchLongTakeTransitionPageTwo' }, false);
    })
  }
  // [End showSearchPage_start]
}
// [End set_geometry_transition]