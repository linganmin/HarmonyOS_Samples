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

import { webview } from '@kit.ArkWeb';

const maxHeight = 170;
const minHeight = 100;
const differenceValue = maxHeight - minHeight;

@Component
export struct NestedScrolling {
  @State yOffset: number = 0;
  @State NestedScrollModeF: NestedScrollMode = NestedScrollMode.PARENT_FIRST;
  @State NestedScrollModeB: NestedScrollMode = NestedScrollMode.SELF_FIRST;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  private controller: webview.WebviewController = new webview.WebviewController();

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Image($r('app.media.title'))
            .width('100%')
            .height(maxHeight - this.yOffset)
          Web({
            src: 'https://www.huawei.com/cn/',
            controller: this.controller
          })
            .nestedScroll({
              scrollForward: this.NestedScrollModeF,
              scrollBackward: this.NestedScrollModeB
            })
            .layoutWeight(1)
        }
      }
      .onScrollFrameBegin((offset: number) => {
        this.yOffset = Math.min(this.yOffset + offset, differenceValue);
        if (this.yOffset <= 0) {
          this.yOffset = 0;
        } else if (this.yOffset < differenceValue) {
          this.NestedScrollModeF = NestedScrollMode.PARENT_FIRST;
          this.NestedScrollModeB = NestedScrollMode.PARENT_FIRST;
          this.controller.setScrollable(false);
        } else if (this.yOffset == differenceValue) {
          this.NestedScrollModeF = NestedScrollMode.SELF_FIRST;
          this.NestedScrollModeB = NestedScrollMode.SELF_FIRST;
          this.controller.setScrollable(true);
        }
        return {
          offsetRemain: 0
        }
      }
      )
    }
    .padding({ top: this.topRectHeight })
    .title('NestedScrolling')
  }
}