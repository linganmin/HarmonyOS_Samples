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

import { WindowInfo } from '../utils/WindowUtil';
import { NavigationBarView } from './NavigationBarView';
import { NavigationContent1, NavigationContent2 } from './NavigationContentView';

@Component
export struct DoubleColumnView {
  @ObjectLink mainWindowInfo: WindowInfo;
  @State isShowingSidebar: boolean = false;
  pageInfos: NavPathStack = new NavPathStack();
  pathStack: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string) {
    if (name === 'navigationContent1') {
      NavigationContent1({ mainWindowInfo: this.mainWindowInfo })
    } else if (name === 'navigationContent2') {
      NavigationContent2({ mainWindowInfo: this.mainWindowInfo })
    }
  }

  build() {
    // [Start double_column_view]
    Navigation(this.pathStack) {
      // [StartExclude double_column_view]
      NavigationBarView({
        mainWindowInfo: this.mainWindowInfo,
        pageInfos: this.pageInfos,
        pathStack: this.pathStack,
        isShowingSidebar: this.isShowingSidebar
      })
      // [EndExclude double_column_view]
    }
    .mode(this.mainWindowInfo.widthBp === WidthBreakpoint.WIDTH_SM ? NavigationMode.Stack : NavigationMode.Split)
    // [End double_column_view]
    .width('100%')
    .height('100%')
    .navDestination(this.PageMap)
    .backgroundColor('#B8EEB2')
    .navBarWidth('50%')
  }
}