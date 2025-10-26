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

import { WindowUtil } from '../utils/WindowUtil';
import { IndentedView } from '../views/IndentedView';

@Builder
export function IndentedBuilder() {
  IndentedLayout();
}

@Component
export struct IndentedLayout {
  @StorageLink('windowUtil') windowUtil: WindowUtil | undefined = undefined;
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      IndentedView({
        mainWindowInfo: this.windowUtil?.mainWindowInfo,
        pathStack: this.pathStack
      })
    }
    .height('100%')
    .width('100%')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .hideTitleBar(true)
  }
}