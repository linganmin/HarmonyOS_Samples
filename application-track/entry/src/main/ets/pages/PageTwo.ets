/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * Navigation: Go to the second page.
 */
@Builder
export function PageTwoBuilder() {
  PageTwo()
}

@Component
export struct PageTwo {
  pathStack: NavPathStack = new NavPathStack();
  private menuItems: Array<NavigationMenuItem> = [
    {
      value: '1',
      icon: 'resources/base/media/undo.svg'
    },
    {
      value: '2',
      icon: 'resources/base/media/redo.svg',
      isEnabled: false
    },
    {
      value: '3',
      icon: 'resources/base/media/ic_public_ok.svg',
      isEnabled: true
    }
  ];

  build() {
    NavDestination() {
      Column() {
        Button('pushPathByName', { stateEffect: true, type: ButtonType.Capsule })
          .width('100%')
          .onClick(() => {
            this.pathStack.pushPathByName('pageOne', null);
          })
      }
      .padding({
        right: 16,
        left: 16
      })
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height('100%')
    }
    .backgroundColor('#F1F3F5')
    .title('pageTwo')
    .menus(this.menuItems)
    .padding({
      bottom: (AppStorage.get<number>('naviIndicatorHeight') ?? 0) + 16
    })
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      hilog.info(0x0000, 'ApplicationTrack', '%{public}s',
        `Current page config info is: ${JSON.stringify(context.getConfigInRouteMap())}`);
    })
  }
}