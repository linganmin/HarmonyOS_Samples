/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { getTabBars, TabBar } from '../models/Index';
import { Home } from './home/Index';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const statusBarType = window.AvoidAreaType.TYPE_SYSTEM;
const navBarType = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;

interface AvoidArea {
  topRectHeight: number
  bottomRectHeight: number
}

@Component
export struct ShoppingFullScreen {
  @State activeTabIndex: number = 0;
  // [Start full_screen_mode_with_system_bar_avoidance]
  // features/shopping/src/main/ets/views/ShoppingFullScreen.ets
  context = this.getUIContext()?.getHostContext() as common.UIAbilityContext;
  private windowClass = this.context.windowStage.getMainWindowSync();
  @State avoidArea: AvoidArea = { topRectHeight: 0, bottomRectHeight: 0 };

  onShown() {
    try {
      this.windowClass.setWindowLayoutFullScreen(true);
    } catch (exception) {
      hilog.error(0x0000, 'ShoppingFullScreen',
        `setWindowLayoutFullScreen failed. Code:${exception.code}, message:${exception.message}`);
    }
    this.setAvoidArea()
    this.windowClass.on('avoidAreaChange', this.onAvoidAreaChange)
  }

  // [StartExclude full_screen_mode_with_system_bar_avoidance]
  onHidden() {
    try {
      this.windowClass.setWindowLayoutFullScreen(false);
    } catch (exception) {
      hilog.error(0x0000, 'ShoppingFullScreen',
        `setWindowLayoutFullScreen failed. Code:${exception.code}, message:${exception.message}`);
    }
    this.windowClass.off('avoidAreaChange', this.onAvoidAreaChange)
  }

  // [EndExclude full_screen_mode_with_system_bar_avoidance]

  setAvoidArea() {
    try {
      // status bar area
      const statusBarArea = this.windowClass.getWindowAvoidArea(statusBarType);
      this.avoidArea.topRectHeight = statusBarArea.topRect.height;
      // navigation bar area
      const navBarArea = this.windowClass.getWindowAvoidArea(navBarType);
      this.avoidArea.bottomRectHeight = navBarArea.bottomRect.height;
    } catch (exception) {
      hilog.error(0x0000, 'ShoppingFullScreen',
        `setAvoidArea failed. Code:${exception.code}, message:${exception.message}`);
    }
  }

  onAvoidAreaChange = (data: window.AvoidAreaOptions) => {
    if (data.type === statusBarType) {
      this.avoidArea.topRectHeight = data.area.topRect.height;
    } else if (data.type === navBarType) {
      this.avoidArea.bottomRectHeight = data.area.bottomRect.height;
    }
  }

  // [End full_screen_mode_with_system_bar_avoidance]

  @Builder
  TabBarBuilder(tabBar: TabBar, index: number) {
    Column() {
      Image(this.isActive(index) ? tabBar.activeIcon : tabBar.icon)
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
      Text(tabBar.text)
        .fontSize(10)
        .fontWeight(500)
        .fontColor(this.isActive(index) ? '#D0092D' : Color.Black)
        .opacity(this.isActive(index) ? 1 : 0.4)
    }
  }

  isActive(index: number): boolean {
    return this.activeTabIndex === index;
  }

  onActiveTabChange(index: number) {
    this.activeTabIndex = index;
  }

  build() {
    NavDestination() {
      // [Start full_screen_window_excluding_system_bar]
      // features/shopping/src/main/ets/views/ShoppingFullScreen.ets
      Tabs({ barPosition: BarPosition.End }) {
        // [StartExclude full_screen_window_excluding_system_bar]
        ForEach(getTabBars(), (tabBar: TabBar, index) => {
          TabContent() {
            if (index === 0) {
              Home()
            }
          }
          .tabBar(this.TabBarBuilder(tabBar, index))
        }, (tabBar: TabBar) => JSON.stringify(tabBar))
        // [EndExclude full_screen_window_excluding_system_bar]
      }
      .backgroundColor('#F1F3F5')
      .padding({
        top: this.avoidArea.topRectHeight + 'px',
        bottom: this.avoidArea.bottomRectHeight + 'px'
      })
      // [End full_screen_window_excluding_system_bar]
      .onChange((index: number) => this.onActiveTabChange(index))
    }
    .hideTitleBar(true)
    .onShown(() => this.onShown())
    .onHidden(() => this.onHidden())
  }
}
