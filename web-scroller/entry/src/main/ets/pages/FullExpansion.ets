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

@Component
export struct FullExpansion {
  @State scrollMode: NestedScrollMode = NestedScrollMode.PARENT_FIRST;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  private controller: webview.WebviewController = new webview.WebviewController();

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row() {
            Text($r('app.string.native_component_area'))
          }
          .width('100%')
          .height(72)
          .backgroundColor('#F1F3F5')
          .justifyContent(FlexAlign.Center)

          Web({
            src: 'https:/www.huawei.com/cn/',
            controller: this.controller,
            renderMode: RenderMode.SYNC_RENDER
          })
            .layoutMode(WebLayoutMode.FIT_CONTENT)
            .nestedScroll({
              scrollForward: NestedScrollMode.SELF_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })

          Row() {
            Text($r('app.string.native_component_area'))
          }
          .width('100%')
          .height(72)
          .backgroundColor('#F1F3F5')
          .justifyContent(FlexAlign.Center)
        }
      }
    }
    .padding({ top: this.topRectHeight })
    .title('FullExpansion')
  }
}